package com.clickeat.controller.admin;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.json.JSONObject;

import com.clickeat.dal.impl.AITrainingEventDAO;
import com.clickeat.dal.impl.AITrainingTriggerAuditDAO;
import com.clickeat.model.AITrainingEvent;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminAITrainingExportServlet", urlPatterns = {"/admin/ai-training/export"})
public class AdminAITrainingExportServlet extends HttpServlet {

    private static final DateTimeFormatter TS_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final int FAIL_MIN_ROWS = 100;
    private static final int WARN_MIN_ROWS = 1000;
    private static final double WARN_MIN_LABELED_RATIO = 0.60;
    private static final double WARN_MIN_PROFILE_RATIO = 0.20;
    private static final double WARN_MIN_AVG_PROMPT_LEN = 8.0;
    private static final double WARN_MIN_AVG_RESPONSE_LEN = 20.0;
    private static final double WARN_MAX_LABEL_IMBALANCE = 0.90;
    private static final long DEFAULT_REPLAY_WINDOW_SECONDS = 24L * 60L * 60L;
    private static final long MIN_REPLAY_WINDOW_SECONDS = 60L;
    private static final long MAX_REPLAY_WINDOW_SECONDS = 7L * 24L * 60L * 60L;
    private static final Map<String, Long> USED_TRIGGER_IDS = new ConcurrentHashMap<>();
    private static final String TRAINING_WEBHOOK_ENV = "AI_TRAINING_WEBHOOK_URL";
    private static final String TRAINING_API_KEY_ENV = "AI_TRAINING_API_KEY";
    private final AITrainingTriggerAuditDAO triggerAuditDAO = new AITrainingTriggerAuditDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || account.getRole() == null || !"ADMIN".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String mode = request.getParameter("mode");
        int limit = parseInt(request.getParameter("limit"), 1000, 1, 50000);
        int maxAgeDays = parseInt(request.getParameter("maxAgeDays"), 120, 1, 3650);
        String jsonlProfile = parseJsonlProfile(request.getParameter("jsonlProfile"));
        boolean defaultOnlyLabeled = "split".equalsIgnoreCase(mode) || "jsonl-split".equalsIgnoreCase(mode);
        boolean onlyLabeled = parseBooleanOrDefault(request.getParameter("onlyLabeled"), defaultOnlyLabeled);
        GateConfig gateConfig = parseGateConfig(request);

        AITrainingEventDAO dao = new AITrainingEventDAO();
        List<AITrainingEvent> rows = dao.findForExport(limit, onlyLabeled, maxAgeDays);

        if ("split".equalsIgnoreCase(mode)) {
            exportSplitZip(request, response, rows, onlyLabeled, gateConfig);
            return;
        }
        if ("jsonl-split".equalsIgnoreCase(mode)) {
            exportSplitJsonlZip(request, response, rows, onlyLabeled, gateConfig, jsonlProfile);
            return;
        }
        if ("report".equalsIgnoreCase(mode)) {
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(buildStatsJson(rows, onlyLabeled, limit, gateConfig));
            return;
        }
        if ("ready-check".equalsIgnoreCase(mode)) {
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(buildReadyCheckJson(rows, onlyLabeled, limit, gateConfig,
                    parseInt(request.getParameter("blockerLimit"), 3, 1, 20)));
            return;
        }
        if ("train-trigger-dry-run".equalsIgnoreCase(mode)) {
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(buildTrainTriggerDryRunJson(request, account, rows, onlyLabeled, limit, gateConfig,
                    parseInt(request.getParameter("blockerLimit"), 3, 1, 20)));
            return;
        }
        if ("train-trigger".equalsIgnoreCase(mode)) {
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(buildTrainTriggerJson(request, account, rows, onlyLabeled, limit, gateConfig,
                    parseInt(request.getParameter("blockerLimit"), 3, 1, 20)));
            return;
        }
        if ("train-trigger-confirm".equalsIgnoreCase(mode)) {
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(buildTrainTriggerConfirmJson(request, account, rows, onlyLabeled, limit, gateConfig,
                    parseInt(request.getParameter("blockerLimit"), 3, 1, 20)));
            return;
        }
        if ("train-trigger-history".equalsIgnoreCase(mode)) {
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(buildTrainTriggerHistoryJson(
                    parseInt(request.getParameter("historyLimit"), 50, 1, 500),
                    parseReplayWindowSeconds(request),
                    emptyToNull(request.getParameter("decisionReason"), request.getParameter("decision")),
                    emptyToNull(request.getParameter("gateStatus")),
                    emptyToNull(request.getParameter("requestedBy")),
                    emptyToNull(request.getParameter("historyMode"), request.getParameter("triggerMode")),
                    parseInt(request.getParameter("page"), 1, 1, 1_000_000),
                    parseInt(request.getParameter("pageSize"),
                            parseInt(request.getParameter("historyLimit"), 50, 1, 500),
                            1, 500),
                    parseSortAsc(request.getParameter("sort"))));
            return;
        }

        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=ai-training-events.csv");

