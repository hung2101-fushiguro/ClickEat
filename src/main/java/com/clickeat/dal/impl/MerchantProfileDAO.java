/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.MerchantProfile;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
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
        try {
            Object minOrder = rs.getObject("min_order_amount");
            if (minOrder != null) {
                p.setMinOrderAmount(((Number) minOrder).doubleValue());
            }
        } catch (Exception e) {
        }
        try {
            Object openValue = rs.getObject("is_open");
            if (openValue != null) {
                p.setIsOpen(rs.getBoolean("is_open"));
            }
        } catch (Exception e) {
        }
        try {
            p.setRejectionReason(rs.getString("rejection_reason"));
        } catch (Exception e) {
        }
        try {
            p.setAvgRating(rs.getDouble("avg_rating"));
        } catch (Exception e) {
        }
        try {
            p.setTotalRatings(rs.getInt("total_ratings"));
        } catch (Exception e) {
        }
        try {
            p.setFoodCount(rs.getInt("food_count"));
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

    public boolean updateOpenState(long userId, boolean isOpen) {
        String sql = "UPDATE MerchantProfiles SET is_open = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
        int updated = update(sql, isOpen, userId);
        if (updated > 0) {
            return true;
        }
        return false;
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

    public List<MerchantProfile> getFeaturedMerchants(int limit) {
        int safeLimit = Math.max(1, limit);
        String sql = "SELECT TOP " + safeLimit + " mp.*, "
                + "ISNULL((SELECT AVG(CAST(stars AS FLOAT)) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id), 0) as avg_rating, "
                + "(SELECT COUNT(*) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id) as total_ratings, "
                + "(SELECT COUNT(*) FROM FoodItems WHERE merchant_user_id = mp.user_id AND is_available = 1) as food_count "
                + "FROM MerchantProfiles mp "
                + "WHERE mp.status = 'APPROVED' "
                + "AND EXISTS (SELECT 1 FROM FoodItems fi WHERE fi.merchant_user_id = mp.user_id AND fi.is_available = 1) "
                + "ORDER BY avg_rating DESC, total_ratings DESC, mp.updated_at DESC";
        return query(sql);
    }

    public List<MerchantProfile> getAllApprovedWithStats() {
        String sql = "SELECT mp.*, "
                + "ISNULL((SELECT AVG(CAST(stars AS FLOAT)) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id), 0) as avg_rating, "
                + "(SELECT COUNT(*) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id) as total_ratings, "
                + "(SELECT COUNT(*) FROM FoodItems WHERE merchant_user_id = mp.user_id AND is_available = 1) as food_count "
                + "FROM MerchantProfiles mp WHERE mp.status = 'APPROVED' "
                + "ORDER BY avg_rating DESC";
        return query(sql);
    }

    public MerchantProfile findApprovedStoreById(int merchantId) {
        String sql = "SELECT mp.*, "
                + "ISNULL((SELECT AVG(CAST(stars AS FLOAT)) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id), 0) as avg_rating, "
                + "(SELECT COUNT(*) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id) as total_ratings "
                + "FROM MerchantProfiles mp "
                + "WHERE mp.user_id = ? AND mp.status = 'APPROVED'";
        return queryOne(sql, merchantId);
    }

    public List<String> getAllApprovedProvinces() {
        String sql = "SELECT DISTINCT province_name "
                + "FROM MerchantProfiles "
                + "WHERE status = 'APPROVED' AND province_name IS NOT NULL AND LTRIM(RTRIM(province_name)) <> '' "
                + "ORDER BY province_name";
        List<String> provinces = new ArrayList<>();
        List<Object[]> rows = queryRaw(sql);
        for (Object[] row : rows) {
            provinces.add(String.valueOf(row[0]));
        }
        return provinces;
    }

    public List<String> getDistrictsByProvince(String provinceName) {
        String sql = "SELECT DISTINCT district_name "
                + "FROM MerchantProfiles "
                + "WHERE status = 'APPROVED' AND province_name = ? "
                + "AND district_name IS NOT NULL AND LTRIM(RTRIM(district_name)) <> '' "
                + "ORDER BY district_name";
        List<String> districts = new ArrayList<>();
        List<Object[]> rows = queryRaw(sql, provinceName);
        for (Object[] row : rows) {
            districts.add(String.valueOf(row[0]));
        }
        return districts;
    }

    public List<MerchantProfile> searchApprovedStores(String keyword, String province, String district, String sort) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        sql.append("SELECT mp.*, ")
                .append("ISNULL((SELECT AVG(CAST(stars AS FLOAT)) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id), 0) as avg_rating, ")
                .append("(SELECT COUNT(*) FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = mp.user_id) as total_ratings ")
                .append("FROM MerchantProfiles mp WHERE mp.status = 'APPROVED' ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (mp.shop_name LIKE ? OR mp.shop_address_line LIKE ?) ");
            String likeKeyword = "%" + keyword.trim() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        if (province != null && !province.trim().isEmpty()) {
            sql.append("AND mp.province_name = ? ");
            params.add(province.trim());
        }

        if (district != null && !district.trim().isEmpty()) {
            sql.append("AND mp.district_name = ? ");
            params.add(district.trim());
        }

        if ("rating_desc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY avg_rating DESC, mp.shop_name ASC");
        } else if ("name_asc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY mp.shop_name ASC");
        } else if ("name_desc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY mp.shop_name DESC");
        } else {
            sql.append("ORDER BY mp.shop_name ASC");
        }

        return query(sql.toString(), params.toArray());
    }

    @Override
    public int insert(MerchantProfile m) {
        return 0; // Luồng Đăng ký Merchant sẽ lo phần này
    }

    @Override
    public boolean update(MerchantProfile m) {
        String fullSql = "UPDATE MerchantProfiles SET "
                + "shop_name = ?, shop_phone = ?, shop_address_line = ?, "
                + "shop_avatar = ?, business_hours = ?, shop_description = ?, notification_settings = ?, "
                + "min_order_amount = ?, is_open = ?, updated_at = SYSUTCDATETIME() "
                + "WHERE user_id = ?";

        int updated = update(fullSql,
                m.getShopName(),
                m.getShopPhone(),
                m.getShopAddressLine(),
                m.getShopAvatar(),
                m.getBusinessHours(),
                m.getShopDescription(),
                m.getNotificationSettings(),
                m.getMinOrderAmount(),
                m.getIsOpen(),
                m.getUserId()
        );

        if (updated > 0) {
            return true;
        }

        String fallbackSql = "UPDATE MerchantProfiles SET "
                + "shop_name = ?, shop_phone = ?, shop_address_line = ?, "
                + "shop_avatar = ?, business_hours = ?, shop_description = ?, notification_settings = ?, "
                + "updated_at = SYSUTCDATETIME() WHERE user_id = ?";

        return update(fallbackSql,
                m.getShopName(),
                m.getShopPhone(),
                m.getShopAddressLine(),
                m.getShopAvatar(),
                m.getBusinessHours(),
                m.getShopDescription(),
                m.getNotificationSettings(),
                m.getUserId()
        ) > 0;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
