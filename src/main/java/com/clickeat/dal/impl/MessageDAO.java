package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.model.Message;

public class MessageDAO extends AbstractDAO<Message> {

    @Override
    protected Message mapRow(ResultSet rs) throws SQLException {
        Message m = new Message();
        m.setId(rs.getLong("id"));
        m.setSenderId(rs.getLong("sender_id"));
        m.setReceiverId(rs.getLong("receiver_id"));
        m.setContent(rs.getString("content"));
        m.setIsRead(rs.getBoolean("is_read"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        return m;
    }

    // Lấy danh sách những người đã từng nhắn tin với Merchant
    public List<Message> getConversations(long merchantId) {
        if (!tableExists("Messages")) {
            return new ArrayList<>();
        }

        String sql = "SELECT DISTINCT partner_id, u.full_name, u.avatar_url, u.role, "
                + "(SELECT TOP 1 content FROM Messages WHERE (sender_id = partner_id AND receiver_id = ?) OR (sender_id = ? AND receiver_id = partner_id) ORDER BY created_at DESC) as last_content, "
                + "(SELECT TOP 1 created_at FROM Messages WHERE (sender_id = partner_id AND receiver_id = ?) OR (sender_id = ? AND receiver_id = partner_id) ORDER BY created_at DESC) as last_time "
                + "FROM (SELECT sender_id as partner_id FROM Messages WHERE receiver_id = ? UNION SELECT receiver_id as partner_id FROM Messages WHERE sender_id = ?) as sub "
                + "JOIN Users u ON sub.partner_id = u.id ORDER BY last_time DESC";

        List<Message> list = new ArrayList<>();
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 6; i++) {
                ps.setLong(i, merchantId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Message m = new Message();
                    m.setSenderId(rs.getLong("partner_id"));
                    m.setOtherPartyName(rs.getString("full_name"));
                    m.setOtherPartyAvatar(rs.getString("avatar_url"));
                    m.setOtherPartyRole(rs.getString("role"));
                    m.setContent(rs.getString("last_content"));
                    m.setCreatedAt(rs.getTimestamp("last_time"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Message> getChatHistory(long u1, long u2) {
        if (!tableExists("Messages")) {
            return new ArrayList<>();
        }

        // Luôn phải có ORDER BY created_at ASC để tin mới nhất nằm cuối danh sách
        String sql = "SELECT * FROM Messages WHERE (sender_id = ? AND receiver_id = ?) "
                + "OR (sender_id = ? AND receiver_id = ?) "
                + "ORDER BY created_at ASC";
        return query(sql, u1, u2, u2, u1);
    }

    public boolean saveMessage(long from, long to, String content) {
        if (!tableExists("Messages")) {
            return false;
        }

        String sql = "INSERT INTO Messages (sender_id, receiver_id, content) VALUES (?, ?, ?)";
        return update(sql, from, to, content) > 0;
    }

    public int countUnreadForMerchant(long merchantId) {
        if (!tableExists("Messages")) {
            return 0;
        }

        String sql = "SELECT COUNT(*) AS unread_count FROM Messages WHERE receiver_id = ? AND is_read = 0";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("unread_count");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Message> getRecentNotificationsForMerchant(long merchantId, int limit) {
        if (!tableExists("Messages")) {
            return new ArrayList<>();
        }

        int safeLimit = Math.max(1, Math.min(limit, 50));
        String sql = "SELECT TOP (?) m.id, m.sender_id, m.receiver_id, m.content, m.is_read, m.created_at, u.full_name AS other_party_name "
                + "FROM Messages m "
                + "LEFT JOIN Users u ON u.id = m.sender_id "
                + "WHERE m.receiver_id = ? "
                + "ORDER BY m.created_at DESC";

        List<Message> items = new ArrayList<>();
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeLimit);
            ps.setLong(2, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Message m = new Message();
                    m.setId(rs.getLong("id"));
                    m.setSenderId(rs.getLong("sender_id"));
                    m.setReceiverId(rs.getLong("receiver_id"));
                    m.setContent(rs.getString("content"));
                    m.setIsRead(rs.getBoolean("is_read"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    m.setCreatedAt(createdAt);
                    m.setOtherPartyName(rs.getString("other_party_name"));
                    items.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public boolean markAllReadForMerchant(long merchantId) {
        if (!tableExists("Messages")) {
            return false;
        }

        String sql = "UPDATE Messages SET is_read = 1 WHERE receiver_id = ? AND is_read = 0";
        update(sql, merchantId);
        return true;
    }

    @Override
    public List<Message> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(Message t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(Message t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public Message findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