        try (PrintWriter out = response.getWriter()) {
            out.write("\uFEFF");
            out.println(csvHeader());
            for (AITrainingEvent row : rows) {
                out.println(toCsv(row));
            }
        }
    }

    private void exportSplitZip(HttpServletRequest request,
            HttpServletResponse response,
            List<AITrainingEvent> rows,
            boolean onlyLabeled,
            GateConfig gateConfig) throws IOException {
        int trainPct = parseInt(request.getParameter("trainPct"), 80, 10, 98);
        int valPct = parseInt(request.getParameter("valPct"), 10, 1, 80);
        if (trainPct + valPct >= 100) {
            valPct = Math.max(1, 99 - trainPct);
        }
        DatasetSplit split = splitRows(rows, trainPct, valPct);

        response.setContentType("application/zip");
        response.setHeader("Content-Disposition", "attachment; filename=ai-training-split.zip");

        try (ZipOutputStream zos = new ZipOutputStream(response.getOutputStream(), StandardCharsets.UTF_8)) {
            writeCsvEntry(zos, "train.csv", split.train);
            writeCsvEntry(zos, "validation.csv", split.validation);
            writeCsvEntry(zos, "test.csv", split.test);
            writeManifestEntry(zos, "csv", split, rows.size(), onlyLabeled, gateConfig);

            ZipEntry metadata = new ZipEntry("README.txt");
            zos.putNextEntry(metadata);
            String readme = "AI dataset split export\n"
                    + "Total rows: " + rows.size() + "\n"
                    + "onlyLabeled: " + onlyLabeled + "\n"
                    + "trainPct: " + trainPct + "\n"
                    + "valPct: " + valPct + "\n"
                    + "testPct: " + split.testPct + "\n"
                    + "train rows: " + split.train.size() + "\n"
                    + "validation rows: " + split.validation.size() + "\n"
                    + "test rows: " + split.test.size() + "\n"
                    + "quality gate params: " + gateConfig.describe() + "\n"
                    + "manifest: manifest.json\n";
            zos.write(readme.getBytes(StandardCharsets.UTF_8));
            zos.closeEntry();
        }
    }

    private void exportSplitJsonlZip(HttpServletRequest request,
            HttpServletResponse response,
            List<AITrainingEvent> rows,
            boolean onlyLabeled,
            GateConfig gateConfig,
            String jsonlProfile) throws IOException {
        int trainPct = parseInt(request.getParameter("trainPct"), 80, 10, 98);
        int valPct = parseInt(request.getParameter("valPct"), 10, 1, 80);
        if (trainPct + valPct >= 100) {
            valPct = Math.max(1, 99 - trainPct);
        }
        DatasetSplit split = splitRows(rows, trainPct, valPct);

        response.setContentType("application/zip");
        response.setHeader("Content-Disposition", "attachment; filename=ai-training-jsonl-split.zip");

        try (ZipOutputStream zos = new ZipOutputStream(response.getOutputStream(), StandardCharsets.UTF_8)) {
            writeJsonlEntry(zos, "train.jsonl", split.train, jsonlProfile);
            writeJsonlEntry(zos, "validation.jsonl", split.validation, jsonlProfile);
            writeJsonlEntry(zos, "test.jsonl", split.test, jsonlProfile);
            writeManifestEntry(zos, "jsonl", split, rows.size(), onlyLabeled, gateConfig);

            ZipEntry metadata = new ZipEntry("README.txt");
            zos.putNextEntry(metadata);
            String readme = "AI dataset JSONL split export\n"
                    + "Total rows: " + rows.size() + "\n"
                    + "onlyLabeled: " + onlyLabeled + "\n"
                    + "trainPct: " + trainPct + "\n"
                    + "valPct: " + valPct + "\n"
                    + "testPct: " + split.testPct + "\n"
                    + "train rows: " + split.train.size() + "\n"
                    + "validation rows: " + split.validation.size() + "\n"
                    + "test rows: " + split.test.size() + "\n"
                    + "jsonlProfile: " + jsonlProfile + "\n"
                    + "format: " + ("google-ai-studio".equals(jsonlProfile)
                    ? "one JSON object per line with fields text_input, output"
                    : "one JSON object per line with fields prompt, response, label, metadata") + "\n"
                    + "quality gate params: " + gateConfig.describe() + "\n"
                    + "manifest: manifest.json\n";
            zos.write(readme.getBytes(StandardCharsets.UTF_8));
            zos.closeEntry();
        }
    }

    private void writeManifestEntry(ZipOutputStream zos,
            String format,
            DatasetSplit split,
            int totalRows,
            boolean onlyLabeled,
            GateConfig gateConfig) throws IOException {
        ZipEntry entry = new ZipEntry("manifest.json");
        zos.putNextEntry(entry);
        String manifest = buildManifestJson(format, split, totalRows, onlyLabeled, gateConfig);
        zos.write(manifest.getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }

    private void writeCsvEntry(ZipOutputStream zos, String entryName, List<AITrainingEvent> rows) throws IOException {
        ZipEntry entry = new ZipEntry(entryName);
        zos.putNextEntry(entry);
        StringBuilder sb = new StringBuilder();
        sb.append(csvHeader()).append('\n');
        for (AITrainingEvent row : rows) {
            sb.append(toCsv(row)).append('\n');
        }
        zos.write(sb.toString().getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }

    private void writeJsonlEntry(ZipOutputStream zos, String entryName, List<AITrainingEvent> rows, String jsonlProfile) throws IOException {
        ZipEntry entry = new ZipEntry(entryName);
        zos.putNextEntry(entry);
        StringBuilder sb = new StringBuilder();
        for (AITrainingEvent row : rows) {
            sb.append(toJsonl(row, jsonlProfile)).append('\n');
        }
        zos.write(sb.toString().getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }

    private int splitBucket(AITrainingEvent row) {
        long seed = row.getId() * 31L + row.getUserId() * 17L;
        return Math.floorMod(Long.hashCode(seed), 100);
    }

    private DatasetSplit splitRows(List<AITrainingEvent> rows, int trainPct, int valPct) {
        int safeTrainPct = Math.max(10, Math.min(trainPct, 98));
        int safeValPct = Math.max(1, Math.min(valPct, 80));
        if (safeTrainPct + safeValPct >= 100) {
            safeValPct = Math.max(1, 99 - safeTrainPct);
        }
        int safeTestPct = 100 - safeTrainPct - safeValPct;

        List<AITrainingEvent> train = new ArrayList<>();
        List<AITrainingEvent> validation = new ArrayList<>();
        List<AITrainingEvent> test = new ArrayList<>();

        for (AITrainingEvent row : rows) {
            int bucket = splitBucket(row);
            if (bucket < safeTrainPct) {
                train.add(row);
            } else if (bucket < safeTrainPct + safeValPct) {
                validation.add(row);
            } else {
                test.add(row);
            }
        }

        return new DatasetSplit(train, validation, test, safeTrainPct, safeValPct, safeTestPct);
    }

    private String csvHeader() {
        return "id,user_id,created_at,feedback_score,feedback_note,has_profile,health_goal,user_message,ai_reply,system_context";
    }

    private String toJsonl(AITrainingEvent row, String jsonlProfile) {
        if ("google-ai-studio".equals(jsonlProfile)) {
            return toJsonlGoogleAiStudio(row);
        }

        String createdAt = row.getCreatedAt() == null ? "" : row.getCreatedAt().toLocalDateTime().format(TS_FORMAT);
        String feedbackAt = row.getFeedbackAt() == null ? "" : row.getFeedbackAt().toLocalDateTime().format(TS_FORMAT);

        StringBuilder sb = new StringBuilder();
        sb.append('{')
                .append("\"prompt\":\"").append(escapeJson(row.getUserMessage())).append("\",")
                .append("\"response\":\"").append(escapeJson(row.getAiReply())).append("\",")
                .append("\"label\":").append(labelNumber(row.getFeedbackScore())).append(',')
                .append("\"metadata\":{")
                .append("\"id\":").append(row.getId()).append(',')
                .append("\"user_id\":").append(row.getUserId()).append(',')
                .append("\"has_profile\":").append(row.isHasProfile()).append(',')
                .append("\"health_goal\":\"").append(escapeJson(nullSafe(row.getHealthGoal()))).append("\",")
                .append("\"feedback_note\":\"").append(escapeJson(nullSafe(row.getFeedbackNote()))).append("\",")
                .append("\"created_at\":\"").append(escapeJson(createdAt)).append("\",")
                .append("\"feedback_at\":\"").append(escapeJson(feedbackAt)).append("\",")
                .append("\"system_context\":\"").append(escapeJson(nullSafe(row.getSystemContext()))).append("\"")
                .append("}}");
        return sb.toString();
    }

    private String toJsonlGoogleAiStudio(AITrainingEvent row) {
        String textInput = "user: " + nullSafe(row.getUserMessage());
        String output = "AI: " + nullSafe(row.getAiReply());

        return "{"
                + "\"text_input\":\"" + escapeJson(textInput) + "\","
                + "\"output\":\"" + escapeJson(output) + "\""
                + "}";
    }

    private String buildManifestJson(String format, DatasetSplit split, int totalRows, boolean onlyLabeled, GateConfig gateConfig) {
        List<AITrainingEvent> merged = new ArrayList<>(split.train.size() + split.validation.size() + split.test.size());
        merged.addAll(split.train);
        merged.addAll(split.validation);
        merged.addAll(split.test);
        QualityStats stats = computeQualityStats(merged);
        String gateJson = buildQualityGateJson(stats, totalRows, onlyLabeled, gateConfig);

        return "{"
                + "\"format\":\"" + escapeJson(format) + "\","
                + "\"total_rows\":" + totalRows + ","
                + "\"only_labeled\":" + onlyLabeled + ","
                + "\"split\":{"
                + "\"train_pct\":" + split.trainPct + ","
                + "\"validation_pct\":" + split.valPct + ","
                + "\"test_pct\":" + split.testPct + ","
                + "\"train_rows\":" + split.train.size() + ","
                + "\"validation_rows\":" + split.validation.size() + ","
                + "\"test_rows\":" + split.test.size()
                + "},"
                + "\"quality\":{"
                + "\"labeled\":" + stats.labeled + ","
                + "\"positive\":" + stats.positive + ","
                + "\"negative\":" + stats.negative + ","
                + "\"neutral\":" + stats.neutral + ","
                + "\"with_profile\":" + stats.withProfile + ","
                + "\"avg_prompt_len\":" + quoteDecimal(stats.avgPromptLen) + ","
                + "\"avg_response_len\":" + quoteDecimal(stats.avgResponseLen) + ","
                + "\"labeled_ratio\":" + quoteDecimal(stats.labeledRatio * 100.0) + ","
                + "\"profile_ratio\":" + quoteDecimal(stats.profileRatio * 100.0)
                + "},"
                + "\"gate_config\":" + gateConfig.toJson() + ","
                + "\"quality_gate\":" + gateJson
                + "}";
    }

    private String buildStatsJson(List<AITrainingEvent> rows, boolean onlyLabeled, int limit, GateConfig gateConfig) {
        DatasetSplit preview = splitRows(rows, 80, 10);
        String manifest = buildManifestJson("report", preview, rows.size(), onlyLabeled, gateConfig);
        return "{"
                + "\"mode\":\"report\","
                + "\"limit\":" + limit + ","
                + "\"row_count\":" + rows.size() + ","
                + "\"default_preview_split\":{\"train_pct\":80,\"validation_pct\":10,\"test_pct\":10},"
                + "\"gate_config\":" + gateConfig.toJson() + ","
                + "\"manifest\":" + manifest
                + "}";
    }

    private QualityStats computeQualityStats(List<AITrainingEvent> rows) {
        long labeled = 0;
        long positive = 0;
        long negative = 0;
        long neutral = 0;
        long withProfile = 0;
        long promptChars = 0;
        long responseChars = 0;

        for (AITrainingEvent row : rows) {
            if (row.isHasProfile()) {
                withProfile++;
            }
            promptChars += nullSafe(row.getUserMessage()).length();
            responseChars += nullSafe(row.getAiReply()).length();

            Integer score = row.getFeedbackScore();
            if (score == null) {
                continue;
            }
            labeled++;
            if (score > 0) {
                positive++;
            } else if (score < 0) {
                negative++;
            } else {
                neutral++;
            }
        }

        double total = rows.size();
        double avgPromptLen = total <= 0 ? 0.0 : (double) promptChars / total;
        double avgResponseLen = total <= 0 ? 0.0 : (double) responseChars / total;
        double labeledRatio = total <= 0 ? 0.0 : (double) labeled / total;
        double profileRatio = total <= 0 ? 0.0 : (double) withProfile / total;
        double positiveRatio = labeled <= 0 ? 0.0 : (double) positive / labeled;
        double negativeRatio = labeled <= 0 ? 0.0 : (double) negative / labeled;

        return new QualityStats(labeled, positive, negative, neutral, withProfile,
                avgPromptLen, avgResponseLen, labeledRatio, profileRatio, positiveRatio, negativeRatio);
    }

    private String buildReadyCheckJson(List<AITrainingEvent> rows,
            boolean onlyLabeled,
            int limit,
            GateConfig gateConfig,
            int blockerLimit) {
        String triggerId = UUID.randomUUID().toString();
        String evaluatedAt = Instant.now().toString();
        QualityStats stats = computeQualityStats(rows);
        QualityGateResult gate = evaluateQualityGate(stats, rows.size(), onlyLabeled, gateConfig);

        List<ActionItem> blockers = new ArrayList<>();
        if (!"PASS".equals(gate.status)) {
            for (int i = 0; i < gate.nextActions.size() && blockers.size() < blockerLimit; i++) {
                blockers.add(gate.nextActions.get(i));
            }
        }
        ActionItem criticalBlocker = blockers.isEmpty() ? null : blockers.get(0);
        List<String> blockerReasonCodes = actionReasonCodes(blockers);
        List<String> gateSummaryCodes = actionReasonCodes(gate.nextActions);

        return "{"
                + "\"mode\":\"ready-check\","
                + "\"trigger_id\":\"" + escapeJson(triggerId) + "\","
                + "\"evaluated_at\":\"" + escapeJson(evaluatedAt) + "\","
                + "\"ready\":" + "PASS".equals(gate.status) + ","
                + "\"gate_status\":\"" + gate.status + "\","
                + "\"limit\":" + limit + ","
                + "\"row_count\":" + rows.size() + ","
                + "\"only_labeled\":" + onlyLabeled + ","
                + "\"blocker_limit\":" + blockerLimit + ","
                + "\"blocker_count\":" + blockers.size() + ","
                + "\"blocker_reason_codes\":" + stringListToJson(blockerReasonCodes) + ","
                + "\"gate_summary_codes\":" + stringListToJson(gateSummaryCodes) + ","
                + "\"critical_blocker\":" + (criticalBlocker == null ? "null" : criticalBlocker.toJson(this::escapeJson)) + ","
                + "\"blockers\":" + actionListToJson(blockers) + ","
                + "\"recommendations\":" + stringListToJson(gate.recommendations) + ","
                + "\"gate_config\":" + gateConfig.toJson()
                + "}";
    }

    private String buildTrainTriggerDryRunJson(HttpServletRequest request,
            User account,
            List<AITrainingEvent> rows,
            boolean onlyLabeled,
            int limit,
            GateConfig gateConfig,
            int blockerLimit) {
        String triggerId = UUID.randomUUID().toString();
        String evaluatedAt = Instant.now().toString();
        String requestedAt = Instant.now().toString();
        String sourceIp = resolveSourceIp(request);
        String requestedBy = resolveRequestedBy(account);
        String requestedByRole = account == null ? "UNKNOWN" : nullSafe(account.getRole());
        String jsonlProfile = parseJsonlProfile(request.getParameter("jsonlProfile"));
        int trainPct = parseInt(request.getParameter("trainPct"), 80, 10, 98);
        int valPct = parseInt(request.getParameter("valPct"), 10, 1, 80);
        if (trainPct + valPct >= 100) {
            valPct = Math.max(1, 99 - trainPct);
        }

        QualityStats stats = computeQualityStats(rows);
        QualityGateResult gate = evaluateQualityGate(stats, rows.size(), onlyLabeled, gateConfig);
        boolean accepted = "PASS".equals(gate.status);

        List<ActionItem> blockers = new ArrayList<>();
        if (!accepted) {
            for (int i = 0; i < gate.nextActions.size() && blockers.size() < blockerLimit; i++) {
                blockers.add(gate.nextActions.get(i));
            }
        }

        DatasetSplit previewSplit = splitRows(rows, trainPct, valPct);
        List<String> gateSummaryCodes = actionReasonCodes(gate.nextActions);

        return "{"
                + "\"mode\":\"train-trigger-dry-run\","
                + "\"trigger_id\":\"" + escapeJson(triggerId) + "\","
                + "\"evaluated_at\":\"" + escapeJson(evaluatedAt) + "\","
                + "\"requested_at\":\"" + escapeJson(requestedAt) + "\","
                + "\"requested_by\":\"" + escapeJson(requestedBy) + "\","
                + "\"requested_by_role\":\"" + escapeJson(requestedByRole) + "\","
                + "\"source_ip\":\"" + escapeJson(sourceIp) + "\","
                + "\"accepted\":" + accepted + ","
                + "\"decision\":\"" + (accepted ? "APPROVED" : "BLOCKED") + "\","
                + "\"decision_reason\":\"" + (accepted ? "READY_TO_TRAIN" : "BLOCKED_BY_GATE") + "\","
                + "\"gate_status\":\"" + gate.status + "\","
                + "\"gate_summary_codes\":" + stringListToJson(gateSummaryCodes) + ","
                + "\"limit\":" + limit + ","
                + "\"row_count\":" + rows.size() + ","
                + "\"only_labeled\":" + onlyLabeled + ","
                + "\"blocker_limit\":" + blockerLimit + ","
                + "\"blockers\":" + actionListToJson(blockers) + ","
                + "\"proposed_export\":{"
                + "\"mode\":\"jsonl-split\","
                + "\"jsonl_profile\":\"" + escapeJson(jsonlProfile) + "\","
                + "\"train_pct\":" + previewSplit.trainPct + ","
                + "\"validation_pct\":" + previewSplit.valPct + ","
                + "\"test_pct\":" + previewSplit.testPct + ","
                + "\"train_rows\":" + previewSplit.train.size() + ","
                + "\"validation_rows\":" + previewSplit.validation.size() + ","
                + "\"test_rows\":" + previewSplit.test.size() + ","
                + "\"only_labeled\":" + onlyLabeled
                + "},"
                + "\"gate_config\":" + gateConfig.toJson()
                + "}";
    }

    private String buildTrainTriggerJson(HttpServletRequest request,
            User account,
            List<AITrainingEvent> rows,
            boolean onlyLabeled,
            int limit,
            GateConfig gateConfig,
            int blockerLimit) {
        String triggerId = UUID.randomUUID().toString();
        String evaluatedAt = Instant.now().toString();
        String requestedAt = Instant.now().toString();
        String sourceIp = resolveSourceIp(request);
        String requestedBy = resolveRequestedBy(account);
        String requestedByRole = account == null ? "UNKNOWN" : nullSafe(account.getRole());
        String jsonlProfile = parseJsonlProfile(request.getParameter("jsonlProfile"));
        int trainPct = parseInt(request.getParameter("trainPct"), 80, 10, 98);
        int valPct = parseInt(request.getParameter("valPct"), 10, 1, 80);
        if (trainPct + valPct >= 100) {
            valPct = Math.max(1, 99 - trainPct);
        }

        QualityStats stats = computeQualityStats(rows);
        QualityGateResult gate = evaluateQualityGate(stats, rows.size(), onlyLabeled, gateConfig);
        boolean accepted = "PASS".equals(gate.status);
        TrainingSubmission submission = accepted
                ? submitTrainingJob(triggerId, onlyLabeled, limit, previewJsonSplitPath(limit, onlyLabeled, trainPct, valPct, jsonlProfile), gate.status)
                : TrainingSubmission.simulation("BLOCKED_BY_GATE");
        String jobReference = accepted
                ? (submission.providerJobId == null ? "job-" + triggerId : submission.providerJobId)
                : null;
        String decision = accepted ? (submission.submitted ? "SUBMITTED" : "QUEUED_SIMULATION") : "BLOCKED";
        String decisionReason = accepted
                ? (submission.submitted ? "TRAINING_API_ACCEPTED" : "TRAINING_API_NOT_CONFIGURED")
                : "BLOCKED_BY_GATE";

        List<ActionItem> blockers = new ArrayList<>();
        if (!accepted) {
            for (int i = 0; i < gate.nextActions.size() && blockers.size() < blockerLimit; i++) {
                blockers.add(gate.nextActions.get(i));
            }
        }

        DatasetSplit previewSplit = splitRows(rows, trainPct, valPct);
        List<String> gateSummaryCodes = actionReasonCodes(gate.nextActions);

        return "{"
                + "\"mode\":\"train-trigger\","
                + "\"trigger_id\":\"" + escapeJson(triggerId) + "\","
                + "\"evaluated_at\":\"" + escapeJson(evaluatedAt) + "\","
                + "\"requested_at\":\"" + escapeJson(requestedAt) + "\","
                + "\"requested_by\":\"" + escapeJson(requestedBy) + "\","
                + "\"requested_by_role\":\"" + escapeJson(requestedByRole) + "\","
                + "\"source_ip\":\"" + escapeJson(sourceIp) + "\","
                + "\"accepted\":" + accepted + ","
                + "\"decision\":\"" + decision + "\","
                + "\"decision_reason\":\"" + decisionReason + "\","
                + "\"submission_mode\":\"" + escapeJson(submission.mode) + "\","
                + "\"submission_error\":\"" + escapeJson(nullSafe(submission.error)) + "\","
                + "\"job_reference\":" + (jobReference == null ? "null" : "\"" + escapeJson(jobReference) + "\"") + ","
                + "\"gate_status\":\"" + gate.status + "\","
                + "\"gate_summary_codes\":" + stringListToJson(gateSummaryCodes) + ","
                + "\"limit\":" + limit + ","
                + "\"row_count\":" + rows.size() + ","
                + "\"only_labeled\":" + onlyLabeled + ","
                + "\"blocker_limit\":" + blockerLimit + ","
                + "\"blockers\":" + actionListToJson(blockers) + ","
                + "\"planned_export_url\":\"" + escapeJson(request.getContextPath()
                        + "/admin/ai-training/export?mode=jsonl-split&onlyLabeled=" + onlyLabeled
                        + "&limit=" + limit
                        + "&trainPct=" + previewSplit.trainPct
                        + "&valPct=" + previewSplit.valPct
                        + "&jsonlProfile=" + jsonlProfile) + "\","
                + "\"proposed_export\":{"
                + "\"mode\":\"jsonl-split\","
                + "\"jsonl_profile\":\"" + escapeJson(jsonlProfile) + "\","
                + "\"train_pct\":" + previewSplit.trainPct + ","
                + "\"validation_pct\":" + previewSplit.valPct + ","
                + "\"test_pct\":" + previewSplit.testPct + ","
                + "\"train_rows\":" + previewSplit.train.size() + ","
                + "\"validation_rows\":" + previewSplit.validation.size() + ","
                + "\"test_rows\":" + previewSplit.test.size() + ","
                + "\"only_labeled\":" + onlyLabeled
                + "},"
                + "\"gate_config\":" + gateConfig.toJson()
                + "}";
    }

    private String buildTrainTriggerConfirmJson(HttpServletRequest request,
            User account,
            List<AITrainingEvent> rows,
            boolean onlyLabeled,
            int limit,
            GateConfig gateConfig,
            int blockerLimit) {
        String triggerId = nullSafe(request.getParameter("triggerId")).trim();
        if (triggerId.isEmpty()) {
            triggerId = UUID.randomUUID().toString();
        }
        String confirmToken = nullSafe(request.getParameter("confirmToken")).trim();
        boolean confirmed = !confirmToken.isEmpty();
        long replayWindowSeconds = parseReplayWindowSeconds(request);
        long nowEpochSeconds = Instant.now().getEpochSecond();
        int expiredCleanedCount = cleanupExpiredTriggerIds(nowEpochSeconds, replayWindowSeconds);
        boolean replayDetected = isReplayDetected(triggerId, nowEpochSeconds, replayWindowSeconds);

        String evaluatedAt = Instant.now().toString();
        String requestedAt = Instant.now().toString();
        String sourceIp = resolveSourceIp(request);
        String requestedBy = resolveRequestedBy(account);
        String requestedByRole = account == null ? "UNKNOWN" : nullSafe(account.getRole());
        String jsonlProfile = parseJsonlProfile(request.getParameter("jsonlProfile"));
        int trainPct = parseInt(request.getParameter("trainPct"), 80, 10, 98);
        int valPct = parseInt(request.getParameter("valPct"), 10, 1, 80);
        if (trainPct + valPct >= 100) {
            valPct = Math.max(1, 99 - trainPct);
        }

        QualityStats stats = computeQualityStats(rows);
        QualityGateResult gate = evaluateQualityGate(stats, rows.size(), onlyLabeled, gateConfig);
        boolean gatePass = "PASS".equals(gate.status);
        boolean accepted = gatePass && confirmed && !replayDetected;
        TrainingSubmission submission = accepted
                ? submitTrainingJob(triggerId, onlyLabeled, limit, previewJsonSplitPath(limit, onlyLabeled, trainPct, valPct, jsonlProfile), gate.status)
                : TrainingSubmission.simulation("NOT_ACCEPTED");
        String decision;
        String decisionReason;
        if (replayDetected) {
            decision = "REJECTED_REPLAY";
            decisionReason = "TRIGGER_ID_REUSED";
        } else if (!confirmed) {
            decision = "REJECTED_CONFIRMATION";
            decisionReason = "MISSING_CONFIRM_TOKEN";
        } else if (!gatePass) {
            decision = "BLOCKED";
            decisionReason = "BLOCKED_BY_GATE";
        } else {
            if (submission.submitted) {
                decision = "SUBMITTED";
                decisionReason = "TRAINING_API_ACCEPTED";
            } else {
                decision = "QUEUED_SIMULATION";
                decisionReason = "TRAINING_API_NOT_CONFIGURED";
            }
        }
        String jobReference = accepted
                ? (submission.providerJobId == null ? "job-" + triggerId : submission.providerJobId)
                : null;

        List<ActionItem> blockers = new ArrayList<>();
        if (!gatePass) {
            for (int i = 0; i < gate.nextActions.size() && blockers.size() < blockerLimit; i++) {
                blockers.add(gate.nextActions.get(i));
            }
        }

        DatasetSplit previewSplit = splitRows(rows, trainPct, valPct);
        List<String> gateSummaryCodes = actionReasonCodes(gate.nextActions);

        String responseJson = "{"
                + "\"mode\":\"train-trigger-confirm\","
                + "\"trigger_id\":\"" + escapeJson(triggerId) + "\","
                + "\"evaluated_at\":\"" + escapeJson(evaluatedAt) + "\","
                + "\"requested_at\":\"" + escapeJson(requestedAt) + "\","
                + "\"requested_by\":\"" + escapeJson(requestedBy) + "\","
                + "\"requested_by_role\":\"" + escapeJson(requestedByRole) + "\","
                + "\"source_ip\":\"" + escapeJson(sourceIp) + "\","
                + "\"replay_detected\":" + replayDetected + ","
                + "\"replay_window_seconds\":" + replayWindowSeconds + ","
                + "\"confirmation\":{"
                + "\"confirmed\":" + confirmed + ","
                + "\"token_present\":" + (!confirmToken.isEmpty())
                + "},"
                + "\"accepted\":" + accepted + ","
                + "\"decision\":\"" + decision + "\","
                + "\"decision_reason\":\"" + decisionReason + "\","
                + "\"submission_mode\":\"" + escapeJson(submission.mode) + "\","
                + "\"submission_error\":\"" + escapeJson(nullSafe(submission.error)) + "\","
                + "\"job_reference\":" + (jobReference == null ? "null" : "\"" + escapeJson(jobReference) + "\"") + ","
                + "\"gate_status\":\"" + gate.status + "\","
                + "\"gate_summary_codes\":" + stringListToJson(gateSummaryCodes) + ","
                + "\"limit\":" + limit + ","
                + "\"row_count\":" + rows.size() + ","
                + "\"only_labeled\":" + onlyLabeled + ","
                + "\"blocker_limit\":" + blockerLimit + ","
                + "\"blockers\":" + actionListToJson(blockers) + ","
                + "\"used_trigger_count\":" + getUsedTriggerCount(nowEpochSeconds, replayWindowSeconds) + ","
                + "\"expired_cleaned_count\":" + expiredCleanedCount + ","
                + "\"planned_export_url\":\"" + escapeJson(request.getContextPath()
                        + "/admin/ai-training/export?mode=jsonl-split&onlyLabeled=" + onlyLabeled
                        + "&limit=" + limit
                        + "&trainPct=" + previewSplit.trainPct
                        + "&valPct=" + previewSplit.valPct
                        + "&jsonlProfile=" + jsonlProfile) + "\","
                + "\"proposed_export\":{"
                + "\"mode\":\"jsonl-split\","
                + "\"jsonl_profile\":\"" + escapeJson(jsonlProfile) + "\","
                + "\"train_pct\":" + previewSplit.trainPct + ","
                + "\"validation_pct\":" + previewSplit.valPct + ","
                + "\"test_pct\":" + previewSplit.testPct + ","
                + "\"train_rows\":" + previewSplit.train.size() + ","
                + "\"validation_rows\":" + previewSplit.validation.size() + ","
                + "\"test_rows\":" + previewSplit.test.size() + ","
                + "\"only_labeled\":" + onlyLabeled
                + "},"
                + "\"gate_config\":" + gateConfig.toJson()
                + "}";

        if (accepted) {
            markTriggerIdUsed(triggerId, nowEpochSeconds, requestedBy, requestedByRole, sourceIp,
                    "train-trigger-confirm", gate.status, decisionReason);
        }

        return responseJson;
    }

    private String buildTrainTriggerHistoryJson(int historyLimit,
            long replayWindowSeconds,
            String decisionReason,
            String gateStatus,
            String requestedBy,
            String historyMode,
            int page,
            int pageSize,
            boolean sortAsc) {
        long nowEpochSeconds = Instant.now().getEpochSecond();
        int expiredCleanedCount = cleanupExpiredTriggerIds(nowEpochSeconds, replayWindowSeconds);
        int safePageSize = pageSize > 0 ? pageSize : historyLimit;
        int totalFiltered = triggerAuditDAO.countRecentFiltered(decisionReason, gateStatus, requestedBy, historyMode);
        List<AITrainingTriggerAuditDAO.TriggerAuditRecord> records = triggerAuditDAO.findRecentPaged(
                page,
                safePageSize,
                sortAsc,
                decisionReason,
                gateStatus,
                requestedBy,
                historyMode);
        boolean hasMore = (long) page * safePageSize < totalFiltered;

        StringBuilder recordsJson = new StringBuilder("[");
        for (int i = 0; i < records.size(); i++) {
            AITrainingTriggerAuditDAO.TriggerAuditRecord record = records.get(i);
            if (i > 0) {
                recordsJson.append(',');
            }
            String usedAt = record.getUsedAt() == null ? "" : record.getUsedAt().toInstant().toString();
            recordsJson.append("{")
                    .append("\"trigger_id\":\"").append(escapeJson(nullSafe(record.getTriggerId()))).append("\",")
                    .append("\"requested_by\":\"").append(escapeJson(nullSafe(record.getRequestedBy()))).append("\",")
                    .append("\"requested_by_role\":\"").append(escapeJson(nullSafe(record.getRequestedByRole()))).append("\",")
                    .append("\"source_ip\":\"").append(escapeJson(nullSafe(record.getSourceIp()))).append("\",")
                    .append("\"mode\":\"").append(escapeJson(nullSafe(record.getMode()))).append("\",")
                    .append("\"gate_status\":\"").append(escapeJson(nullSafe(record.getGateStatus()))).append("\",")
                    .append("\"decision_reason\":\"").append(escapeJson(nullSafe(record.getDecisionReason()))).append("\",")
                    .append("\"used_at\":\"").append(escapeJson(usedAt)).append("\"")
                    .append("}");
        }
        recordsJson.append(']');

        return "{"
                + "\"mode\":\"train-trigger-history\","
                + "\"history_limit\":" + historyLimit + ","
                + "\"replay_window_seconds\":" + replayWindowSeconds + ","
                + "\"page\":" + page + ","
                + "\"page_size\":" + safePageSize + ","
                + "\"sort\":\"" + (sortAsc ? "asc" : "desc") + "\","
                + "\"filters\":{"
                + "\"decision_reason\":\"" + escapeJson(nullSafe(decisionReason)) + "\","
                + "\"gate_status\":\"" + escapeJson(nullSafe(gateStatus)) + "\","
                + "\"requested_by\":\"" + escapeJson(nullSafe(requestedBy)) + "\","
                + "\"mode\":\"" + escapeJson(nullSafe(historyMode)) + "\""
                + "},"
                + "\"expired_cleaned_count\":" + expiredCleanedCount + ","
                + "\"total_filtered\":" + totalFiltered + ","
                + "\"has_more\":" + hasMore + ","
                + "\"total\":" + records.size() + ","
                + "\"records\":" + recordsJson
                + "}";
    }

    private boolean parseSortAsc(String sort) {
        if (sort == null) {
            return false;
        }
        return "asc".equalsIgnoreCase(sort.trim());
    }

    private String parseJsonlProfile(String rawProfile) {
        if (rawProfile == null) {
            return "default";
        }
        String normalized = rawProfile.trim().toLowerCase();
        if ("google-ai-studio".equals(normalized) || "google".equals(normalized)) {
            return "google-ai-studio";
        }
        return "default";
    }

    private String emptyToNull(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value == null) {
                continue;
            }
            String normalized = value.trim();
            if (!normalized.isEmpty()) {
                return normalized;
            }
        }
        return null;
    }

    private String resolveSourceIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.trim().isEmpty()) {
            return forwarded.split(",")[0].trim();
        }
        String realIp = request.getHeader("X-Real-IP");
        if (realIp != null && !realIp.trim().isEmpty()) {
            return realIp.trim();
        }
        return nullSafe(request.getRemoteAddr());
    }

    private String resolveRequestedBy(User account) {
        if (account == null) {
            return "UNKNOWN";
        }
        String email = nullSafe(account.getEmail()).trim();
        String fullName = nullSafe(account.getFullName()).trim();
        String principal = !email.isEmpty() ? email : (!fullName.isEmpty() ? fullName : "user-" + account.getId());
        return "id:" + account.getId() + "|" + principal;
    }

    private String previewJsonSplitPath(int limit, boolean onlyLabeled, int trainPct, int valPct, String jsonlProfile) {
        return "mode=jsonl-split"
                + "&onlyLabeled=" + onlyLabeled
                + "&limit=" + limit
                + "&trainPct=" + trainPct
                + "&valPct=" + valPct
                + "&jsonlProfile=" + jsonlProfile;
    }

    private TrainingSubmission submitTrainingJob(String triggerId,
            boolean onlyLabeled,
            int limit,
            String exportQuery,
            String gateStatus) {
        String webhook = readConfig(TRAINING_WEBHOOK_ENV);
        if (webhook.isEmpty()) {
            return TrainingSubmission.simulation("WEBHOOK_NOT_CONFIGURED");
        }

        try {
            JSONObject payload = new JSONObject();
            payload.put("triggerId", triggerId);
            payload.put("onlyLabeled", onlyLabeled);
            payload.put("limit", limit);
            payload.put("exportQuery", exportQuery);
            payload.put("gateStatus", gateStatus);
            payload.put("requestedAt", Instant.now().toString());

            HttpRequest.Builder builder = HttpRequest.newBuilder()
                    .uri(URI.create(webhook))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString()));

            String apiKey = readConfig(TRAINING_API_KEY_ENV);
            if (!apiKey.isEmpty()) {
                builder.header("Authorization", "Bearer " + apiKey);
            }

            HttpClient client = HttpClient.newHttpClient();
            HttpResponse<String> response = client.send(builder.build(), HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                String providerJobId = null;
                try {
                    JSONObject body = new JSONObject(response.body());
                    providerJobId = body.optString("jobId", null);
                    if (providerJobId == null || providerJobId.isBlank()) {
                        providerJobId = body.optString("id", null);
                    }
                } catch (Exception ignored) {
                    // Keep providerJobId as null when response body is not JSON.
                }
                return TrainingSubmission.submitted(providerJobId);
            }
            return TrainingSubmission.failed("HTTP_" + response.statusCode());
        } catch (Exception e) {
            return TrainingSubmission.failed("SUBMIT_EXCEPTION");
        }
    }

    private String readConfig(String key) {
        String env = System.getenv(key);
        if (env != null && !env.isBlank()) {
            return env.trim();
        }
        String prop = System.getProperty(key);
        if (prop != null && !prop.isBlank()) {
            return prop.trim();
        }
        return "";
    }

    private boolean isReplayDetected(String triggerId, long nowEpochSeconds, long replayWindowSeconds) {
        if (triggerAuditDAO.isTriggerUsedWithinWindow(triggerId, replayWindowSeconds)) {
            return true;
        }
        Long usedAt = USED_TRIGGER_IDS.get(triggerId);
        if (usedAt == null) {
            return false;
        }
        if (nowEpochSeconds - usedAt > replayWindowSeconds) {
            USED_TRIGGER_IDS.remove(triggerId, usedAt);
            return false;
        }
        return true;
    }

    private void markTriggerIdUsed(String triggerId,
            long nowEpochSeconds,
            String requestedBy,
            String requestedByRole,
            String sourceIp,
            String mode,
            String gateStatus,
            String decisionReason) {
        USED_TRIGGER_IDS.put(triggerId, nowEpochSeconds);
        triggerAuditDAO.recordTriggerUsage(triggerId, requestedBy, requestedByRole, sourceIp, mode, gateStatus, decisionReason);
    }

    private int cleanupExpiredTriggerIds(long nowEpochSeconds, long replayWindowSeconds) {
        int removed = 0;
        for (Map.Entry<String, Long> entry : USED_TRIGGER_IDS.entrySet()) {
            Long usedAt = entry.getValue();
            if (usedAt != null && nowEpochSeconds - usedAt > replayWindowSeconds
                    && USED_TRIGGER_IDS.remove(entry.getKey(), usedAt)) {
                removed++;
            }
        }
        return removed + triggerAuditDAO.cleanupExpired(replayWindowSeconds);
    }

    private int getUsedTriggerCount(long nowEpochSeconds, long replayWindowSeconds) {
        int dbCount = triggerAuditDAO.countRecent(replayWindowSeconds);
        if (dbCount > 0) {
            return dbCount;
        }

        int memoryCount = 0;
        for (Long usedAt : USED_TRIGGER_IDS.values()) {
            if (usedAt != null && nowEpochSeconds - usedAt <= replayWindowSeconds) {
                memoryCount++;
            }
        }
        return memoryCount;
    }

    private long parseReplayWindowSeconds(HttpServletRequest request) {
        long raw = parseLong(request.getParameter("replayWindowSeconds"), DEFAULT_REPLAY_WINDOW_SECONDS,
                MIN_REPLAY_WINDOW_SECONDS, MAX_REPLAY_WINDOW_SECONDS);
        return raw;
    }

    private String buildQualityGateJson(QualityStats stats, int totalRows, boolean onlyLabeled, GateConfig gateConfig) {
        QualityGateResult gate = evaluateQualityGate(stats, totalRows, onlyLabeled, gateConfig);
        return gate.toJson(this::escapeJson);
    }

    private QualityGateResult evaluateQualityGate(QualityStats stats, int totalRows, boolean onlyLabeled, GateConfig gateConfig) {
        String status = "PASS";
        List<String> warnings = new ArrayList<>();
        List<String> recommendations = new ArrayList<>();
        List<ActionItem> nextActions = new ArrayList<>();

        if (totalRows < gateConfig.failMinRows) {
            status = "FAIL";
            warnings.add("So luong du lieu qua it (< " + gateConfig.failMinRows + ") de train on dinh.");
            int missingRows = gateConfig.failMinRows - totalRows;
            recommendations.add("Can thu thap them it nhat " + missingRows + " ban ghi moi.");
            nextActions.add(new ActionItem("P0", "Bo sung du lieu toi thieu",
                    "Thu thap them " + missingRows + " ban ghi moi truoc khi train.", "Data", 2, "MIN_ROWS_FAIL"));
        }
        if (onlyLabeled && stats.labeled <= 0) {
            status = "FAIL";
            warnings.add("Che do onlyLabeled dang bat nhung khong co ban ghi gan nhan.");
            recommendations.add("Can thu thap feedback nhan +1/-1 cho toi thieu 30 ban ghi dau tien truoc khi train.");
            nextActions.add(new ActionItem("P0", "Thu thap feedback nhan",
                    "Kich hoat chu trinh danh gia Huu ich/Chua phu hop de tao nhan dau vao.", "QA", 3, "NO_LABELS_ONLYLABELED"));
        }

        if (!"FAIL".equals(status) && totalRows < gateConfig.warnMinRows) {
            status = "WARN";
            warnings.add("Tong so dong du lieu thap (< " + gateConfig.warnMinRows + "), ket qua train co the khong on dinh.");
            int missingRows = gateConfig.warnMinRows - totalRows;
            recommendations.add("Nen bo sung them " + missingRows + " ban ghi de on dinh metric.");
            nextActions.add(new ActionItem("P1", "Tang kich thuoc dataset",
                    "Bo sung them " + missingRows + " ban ghi de dat nguong on dinh.", "Data", 7, "LOW_ROWS_WARN"));
        }
        if (!"FAIL".equals(status) && stats.labeledRatio < gateConfig.warnMinLabeledRatio) {
            status = "WARN";
            warnings.add("Ty le du lieu co nhan thap (< " + (int) (gateConfig.warnMinLabeledRatio * 100) + "%).");
            long needed = Math.max(1L, (long) Math.ceil(gateConfig.warnMinLabeledRatio * totalRows) - stats.labeled);
            recommendations.add("Can them it nhat " + needed + " ban ghi co nhan feedback de dat nguong labeled ratio.");
            nextActions.add(new ActionItem("P1", "Tang ti le du lieu gan nhan",
                    "Thu them " + needed + " feedback co nhan tu nguoi dung.", "QA", 7, "LOW_LABELED_RATIO"));
        }
        if (!"FAIL".equals(status) && stats.profileRatio < gateConfig.warnMinProfileRatio) {
            status = "WARN";
            warnings.add("Ty le ban ghi co profile thap (< " + (int) (gateConfig.warnMinProfileRatio * 100) + "%).");
            long needed = Math.max(1L, (long) Math.ceil(gateConfig.warnMinProfileRatio * totalRows) - stats.withProfile);
            recommendations.add("Can them it nhat " + needed + " ban ghi co profile day du.");
            nextActions.add(new ActionItem("P2", "Cai thien du lieu profile",
                    "Bo sung thong tin profile cho them " + needed + " ban ghi.", "Backend", 14, "LOW_PROFILE_RATIO"));
        }
        if (!"FAIL".equals(status) && stats.avgPromptLen < gateConfig.warnMinAvgPromptLen) {
            status = "WARN";
            warnings.add("Do dai prompt trung binh qua ngan, can cai thien chat luong cau hoi.");
            recommendations.add("Can huong dan nguoi dung dat cau hoi day du boi canh hon (prompt dai hon). ");
            nextActions.add(new ActionItem("P2", "Nang chat luong prompt",
                    "Them UX hint tren UI chat de nguoi dung dat cau hoi chi tiet hon.", "Product", 14, "SHORT_PROMPT"));
        }
        if (!"FAIL".equals(status) && stats.avgResponseLen < gateConfig.warnMinAvgResponseLen) {
            status = "WARN";
            warnings.add("Do dai response trung binh qua ngan, can xet lai quality du lieu AI reply.");
            recommendations.add("Can tang chat luong response AI (chi tiet hon) truoc khi thu thap them du lieu train.");
            nextActions.add(new ActionItem("P2", "Nang chat luong AI reply",
                    "Dieu chinh prompt/chinh sach AI de response co noi dung huu ich hon.", "Backend", 14, "SHORT_RESPONSE"));
        }
        if (!"FAIL".equals(status) && stats.labeled > 0
                && (stats.positiveRatio > gateConfig.warnMaxLabelImbalance || stats.negativeRatio > gateConfig.warnMaxLabelImbalance)) {
            status = "WARN";
            warnings.add("Phan bo nhan mat can bang, mot nhan chiem > " + (int) (gateConfig.warnMaxLabelImbalance * 100) + "%.");
            long dominant = Math.max(stats.positive, stats.negative);
            long opposite = Math.min(stats.positive, stats.negative);
            long targetOpposite = (long) Math.ceil(dominant * (1.0 - gateConfig.warnMaxLabelImbalance) / gateConfig.warnMaxLabelImbalance);
            long neededOpposite = Math.max(1L, targetOpposite - opposite);
            recommendations.add("Can bo sung khoang " + neededOpposite + " feedback o nhom nhan thieu de can bang du lieu.");
            nextActions.add(new ActionItem("P1", "Can bang nhan positive/negative",
                    "Thu thap them ~" + neededOpposite + " feedback cho nhom nhan dang thieu.", "QA", 7, "LABEL_IMBALANCE"));
        }

        if (warnings.isEmpty()) {
            recommendations.add("Dataset dat nguong hien tai. Co the tien hanh train voi cau hinh gate nay.");
            nextActions.add(new ActionItem("P0", "Khoi dong train",
                    "Du lieu dat gate. Co the chay retrain voi split hien tai.", "Backend", 1, "READY_TO_TRAIN"));
        }

        nextActions.sort((a, b) -> {
            int rankDiff = Integer.compare(priorityRank(a.priority), priorityRank(b.priority));
            if (rankDiff != 0) {
                return rankDiff;
            }
            return a.title.compareToIgnoreCase(b.title);
        });

        return new QualityGateResult(status, warnings, recommendations, nextActions);
    }

    private String stringListToJson(List<String> values) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) {
                json.append(',');
            }
            json.append('"').append(escapeJson(values.get(i))).append('"');
        }
        json.append(']');
        return json.toString();
    }

    private String actionListToJson(List<ActionItem> actions) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < actions.size(); i++) {
            if (i > 0) {
                json.append(',');
            }
            json.append(actions.get(i).toJson(this::escapeJson));
        }
        json.append(']');
        return json.toString();
    }

    private List<String> actionReasonCodes(List<ActionItem> actions) {
        List<String> codes = new ArrayList<>();
        for (ActionItem action : actions) {
            if (action.reasonCode == null || action.reasonCode.trim().isEmpty()) {
                continue;
            }
            if (!codes.contains(action.reasonCode)) {
                codes.add(action.reasonCode);
            }
        }
        return codes;
    }

    private GateConfig parseGateConfig(HttpServletRequest request) {
        int failMinRows = parseInt(request.getParameter("failMinRows"), FAIL_MIN_ROWS, 1, 1000000);
        int warnMinRows = parseInt(request.getParameter("warnMinRows"), WARN_MIN_ROWS, 1, 1000000);
        if (warnMinRows < failMinRows) {
            warnMinRows = failMinRows;
        }

        double warnMinLabeledRatio = parseDouble01(request.getParameter("warnMinLabeledRatio"), WARN_MIN_LABELED_RATIO);
        double warnMinProfileRatio = parseDouble01(request.getParameter("warnMinProfileRatio"), WARN_MIN_PROFILE_RATIO);
        double warnMinAvgPromptLen = parseDouble(request.getParameter("warnMinAvgPromptLen"), WARN_MIN_AVG_PROMPT_LEN, 0.0, 10000.0);
        double warnMinAvgResponseLen = parseDouble(request.getParameter("warnMinAvgResponseLen"), WARN_MIN_AVG_RESPONSE_LEN, 0.0, 10000.0);
        double warnMaxLabelImbalance = parseDouble01(request.getParameter("warnMaxLabelImbalance"), WARN_MAX_LABEL_IMBALANCE);

        return new GateConfig(
                failMinRows,
                warnMinRows,
                warnMinLabeledRatio,
                warnMinProfileRatio,
                warnMinAvgPromptLen,
                warnMinAvgResponseLen,
                warnMaxLabelImbalance);
    }

    private String quoteDecimal(double value) {
        return String.format(java.util.Locale.ROOT, "%.2f", value);
    }

    private int labelNumber(Integer feedbackScore) {
        if (feedbackScore == null) {
            return 0;
        }
        return feedbackScore >= 0 ? 1 : -1;
    }

    private String toCsv(AITrainingEvent row) {
        String createdAt = row.getCreatedAt() == null ? "" : row.getCreatedAt().toLocalDateTime().format(TS_FORMAT);
        String score = row.getFeedbackScore() == null ? "" : String.valueOf(row.getFeedbackScore());

        return String.join(",",
                quote(String.valueOf(row.getId())),
                quote(String.valueOf(row.getUserId())),
                quote(createdAt),
                quote(score),
                quote(nullSafe(row.getFeedbackNote())),
                quote(String.valueOf(row.isHasProfile())),
                quote(nullSafe(row.getHealthGoal())),
                quote(nullSafe(row.getUserMessage())),
                quote(nullSafe(row.getAiReply())),
                quote(nullSafe(row.getSystemContext())));
    }

    private String nullSafe(String value) {
        return value == null ? "" : value;
    }

    private String quote(String value) {
        return '"' + value.replace("\"", "\"\"") + '"';
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private int parseInt(String raw, int fallback, int min, int max) {
        int value = fallback;
        try {
            value = Integer.parseInt(raw);
        } catch (Exception ignored) {
        }
        if (value < min) {
            return min;
        }
        if (value > max) {
            return max;
        }
        return value;
    }

    private long parseLong(String raw, long fallback, long min, long max) {
        long value = fallback;
        try {
            value = Long.parseLong(raw);
        } catch (Exception ignored) {
        }
        if (value < min) {
            return min;
        }
        if (value > max) {
            return max;
        }
        return value;
    }

    private double parseDouble01(String raw, double fallback) {
        return parseDouble(raw, fallback, 0.0, 1.0);
    }

    private double parseDouble(String raw, double fallback, double min, double max) {
        double value = fallback;
        try {
            value = Double.parseDouble(raw);
        } catch (Exception ignored) {
        }
        if (Double.isNaN(value) || value < min) {
            return min;
        }
        if (value > max) {
            return max;
        }
        return value;
    }

    private boolean parseBooleanOrDefault(String raw, boolean fallback) {
        if (raw == null) {
            return fallback;
        }
        String normalized = raw.trim();
        if (normalized.isEmpty()) {
            return fallback;
        }
        return Boolean.parseBoolean(normalized);
    }

    private int priorityRank(String priority) {
        if (priority == null) {
            return Integer.MAX_VALUE;
        }
        switch (priority.toUpperCase(java.util.Locale.ROOT)) {
            case "P0":
                return 0;
            case "P1":
                return 1;
            case "P2":
                return 2;
            default:
                return Integer.MAX_VALUE;
        }
    }

    private static final class DatasetSplit {

        private final List<AITrainingEvent> train;
        private final List<AITrainingEvent> validation;
        private final List<AITrainingEvent> test;
        private final int trainPct;
        private final int valPct;
        private final int testPct;

        private DatasetSplit(List<AITrainingEvent> train,
                List<AITrainingEvent> validation,
                List<AITrainingEvent> test,
                int trainPct,
                int valPct,
                int testPct) {
            this.train = train;
            this.validation = validation;
            this.test = test;
            this.trainPct = trainPct;
            this.valPct = valPct;
            this.testPct = testPct;
        }
    }

    private static final class QualityStats {

        private final long labeled;
        private final long positive;
        private final long negative;
        private final long neutral;
        private final long withProfile;
        private final double avgPromptLen;
        private final double avgResponseLen;
        private final double labeledRatio;
        private final double profileRatio;
        private final double positiveRatio;
        private final double negativeRatio;

        private QualityStats(long labeled,
                long positive,
                long negative,
                long neutral,
                long withProfile,
                double avgPromptLen,
                double avgResponseLen,
                double labeledRatio,
                double profileRatio,
                double positiveRatio,
                double negativeRatio) {
            this.labeled = labeled;
            this.positive = positive;
            this.negative = negative;
            this.neutral = neutral;
            this.withProfile = withProfile;
            this.avgPromptLen = avgPromptLen;
            this.avgResponseLen = avgResponseLen;
            this.labeledRatio = labeledRatio;
            this.profileRatio = profileRatio;
            this.positiveRatio = positiveRatio;
            this.negativeRatio = negativeRatio;
        }
    }

    private static final class GateConfig {

        private final int failMinRows;
        private final int warnMinRows;
        private final double warnMinLabeledRatio;
        private final double warnMinProfileRatio;
        private final double warnMinAvgPromptLen;
        private final double warnMinAvgResponseLen;
        private final double warnMaxLabelImbalance;

        private GateConfig(int failMinRows,
                int warnMinRows,
                double warnMinLabeledRatio,
                double warnMinProfileRatio,
                double warnMinAvgPromptLen,
                double warnMinAvgResponseLen,
                double warnMaxLabelImbalance) {
            this.failMinRows = failMinRows;
            this.warnMinRows = warnMinRows;
            this.warnMinLabeledRatio = warnMinLabeledRatio;
            this.warnMinProfileRatio = warnMinProfileRatio;
            this.warnMinAvgPromptLen = warnMinAvgPromptLen;
            this.warnMinAvgResponseLen = warnMinAvgResponseLen;
            this.warnMaxLabelImbalance = warnMaxLabelImbalance;
        }

        private String toJson() {
            return "{"
                    + "\"fail_min_rows\":" + failMinRows + ","
                    + "\"warn_min_rows\":" + warnMinRows + ","
                    + "\"warn_min_labeled_ratio\":" + String.format(java.util.Locale.ROOT, "%.4f", warnMinLabeledRatio) + ","
                    + "\"warn_min_profile_ratio\":" + String.format(java.util.Locale.ROOT, "%.4f", warnMinProfileRatio) + ","
                    + "\"warn_min_avg_prompt_len\":" + String.format(java.util.Locale.ROOT, "%.2f", warnMinAvgPromptLen) + ","
                    + "\"warn_min_avg_response_len\":" + String.format(java.util.Locale.ROOT, "%.2f", warnMinAvgResponseLen) + ","
                    + "\"warn_max_label_imbalance\":" + String.format(java.util.Locale.ROOT, "%.4f", warnMaxLabelImbalance)
                    + "}";
        }

        private String describe() {
            return "failMinRows=" + failMinRows
                    + ", warnMinRows=" + warnMinRows
                    + ", warnMinLabeledRatio=" + String.format(java.util.Locale.ROOT, "%.2f", warnMinLabeledRatio)
                    + ", warnMinProfileRatio=" + String.format(java.util.Locale.ROOT, "%.2f", warnMinProfileRatio)
                    + ", warnMinAvgPromptLen=" + String.format(java.util.Locale.ROOT, "%.1f", warnMinAvgPromptLen)
                    + ", warnMinAvgResponseLen=" + String.format(java.util.Locale.ROOT, "%.1f", warnMinAvgResponseLen)
                    + ", warnMaxLabelImbalance=" + String.format(java.util.Locale.ROOT, "%.2f", warnMaxLabelImbalance);
        }
    }

    private static final class ActionItem {

        private final String priority;
        private final String title;
        private final String action;
        private final String owner;
        private final int etaDays;
        private final String reasonCode;

        private ActionItem(String priority, String title, String action, String owner, int etaDays, String reasonCode) {
            this.priority = priority;
            this.title = title;
            this.action = action;
            this.owner = owner;
            this.etaDays = etaDays;
            this.reasonCode = reasonCode;
        }

        private String toJson(java.util.function.Function<String, String> escape) {
            String ownerRole = normalizeOwnerRole(owner);
            return "{"
                    + "\"priority\":\"" + escape.apply(priority) + "\","
                    + "\"title\":\"" + escape.apply(title) + "\","
                    + "\"action\":\"" + escape.apply(action) + "\","
                    + "\"owner\":\"" + escape.apply(owner) + "\","
                    + "\"owner_role\":\"" + escape.apply(ownerRole) + "\","
                    + "\"reason_code\":\"" + escape.apply(reasonCode) + "\","
                    + "\"eta_days\":" + etaDays
                    + "}";
        }

        private String normalizeOwnerRole(String owner) {
            if (owner == null) {
                return "UNKNOWN";
            }
            switch (owner.trim().toUpperCase(java.util.Locale.ROOT)) {
                case "DATA":
                    return "DATA";
                case "QA":
                    return "QA";
                case "BACKEND":
                    return "BACKEND";
                case "PRODUCT":
                    return "PRODUCT";
                default:
                    return "UNKNOWN";
            }
        }
    }

    private static final class TrainingSubmission {

        private final boolean submitted;
        private final String providerJobId;
        private final String mode;
        private final String error;

        private TrainingSubmission(boolean submitted, String providerJobId, String mode, String error) {
            this.submitted = submitted;
            this.providerJobId = providerJobId;
            this.mode = mode;
            this.error = error;
        }

        private static TrainingSubmission submitted(String providerJobId) {
            return new TrainingSubmission(true, providerJobId, "real", null);
        }

        private static TrainingSubmission simulation(String reason) {
            return new TrainingSubmission(false, null, "simulation", reason);
        }

        private static TrainingSubmission failed(String reason) {
            return new TrainingSubmission(false, null, "real", reason);
        }
    }

    private static final class QualityGateResult {

        private final String status;
        private final List<String> warnings;
        private final List<String> recommendations;
        private final List<ActionItem> nextActions;

        private QualityGateResult(String status,
                List<String> warnings,
                List<String> recommendations,
                List<ActionItem> nextActions) {
            this.status = status;
            this.warnings = warnings;
            this.recommendations = recommendations;
            this.nextActions = nextActions;
        }

        private String toJson(java.util.function.Function<String, String> escape) {
            List<String> summaryCodes = new ArrayList<>();
            for (ActionItem action : nextActions) {
                if (action.reasonCode == null || action.reasonCode.trim().isEmpty()) {
                    continue;
                }
                if (!summaryCodes.contains(action.reasonCode)) {
                    summaryCodes.add(action.reasonCode);
                }
            }

            StringBuilder warningJson = new StringBuilder("[");
            for (int i = 0; i < warnings.size(); i++) {
                if (i > 0) {
                    warningJson.append(',');
                }
                warningJson.append('"').append(escape.apply(warnings.get(i))).append('"');
            }
            warningJson.append(']');

            StringBuilder recommendationJson = new StringBuilder("[");
            for (int i = 0; i < recommendations.size(); i++) {
                if (i > 0) {
                    recommendationJson.append(',');
                }
                recommendationJson.append('"').append(escape.apply(recommendations.get(i))).append('"');
            }
            recommendationJson.append(']');

            StringBuilder actionJson = new StringBuilder("[");
            for (int i = 0; i < nextActions.size(); i++) {
                if (i > 0) {
                    actionJson.append(',');
                }
                actionJson.append(nextActions.get(i).toJson(escape));
            }
            actionJson.append(']');

            StringBuilder summaryCodeJson = new StringBuilder("[");
            for (int i = 0; i < summaryCodes.size(); i++) {
                if (i > 0) {
                    summaryCodeJson.append(',');
                }
                summaryCodeJson.append('"').append(escape.apply(summaryCodes.get(i))).append('"');
            }
            summaryCodeJson.append(']');

            return "{"
                    + "\"status\":\"" + status + "\","
                    + "\"warnings\":" + warningJson + ","
                    + "\"recommendations\":" + recommendationJson + ","
                    + "\"gate_summary_codes\":" + summaryCodeJson + ","
                    + "\"next_actions\":" + actionJson
                    + "}";
        }
    }
}
