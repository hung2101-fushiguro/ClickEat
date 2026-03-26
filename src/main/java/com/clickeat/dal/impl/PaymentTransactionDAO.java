package com.clickeat.dal.impl;

import com.clickeat.model.PaymentTransaction;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class PaymentTransactionDAO extends AbstractDAO<PaymentTransaction> {

    @Override
    protected PaymentTransaction mapRow(ResultSet rs) throws SQLException {
        PaymentTransaction p = new PaymentTransaction();
        p.setId(rs.getInt("id"));
        p.setOrderId(rs.getInt("order_id"));
        p.setProvider(rs.getString("provider"));
        p.setAmount(rs.getDouble("amount"));
        p.setStatus(rs.getString("status"));
        p.setProviderTnxRef(rs.getString("provider_txn_ref"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }

    public int insertVnpay(int orderId, double amount, String providerTxnRef, String vnpTxnRef, String requestPayload) {
        String sql = """
            INSERT INTO PaymentTransactions(
                order_id, provider, amount, status,
                provider_txn_ref, vnp_txn_ref, request_payload,
                created_at, updated_at
            )
            VALUES (?, 'VNPAY', ?, 'INITIATED', ?, ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME())
        """;
        return update(sql, orderId, amount, providerTxnRef, vnpTxnRef, requestPayload);
    }

    public PaymentTransaction findByOrderId(int orderId) {
        String sql = "SELECT TOP 1 * FROM PaymentTransactions WHERE order_id = ? ORDER BY id DESC";
        return queryOne(sql, orderId);
    }

    public boolean markSuccess(int orderId, String vnpTransactionNo, String vnpResponseCode, String vnpPayDate, String callbackPayload) {
        String sql = """
            UPDATE PaymentTransactions
            SET status = 'SUCCESS',
                vnp_transaction_no = ?,
                vnp_response_code = ?,
                vnp_pay_date = ?,
                callback_payload = ?,
                updated_at = SYSUTCDATETIME()
            WHERE order_id = ?
        """;
        return update(sql, vnpTransactionNo, vnpResponseCode, vnpPayDate, callbackPayload, orderId) > 0;
    }

    public boolean markFailed(int orderId, String vnpResponseCode, String callbackPayload) {
        String sql = """
            UPDATE PaymentTransactions
            SET status = 'FAILED',
                vnp_response_code = ?,
                callback_payload = ?,
                updated_at = SYSUTCDATETIME()
            WHERE order_id = ?
        """;
        return update(sql, vnpResponseCode, callbackPayload, orderId) > 0;
    }

    @Override
    public List<PaymentTransaction> findAll() {
        return null;
    }

    @Override
    public PaymentTransaction findById(int id) {
        return null;
    }

    @Override
    public int insert(PaymentTransaction t) {
        return 0;
    }

    @Override
    public boolean update(PaymentTransaction t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
