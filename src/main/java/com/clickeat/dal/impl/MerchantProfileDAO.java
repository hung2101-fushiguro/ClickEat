package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.model.MerchantProfile;

public class MerchantProfileDAO extends AbstractDAO<MerchantProfile> {

    @Override
    protected MerchantProfile mapRow(ResultSet rs) throws SQLException {
        MerchantProfile m = new MerchantProfile();

        m.setUserId(rs.getInt("user_id"));
        m.setShopName(rs.getString("shop_name"));
        m.setShopPhone(rs.getString("shop_phone"));
        m.setShopAddressLine(rs.getString("shop_address_line"));
        m.setProvinceCode(rs.getString("province_code"));
        m.setProvinceName(rs.getString("province_name"));
        m.setDistrictCode(rs.getString("district_code"));
        m.setDistrictName(rs.getString("district_name"));
        m.setWardCode(rs.getString("ward_code"));
        m.setWardName(rs.getString("ward_name"));

        try {
            m.setLatitude(rs.getDouble("latitude"));
        } catch (Exception e) {
            m.setLatitude(0.0);
        }

        try {
            m.setLongitude(rs.getDouble("longitude"));
        } catch (Exception e) {
            m.setLongitude(0.0);
        }

        try {
            m.setIsDefault(rs.getBoolean("is_default"));
        } catch (Exception e) {
            m.setIsDefault(null);
        }

        try {
            m.setNote(rs.getString("note"));
        } catch (Exception e) {
            m.setNote(null);
        }

        try {
            m.setStatus(rs.getString("status"));
        } catch (Exception e) {
            m.setStatus(null);
        }

        try {
            m.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (Exception e) {
            m.setCreatedAt(null);
        }

        try {
            m.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (Exception e) {
            m.setUpdatedAt(null);
        }

        try {
            m.setShopAvatar(rs.getString("shop_avatar"));
        } catch (Exception e) {
            m.setShopAvatar(null);
        }

        try {
            m.setBusinessHours(rs.getString("business_hours"));
        } catch (Exception e) {
            m.setBusinessHours(null);
        }

        try {
            m.setShopDescription(rs.getString("shop_description"));
        } catch (Exception e) {
            m.setShopDescription(null);
        }

        try {
            m.setNotificationSettings(rs.getString("notification_settings"));
        } catch (Exception e) {
            m.setNotificationSettings(null);
        }

        try {
            double minOrder = rs.getDouble("min_order_amount");
            m.setMinOrderAmount(rs.wasNull() ? null : minOrder);
        } catch (Exception e) {
            m.setMinOrderAmount(null);
        }

        try {
            m.setIsOpen(rs.getBoolean("is_open"));
            if (rs.wasNull()) {
                m.setIsOpen(null);
            }
        } catch (Exception e) {
            m.setIsOpen(null);
        }

        try {
            m.setRejectionReason(rs.getString("rejection_reason"));
        } catch (Exception e) {
            m.setRejectionReason(null);
        }

        try {
            m.setSourcePlatform(rs.getString("source_platform"));
        } catch (Exception e) {
            m.setSourcePlatform(null);
        }

        // ảnh đọc từ DB
        try {
            m.setImageUrl(normalizeImageUrl(rs.getString("image_url")));
        } catch (Exception e) {
            m.setImageUrl(null);
        }

        // nếu sau này DB có cover_image_url thì sẽ đọc được, chưa có thì bỏ qua
        try {
            m.setCoverImageUrl(rs.getString("cover_image_url"));
        } catch (Exception e) {
            m.setCoverImageUrl(null);
        }

        // field mở rộng phục vụ giao diện store/store-detail
        try {
            m.setRating(rs.getDouble("rating"));
        } catch (Exception e) {
            m.setRating(4.8);
        }

        try {
            m.setReviewCount(rs.getInt("review_count"));
        } catch (Exception e) {
            m.setReviewCount(0);
        }

        try {
            m.setItemCount(rs.getInt("item_count"));
        } catch (Exception e) {
            m.setItemCount(0);
        }

        try {
            m.setMinPrice(rs.getDouble("min_price"));
        } catch (Exception e) {
            m.setMinPrice(0);
        }

        try {
            m.setCategoryName(rs.getString("category_name"));
        } catch (Exception e) {
            m.setCategoryName(null);
        }

        try {
            m.setVoucherTitle(rs.getString("voucher_title"));
        } catch (Exception e) {
            m.setVoucherTitle(null);
        }

        // chỉ fallback ảnh khi DB chưa có
        try {
            if (m.getImageUrl() == null || m.getImageUrl().trim().isEmpty()) {
                m.setImageUrl(resolveStoreImage(m.getShopName(), m.getDistrictName()));
            }
        } catch (Exception e) {
            // bỏ qua
        }

        try {
            if (m.getCoverImageUrl() == null || m.getCoverImageUrl().trim().isEmpty()) {
                m.setCoverImageUrl(resolveStoreCover(m.getShopName(), m.getDistrictName()));
            }
        } catch (Exception e) {
            // bỏ qua
        }

        try {
            m.setDeliveryTime(resolveDeliveryTime(m.getDistrictName()));
        } catch (Exception e) {
            m.setDeliveryTime("15-25p");
        }

        try {
            m.setDistance(resolveDistance(m.getDistrictName()));
        } catch (Exception e) {
            m.setDistance("1.8km");
        }

        if (m.getIsOpen() == null) {
            m.setOpen("APPROVED".equalsIgnoreCase(m.getStatus()));
        }

        return m;
    }

    private String normalizeImageUrl(String rawImage) {
        if (rawImage == null) {
            return null;
        }

        String normalized = rawImage.trim();
        if (normalized.isEmpty()) {
            return normalized;
        }

        if (normalized.startsWith("http://")
                || normalized.startsWith("https://")
                || normalized.startsWith("data:")
                || normalized.startsWith("/")) {
            return normalized;
        }
        return "/assets/images/" + normalized;
    }

    // =========================
    // CRUD cơ bản
    // =========================
    @Override
    public List<MerchantProfile> findAll() {
        String sql = "SELECT * FROM MerchantProfiles ORDER BY created_at DESC, user_id DESC";
        return query(sql);
    }

    @Override
    public MerchantProfile findById(int id) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, id);
    }

