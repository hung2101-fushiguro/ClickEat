package com.clickeat.dal.impl;

import com.clickeat.model.Message;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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
        // Luôn phải có ORDER BY created_at ASC để tin mới nhất nằm cuối danh sách
        String sql = "SELECT * FROM Messages WHERE (sender_id = ? AND receiver_id = ?) "
                + "OR (sender_id = ? AND receiver_id = ?) "
                + "ORDER BY created_at ASC";
        return query(sql, u1, u2, u2, u1);
    }

    public boolean saveMessage(long from, long to, String content) {
        String sql = "INSERT INTO Messages (sender_id, receiver_id, content) VALUES (?, ?, ?)";
        return update(sql, from, to, content) > 0;
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
