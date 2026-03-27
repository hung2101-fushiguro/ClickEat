package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;

public class AITrainingTriggerAuditDAO {

    private static final String TABLE_NAME = "AITrainingTriggerAudit";

    public int cleanupExpired(long replayWindowSeconds) {
        if (!tableExists()) {
            return 0;
        }
        String sql = "DELETE FROM dbo.AITrainingTriggerAudit WHERE used_at < DATEADD(SECOND, -?, SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, replayWindowSeconds);
            return ps.executeUpdate();
        } catch (SQLException e) {
            return 0;
        }
    }

    public boolean isTriggerUsedWithinWindow(String triggerId, long replayWindowSeconds) {
        if (triggerId == null || triggerId.trim().isEmpty() || !tableExists()) {
            return false;
        }
        String sql = "SELECT TOP 1 1 FROM dbo.AITrainingTriggerAudit "
                + "WHERE trigger_id = ? AND used_at >= DATEADD(SECOND, -?, SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, triggerId.trim());
            ps.setLong(2, replayWindowSeconds);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean recordTriggerUsage(String triggerId,
            String requestedBy,
            String requestedByRole,
            String sourceIp,
            String mode,
            String gateStatus,
            String decisionReason) {
        if (triggerId == null || triggerId.trim().isEmpty() || !tableExists()) {
            return false;
        }

        String sql = "INSERT INTO dbo.AITrainingTriggerAudit "
                + "(trigger_id, requested_by, requested_by_role, source_ip, mode, gate_status, decision_reason, used_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trim(triggerId, 100));
            ps.setString(2, trim(requestedBy, 255));
            ps.setString(3, trim(requestedByRole, 50));
            ps.setString(4, trim(sourceIp, 64));
            ps.setString(5, trim(mode, 50));
            ps.setString(6, trim(gateStatus, 20));
            ps.setString(7, trim(decisionReason, 100));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public int countRecent(long replayWindowSeconds) {
        if (!tableExists()) {
            return 0;
        }
        String sql = "SELECT COUNT(1) FROM dbo.AITrainingTriggerAudit WHERE used_at >= DATEADD(SECOND, -?, SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, replayWindowSeconds);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            return 0;
        }
    }

    public List<TriggerAuditRecord> findRecent(int limit) {
        return findRecent(limit, null, null, null, null);
    }

    public List<TriggerAuditRecord> findRecent(int limit,
            String decisionReason,
            String gateStatus,
            String requestedByContains,
            String mode) {
        return findRecentPaged(1, limit, false, decisionReason, gateStatus, requestedByContains, mode);
    }

    public int countRecentFiltered(String decisionReason,
            String gateStatus,
            String requestedByContains,
            String mode) {
        if (!tableExists()) {
            return 0;
        }

        StringBuilder sql = new StringBuilder("SELECT COUNT(1) FROM dbo.AITrainingTriggerAudit WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, decisionReason, gateStatus, requestedByContains, mode);

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            return 0;
        }
    }

    public List<TriggerAuditRecord> findRecentPaged(int page,
            int pageSize,
            boolean sortAsc,
            String decisionReason,
            String gateStatus,
            String requestedByContains,
            String mode) {
        List<TriggerAuditRecord> records = new ArrayList<>();
        if (!tableExists()) {
            return records;
        }

        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, Math.min(pageSize, 500));
        int offset = (safePage - 1) * safePageSize;

        StringBuilder sql = new StringBuilder("SELECT trigger_id, requested_by, requested_by_role, source_ip, mode, gate_status, decision_reason, used_at "
                + "FROM dbo.AITrainingTriggerAudit WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, decisionReason, gateStatus, requestedByContains, mode);

        String direction = sortAsc ? "ASC" : "DESC";
        sql.append(" ORDER BY used_at ").append(direction).append(", id ").append(direction)
                .append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(safePageSize);

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(new TriggerAuditRecord(
                            rs.getString("trigger_id"),
                            rs.getString("requested_by"),
                            rs.getString("requested_by_role"),
                            rs.getString("source_ip"),
                            rs.getString("mode"),
                            rs.getString("gate_status"),
                            rs.getString("decision_reason"),
                            rs.getTimestamp("used_at")));
                }
            }
        } catch (SQLException e) {
            return new ArrayList<>();
        }
        return records;
    }

    private void appendFilters(StringBuilder sql,
            List<Object> params,
            String decisionReason,
            String gateStatus,
            String requestedByContains,
            String mode) {
        if (notBlank(decisionReason)) {
            sql.append(" AND decision_reason = ?");
            params.add(decisionReason.trim());
        }
        if (notBlank(gateStatus)) {
            sql.append(" AND gate_status = ?");
            params.add(gateStatus.trim());
        }
        if (notBlank(requestedByContains)) {
            sql.append(" AND requested_by LIKE ?");
            params.add("%" + requestedByContains.trim() + "%");
        }
        if (notBlank(mode)) {
            sql.append(" AND mode = ?");
            params.add(mode.trim());
        }
    }

    private boolean notBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private boolean tableExists() {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, TABLE_NAME);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
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

    public static final class TriggerAuditRecord {

        private final String triggerId;
        private final String requestedBy;
        private final String requestedByRole;
        private final String sourceIp;
        private final String mode;
        private final String gateStatus;
        private final String decisionReason;
        private final java.sql.Timestamp usedAt;

        public TriggerAuditRecord(String triggerId,
                String requestedBy,
                String requestedByRole,
                String sourceIp,
                String mode,
                String gateStatus,
                String decisionReason,
                java.sql.Timestamp usedAt) {
            this.triggerId = triggerId;
            this.requestedBy = requestedBy;
            this.requestedByRole = requestedByRole;
            this.sourceIp = sourceIp;
            this.mode = mode;
            this.gateStatus = gateStatus;
            this.decisionReason = decisionReason;
            this.usedAt = usedAt;
        }

        public String getTriggerId() {
            return triggerId;
        }

        public String getRequestedBy() {
            return requestedBy;
        }

        public String getRequestedByRole() {
            return requestedByRole;
        }

        public String getSourceIp() {
            return sourceIp;
        }

        public String getMode() {
            return mode;
        }

        public String getGateStatus() {
            return gateStatus;
        }

        public String getDecisionReason() {
            return decisionReason;
        }

        public java.sql.Timestamp getUsedAt() {
            return usedAt;
        }
    }
}
