package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IShipperDAO;
import com.clickeat.model.ShipperProfile;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ShipperDAO extends AbstractDAO<ShipperProfile> implements IShipperDAO {

    @Override
    protected ShipperProfile mapRow(ResultSet rs) throws SQLException {
        ShipperProfile sp = new ShipperProfile();
        sp.setUserId(rs.getInt("user_id"));
        sp.setVehicleType(rs.getString("vehicle_type"));
        sp.setStatus(rs.getString("status"));
        sp.setVehicleName(rs.getString("vehicle_name"));
        sp.setLicensePlate(rs.getString("license_plate"));
        sp.setCreatedAt(rs.getTimestamp("created_at"));
        return sp;
    }

    @Override
    public boolean registerShipper(String fullName, String phone, String password, String vehicleType, String vehicleName, String licensePlate) {

        String sqlUser = "INSERT INTO Users (full_name, phone, password_hash, role, status, created_at, updated_at) VALUES (?, ?, ?, 'SHIPPER', 'ACTIVE', GETDATE(), GETDATE())";

        int newUserId = update(sqlUser, fullName, phone, password);

        if (newUserId > 0) {
            //Lưu thông tin xe (ShipperProfiles)
            String sqlProfile = "INSERT INTO ShipperProfiles (user_id, vehicle_type, vehicle_name, license_plate, status, created_at) VALUES (?, ?, ?, ?, 'ACTIVE', GETDATE())";
            update(sqlProfile, newUserId, vehicleType, vehicleName, licensePlate);

            //Cấp Ví tiền (0đ)
            String sqlWallet = "INSERT INTO ShipperWallets (shipper_user_id, balance, updated_at) VALUES (?, 0, GETDATE())";
            update(sqlWallet, newUserId);

            //Khởi tạo Trạng thái mặc định (Offline)
            String sqlAvail = "INSERT INTO ShipperAvailability (shipper_user_id, is_online, current_status, updated_at) VALUES (?, 0, 'AVAILABLE', GETDATE())";
            update(sqlAvail, newUserId);

            return true;
        }
        return false;
    }

    @Override
    public List<ShipperProfile> findAll() {
        String sql = "SELECT * FROM ShipperProfiles";
        return query(sql);
    }

    @Override
    public int insert(ShipperProfile sp) {
        return 0;
    }

    @Override
    public boolean update(ShipperProfile sp) {
        String sql = "UPDATE ShipperProfiles SET vehicle_type = ?, vehicle_name = ?, license_plate = ?, status = ? WHERE user_id = ?";
        return update(sql, sp.getVehicleType(), sp.getVehicleName(), sp.getLicensePlate(), sp.getStatus(), sp.getUserId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        String sql = "UPDATE ShipperProfiles SET status = 'SUSPENDED' WHERE user_id = ?";
        return update(sql, id) > 0;
    }

    @Override
    public ShipperProfile findById(int id) {
        String sql = "SELECT * FROM ShipperProfiles WHERE user_id = ?";
        return queryOne(sql, id);
    }

    @Override
    public boolean updateOnlineStatus(int shipperId, boolean isOnline) {
        String sql = "UPDATE ShipperAvailability SET is_online = ?, updated_at = GETDATE() WHERE shipper_user_id = ?";
        return update(sql, isOnline ? 1 : 0, shipperId) > 0;
    }

    @Override
    public boolean checkIsOnline(int shipperId) {
        String sql = "SELECT is_online FROM ShipperAvailability WHERE shipper_user_id = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("is_online");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}
