package com.clickeat.dal.impl;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import com.clickeat.model.AITrainingEvent;

public class AITrainingEventDAO extends AbstractDAO<AITrainingEvent> {

    private static final String TABLE_NAME = "AITrainingEvents";

    @Override
    protected AITrainingEvent mapRow(ResultSet rs) throws SQLException {
        AITrainingEvent e = new AITrainingEvent();
        e.setId(rs.getLong("id"));
        e.setUserId(rs.getInt("user_id"));
        e.setUserMessage(rs.getString("user_message"));
        e.setSystemContext(rs.getString("system_context"));
        e.setConversationContext(readOptionalString(rs, "conversation_context"));
        e.setPromptHash(readOptionalString(rs, "prompt_hash"));
        e.setAiReply(rs.getString("ai_reply"));
        e.setHasProfile(rs.getBoolean("has_profile"));
        e.setHealthGoal(rs.getString("health_goal"));
        Integer feedbackScore = readNullableInt(rs, "feedback_score");
        if (feedbackScore != null) {
            e.setFeedbackScore(feedbackScore);
        }
        e.setFeedbackNote(readOptionalString(rs, "feedback_note"));
        e.setFeedbackCategory(readOptionalString(rs, "feedback_category"));
        e.setFeedbackGroundTruth(readOptionalString(rs, "feedback_ground_truth"));
        e.setFeedbackErrorType(readOptionalString(rs, "feedback_error_type"));
        e.setFeedbackAt(readOptionalTimestamp(rs, "feedback_at"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        return e;
    }

    public long insertEvent(AITrainingEvent event) {
        if (event == null || event.getUserId() <= 0 || !tableExists(TABLE_NAME)) {
            return 0;
        }
        String promptHash = sha256Hex(normalizePrompt(event.getUserMessage()));
        event.setPromptHash(promptHash);

        if (columnExists(TABLE_NAME, "prompt_hash") && existsRecentDuplicate(event.getUserId(), promptHash, 24)) {
            return 0;
        }

        List<String> columns = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        columns.add("user_id");
        params.add(event.getUserId());

        columns.add("user_message");
        params.add(trim(event.getUserMessage(), 2000));

        columns.add("system_context");
        params.add(trim(event.getSystemContext(), 12000));

        if (columnExists(TABLE_NAME, "conversation_context")) {
            columns.add("conversation_context");
            params.add(trim(event.getConversationContext(), 32000));
        }
        if (columnExists(TABLE_NAME, "prompt_hash")) {
            columns.add("prompt_hash");
            params.add(trim(promptHash, 64));
        }

        columns.add("ai_reply");
        params.add(trim(event.getAiReply(), 8000));

        columns.add("has_profile");
        params.add(event.isHasProfile());

        columns.add("health_goal");
        params.add(trim(event.getHealthGoal(), 255));

        columns.add("created_at");

        StringBuilder sql = new StringBuilder("INSERT INTO AITrainingEvents (");
        for (int i = 0; i < columns.size(); i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append(columns.get(i));
        }
        sql.append(") VALUES (");
        int paramCount = params.size();
        for (int i = 0; i < paramCount; i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append("?");
        }
        sql.append(", SYSUTCDATETIME())");

        return update(sql.toString(), params.toArray(new Object[0]));
    }

    public boolean updateFeedback(long eventId,
            int userId,
            int feedbackScore,
            String feedbackNote,
            String feedbackCategory,
            String feedbackGroundTruth,
            String feedbackErrorType) {
        if (eventId <= 0 || userId <= 0 || !tableExists(TABLE_NAME) || !columnExists(TABLE_NAME, "feedback_score")) {
            return false;
        }

        int normalizedScore = feedbackScore >= 0 ? 1 : -1;
        String note = trim(feedbackNote, 500);
        String category = trim(feedbackCategory, 100);
        String groundTruth = trim(feedbackGroundTruth, 2000);
        String errorType = trim(feedbackErrorType, 100);

        String sql;
        if (columnExists(TABLE_NAME, "feedback_note")
                && columnExists(TABLE_NAME, "feedback_at")
                && columnExists(TABLE_NAME, "feedback_category")
                && columnExists(TABLE_NAME, "feedback_ground_truth")
                && columnExists(TABLE_NAME, "feedback_error_type")) {
            sql = "UPDATE AITrainingEvents "
                    + "SET feedback_score = ?, feedback_note = ?, feedback_category = ?, feedback_ground_truth = ?, feedback_error_type = ?, feedback_at = SYSUTCDATETIME() "
                    + "WHERE id = ? AND user_id = ?";
            return update(sql, normalizedScore, note, category, groundTruth, errorType, eventId, userId) > 0;
        }

        sql = "UPDATE AITrainingEvents SET feedback_score = ? WHERE id = ? AND user_id = ?";
        return update(sql, normalizedScore, eventId, userId) > 0;
    }

    public List<AITrainingEvent> findForExport(int limit, boolean onlyLabeled) {
        return findForExport(limit, onlyLabeled, null);
    }

    /**
     * LÃƒÂ¡Ã‚ÂºÃ‚Â¥y cÃƒÆ’Ã‚Â¡c vÃƒÆ’Ã‚Â­ dÃƒÂ¡Ã‚Â»Ã‚Â¥ Ãƒâ€žÃ¢â‚¬ËœÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã‚Â£c Ãƒâ€žÃ¢â‚¬ËœÃƒÆ’Ã‚Â¡nh giÃƒÆ’Ã‚Â¡ tÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœt (feedback_score = 1) Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã†â€™ dÃƒÆ’Ã‚Â¹ng lÃƒÆ’Ã‚Â m few-shot examples.
     * Ãƒâ€ Ã‚Â¯u tiÃƒÆ’Ã‚Âªn cÃƒÆ’Ã‚Â¡c vÃƒÆ’Ã‚Â­ dÃƒÂ¡Ã‚Â»Ã‚Â¥ cÃƒÆ’Ã‚Â³ cÃƒÆ’Ã‚Â¹ng health_goal vÃƒÂ¡Ã‚Â»Ã¢â‚¬Âºi user hiÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡n tÃƒÂ¡Ã‚ÂºÃ‚Â¡i.
     * DÃƒÆ’Ã‚Â¹ng Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã†â€™ inject vÃƒÆ’Ã‚Â o system prompt thay cho fine-tuning.
     *
     * @param limit       sÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœ vÃƒÆ’Ã‚Â­ dÃƒÂ¡Ã‚Â»Ã‚Â¥ tÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœi Ãƒâ€žÃ¢â‚¬Ëœa (khuyÃƒÆ’Ã‚Âªn dÃƒÆ’Ã‚Â¹ng 3ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“6)
     * @param healthGoal  mÃƒÂ¡Ã‚Â»Ã‚Â¥c tiÃƒÆ’Ã‚Âªu sÃƒÂ¡Ã‚Â»Ã‚Â©c khÃƒÂ¡Ã‚Â»Ã‚Âe cÃƒÂ¡Ã‚Â»Ã‚Â§a user hiÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡n tÃƒÂ¡Ã‚ÂºÃ‚Â¡i (nullable, dÃƒÆ’Ã‚Â¹ng Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã†â€™ Ãƒâ€ Ã‚Â°u tiÃƒÆ’Ã‚Âªn)
     */
    public List<AITrainingEvent> findTopRatedExamples(int limit, String healthGoal) {
        if (!tableExists(TABLE_NAME) || !columnExists(TABLE_NAME, "feedback_score")) {
            return Collections.emptyList();
        }

        int safeLimit = Math.max(1, Math.min(limit, 20));

        // Ãƒâ€ Ã‚Â¯u tiÃƒÆ’Ã‚Âªn: cÃƒÆ’Ã‚Â¹ng health_goal + score=1 trÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã¢â‚¬Âºc, sau Ãƒâ€žÃ¢â‚¬ËœÃƒÆ’Ã‚Â³ lÃƒÂ¡Ã‚ÂºÃ‚Â¥y thÃƒÆ’Ã‚Âªm cÃƒÆ’Ã‚Â¡c vÃƒÆ’Ã‚Â­ dÃƒÂ¡Ã‚Â»Ã‚Â¥ tÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœt khÃƒÆ’Ã‚Â¡c
        // DÃƒÆ’Ã‚Â¹ng 2 lÃƒÂ¡Ã‚ÂºÃ‚Â§n query rÃƒÂ¡Ã‚Â»Ã¢â‚¬Å“i merge Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã†â€™ trÃƒÆ’Ã‚Â¡nh SQL phÃƒÂ¡Ã‚Â»Ã‚Â©c tÃƒÂ¡Ã‚ÂºÃ‚Â¡p
        List<AITrainingEvent> result = new ArrayList<>();

        // Query 1: cÃƒÆ’Ã‚Â¹ng health_goal (nÃƒÂ¡Ã‚ÂºÃ‚Â¿u cÃƒÆ’Ã‚Â³)
        if (healthGoal != null && !healthGoal.isBlank()) {
            String sql1 = "SELECT TOP (?) * FROM AITrainingEvents "
                    + "WHERE feedback_score = 1 "
                    + "AND user_message IS NOT NULL AND LEN(user_message) >= 5 "
                    + "AND ai_reply IS NOT NULL AND LEN(ai_reply) >= 20 "
                    + "AND health_goal LIKE ? "
                    + "ORDER BY feedback_at DESC, id DESC";
            List<AITrainingEvent> matched = query(sql1, safeLimit, "%" + healthGoal.trim() + "%");
            result.addAll(matched);
        }

        // Query 2: bÃƒÂ¡Ã‚ÂºÃ‚Â¥t kÃƒÂ¡Ã‚Â»Ã‚Â³ vÃƒÆ’Ã‚Â­ dÃƒÂ¡Ã‚Â»Ã‚Â¥ tÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœt nÃƒÆ’Ã‚Â o, trÃƒÆ’Ã‚Â¡nh trÃƒÆ’Ã‚Â¹ng id
        if (result.size() < safeLimit) {
            int remaining = safeLimit - result.size();
            StringBuilder sql2 = new StringBuilder(
                    "SELECT TOP (?) * FROM AITrainingEvents "
                    + "WHERE feedback_score = 1 "
                    + "AND user_message IS NOT NULL AND LEN(user_message) >= 5 "
                    + "AND ai_reply IS NOT NULL AND LEN(ai_reply) >= 20 ");

            List<Object> params2 = new ArrayList<>();
            params2.add(remaining);

            if (!result.isEmpty()) {
                // LoÃƒÂ¡Ã‚ÂºÃ‚Â¡i bÃƒÂ¡Ã‚Â»Ã‚Â cÃƒÆ’Ã‚Â¡c id Ãƒâ€žÃ¢â‚¬ËœÃƒÆ’Ã‚Â£ cÃƒÆ’Ã‚Â³ (trÃƒÆ’Ã‚Â¡nh trÃƒÆ’Ã‚Â¹ng lÃƒÂ¡Ã‚ÂºÃ‚Â·p)
                sql2.append("AND id NOT IN (");
                for (int i = 0; i < result.size(); i++) {
                    if (i > 0) sql2.append(",");
                    sql2.append("?");
                    params2.add(result.get(i).getId());
                }
                sql2.append(") ");
            }

            sql2.append("ORDER BY feedback_at DESC, id DESC");
            List<AITrainingEvent> others = query(sql2.toString(), params2.toArray());
            result.addAll(others);
        }

        return dedupeExamples(result, safeLimit);
    }


    private List<AITrainingEvent> dedupeExamples(List<AITrainingEvent> examples, int limit) {
        if (examples == null || examples.isEmpty()) {
            return Collections.emptyList();
        }

        int safeLimit = Math.max(1, Math.min(limit, 20));
        List<AITrainingEvent> deduped = new ArrayList<>();
        Set<String> seen = new LinkedHashSet<>();

        for (AITrainingEvent e : examples) {
            if (e == null) {
                continue;
            }

            String key = trim(e.getPromptHash(), 64);
            if (key == null || key.isBlank()) {
                key = sha256Hex(normalizePrompt(e.getUserMessage()));
            }
            if (key == null || key.isBlank() || seen.contains(key)) {
                continue;
            }

            seen.add(key);
            deduped.add(e);
            if (deduped.size() >= safeLimit) {
                break;
            }
        }

        return deduped;
    }

    public List<AITrainingEvent> findForExport(int limit, boolean onlyLabeled, Integer maxAgeDays) {
        if (!tableExists(TABLE_NAME)) {
            return Collections.emptyList();
        }

        int safeLimit = Math.max(1, Math.min(limit, 50000));
        StringBuilder sql = new StringBuilder("SELECT TOP (?) * FROM AITrainingEvents");
        List<Object> params = new ArrayList<>();
        params.add(safeLimit);

        boolean whereAdded = false;
        if (onlyLabeled && columnExists(TABLE_NAME, "feedback_score")) {
            sql.append(" WHERE feedback_score IS NOT NULL");
            whereAdded = true;
        }
        if (maxAgeDays != null && maxAgeDays > 0) {
            sql.append(whereAdded ? " AND" : " WHERE");
            sql.append(" created_at >= DATEADD(DAY, -?, SYSUTCDATETIME())");
            params.add(Math.min(maxAgeDays, 3650));
        }
        sql.append(" ORDER BY created_at DESC, id DESC");
        return query(sql.toString(), params.toArray());
    }

    private String trim(String value, int maxLen) {
        if (value == null) {
            return null;
        }
        String normalized = value.trim();
        if (normalized.length() <= maxLen) {
            return normalized;
        }
        return normalized.substring(0, maxLen);
    }

    private boolean existsRecentDuplicate(int userId, String promptHash, int hoursWindow) {
        if (promptHash == null || promptHash.isEmpty()) {
            return false;
        }
        String sql = "SELECT TOP 1 1 FROM AITrainingEvents "
                + "WHERE user_id = ? AND prompt_hash = ? "
                + "AND created_at >= DATEADD(HOUR, -?, SYSUTCDATETIME())";
        return queryOneAsInt(sql, userId, promptHash, hoursWindow) != null;
    }

    private Integer queryOneAsInt(String sql, Object... params) {
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        } catch (SQLException e) {
            return null;
        }
    }

    private String normalizePrompt(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().replaceAll("\\s+", " ").toLowerCase(java.util.Locale.ROOT);
    }

    private String sha256Hex(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    @Override
    public List<AITrainingEvent> findAll() {
        if (!tableExists(TABLE_NAME)) {
            return Collections.emptyList();
        }
        return query("SELECT * FROM AITrainingEvents ORDER BY id DESC");
    }

    @Override
    public int insert(AITrainingEvent t) {
        return (int) insertEvent(t);
    }

    @Override
    public boolean update(AITrainingEvent t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }

    @Override
    public AITrainingEvent findById(int id) {
        if (!tableExists(TABLE_NAME)) {
            return null;
        }
        return queryOne("SELECT * FROM AITrainingEvents WHERE id = ?", id);
    }

    private Integer readNullableInt(ResultSet rs, String column) {
        try {
            int value = rs.getInt(column);
            return rs.wasNull() ? null : value;
        } catch (SQLException ignored) {
            return null;
        }
    }

    private String readOptionalString(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (SQLException ignored) {
            return null;
        }
    }

    private java.sql.Timestamp readOptionalTimestamp(ResultSet rs, String column) {
        try {
            return rs.getTimestamp(column);
        } catch (SQLException ignored) {
            return null;
        }
    }
}
