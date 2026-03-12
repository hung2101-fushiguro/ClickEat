/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.MerchantProfile;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class MerchantProfileDAO extends AbstractDAO<MerchantProfile> {

    @Override
    protected MerchantProfile mapRow(ResultSet rs) throws SQLException {
        MerchantProfile p = new MerchantProfile();
        p.setUserId(rs.getLong("user_id"));
        p.setShopName(rs.getString("shop_name"));
        p.setShopPhone(rs.getString("shop_phone"));
        p.setShopAddressLine(rs.getString("shop_address_line"));
        p.setProvinceCode(rs.getString("province_code"));
        p.setProvinceName(rs.getString("province_name"));
        p.setDistrictCode(rs.getString("district_code"));
        p.setDistrictName(rs.getString("district_name"));
        p.setWardCode(rs.getString("ward_code"));
        p.setWardName(rs.getString("ward_name"));

        // Tránh lỗi null cho kiểu Double
        Object lat = rs.getObject("latitude");
        if (lat != null) {
            p.setLatitude(((Number) lat).doubleValue());
        }
        Object lng = rs.getObject("longitude");
        if (lng != null) {
            p.setLongitude(((Number) lng).doubleValue());
        }

        p.setStatus(rs.getString("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));

        // 3 Cột mới thêm (dùng try catch để lỡ DB chưa cập nhật thì không lỗi)
        try {
            p.setShopAvatar(rs.getString("shop_avatar"));
        } catch (Exception e) {
        }
        try {
            p.setBusinessHours(rs.getString("business_hours"));
        } catch (Exception e) {
        }
        try {
            p.setShopDescription(rs.getString("shop_description"));
        } catch (Exception e) {
        }
        try {
            p.setNotificationSettings(rs.getString("notification_settings"));
        } catch (Exception e) {
        }

        return p;
    }

    public MerchantProfile getByUserId(long userId) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, userId);
    }

    // Cập nhật thông tin quán cơ bản từ giao diện settings.jsp
    public boolean updateStoreInfo(long userId, String name, String phone, String address, String avatar) {
        String sql = "UPDATE MerchantProfiles SET shop_name = ?, shop_phone = ?, shop_address_line = ?, shop_avatar = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
        return update(sql, name, phone, address, avatar, userId) > 0;
    }

    // Cập nhật cấu hình Giờ mở cửa
    public boolean updateBusinessHours(long userId, String hoursJson) {
        String sql = "UPDATE MerchantProfiles SET business_hours = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
        return update(sql, hoursJson, userId) > 0;
    }

    public boolean updateNotificationSettings(long userId, String settingsJson) {
        String sql = "UPDATE MerchantProfiles SET notification_settings = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
        return update(sql, settingsJson, userId) > 0;
    }

    @Override
    public MerchantProfile findById(int id) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, id);
    }

    @Override
    public List<MerchantProfile> findAll() {
        return query("SELECT * FROM MerchantProfiles");
    }

    @Override
    public int insert(MerchantProfile m) {
        return 0; // Luồng Đăng ký Merchant sẽ lo phần này
    }

    @Override
    public boolean update(MerchantProfile m) {
        return false; // Sẽ code sau
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
