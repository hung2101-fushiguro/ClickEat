package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IOrderIssueDAO;
import com.clickeat.model.OrderIssue;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class OrderIssueDAO extends AbstractDAO<OrderIssue> implements IOrderIssueDAO {

    @Override
    protected OrderIssue mapRow(ResultSet rs) throws SQLException {
        OrderIssue issue = new OrderIssue();
        issue.setId(rs.getInt("id"));
        issue.setOrderId(rs.getInt("order_id"));
        issue.setReporterUserId(rs.getInt("reporter_user_id"));
        issue.setIssueType(rs.getString("issue_type"));
        issue.setDescription(rs.getString("description"));
        issue.setStatus(rs.getString("status"));
        issue.setCreatedAt(rs.getTimestamp("created_at"));

        // Map thêm thông tin JOIN (nếu có)
        try {
            issue.setOrderCode(rs.getString("order_code"));
            issue.setReporterName(rs.getString("reporter_name"));
            issue.setReporterPhone(rs.getString("reporter_phone"));
        } catch (SQLException e) {
            /* Bỏ qua nếu query không có JOIN */ }

        return issue;
    }

    // [Dùng cho Admin] Lấy danh sách sự cố chờ giải quyết (Kèm tên Shipper và Mã đơn)
    @Override
    public List<OrderIssue> getPendingIssues() {
        String sql = "SELECT i.*, o.order_code, u.full_name AS reporter_name, u.phone AS reporter_phone "
                + "FROM OrderIssues i "
                + "JOIN Orders o ON i.order_id = o.id "
                + "JOIN Users u ON i.reporter_user_id = u.id "
                + "WHERE i.status = 'PENDING' "
                + "ORDER BY i.created_at ASC";
        return query(sql);
    }

    // [Dùng cho Admin] Đánh dấu sự cố đã được giải quyết
    @Override
    public boolean resolveIssue(int issueId) {
        String sql = "UPDATE OrderIssues SET status = 'RESOLVED' WHERE id = ?";
        return update(sql, issueId) > 0;
    }

    // [Dùng cho Shipper] Thêm sự cố mới
    @Override
    public int insert(OrderIssue issue) {
        String sql = "INSERT INTO OrderIssues (order_id, reporter_user_id, issue_type, description, status) VALUES (?, ?, ?, ?, 'PENDING')";
        return update(sql, issue.getOrderId(), issue.getReporterUserId(), issue.getIssueType(), issue.getDescription());
    }

    // [Dùng cho Shipper] Lấy lịch sử sự cố
    @Override
    public List<OrderIssue> getIssuesByShipperId(long shipperId) {
        String sql = "SELECT * FROM OrderIssues WHERE reporter_user_id = ? ORDER BY created_at DESC";
        return query(sql, shipperId);
    }

    @Override
    public List<OrderIssue> findAll() {
        return null;
    }

    @Override
    public OrderIssue findById(int id) {
        return null;
    }

    @Override
    public boolean update(OrderIssue t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
