package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.model.RefundRequest;

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

    public boolean processRefundForMerchant(RefundRequest refund) {
        if (refund == null || refund.getOrderId() <= 0 || refund.getMerchantUserId() <= 0) {
            return false;
        }
        if (refund.getRefundAmount() <= 0 || refund.getReason() == null || refund.getReason().trim().isEmpty()) {
            return false;
        }

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String paymentProvider = "VNPAY";
            double totalAmount;
            String paymentStatus;
            String orderStatus;

            String lockOrderSql = "SELECT total_amount, payment_status, order_status FROM Orders WITH (UPDLOCK, ROWLOCK) "
                    + "WHERE id = ? AND merchant_user_id = ?";
            try (PreparedStatement lockStmt = conn.prepareStatement(lockOrderSql)) {
                lockStmt.setLong(1, refund.getOrderId());
                lockStmt.setLong(2, refund.getMerchantUserId());
                try (ResultSet rs = lockStmt.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    totalAmount = rs.getDouble("total_amount");
                    paymentStatus = rs.getString("payment_status");
                    orderStatus = rs.getString("order_status");
                }
            }

            if ("REFUNDED".equalsIgnoreCase(paymentStatus) || "REFUNDED".equalsIgnoreCase(orderStatus)) {
                conn.rollback();
                return false;
            }

            if (refund.getRefundAmount() > totalAmount) {
                conn.rollback();
                return false;
            }

            String providerSql = "SELECT TOP 1 provider FROM PaymentTransactions WHERE order_id = ? ORDER BY created_at DESC";
            try (PreparedStatement providerStmt = conn.prepareStatement(providerSql)) {
                providerStmt.setLong(1, refund.getOrderId());
                try (ResultSet rs = providerStmt.executeQuery()) {
                    if (rs.next() && rs.getString("provider") != null && !rs.getString("provider").trim().isEmpty()) {
                        paymentProvider = rs.getString("provider").trim();
                    }
                }
            }

            String insertRefundSql = "INSERT INTO RefundRequests (order_id, merchant_user_id, refund_amount, reason, status) VALUES (?, ?, ?, ?, 'COMPLETED')";
            try (PreparedStatement insertRefund = conn.prepareStatement(insertRefundSql)) {
                insertRefund.setLong(1, refund.getOrderId());
                insertRefund.setLong(2, refund.getMerchantUserId());
                insertRefund.setDouble(3, refund.getRefundAmount());
                insertRefund.setString(4, refund.getReason().trim());
                if (insertRefund.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            String updateOrderSql = "UPDATE Orders SET payment_status = 'REFUNDED', order_status = 'REFUNDED' WHERE id = ? AND merchant_user_id = ?";
            try (PreparedStatement updateOrder = conn.prepareStatement(updateOrderSql)) {
                updateOrder.setLong(1, refund.getOrderId());
                updateOrder.setLong(2, refund.getMerchantUserId());
                if (updateOrder.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            String insertPaymentSql = "INSERT INTO PaymentTransactions(order_id, provider, amount, status, provider_txn_ref) "
                    + "VALUES (?, ?, ?, 'REFUNDED', ?)";
            String refundRef = "REFUND-" + refund.getOrderId() + "-" + System.currentTimeMillis();
            try (PreparedStatement insertPayment = conn.prepareStatement(insertPaymentSql)) {
                insertPayment.setLong(1, refund.getOrderId());
                insertPayment.setString(2, paymentProvider);
                insertPayment.setDouble(3, refund.getRefundAmount());
                insertPayment.setString(4, refundRef);
                if (insertPayment.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignore) {
                }
            }
            ex.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignore) {
                }
            }
        }
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
