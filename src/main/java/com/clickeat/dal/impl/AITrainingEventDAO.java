package com.clickeat.dal.impl;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

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
     * Lấy các ví dụ được đánh giá tốt (feedback_score = 1) để dùng làm few-shot examples.
     * Ưu tiên các ví dụ có cùng health_goal với user hiện tại.
     * Dùng để inject vào system prompt thay cho fine-tuning.
     *
     * @param limit       số ví dụ tối đa (khuyên dùng 3–6)
     * @param healthGoal  mục tiêu sức khỏe của user hiện tại (nullable, dùng để ưu tiên)
     */
    public List<AITrainingEvent> findTopRatedExamples(int limit, String healthGoal) {
        if (!tableExists(TABLE_NAME) || !columnExists(TABLE_NAME, "feedback_score")) {
            return Collections.emptyList();
        }

        int safeLimit = Math.max(1, Math.min(limit, 20));

        // Ưu tiên: cùng health_goal + score=1 trước, sau đó lấy thêm các ví dụ tốt khác
        // Dùng 2 lần query rồi merge để tránh SQL phức tạp
        List<AITrainingEvent> result = new java.util.ArrayList<>();

        // Query 1: cùng health_goal (nếu có)
        if (healthGoal != null && !healthGoal.isBlank()) {
            String sql1 = "SELECT TOP (?) user_message, ai_reply, health_goal FROM AITrainingEvents "
                    + "WHERE feedback_score = 1 "
                    + "AND user_message IS NOT NULL AND LEN(user_message) >= 5 "
                    + "AND ai_reply IS NOT NULL AND LEN(ai_reply) >= 20 "
                    + "AND health_goal LIKE ? "
                    + "ORDER BY feedback_at DESC, id DESC";
            List<AITrainingEvent> matched = query(sql1, safeLimit, "%" + healthGoal.trim() + "%");
            result.addAll(matched);
        }

        // Query 2: bất kỳ ví dụ tốt nào, tránh trùng id
        if (result.size() < safeLimit) {
            int remaining = safeLimit - result.size();
            StringBuilder sql2 = new StringBuilder(
                    "SELECT TOP (?) user_message, ai_reply, health_goal FROM AITrainingEvents "
                    + "WHERE feedback_score = 1 "
                    + "AND user_message IS NOT NULL AND LEN(user_message) >= 5 "
                    + "AND ai_reply IS NOT NULL AND LEN(ai_reply) >= 20 ");

            java.util.List<Object> params2 = new java.util.ArrayList<>();
            params2.add(remaining);

            if (!result.isEmpty()) {
                // Loại bỏ các id đã có (tránh trùng lặp)
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

        return result;
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
