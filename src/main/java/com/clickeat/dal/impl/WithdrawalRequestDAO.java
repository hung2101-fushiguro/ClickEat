/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IWithdrawalRequestDAO;
import com.clickeat.model.WithdrawalRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class WithdrawalRequestDAO extends AbstractDAO<WithdrawalRequest> implements IWithdrawalRequestDAO {

    @Override
    protected WithdrawalRequest mapRow(ResultSet rs) throws SQLException {
        WithdrawalRequest req = new WithdrawalRequest();
        req.setId(rs.getLong("id"));
        req.setShipperUserId(rs.getLong("shipper_user_id"));
        req.setAmount(rs.getDouble("amount"));
        req.setBankName(rs.getString("bank_name"));
        req.setBankAccountNumber(rs.getString("bank_account_number"));
        req.setStatus(rs.getString("status"));
        req.setCreatedAt(rs.getTimestamp("created_at"));
        req.setProcessedAt(rs.getTimestamp("processed_at"));

        try { // Dữ liệu JOIN từ bảng Users
            req.setShipperName(rs.getString("shipper_name"));
            req.setShipperPhone(rs.getString("shipper_phone"));
        } catch (SQLException e) {
        }

        return req;
    }

    @Override
    public List<WithdrawalRequest> getPendingRequests() {
        String sql = "SELECT w.*, u.full_name AS shipper_name, u.phone AS shipper_phone "
                + "FROM WithdrawalRequests w "
                + "JOIN Users u ON w.shipper_user_id = u.id "
                + "WHERE w.status = 'PENDING' ORDER BY w.created_at ASC";
        return query(sql);
    }

    @Override
    public boolean approveRequest(long requestId, long shipperId, double amount) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Cập nhật lệnh rút thành APPROVED (chỉ khi còn PENDING)
            String sqlReq = "UPDATE WithdrawalRequests "
                    + "SET status = 'APPROVED', processed_at = SYSUTCDATETIME() "
                    + "WHERE id = ? AND shipper_user_id = ? AND status = 'PENDING'";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlReq)) {
                ps1.setLong(1, requestId);
                ps1.setLong(2, shipperId);
                if (ps1.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Trừ tiền thực tế trong ví Shipper với điều kiện đủ số dư
            String sqlWallet = "UPDATE ShipperWallets "
                    + "SET balance = balance - ?, updated_at = SYSUTCDATETIME() "
                    + "WHERE shipper_user_id = ? AND balance >= ?";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlWallet)) {
                ps2.setDouble(1, amount);
                ps2.setLong(2, shipperId);
                ps2.setDouble(3, amount);
                if (ps2.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException ex) {
            }
        }
    }

    @Override
    public boolean rejectRequest(long requestId) {
        String sql = "UPDATE WithdrawalRequests "
                + "SET status = 'REJECTED', processed_at = SYSUTCDATETIME() "
                + "WHERE id = ? AND status = 'PENDING'";
        return update(sql, requestId) > 0;
    }

    @Override
    public boolean createRequest(WithdrawalRequest req) {
        if (req == null || req.getAmount() <= 0) {
            return false;
        }

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String checkWalletSql = "SELECT balance FROM ShipperWallets WITH (UPDLOCK, ROWLOCK) WHERE shipper_user_id = ?";
            try (PreparedStatement checkWallet = conn.prepareStatement(checkWalletSql)) {
                checkWallet.setLong(1, req.getShipperUserId());
                try (ResultSet rs = checkWallet.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    if (rs.getDouble("balance") < req.getAmount()) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            String sql = "INSERT INTO WithdrawalRequests (shipper_user_id, amount, bank_name, bank_account_number, status) "
                    + "VALUES (?, ?, ?, ?, 'PENDING')";
            try (PreparedStatement insertReq = conn.prepareStatement(sql)) {
                insertReq.setLong(1, req.getShipperUserId());
                insertReq.setDouble(2, req.getAmount());
                insertReq.setString(3, req.getBankName());
                insertReq.setString(4, req.getBankAccountNumber());
                if (insertReq.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ex) {
                }
            }
        }
    }

    @Override
    public List<WithdrawalRequest> findAll() {
        return null;
    }

    @Override
    public WithdrawalRequest findById(int id) {
        return null;
    }

    @Override
    public int insert(WithdrawalRequest t) {
        return 0;
    }

    @Override
    public boolean update(WithdrawalRequest t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
