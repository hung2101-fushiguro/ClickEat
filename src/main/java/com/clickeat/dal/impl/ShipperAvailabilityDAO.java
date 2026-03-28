package com.clickeat.dal.impl;

import com.clickeat.model.ShipperAvailability;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ShipperAvailabilityDAO extends AbstractDAO<ShipperAvailability> {

    @Override
    protected ShipperAvailability mapRow(ResultSet rs) throws SQLException {
        ShipperAvailability sa = new ShipperAvailability();
        sa.setShipperUserId(rs.getInt("shipper_user_id"));
        sa.setOnline(rs.getBoolean("is_online"));
        sa.setCurrentStatus(rs.getString("current_status"));
        sa.setCurrentLatitude(rs.getDouble("current_latitude"));
        sa.setCurrentLongitude(rs.getDouble("current_longitude"));
        sa.setUpdatedAt(rs.getTimestamp("updated_at"));
        return sa;
    }

    public ShipperAvailability findByShipperUserId(int shipperUserId) {
        String sql = "SELECT * FROM ShipperAvailability WHERE shipper_user_id = ?";
        return queryOne(sql, shipperUserId);
    }

    @Override
    public List<ShipperAvailability> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(ShipperAvailability t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(ShipperAvailability t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public ShipperAvailability findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}