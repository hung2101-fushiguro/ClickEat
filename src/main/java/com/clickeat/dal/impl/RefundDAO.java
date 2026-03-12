package com.clickeat.dal.impl;

import com.clickeat.model.RefundRequest;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class RefundDAO extends AbstractDAO<RefundRequest> {

    @Override
    protected RefundRequest mapRow(ResultSet rs) throws SQLException {
        RefundRequest r = new RefundRequest();
        r.setId(rs.getLong("id"));
        r.setOrderId(rs.getLong("order_id"));
        r.setMerchantUserId(rs.getLong("merchant_user_id"));
        r.setRefundAmount(rs.getDouble("refund_amount"));
        r.setReason(rs.getString("reason"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }

    public boolean insertRefund(RefundRequest refund) {
        String sql = "INSERT INTO RefundRequests (order_id, merchant_user_id, refund_amount, reason, status) VALUES (?, ?, ?, ?, 'COMPLETED')";
        return update(sql, refund.getOrderId(), refund.getMerchantUserId(), refund.getRefundAmount(), refund.getReason()) > 0;
    }

    @Override
    public List<RefundRequest> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(RefundRequest t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(RefundRequest t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public RefundRequest findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
