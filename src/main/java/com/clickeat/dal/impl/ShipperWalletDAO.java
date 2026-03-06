/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IShipperWalletDAO;
import com.clickeat.model.ShipperWallet;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ShipperWalletDAO extends AbstractDAO<ShipperWallet> implements IShipperWalletDAO {

    @Override
    protected ShipperWallet mapRow(ResultSet rs) throws SQLException {
        ShipperWallet w = new ShipperWallet();
        w.setShipperUserId(rs.getInt("shipper_user_id"));
        w.setBalance(rs.getDouble("balance"));
        w.setUpdatedAt(rs.getTimestamp("updated_at"));
        return w;
    }

    @Override
    public ShipperWallet getWalletByShipperId(int shipperId) {
        String sql = "SELECT * FROM ShipperWallets WHERE shipper_user_id = ?";
        return queryOne(sql, shipperId);
    }

    @Override
    public boolean addBalance(int shipperId, double amount) {
       
        String sql = "UPDATE ShipperWallets SET balance = balance + ?, updated_at = GETDATE() WHERE shipper_user_id = ?";
        return update(sql, amount, shipperId) > 0;
    }
    @Override
    public List<ShipperWallet> findAll() {
        return null;
    }

    @Override
    public int insert(ShipperWallet t) {
        return 0;
    }

    @Override
    public boolean update(ShipperWallet t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }

    @Override
    public ShipperWallet findById(int id) {
        return null;
    }
}
