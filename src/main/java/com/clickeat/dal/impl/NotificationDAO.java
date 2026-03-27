package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

import com.clickeat.model.Notification;

public class NotificationDAO extends AbstractDAO<Notification> {

    @Override
    protected Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setGuestId(rs.getString("guest_id"));
        n.setType(rs.getString("type"));
        n.setContent(rs.getString("content"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }

    private boolean isReady() {
        return tableExists("Notifications");
    }

    public boolean createForUser(int userId, String type, String content) {
        if (userId <= 0 || type == null || type.trim().isEmpty() || content == null || content.trim().isEmpty() || !isReady()) {
            return false;
        }
        String sql = "INSERT INTO Notifications (user_id, type, content, is_read, created_at) VALUES (?, ?, ?, 0, SYSUTCDATETIME())";
        return update(sql, userId, type.trim(), content.trim()) > 0;
    }

    public int countUnreadForUser(int userId) {
        if (userId <= 0 || !isReady()) {
            return 0;
        }
        String sql = "SELECT COUNT(*) AS total FROM Notifications WHERE user_id = ? AND is_read = 0";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException ignored) {
        }
        return 0;
    }

    public List<Notification> getRecentForUser(int userId, int limit) {
        if (userId <= 0 || limit <= 0 || !isReady()) {
            return Collections.emptyList();
        }
        String sql = "SELECT TOP (?) * FROM Notifications WHERE user_id = ? ORDER BY created_at DESC";
        return query(sql, limit, userId);
    }

    public boolean markAllReadForUser(int userId) {
        if (userId <= 0 || !isReady()) {
            return false;
        }
        String sql = "UPDATE Notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        return update(sql, userId) >= 0;
    }

    @Override
    public List<Notification> findAll() {
        if (!isReady()) {
            return Collections.emptyList();
        }
        return query("SELECT * FROM Notifications ORDER BY created_at DESC");
    }

    @Override
    public int insert(Notification t) {
        if (t == null || !isReady()) {
            return 0;
        }
        if (t.getUserId() > 0) {
            String sql = "INSERT INTO Notifications (user_id, type, content, is_read, created_at) VALUES (?, ?, ?, ?, SYSUTCDATETIME())";
            return update(sql, t.getUserId(), t.getType(), t.getContent(), t.isRead());
        }
        if (t.getGuestId() != null && !t.getGuestId().trim().isEmpty()) {
            String sql = "INSERT INTO Notifications (guest_id, type, content, is_read, created_at) VALUES (?, ?, ?, ?, SYSUTCDATETIME())";
            return update(sql, t.getGuestId().trim(), t.getType(), t.getContent(), t.isRead());
        }
        return 0;
    }

    @Override
    public boolean update(Notification t) {
        if (t == null || t.getId() <= 0 || !isReady()) {
            return false;
        }
        String sql = "UPDATE Notifications SET type = ?, content = ?, is_read = ? WHERE id = ?";
        return update(sql, t.getType(), t.getContent(), t.isRead(), t.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        if (id <= 0 || !isReady()) {
            return false;
        }
        return update("DELETE FROM Notifications WHERE id = ?", id) > 0;
    }

    @Override
    public Notification findById(int id) {
        if (id <= 0 || !isReady()) {
            return null;
        }
        return queryOne("SELECT * FROM Notifications WHERE id = ?", id);
    }
}
