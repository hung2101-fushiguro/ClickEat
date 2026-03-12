package com.clickeat.dal.impl;

import com.clickeat.model.MerchantProfile;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class MerchantDAO extends AbstractDAO<MerchantProfile> {

    @Override
    protected MerchantProfile mapRow(ResultSet rs) throws SQLException {
        MerchantProfile merchant = new MerchantProfile();
        merchant.setUserId(rs.getInt("user_id"));
        merchant.setShopName(rs.getString("shop_name"));
        merchant.setShopPhone(rs.getString("shop_phone"));
        merchant.setShopAddressLine(rs.getString("shop_address_line"));
        merchant.setProvinceCode(rs.getString("province_code"));
        merchant.setProvinceName(rs.getString("province_name"));
        merchant.setDistrictCode(rs.getString("district_code"));
        merchant.setDistrictName(rs.getString("district_name"));
        merchant.setWardCode(rs.getString("ward_code"));
        merchant.setWardName(rs.getString("ward_name"));
        merchant.setLatitude(rs.getDouble("latitude"));
        merchant.setLongitude(rs.getDouble("longitude"));
        merchant.setStatus(rs.getString("status"));
        merchant.setCreatedAt(rs.getTimestamp("created_at"));
        merchant.setUpdatedAt(rs.getTimestamp("updated_at"));
        return merchant;
    }

    public double[] getTodayStats(int merchantId) {
        double[] stats = new double[2];

        String sql = "SELECT SUM(total_amount) as Revenue, COUNT(id) as TotalOrders "
                + "FROM Orders "
                + "WHERE merchant_user_id = ? AND order_status = 'DELIVERED' "
                + "AND CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, merchantId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats[0] = rs.getDouble("Revenue");
                    stats[1] = rs.getDouble("TotalOrders");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return stats;
    }

    public MerchantProfile getMerchantByUserId(int userId) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, userId);
    }

    @Override
    public List<MerchantProfile> findAll() {
        String sql = "SELECT * FROM MerchantProfiles";
        return query(sql);
    }

    @Override
    public int insert(MerchantProfile merchant) {
        String sql = "INSERT INTO MerchantProfiles (user_id, shop_name, shop_phone, shop_address_line, province_code, province_name, district_code, district_name, ward_code, ward_name, latitude, longitude, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return update(sql,
                merchant.getUserId(),
                merchant.getShopName(),
                merchant.getShopPhone(),
                merchant.getShopAddressLine(),
                merchant.getProvinceCode(),
                merchant.getProvinceName(),
                merchant.getDistrictCode(),
                merchant.getDistrictName(),
                merchant.getWardCode(),
                merchant.getWardName(),
                merchant.getLatitude(),
                merchant.getLongitude(),
                merchant.getStatus()
        );
    }

    @Override
    public boolean update(MerchantProfile merchant) {
        String sql = "UPDATE MerchantProfiles SET shop_name = ?, shop_phone = ?, shop_address_line = ?, status = ?, updated_at = GETDATE() WHERE user_id = ?";
        int rows = update(sql,
                merchant.getShopName(),
                merchant.getShopPhone(),
                merchant.getShopAddressLine(),
                merchant.getStatus(),
                merchant.getUserId()
        );
        return rows > 0;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM MerchantProfiles WHERE user_id = ?";
        return update(sql, id) > 0;
    }

    @Override
    public MerchantProfile findById(int id) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, id);
    }
}
