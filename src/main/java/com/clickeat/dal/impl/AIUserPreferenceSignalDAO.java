package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import com.clickeat.config.DBContext;

public class AIUserPreferenceSignalDAO extends DBContext {

    private static final String TABLE_NAME = "AIUserPreferenceSignals";

    public Map<String, Integer> getTopSignals(int userId, int limit) {
        if (userId <= 0 || !tableExists(TABLE_NAME)) {
            return Collections.emptyMap();
        }

        int safeLimit = Math.max(1, Math.min(limit, 20));
        Map<String, Integer> signals = new LinkedHashMap<>();
        String sql = "SELECT TOP (?) signal_label, signal_score FROM AIUserPreferenceSignals "
                + "WHERE user_id = ? ORDER BY signal_score DESC, last_seen_at DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeLimit);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String label = rs.getString("signal_label");
                    int score = rs.getInt("signal_score");
                    if (label != null && !label.isBlank()) {
                        signals.put(label.trim(), score);
                    }
                }
            }
        } catch (SQLException e) {
            return Collections.emptyMap();
        }

        return signals;
    }

    public void incrementSignal(int userId, String signalKey, String signalLabel) {
        if (userId <= 0 || signalKey == null || signalKey.isBlank() || !tableExists(TABLE_NAME)) {
            return;
        }

        String key = trim(signalKey, 100);
        String label = trim(signalLabel == null || signalLabel.isBlank() ? signalKey : signalLabel, 200);

        String updateSql = "UPDATE AIUserPreferenceSignals "
                + "SET signal_score = signal_score + 1, signal_label = ?, last_seen_at = SYSUTCDATETIME() "
                + "WHERE user_id = ? AND signal_key = ?";

        String insertSql = "INSERT INTO AIUserPreferenceSignals (user_id, signal_key, signal_label, signal_score, last_seen_at, created_at) "
                + "VALUES (?, ?, ?, 1, SYSUTCDATETIME(), SYSUTCDATETIME())";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, label);
                ps.setInt(2, userId);
                ps.setString(3, key);
                int updated = ps.executeUpdate();
                if (updated > 0) {
                    return;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, userId);
                ps.setString(2, key);
                ps.setString(3, label);
                ps.executeUpdate();
            }
        } catch (SQLException ignored) {
            // Keep chat flow resilient even when preference persistence fails.
        }
    }

    private String trim(String raw, int maxLen) {
        String text = raw == null ? "" : raw.trim();
        if (text.length() <= maxLen) {
            return text;
        }
        return text.substring(0, maxLen);
    }

    private boolean tableExists(String tableName) {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }
}