    @Override
    public int insert(MerchantProfile m) {
        if (columnExists("MerchantProfiles", "source_platform")) {
            String sql = """
                INSERT INTO MerchantProfiles
                (user_id, shop_name, shop_phone, shop_address_line,
                 province_code, province_name, district_code, district_name,
                 ward_code, ward_name, latitude, longitude, note, status,
                 shop_avatar, business_hours, shop_description, notification_settings, source_platform)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

            return update(sql,
                    m.getUserId(),
                    m.getShopName(),
                    m.getShopPhone(),
                    m.getShopAddressLine(),
                    m.getProvinceCode(),
                    m.getProvinceName(),
                    m.getDistrictCode(),
                    m.getDistrictName(),
                    m.getWardCode(),
                    m.getWardName(),
                    m.getLatitude(),
                    m.getLongitude(),
                    m.getNote(),
                    m.getStatus(),
                    m.getShopAvatar(),
                    m.getBusinessHours(),
                    m.getShopDescription(),
                    m.getNotificationSettings(),
                    m.getSourcePlatform());
        }

        String sql = """
            INSERT INTO MerchantProfiles
            (user_id, shop_name, shop_phone, shop_address_line,
             province_code, province_name, district_code, district_name,
             ward_code, ward_name, latitude, longitude, note, status,
             shop_avatar, business_hours, shop_description, notification_settings)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        return update(sql,
                m.getUserId(),
                m.getShopName(),
                m.getShopPhone(),
                m.getShopAddressLine(),
                m.getProvinceCode(),
                m.getProvinceName(),
                m.getDistrictCode(),
                m.getDistrictName(),
                m.getWardCode(),
                m.getWardName(),
                m.getLatitude(),
                m.getLongitude(),
                m.getNote(),
                m.getStatus(),
                m.getShopAvatar(),
                m.getBusinessHours(),
                m.getShopDescription(),
                m.getNotificationSettings());
    }

    @Override
    public boolean update(MerchantProfile m) {
        if (columnExists("MerchantProfiles", "source_platform")) {
            String sql = """
                UPDATE MerchantProfiles
                SET shop_name = ?,
                    shop_phone = ?,
                    shop_address_line = ?,
                    province_code = ?,
                    province_name = ?,
                    district_code = ?,
                    district_name = ?,
                    ward_code = ?,
                    ward_name = ?,
                    latitude = ?,
                    longitude = ?,
                    note = ?,
                    status = ?,
                    shop_avatar = ?,
                    business_hours = ?,
                    shop_description = ?,
                    notification_settings = ?,
                    source_platform = ?
                WHERE user_id = ?
            """;

            return update(sql,
                    m.getShopName(),
                    m.getShopPhone(),
                    m.getShopAddressLine(),
                    m.getProvinceCode(),
                    m.getProvinceName(),
                    m.getDistrictCode(),
                    m.getDistrictName(),
                    m.getWardCode(),
                    m.getWardName(),
                    m.getLatitude(),
                    m.getLongitude(),
                    m.getNote(),
                    m.getStatus(),
                    m.getShopAvatar(),
                    m.getBusinessHours(),
                    m.getShopDescription(),
                    m.getNotificationSettings(),
                    m.getSourcePlatform(),
                    m.getUserId()) > 0;
        }

        String sql = """
            UPDATE MerchantProfiles
            SET shop_name = ?,
                shop_phone = ?,
                shop_address_line = ?,
                province_code = ?,
                province_name = ?,
                district_code = ?,
                district_name = ?,
                ward_code = ?,
                ward_name = ?,
                latitude = ?,
                longitude = ?,
                note = ?,
                status = ?,
                shop_avatar = ?,
                business_hours = ?,
                shop_description = ?,
                notification_settings = ?
            WHERE user_id = ?
        """;

        return update(sql,
                m.getShopName(),
                m.getShopPhone(),
                m.getShopAddressLine(),
                m.getProvinceCode(),
                m.getProvinceName(),
                m.getDistrictCode(),
                m.getDistrictName(),
                m.getWardCode(),
                m.getWardName(),
                m.getLatitude(),
                m.getLongitude(),
                m.getNote(),
                m.getStatus(),
                m.getShopAvatar(),
                m.getBusinessHours(),
                m.getShopDescription(),
                m.getNotificationSettings(),
                m.getUserId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        // soft delete hợp lý hơn xóa cứng
        String sql = "UPDATE MerchantProfiles SET status = 'INACTIVE' WHERE user_id = ?";
        return update(sql, id) > 0;
    }

    // =========================
    // Hàm phục vụ trang store
    // =========================
    public List<MerchantProfile> searchApprovedStores(String keyword, String province, String district, String sortBy) {
        StringBuilder sql = new StringBuilder("""
            SELECT mp.*,
                   ISNULL(rt.avg_rating, 4.8) AS rating,
                   ISNULL(rt.review_count, 0) AS review_count,
                   ISNULL(fi.item_count, 0) AS item_count,
                   ISNULL(fi.min_price, 0) AS min_price,
                   fi.category_name,
                   vc.voucher_title
            FROM MerchantProfiles mp
            OUTER APPLY (
                SELECT AVG(CAST(r.stars AS FLOAT)) AS avg_rating,
                       COUNT(*) AS review_count
                FROM Ratings r
                WHERE r.target_type = 'MERCHANT'
                  AND r.target_user_id = mp.user_id
            ) rt
            OUTER APPLY (
                SELECT COUNT(*) AS item_count,
                       MIN(f.price) AS min_price,
                       MIN(c.name) AS category_name
                FROM FoodItems f
                INNER JOIN Categories c ON c.id = f.category_id
                WHERE f.merchant_user_id = mp.user_id
                  AND f.is_available = 1
            ) fi
            OUTER APPLY (
                SELECT TOP 1 v.title AS voucher_title
                FROM Vouchers v
                WHERE v.merchant_user_id = mp.user_id
                  AND v.is_published = 1
                  AND v.status = 'ACTIVE'
                ORDER BY v.id DESC
            ) vc
            WHERE mp.status = 'APPROVED'
        """);

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("""
                 AND (
                    mp.shop_name LIKE ?
                    OR mp.shop_address_line LIKE ?
                    OR mp.district_name LIKE ?
                 )
            """);
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (province != null && !province.trim().isEmpty()) {
            sql.append(" AND mp.province_name = ? ");
            params.add(province.trim());
        }

        if (district != null && !district.trim().isEmpty()) {
            sql.append(" AND mp.district_name = ? ");
            params.add(district.trim());
        }

        if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY rating DESC, mp.shop_name ASC ");
        } else if ("price".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY min_price ASC, mp.shop_name ASC ");
        } else {
            sql.append(" ORDER BY mp.created_at DESC, mp.user_id DESC ");
        }

        return query(sql.toString(), params.toArray());
    }

    public MerchantProfile findApprovedStoreById(int merchantUserId) {
        String sql = """
            SELECT mp.*,
                   ISNULL(rt.avg_rating, 4.8) AS rating,
                   ISNULL(rt.review_count, 0) AS review_count,
                   ISNULL(fi.item_count, 0) AS item_count,
                   ISNULL(fi.min_price, 0) AS min_price,
                   fi.category_name,
                   vc.voucher_title
            FROM MerchantProfiles mp
            OUTER APPLY (
                SELECT AVG(CAST(r.stars AS FLOAT)) AS avg_rating,
                       COUNT(*) AS review_count
                FROM Ratings r
                WHERE r.target_type = 'MERCHANT'
                  AND r.target_user_id = mp.user_id
            ) rt
            OUTER APPLY (
                SELECT COUNT(*) AS item_count,
                       MIN(f.price) AS min_price,
                       MIN(c.name) AS category_name
                FROM FoodItems f
                INNER JOIN Categories c ON c.id = f.category_id
                WHERE f.merchant_user_id = mp.user_id
                  AND f.is_available = 1
            ) fi
            OUTER APPLY (
                SELECT TOP 1 v.title AS voucher_title
                FROM Vouchers v
                WHERE v.merchant_user_id = mp.user_id
                  AND v.is_published = 1
                  AND v.status = 'ACTIVE'
                ORDER BY v.id DESC
            ) vc
            WHERE mp.user_id = ?
              AND mp.status = 'APPROVED'
        """;

        return queryOne(sql, merchantUserId);
    }

    public List<String> getAllApprovedDistricts() {
        String sql = """
            SELECT DISTINCT district_name
            FROM MerchantProfiles
            WHERE status = 'APPROVED'
              AND district_name IS NOT NULL
              AND LTRIM(RTRIM(district_name)) <> ''
            ORDER BY district_name
        """;
        return queryString(sql);
    }

    // =========================
    // Helper query 1 cột string
    // =========================
    private List<String> queryString(String sql, Object... params) {
        List<String> list = new ArrayList<>();

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            if (params != null) {
                for (int i = 0; i < params.length; i++) {
                    ps.setObject(i + 1, params[i]);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString(1));
                }
            }

        } catch (Exception e) {
            System.out.println("===== QUERY STRING ERROR =====");
            System.out.println("SQL: " + sql);
            System.out.println("PARAMS: " + java.util.Arrays.toString(params));
            e.printStackTrace();
            System.out.println("==============================");
        }

