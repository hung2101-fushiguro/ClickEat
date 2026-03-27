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
            conn.setAutoCommit(false);

            // 1. Cập nhật lệnh rút thành APPROVED
            String sqlReq = "UPDATE WithdrawalRequests SET status = 'APPROVED', processed_at = GETDATE() WHERE id = ?";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlReq)) {
                ps1.setLong(1, requestId);
                if (ps1.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Trừ tiền thực tế trong ví Shipper — CHỈ khi số dư >= amount
            String sqlWallet = "UPDATE ShipperWallets SET balance = balance - ?, updated_at = GETDATE() "
                    + "WHERE shipper_user_id = ? AND balance >= ?";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlWallet)) {
                ps2.setDouble(1, amount);
                ps2.setLong(2, shipperId);
                ps2.setDouble(3, amount);
                if (ps2.executeUpdate() <= 0) {
                    // Số dư không đủ → rollback, không duyệt
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException ex) {}
        }
    }

    @Override
    public boolean rejectRequest(long requestId) {
        String sql = "UPDATE WithdrawalRequests SET status = 'REJECTED', processed_at = GETDATE() WHERE id = ?";
        return update(sql, requestId) > 0;
    }

    @Override
    public boolean createRequest(WithdrawalRequest req) {
        // Kiểm tra số dư thực tế có đủ không (số dư hiện tại - tổng các lệnh đang PENDING)
        // Shipper có số dư âm (đang nợ tiền COD) thì không được rút
        String checkSql = "SELECT "
                + "  ISNULL((SELECT balance FROM ShipperWallets WHERE shipper_user_id = ?), 0) "
                + "  - ISNULL((SELECT SUM(amount) FROM WithdrawalRequests WHERE shipper_user_id = ? AND status = 'PENDING'), 0) "
                + "  AS available_balance";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setLong(1, req.getShipperUserId());
            ps.setLong(2, req.getShipperUserId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double available = rs.getDouble("available_balance");
                    if (available < req.getAmount()) {
                        return false; // Số dư không đủ hoặc đang nợ tiền thu hộ COD
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        String sql = "INSERT INTO WithdrawalRequests (shipper_user_id, amount, bank_name, bank_account_number, status) VALUES (?, ?, ?, ?, 'PENDING')";
        return update(sql, req.getShipperUserId(), req.getAmount(), req.getBankName(), req.getBankAccountNumber()) > 0;
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
