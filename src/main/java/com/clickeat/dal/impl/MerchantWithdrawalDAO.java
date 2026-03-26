/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.MerchantWithdrawal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

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
        return w;
    }

    public List<MerchantWithdrawal> getHistoryByMerchantId(int merchantId) {
        String sql = "SELECT * FROM MerchantWithdrawals WHERE merchant_user_id = ? ORDER BY created_at DESC";
        return query(sql, merchantId);
    }

    public int insertRequest(MerchantWithdrawal w) {
        String sql = "INSERT INTO MerchantWithdrawals (merchant_user_id, amount, bank_name, bank_account_number, status) VALUES (?, ?, ?, ?, 'PENDING')";
        return update(sql, w.getMerchantUserId(), w.getAmount(), w.getBankName(), w.getBankAccountNumber());
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
