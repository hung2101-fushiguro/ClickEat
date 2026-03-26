package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
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
        String sql = "SELECT DISTINCT o.customer_user_id AS partner_id, u.full_name, u.avatar_url, u.role, "
                + "(SELECT TOP 1 content FROM Messages WHERE (sender_id = o.customer_user_id AND receiver_id = ?) OR (sender_id = ? AND receiver_id = o.customer_user_id) ORDER BY created_at DESC) as last_content, "
                + "(SELECT TOP 1 created_at FROM Messages WHERE (sender_id = o.customer_user_id AND receiver_id = ?) OR (sender_id = ? AND receiver_id = o.customer_user_id) ORDER BY created_at DESC) as last_time "
                + "FROM Orders o "
                + "JOIN Users u ON u.id = o.customer_user_id "
                + "WHERE o.merchant_user_id = ? AND o.customer_user_id IS NOT NULL "
                + "AND o.order_status IN ('READY_FOR_PICKUP', 'DELIVERING', 'PICKED_UP') "
                + "ORDER BY last_time DESC";

        List<Message> list = new ArrayList<>();
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, merchantId);
            ps.setLong(2, merchantId);
            ps.setLong(3, merchantId);
            ps.setLong(4, merchantId);
            ps.setLong(5, merchantId);
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
            return list;
        }
        return list;
    }

    public boolean hasActiveDeliveryWindow(long merchantId, long customerId) {
        String sql = "SELECT TOP 1 1 FROM Orders WHERE merchant_user_id = ? AND customer_user_id = ? "
                + "AND order_status IN ('READY_FOR_PICKUP', 'DELIVERING', 'PICKED_UP')";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, merchantId);
            ps.setLong(2, customerId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean deleteConversationBetween(long u1, long u2) {
        String sql = "DELETE FROM Messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
        update(sql, u1, u2, u2, u1);
        return true;
    }

    public boolean purgeExpiredConversationsForMerchant(long merchantId) {
        String sql = "DELETE m FROM Messages m "
                + "WHERE (m.sender_id = ? OR m.receiver_id = ?) "
                + "AND NOT EXISTS ("
                + "    SELECT 1 FROM Orders o "
                + "    WHERE o.merchant_user_id = ? "
                + "      AND o.customer_user_id = CASE WHEN m.sender_id = ? THEN m.receiver_id ELSE m.sender_id END "
                + "      AND o.order_status IN ('READY_FOR_PICKUP', 'DELIVERING', 'PICKED_UP')"
                + ")";
        update(sql, merchantId, merchantId, merchantId, merchantId);
        return true;
    }

    public List<Message> getChatHistory(long u1, long u2) {
        // Luôn phải có ORDER BY created_at ASC để tin mới nhất nằm cuối danh sách
        String sql = "SELECT * FROM Messages WHERE (sender_id = ? AND receiver_id = ?) "
                + "OR (sender_id = ? AND receiver_id = ?) "
                + "ORDER BY created_at ASC";
        return query(sql, u1, u2, u2, u1);
    }

    public List<Message> getChatHistorySince(long u1, long u2, long sinceId) {
        String sql = "SELECT * FROM Messages WHERE ((sender_id = ? AND receiver_id = ?) "
                + "OR (sender_id = ? AND receiver_id = ?)) AND id > ? ORDER BY created_at ASC";
        return query(sql, u1, u2, u2, u1, sinceId);
    }

    public boolean saveMessage(long from, long to, String content) {
        String sql = "INSERT INTO Messages (sender_id, receiver_id, content) VALUES (?, ?, ?)";
        return update(sql, from, to, content) > 0;
    }

    public Message getLatestBetween(long u1, long u2) {
        String sql = "SELECT TOP 1 * FROM Messages WHERE (sender_id = ? AND receiver_id = ?) "
                + "OR (sender_id = ? AND receiver_id = ?) ORDER BY id DESC";
        return queryOne(sql, u1, u2, u2, u1);
    }

    public int countUnreadForMerchant(int merchantId) {
        String sql = "SELECT COUNT(*) FROM Messages WHERE receiver_id = ? AND is_read = 0";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            return 0;
        }
        return 0;
    }

    public List<Message> getRecentNotificationsForMerchant(int merchantId, int limit) {
        String sql = "SELECT TOP (?) m.*, u.full_name FROM Messages m LEFT JOIN Users u ON m.sender_id = u.id WHERE m.receiver_id = ? ORDER BY m.created_at DESC";
        List<Message> list = new ArrayList<>();
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, merchantId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Message m = mapRow(rs);
                    m.setOtherPartyName(rs.getString("full_name"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            return list;
        }
        return list;
    }

    public boolean markAllReadForMerchant(int merchantId) {
        String sql = "UPDATE Messages SET is_read = 1 WHERE receiver_id = ? AND is_read = 0";
        update(sql, merchantId);
        return true;
    }

    public boolean markConversationRead(long receiverId, long senderId) {
        String sql = "UPDATE Messages SET is_read = 1 WHERE receiver_id = ? AND sender_id = ? AND is_read = 0";
        update(sql, receiverId, senderId);
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