        return list;
    }

    // =========================
    // Helper render UI
    // =========================
    private String resolveStoreImage(String shopName, String districtName) {
        String key = ((shopName == null ? "" : shopName) + " "
                + (districtName == null ? "" : districtName)).toLowerCase();

        if (key.contains("burger")) {
            return "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1200&auto=format&fit=crop";
        }
        if (key.contains("pizza")) {
            return "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=1200&auto=format&fit=crop";
        }
        if (key.contains("trà") || key.contains("cafe") || key.contains("coffee")) {
            return "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=1200&auto=format&fit=crop";
        }
        return "https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=1200&auto=format&fit=crop";
    }

    private String resolveStoreCover(String shopName, String districtName) {
        String key = ((shopName == null ? "" : shopName) + " "
                + (districtName == null ? "" : districtName)).toLowerCase();

        if (key.contains("burger")) {
            return "https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=1600&auto=format&fit=crop";
        }
        return "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1600&auto=format&fit=crop";
    }

    private String resolveDeliveryTime(String districtName) {
        if (districtName == null) {
            return "15-25p";
        }
        String key = districtName.toLowerCase();
        if (key.contains("quận 1")) {
            return "15-20p";
        }
        if (key.contains("quận 3")) {
            return "15-25p";
        }
        return "20-30p";
    }

    private String resolveDistance(String districtName) {
        if (districtName == null) {
            return "1.8km";
        }
        String key = districtName.toLowerCase();
        if (key.contains("quận 1")) {
            return "1.2km";
        }
        if (key.contains("quận 3")) {
            return "1.6km";
        }
        return "2.1km";
    }

    public List<MerchantProfile> getFeaturedMerchants(int limit) {
        String sql = """
        SELECT TOP (?)
               mp.*,
               COALESCE(rt.avg_rating, 4.5) AS rating,
               (
                   SELECT TOP 1 c.name
                   FROM Categories c
                   WHERE c.merchant_user_id = mp.user_id
                     AND c.is_active = 1
                   ORDER BY c.sort_order ASC, c.id ASC
               ) AS category_name,
               (
                   SELECT TOP 1 v.title
                   FROM Vouchers v
                   WHERE v.merchant_user_id = mp.user_id
                     AND v.is_published = 1
                     AND v.status = N'ACTIVE'
                     AND GETUTCDATE() BETWEEN v.start_at AND v.end_at
                   ORDER BY v.id DESC
               ) AS voucher_title
        FROM MerchantProfiles mp
         OUTER APPLY (
             SELECT AVG(CAST(r.stars AS DECIMAL(10,2))) AS avg_rating
             FROM Ratings r
             WHERE r.target_type = N'MERCHANT'
            AND r.target_user_id = mp.user_id
         ) rt
        WHERE mp.status = N'APPROVED'
        ORDER BY rating DESC, mp.user_id ASC
    """;

        List<MerchantProfile> merchants = query(sql, limit);

        String[] deliverySamples = {"15-25p", "20-30p", "30-40p", "10-20p", "15-20p", "5-15p"};
        String[] distanceSamples = {"1.2km", "2.5km", "3.0km", "0.8km", "1.5km", "0.5km"};

        for (int i = 0; i < merchants.size(); i++) {
            MerchantProfile m = merchants.get(i);

            if (m.getImageUrl() == null || m.getImageUrl().trim().isEmpty()) {
                m.setImageUrl(resolveStoreImage(m.getShopName(), m.getDistrictName()));
            }

            m.setDeliveryTime(deliverySamples[i % deliverySamples.length]);
            m.setDistance(distanceSamples[i % distanceSamples.length]);

            if (m.getVoucherTitle() == null || m.getVoucherTitle().trim().isEmpty()) {
                m.setVoucherTitle("Đang mở bán");
            }

            if (m.getCategoryName() == null || m.getCategoryName().trim().isEmpty()) {
                m.setCategoryName("Món ăn");
            }
        }

        return merchants;
    }

    public List<String> getAllApprovedProvinces() {
        String sql = """
        SELECT DISTINCT province_name
        FROM MerchantProfiles
        WHERE status = 'APPROVED'
          AND province_name IS NOT NULL
          AND LTRIM(RTRIM(province_name)) <> ''
        ORDER BY province_name
    """;
        return queryString(sql);
    }

    public List<String> getDistrictsByProvince(String provinceName) {
        String sql = """
        SELECT DISTINCT district_name
        FROM MerchantProfiles
        WHERE status = 'APPROVED'
          AND province_name = ?
          AND district_name IS NOT NULL
          AND LTRIM(RTRIM(district_name)) <> ''
        ORDER BY district_name
    """;
        return queryString(sql, provinceName);
    }

    public List<MerchantProfile> suggestStoresByName(String province, String keyword, int limit) {
        int safeLimit = Math.max(1, Math.min(limit, 20));

        String sql = """
        SELECT TOP """ + safeLimit + """
               mp.user_id,
               mp.shop_name,
               mp.district_name,
               mp.province_name,
               mp.image_url
        FROM MerchantProfiles mp
        WHERE mp.status = 'APPROVED'
          AND (? IS NULL OR LTRIM(RTRIM(?)) = '' OR mp.province_name = ?)
          AND mp.shop_name COLLATE Vietnamese_CI_AI LIKE ?
        ORDER BY
            CASE
                WHEN mp.shop_name COLLATE Vietnamese_CI_AI LIKE ? THEN 0
                ELSE 1
            END,
            mp.shop_name ASC
    """;

        String cleanKeyword = keyword == null ? "" : keyword.trim();
        String kwContains = "%" + cleanKeyword + "%";
        String kwPrefix = cleanKeyword + "%";

        System.out.println("=== DAO SUGGEST ===");
        System.out.println("province = [" + province + "]");
        System.out.println("keyword = [" + cleanKeyword + "]");
        System.out.println("kwContains = [" + kwContains + "]");
        System.out.println("kwPrefix = [" + kwPrefix + "]");
        System.out.println("===================");

        return query(sql,
                province, province, province,
                kwContains,
                kwPrefix
        );
    }

    public com.clickeat.model.MerchantProfile getByUserId(long userId) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, userId);
    }

    public boolean updateStoreInfo(long userId, String name, String phone, String address, String avatar) {
        if (columnExists("MerchantProfiles", "updated_at")) {
            String sql = "UPDATE MerchantProfiles SET shop_name = ?, shop_phone = ?, shop_address_line = ?, shop_avatar = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
            int rows = update(sql, name, phone, address, avatar, userId);
            if (rows > 0) {
                return true;
            }
        }

        String fallbackSql = "UPDATE MerchantProfiles SET shop_name = ?, shop_phone = ?, shop_address_line = ?, shop_avatar = ? WHERE user_id = ?";
        return update(fallbackSql, name, phone, address, avatar, userId) > 0;
    }

    public boolean updateBusinessHours(long userId, String hoursJson) {
        if (columnExists("MerchantProfiles", "updated_at")) {
            String sql = "UPDATE MerchantProfiles SET business_hours = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
            int rows = update(sql, hoursJson, userId);
            if (rows > 0) {
                return true;
            }
        }

        String fallbackSql = "UPDATE MerchantProfiles SET business_hours = ? WHERE user_id = ?";
        return update(fallbackSql, hoursJson, userId) > 0;
    }

    public boolean updateNotificationSettings(long userId, String settingsJson) {
        if (columnExists("MerchantProfiles", "updated_at")) {
            String sql = "UPDATE MerchantProfiles SET notification_settings = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
            int rows = update(sql, settingsJson, userId);
            if (rows > 0) {
                return true;
            }
        }

        String fallbackSql = "UPDATE MerchantProfiles SET notification_settings = ? WHERE user_id = ?";
        return update(fallbackSql, settingsJson, userId) > 0;
    }

    public boolean updateOpenState(long userId, boolean isOpen) {
        if (columnExists("MerchantProfiles", "updated_at")) {
            String sql = "UPDATE MerchantProfiles SET is_open = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
            int rows = update(sql, isOpen, userId);
            if (rows > 0) {
                return true;
            }
        }

        String fallbackSql = "UPDATE MerchantProfiles SET is_open = ? WHERE user_id = ?";
        return update(fallbackSql, isOpen, userId) > 0;
    }

    public boolean updateMinOrderAmount(long userId, Double minOrderAmount) {
        if (columnExists("MerchantProfiles", "updated_at")) {
            String sql = "UPDATE MerchantProfiles SET min_order_amount = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
            int rows = update(sql, minOrderAmount, userId);
            if (rows > 0) {
                return true;
            }
        }

        String fallbackSql = "UPDATE MerchantProfiles SET min_order_amount = ? WHERE user_id = ?";
        return update(fallbackSql, minOrderAmount, userId) > 0;
    }

}
