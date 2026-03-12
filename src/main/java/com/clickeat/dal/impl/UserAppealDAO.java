/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.UserAppeal;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.clickeat.dal.interfaces.IUserAppealDAO;
import java.util.List;

public class UserAppealDAO extends AbstractDAO<UserAppeal> implements IUserAppealDAO {

    @Override
    protected UserAppeal mapRow(ResultSet rs) throws SQLException {
        UserAppeal a = new UserAppeal();
        a.setId(rs.getLong("id"));
        a.setUserId(rs.getInt("user_id"));
        a.setReason(rs.getString("reason"));
        a.setStatus(rs.getString("status"));
        a.setAdminNote(rs.getString("admin_note"));
        a.setCreatedAt(rs.getTimestamp("created_at"));

        try {
            a.setFullName(rs.getString("full_name"));
            a.setPhone(rs.getString("phone"));
            a.setRole(rs.getString("role"));
        } catch (SQLException e) {
        }
        return a;
    }

    // Shipper gửi đơn mới
    @Override
    public boolean createAppeal(int userId, String reason) {
        String sql = "INSERT INTO UserAppeals (user_id, reason, status) VALUES (?, ?, 'PENDING')";
        return update(sql, userId, reason) > 0;
    }

    // Admin lấy danh sách đơn chờ duyệt
    @Override
    public List<UserAppeal> getPendingAppeals() {
        String sql = "SELECT a.*, u.full_name, u.phone, u.role FROM UserAppeals a JOIN Users u ON a.user_id = u.id WHERE a.status = 'PENDING' ORDER BY a.created_at ASC";
        return query(sql);
    }

    // Admin Phán xử (Duyệt / Từ chối)
    @Override
    public boolean resolveAppeal(long appealId, String status, String adminNote) {
        String sql = "UPDATE UserAppeals SET status = ?, admin_note = ?, resolved_at = GETDATE() WHERE id = ?";
        return update(sql, status, adminNote, appealId) > 0;
    }

    @Override
    // Lấy đơn kháng cáo MỚI NHẤT của một user
    public UserAppeal getLatestAppeal(int userId) {
        // Dùng SELECT TOP 1 và ORDER BY DESC để lấy đơn nộp gần đây nhất
        String sql = "SELECT TOP 1 * FROM UserAppeals WHERE user_id = ? ORDER BY created_at DESC";
        List<UserAppeal> list = query(sql, userId);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public List<UserAppeal> findAll() {
        return null;
    }

    @Override
    public UserAppeal findById(int id) {
        return null;
    }

    @Override
    public int insert(UserAppeal t) {
        return 0;
    }

    @Override
    public boolean update(UserAppeal t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
