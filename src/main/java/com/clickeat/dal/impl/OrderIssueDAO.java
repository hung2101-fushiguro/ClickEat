/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.OrderIssue;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class OrderIssueDAO extends AbstractDAO<OrderIssue> {

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
        return issue;
    }

    @Override
    public int insert(OrderIssue issue) {
        String sql = "INSERT INTO OrderIssues (order_id, reporter_user_id, issue_type, description, status, created_at) VALUES (?, ?, ?, ?, 'PENDING', GETDATE())";
        return update(sql, issue.getOrderId(), issue.getReporterUserId(), issue.getIssueType(), issue.getDescription());
    }

    public List<OrderIssue> getIssuesByShipperId(int shipperId) {
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
