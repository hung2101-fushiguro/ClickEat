/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.model.MerchantWithdrawal;

public class MerchantWithdrawalDAO extends AbstractDAO<MerchantWithdrawal> {

    @Override
    protected MerchantWithdrawal mapRow(ResultSet rs) throws SQLException {
        MerchantWithdrawal w = new MerchantWithdrawal();
        w.setId(rs.getLong("id"));
        w.setMerchantUserId(rs.getInt("merchant_user_id"));
        w.setAmount(rs.getDouble("amount"));
        w.setBankName(rs.getString("bank_name"));
        w.setBankAccountNumber(rs.getString("bank_account_number"));
        w.setStatus(rs.getString("status"));
        w.setCreatedAt(rs.getTimestamp("created_at"));
        w.setProcessedAt(rs.getTimestamp("processed_at"));
        try {
            w.setMerchantName(rs.getString("merchant_name"));
            w.setMerchantPhone(rs.getString("merchant_phone"));
            w.setShopName(rs.getString("shop_name"));
        } catch (SQLException ex) {
        }
        return w;
    }

    public List<MerchantWithdrawal> getHistoryByMerchantId(int merchantId) {
        if (!tableExists("MerchantWithdrawals")) {
            return new ArrayList<>();
        }

        String sql = "SELECT * FROM MerchantWithdrawals WHERE merchant_user_id = ? ORDER BY created_at DESC";
        return query(sql, merchantId);
    }

    public int insertRequest(MerchantWithdrawal w) {
        if (!tableExists("MerchantWithdrawals")) {
            return 0;
        }

        String sql = "INSERT INTO MerchantWithdrawals (merchant_user_id, amount, bank_name, bank_account_number, status) "
                + "VALUES (?, ?, ?, ?, 'PENDING')";
        return update(sql, w.getMerchantUserId(), w.getAmount(), w.getBankName(), w.getBankAccountNumber());
    }

    public boolean createRequestWithBalanceCheck(int merchantUserId, double amount, String bankName, String bankAccountNumber) {
        if (!tableExists("MerchantWithdrawals") || !tableExists("MerchantWallets")) {
            return false;
        }

        if (amount <= 0) {
            return false;
        }

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String checkWalletSql = "SELECT balance FROM MerchantWallets WITH (UPDLOCK, ROWLOCK) WHERE merchant_user_id = ?";
            double walletBalance;
            try (PreparedStatement checkWallet = conn.prepareStatement(checkWalletSql)) {
                checkWallet.setInt(1, merchantUserId);
                try (ResultSet rs = checkWallet.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    walletBalance = rs.getDouble("balance");
                }
            }

            double pendingAmount = 0;
            String pendingSql = "SELECT ISNULL(SUM(amount), 0) AS pending_total FROM MerchantWithdrawals WITH (UPDLOCK, ROWLOCK) WHERE merchant_user_id = ? AND status = 'PENDING'";
            try (PreparedStatement psPending = conn.prepareStatement(pendingSql)) {
                psPending.setInt(1, merchantUserId);
                try (ResultSet rs = psPending.executeQuery()) {
                    if (rs.next()) {
                        pendingAmount = rs.getDouble("pending_total");
                    }
                }
            }

            double availableForNewRequest = walletBalance - pendingAmount;
            if (availableForNewRequest < amount) {
                conn.rollback();
                return false;
            }

            String insertSql = "INSERT INTO MerchantWithdrawals (merchant_user_id, amount, bank_name, bank_account_number, status) "
                    + "VALUES (?, ?, ?, ?, 'PENDING')";
            try (PreparedStatement insertReq = conn.prepareStatement(insertSql)) {
                insertReq.setInt(1, merchantUserId);
                insertReq.setDouble(2, amount);
                insertReq.setString(3, bankName);
                insertReq.setString(4, bankAccountNumber);
                if (insertReq.executeUpdate() <= 0) {
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
                } catch (SQLException rollbackEx) {
                }
            }
            ex.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignoreEx) {
                }
            }
        }
    }

    public List<MerchantWithdrawal> getPendingRequests() {
        if (!tableExists("MerchantWithdrawals")) {
            return new ArrayList<>();
        }

        String sql = "SELECT w.*, u.full_name AS merchant_name, u.phone AS merchant_phone, mp.shop_name "
                + "FROM MerchantWithdrawals w "
                + "JOIN Users u ON w.merchant_user_id = u.id "
                + "LEFT JOIN MerchantProfiles mp ON w.merchant_user_id = mp.user_id "
                + "WHERE w.status = 'PENDING' "
                + "ORDER BY w.created_at ASC";
        return query(sql);
    }

    public boolean approveRequest(long requestId, int merchantUserId, double amount) {
        if (!tableExists("MerchantWithdrawals") || !tableExists("MerchantWallets")) {
            return false;
        }

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String approveSql = "UPDATE MerchantWithdrawals "
                    + "SET status = 'APPROVED', processed_at = SYSUTCDATETIME() "
                    + "WHERE id = ? AND merchant_user_id = ? AND status = 'PENDING'";
            try (PreparedStatement approveStmt = conn.prepareStatement(approveSql)) {
                approveStmt.setLong(1, requestId);
                approveStmt.setInt(2, merchantUserId);
                if (approveStmt.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            String deductSql = "UPDATE MerchantWallets "
                    + "SET balance = balance - ?, updated_at = SYSUTCDATETIME() "
                    + "WHERE merchant_user_id = ? AND balance >= ?";
            try (PreparedStatement deductStmt = conn.prepareStatement(deductSql)) {
                deductStmt.setDouble(1, amount);
                deductStmt.setInt(2, merchantUserId);
                deductStmt.setDouble(3, amount);
                if (deductStmt.executeUpdate() <= 0) {
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
                } catch (SQLException rollbackEx) {
                }
            }
            ex.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignoreEx) {
                }
            }
        }
    }

    public boolean rejectRequest(long requestId) {
        if (!tableExists("MerchantWithdrawals")) {
            return false;
        }

        String sql = "UPDATE MerchantWithdrawals "
                + "SET status = 'REJECTED', processed_at = SYSUTCDATETIME() "
                + "WHERE id = ? AND status = 'PENDING'";
        return update(sql, requestId) > 0;
    }

    @Override
    public List<MerchantWithdrawal> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(MerchantWithdrawal t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(MerchantWithdrawal t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public MerchantWithdrawal findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
