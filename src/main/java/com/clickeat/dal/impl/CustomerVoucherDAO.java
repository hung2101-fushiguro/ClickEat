package com.clickeat.dal.impl;

import com.clickeat.model.CustomerVoucher;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class CustomerVoucherDAO extends AbstractDAO<CustomerVoucher> {

    @Override
    protected CustomerVoucher mapRow(ResultSet rs) throws SQLException {
        CustomerVoucher cv = new CustomerVoucher();

        cv.setId(rs.getInt("id"));
        cv.setCustomerUserId(rs.getInt("customer_user_id"));
        cv.setVoucherId(rs.getInt("voucher_id"));
        cv.setSavedCode(rs.getString("saved_code"));
        cv.setStatus(rs.getString("status"));
        cv.setSavedAt(rs.getTimestamp("saved_at"));
        cv.setUsedAt(rs.getTimestamp("used_at"));

        try { cv.setTitle(rs.getString("title")); } catch (Exception ignored) {}
        try { cv.setDescription(rs.getString("description")); } catch (Exception ignored) {}
        try { cv.setDiscountType(rs.getString("discount_type")); } catch (Exception ignored) {}
        try { cv.setDiscountValue(rs.getDouble("discount_value")); } catch (Exception ignored) {}

        try {
            Object x = rs.getObject("max_discount_amount");
            cv.setMaxDiscountAmount(x == null ? null : rs.getDouble("max_discount_amount"));
        } catch (Exception ignored) {}

        try {
            Object x = rs.getObject("min_order_amount");
            cv.setMinOrderAmount(x == null ? null : rs.getDouble("min_order_amount"));
        } catch (Exception ignored) {}

        try { cv.setStartAt(rs.getTimestamp("start_at")); } catch (Exception ignored) {}
        try { cv.setEndAt(rs.getTimestamp("end_at")); } catch (Exception ignored) {}

        try {
            Object x = rs.getObject("max_uses_total");
            cv.setMaxUsesTotal(x == null ? null : rs.getInt("max_uses_total"));
        } catch (Exception ignored) {}

        try {
            Object x = rs.getObject("max_uses_per_user");
            cv.setMaxUsesPerUser(x == null ? null : rs.getInt("max_uses_per_user"));
        } catch (Exception ignored) {}

        try { cv.setPublished(rs.getBoolean("is_published")); } catch (Exception ignored) {}
        try { cv.setVoucherStatus(rs.getString("voucher_status")); } catch (Exception ignored) {}
        try { cv.setMerchantName(rs.getString("merchant_name")); } catch (Exception ignored) {}

        return cv;
    }

    public boolean isSaved(int customerUserId, int voucherId) {
        String sql = """
            SELECT COUNT(*)
            FROM CustomerVouchers
            WHERE customer_user_id = ?
              AND voucher_id = ?
        """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerUserId);
            ps.setInt(2, voucherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean saveVoucher(int customerUserId, int voucherId, String savedCode) {
        String sql = """
            INSERT INTO CustomerVouchers(customer_user_id, voucher_id, saved_code, status, saved_at)
            VALUES (?, ?, ?, N'SAVED', SYSUTCDATETIME())
        """;
        return update(sql, customerUserId, voucherId, savedCode) > 0;
    }

    public List<CustomerVoucher> getSavedVouchersByCustomer(int customerUserId) {
        String sql = """
            SELECT cv.*,
                   v.title,
                   v.description,
                   v.discount_type,
                   v.discount_value,
                   v.max_discount_amount,
                   v.min_order_amount,
                   v.start_at,
                   v.end_at,
                   v.max_uses_total,
                   v.max_uses_per_user,
                   v.is_published,
                   v.status AS voucher_status,
                   mp.shop_name AS merchant_name
            FROM CustomerVouchers cv
            INNER JOIN Vouchers v ON v.id = cv.voucher_id
            INNER JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
            WHERE cv.customer_user_id = ?
            ORDER BY cv.saved_at DESC
        """;
        return query(sql, customerUserId);
    }

    public CustomerVoucher findSavedVoucherForCheckout(int customerUserId, int merchantUserId, String code) {
        String sql = """
            SELECT cv.*,
                   v.title,
                   v.description,
                   v.discount_type,
                   v.discount_value,
                   v.max_discount_amount,
                   v.min_order_amount,
                   v.start_at,
                   v.end_at,
                   v.max_uses_total,
                   v.max_uses_per_user,
                   v.is_published,
                   v.status AS voucher_status,
                   mp.shop_name AS merchant_name
            FROM CustomerVouchers cv
            INNER JOIN Vouchers v ON v.id = cv.voucher_id
            INNER JOIN MerchantProfiles mp ON mp.user_id = v.merchant_user_id
            WHERE cv.customer_user_id = ?
              AND v.merchant_user_id = ?
              AND UPPER(LTRIM(RTRIM(cv.saved_code))) = UPPER(LTRIM(RTRIM(?)))
              AND cv.status = N'SAVED'
              AND v.is_published = 1
              AND v.status = N'ACTIVE'
              AND (SYSUTCDATETIME() BETWEEN v.start_at AND v.end_at
                   OR GETDATE() BETWEEN v.start_at AND v.end_at)
        """;
        return queryOne(sql, customerUserId, merchantUserId, code);
    }

    public boolean markUsed(int customerUserId, int voucherId) {
        String sql = """
            UPDATE CustomerVouchers
            SET status = N'USED',
                used_at = SYSUTCDATETIME()
            WHERE customer_user_id = ?
              AND voucher_id = ?
              AND status = N'SAVED'
        """;
        return update(sql, customerUserId, voucherId) > 0;
    }

    public boolean markExpiredByVoucher(int voucherId) {
        String sql = """
            UPDATE CustomerVouchers
            SET status = N'EXPIRED'
            WHERE voucher_id = ?
              AND status = N'SAVED'
        """;
        return update(sql, voucherId) > 0;
    }

    @Override
    public List<CustomerVoucher> findAll() {
        return query("SELECT * FROM CustomerVouchers ORDER BY id DESC");
    }

    @Override
    public CustomerVoucher findById(int id) {
        return queryOne("SELECT * FROM CustomerVouchers WHERE id = ?", id);
    }

    @Override
    public int insert(CustomerVoucher entity) {
        String sql = """
            INSERT INTO CustomerVouchers(customer_user_id, voucher_id, saved_code, status, saved_at)
            VALUES (?, ?, ?, ?, SYSUTCDATETIME())
        """;
        return update(sql,
                entity.getCustomerUserId(),
                entity.getVoucherId(),
                entity.getSavedCode(),
                entity.getStatus() == null ? "SAVED" : entity.getStatus()
        );
    }

    @Override
    public boolean update(CustomerVoucher entity) {
        String sql = """
            UPDATE CustomerVouchers
            SET status = ?, used_at = ?
            WHERE id = ?
        """;
        return update(sql, entity.getStatus(), entity.getUsedAt(), entity.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        return update("DELETE FROM CustomerVouchers WHERE id = ?", id) > 0;
    }
}