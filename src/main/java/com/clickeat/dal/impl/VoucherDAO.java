package com.clickeat.dal.impl;

import com.clickeat.model.Voucher;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class VoucherDAO extends AbstractDAO<Voucher> {

    @Override
    protected Voucher mapRow(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();

        v.setId(rs.getInt("id"));
        v.setMerchantUserId(rs.getInt("merchant_user_id"));
        v.setCode(rs.getString("code"));
        v.setTitle(rs.getString("title"));
        v.setDescription(rs.getString("description"));
        v.setDiscountType(rs.getString("discount_type"));
        v.setDiscountValue(rs.getDouble("discount_value"));

        Object maxDiscount = rs.getObject("max_discount_amount");
        if (maxDiscount != null) {
            v.setMaxDiscountAmount(rs.getDouble("max_discount_amount"));
        } else {
            v.setMaxDiscountAmount(null);
        }

        Object minOrder = rs.getObject("min_order_amount");
        if (minOrder != null) {
            v.setMinOrderAmount(rs.getDouble("min_order_amount"));
        } else {
            v.setMinOrderAmount(null);
        }

        v.setStartAt(rs.getTimestamp("start_at"));
        v.setEndAt(rs.getTimestamp("end_at"));

        Object maxUsesTotal = rs.getObject("max_uses_total");
        if (maxUsesTotal != null) {
            v.setMaxUsesTotal(rs.getInt("max_uses_total"));
        } else {
            v.setMaxUsesTotal(null);
        }

        Object maxUsesPerUser = rs.getObject("max_uses_per_user");
        if (maxUsesPerUser != null) {
            v.setMaxUsesPerUser(rs.getInt("max_uses_per_user"));
        } else {
            v.setMaxUsesPerUser(null);
        }

        try {
            v.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
            v.setCreatedAt(null);
        }
        try {
            v.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (SQLException e) {
            v.setUpdatedAt(null);
        }

        try {
            Object usedCount = rs.getObject("used_order_count");
            if (usedCount != null) {
                v.setUsedOrderCount(((Number) usedCount).intValue());
            }
        } catch (SQLException e) {
            v.setUsedOrderCount(0);
        }

        try {
            v.setMerchantName(rs.getString("merchant_name"));
        } catch (SQLException e) {
            v.setMerchantName(null);
        }

        v.setDisplayDiscount(buildDiscountLabel(v.getDiscountType(), v.getDiscountValue()));

        return v;
    }

    public List<Voucher> getActiveVouchers(int limit) {
        String sql = """
        SELECT TOP (?)
               v.*,
               mp.shop_name AS merchant_name,
               CASE
                   WHEN UPPER(v.discount_type) = 'PERCENT'
                        THEN v.discount_value * ISNULL(v.max_discount_amount, 1000000) / 100.0
                   ELSE v.discount_value
               END AS effective_discount_value
        FROM Vouchers v
        INNER JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
        WHERE v.is_published = 1
          AND v.status = N'ACTIVE'
          AND (GETUTCDATE() BETWEEN v.start_at AND v.end_at OR GETDATE() BETWEEN v.start_at AND v.end_at)
          AND (mp.status = N'APPROVED' OR mp.status = N'Approved' OR mp.status = N'active')
        ORDER BY
            CASE
                WHEN UPPER(v.discount_type) = 'PERCENT'
                     THEN ISNULL(v.max_discount_amount, v.discount_value * 1000)
                ELSE v.discount_value
            END DESC,
            ISNULL(v.min_order_amount, 0) ASC,
            v.id DESC
    """;
        return query(sql, limit);
    }

    public List<Voucher> getByMerchantId(int merchantUserId) {
        return findByMerchant(merchantUserId);
    }

    public List<Voucher> findByMerchant(int merchantUserId) {
        String sql = """
            SELECT v.*,
                   mp.shop_name AS merchant_name,
                   ISNULL(vu.used_order_count, 0) AS used_order_count
            FROM Vouchers v
            INNER JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
            LEFT JOIN (
                SELECT voucher_id, COUNT(*) AS used_order_count
                FROM VoucherUsages
                GROUP BY voucher_id
            ) vu ON vu.voucher_id = v.id
            WHERE v.merchant_user_id = ?
            ORDER BY v.id DESC
        """;
        return query(sql, merchantUserId);
    }

    public List<Voucher> findPublishedByMerchant(int merchantUserId) {
        String sql = """
            SELECT v.*,
                   mp.shop_name AS merchant_name
            FROM Vouchers v
            INNER JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
            WHERE v.merchant_user_id = ?
              AND v.is_published = 1
            ORDER BY v.id DESC
        """;
        return query(sql, merchantUserId);
    }

    @Override
    public List<Voucher> findAll() {
        String sql = """
            SELECT v.*,
                   mp.shop_name AS merchant_name
            FROM Vouchers v
            LEFT JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
            ORDER BY v.id DESC
        """;
        return query(sql);
    }

    @Override
    public Voucher findById(int id) {
        String sql = """
            SELECT v.*,
                   mp.shop_name AS merchant_name
            FROM Vouchers v
            LEFT JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
            WHERE v.id = ?
        """;
        return queryOne(sql, id);
    }

    @Override
    public int insert(Voucher v) {
        String sql = """
            INSERT INTO Vouchers (
                merchant_user_id,
                code,
                title,
                description,
                discount_type,
                discount_value,
                max_discount_amount,
                min_order_amount,
                start_at,
                end_at,
                max_uses_total,
                max_uses_per_user,
                is_published,
                status
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        return update(sql,
                v.getMerchantUserId(),
                v.getCode(),
                v.getTitle(),
                v.getDescription(),
                v.getDiscountType(),
                v.getDiscountValue(),
                v.getMaxDiscountAmount(),
                v.getMinOrderAmount(),
                v.getStartAt(),
                v.getEndAt(),
                v.getMaxUsesTotal(),
                v.getMaxUsesPerUser(),
                v.isPublished(),
                v.getStatus()
        );
    }

    @Override
    public boolean update(Voucher v) {
        String sql = """
            UPDATE Vouchers
            SET merchant_user_id = ?,
                code = ?,
                title = ?,
                description = ?,
                discount_type = ?,
                discount_value = ?,
                max_discount_amount = ?,
                min_order_amount = ?,
                start_at = ?,
                end_at = ?,
                max_uses_total = ?,
                max_uses_per_user = ?,
                is_published = ?,
                status = ?
            WHERE id = ?
        """;

        return update(sql,
                v.getMerchantUserId(),
                v.getCode(),
                v.getTitle(),
                v.getDescription(),
                v.getDiscountType(),
                v.getDiscountValue(),
                v.getMaxDiscountAmount(),
                v.getMinOrderAmount(),
                v.getStartAt(),
                v.getEndAt(),
                v.getMaxUsesTotal(),
                v.getMaxUsesPerUser(),
                v.isPublished(),
                v.getStatus(),
                v.getId()
        ) > 0;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM Vouchers WHERE id = ?";
        return update(sql, id) > 0;
    }

    public boolean softDelete(int id) {
        String sql = """
            UPDATE Vouchers
            SET status = N'INACTIVE',
                is_published = 0
            WHERE id = ?
        """;
        return update(sql, id) > 0;
    }

    public List<Voucher> getAvailableVouchersForCustomer(int customerUserId) {
        String sql = """
        SELECT v.*,
               mp.shop_name AS merchant_name
        FROM Vouchers v
        INNER JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
        WHERE v.is_published = 1
          AND v.status = N'ACTIVE'
          AND (GETUTCDATE() BETWEEN v.start_at AND v.end_at OR GETDATE() BETWEEN v.start_at AND v.end_at)
          AND (mp.status = N'APPROVED' OR mp.status = N'Approved' OR mp.status = N'active')
          AND (
                v.max_uses_per_user IS NULL
                OR v.max_uses_per_user >
                    (SELECT COUNT(*)
                     FROM VoucherUsages vu
                     WHERE vu.voucher_id = v.id
                       AND vu.customer_user_id = ?)
              )
        ORDER BY v.end_at ASC, v.id DESC
    """;
        return query(sql, customerUserId);
    }

    public boolean publishVoucher(int id) {
        String sql = "UPDATE Vouchers SET is_published = 1 WHERE id = ?";
        return update(sql, id) > 0;
    }

    public boolean unpublishVoucher(int id) {
        String sql = "UPDATE Vouchers SET is_published = 0 WHERE id = ?";
        return update(sql, id) > 0;
    }

    private String buildDiscountLabel(String discountType, double discountValue) {
        if ("PERCENT".equalsIgnoreCase(discountType)) {
            return "Giảm " + ((int) discountValue) + "%";
        }
        return "Giảm " + ((int) discountValue / 1000) + "k";
    }

    public boolean togglePublishByMerchant(int voucherId, int merchantId, boolean publish) {
        String sql = "UPDATE Vouchers SET is_published = ?, updated_at = SYSUTCDATETIME() WHERE id = ? AND merchant_user_id = ?";
        return update(sql, publish, voucherId, merchantId) > 0;
    }

}
