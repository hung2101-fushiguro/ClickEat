/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.model.MerchantWallet;

public class MerchantWalletDAO extends AbstractDAO<MerchantWallet> {

    @Override
    protected MerchantWallet mapRow(ResultSet rs) throws SQLException {
        MerchantWallet w = new MerchantWallet();
        w.setMerchantUserId(rs.getInt("merchant_user_id"));
        w.setBalance(rs.getDouble("balance"));
        w.setUpdatedAt(rs.getTimestamp("updated_at"));
        return w;
    }

    public MerchantWallet getWalletByMerchantId(int merchantId) {
        if (!tableExists("MerchantWallets")) {
            MerchantWallet wallet = new MerchantWallet();
            wallet.setMerchantUserId(merchantId);
            wallet.setBalance(0d);
            return wallet;
        }

        ensureWalletExists(merchantId);
        String sql = "SELECT * FROM MerchantWallets WHERE merchant_user_id = ?";
        return queryOne(sql, merchantId);
    }

    public void ensureWalletExists(int merchantId) {
        if (!tableExists("MerchantWallets")) {
            return;
        }

        String sql = "INSERT INTO MerchantWallets(merchant_user_id, balance, updated_at) "
                + "SELECT ?, 0, SYSUTCDATETIME() "
                + "WHERE NOT EXISTS (SELECT 1 FROM MerchantWallets WHERE merchant_user_id = ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setInt(2, merchantId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    public boolean synchronizeBalanceWithDeliveredIncome(int merchantId) {
        if (!tableExists("MerchantWallets") || !tableExists("Orders")) {
            return false;
        }

        ensureWalletExists(merchantId);

        String approvedWithdrawSql = "SELECT ISNULL(SUM(amount),0) AS total FROM MerchantWithdrawals WHERE merchant_user_id = ? AND status = 'APPROVED'";

        double currentBalance = 0;
        MerchantWallet wallet = queryOne("SELECT * FROM MerchantWallets WHERE merchant_user_id = ?", merchantId);
        if (wallet != null) {
            currentBalance = wallet.getBalance();
        }

        double grossIncome = 0;
        boolean hasAppFeeColumn = columnExists("Orders", "app_fee");
        String deliveredSql = hasAppFeeColumn
                ? "SELECT subtotal_amount, discount_amount, delivery_fee, total_amount, ISNULL(app_fee,0) AS app_fee "
                + "FROM Orders WHERE merchant_user_id = ? AND order_status = 'DELIVERED'"
                : "SELECT subtotal_amount, discount_amount, delivery_fee, total_amount, 0 AS app_fee "
                + "FROM Orders WHERE merchant_user_id = ? AND order_status = 'DELIVERED'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(deliveredSql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double subtotal = rs.getDouble("subtotal_amount");
                    double discount = rs.getDouble("discount_amount");
                    double deliveryFee = rs.getDouble("delivery_fee");
                    double total = rs.getDouble("total_amount");
                    double appFee = rs.getDouble("app_fee");

                    double grossMerchantRevenue = total - deliveryFee;
                    if (grossMerchantRevenue < 0) {
                        grossMerchantRevenue = subtotal - discount;
                    }
                    if (grossMerchantRevenue < 0) {
                        grossMerchantRevenue = 0;
                    }

                    double merchantIncome = grossMerchantRevenue - Math.max(0, appFee);
                    if (merchantIncome < 0) {
                        merchantIncome = 0;
                    }
                    grossIncome += merchantIncome;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }

        double approvedWithdraw = 0;
        if (tableExists("MerchantWithdrawals")) {
            try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(approvedWithdrawSql)) {
                ps.setInt(1, merchantId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        approvedWithdraw = rs.getDouble("total");
                    }
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
                return false;
            }
        }

        double targetBalance = grossIncome - approvedWithdraw;
        if (targetBalance < 0) {
            targetBalance = 0;
        }

        if (Math.abs(targetBalance - currentBalance) > 0.0001d) {
            String sql = "UPDATE MerchantWallets SET balance = ?, updated_at = SYSUTCDATETIME() WHERE merchant_user_id = ?";
            return update(sql, targetBalance, merchantId) > 0;
        }
        return true;
    }

    public boolean deductBalance(int merchantId, double amount) {
        if (!tableExists("MerchantWallets")) {
            return false;
        }
        String sql = "UPDATE MerchantWallets SET balance = balance - ?, updated_at = SYSUTCDATETIME() WHERE merchant_user_id = ? AND balance >= ?";
        return update(sql, amount, merchantId, amount) > 0;
    }

    public boolean addBalance(int merchantId, double amount) {
        if (!tableExists("MerchantWallets")) {
            return false;
        }
        String sql = "UPDATE MerchantWallets SET balance = balance + ?, updated_at = SYSUTCDATETIME() WHERE merchant_user_id = ?";
        return update(sql, amount, merchantId) > 0;
    }

    @Override
    public List<MerchantWallet> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(MerchantWallet t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(MerchantWallet t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public MerchantWallet findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
