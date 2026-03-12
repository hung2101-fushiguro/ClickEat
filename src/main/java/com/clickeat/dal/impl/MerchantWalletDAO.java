/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.MerchantWallet;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

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
        String sql = "SELECT * FROM MerchantWallets WHERE merchant_user_id = ?";
        return queryOne(sql, merchantId);
    }

    public boolean deductBalance(int merchantId, double amount) {
        String sql = "UPDATE MerchantWallets SET balance = balance - ?, updated_at = SYSUTCDATETIME() WHERE merchant_user_id = ? AND balance >= ?";
        return update(sql, amount, merchantId, amount) > 0;
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
