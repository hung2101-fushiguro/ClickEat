package com.clickeat.dal.impl;

import com.clickeat.model.Voucher;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class VoucherDAO extends AbstractDAO<Voucher> {

    @Override
    protected Voucher mapRow(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setId(rs.getLong("id"));
        v.setMerchantUserId(rs.getInt("merchant_user_id"));
        v.setCode(rs.getString("code"));
        v.setTitle(rs.getString("title"));
        v.setDiscountType(rs.getString("discount_type"));
        v.setDiscountValue(rs.getDouble("discount_value"));

        
        v.setMinOrderAmount(rs.getDouble("min_order_amount"));
        v.setMaxUsesTotal(rs.getInt("max_uses_total"));

        v.setStartAt(rs.getTimestamp("start_at"));
        v.setEndAt(rs.getTimestamp("end_at"));
        v.setPublished(rs.getBoolean("is_published"));
        v.setStatus(rs.getString("status"));
        return v;
    }

    public List<Voucher> getByMerchantId(int merchantId) {
        String sql = "SELECT * FROM Vouchers WHERE merchant_user_id = ? ORDER BY created_at DESC";
        return query(sql, merchantId);
    }

    @Override
    public int insert(Voucher v) {
        String sql = "INSERT INTO Vouchers (merchant_user_id, code, title, discount_type, discount_value, "
                + "min_order_amount, start_at, end_at, max_uses_total, is_published, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";

        
        return update(sql, v.getMerchantUserId(), v.getCode(), v.getTitle(), v.getDiscountType(),
                v.getDiscountValue(), v.getMinOrderAmount(), v.getStartAt(), v.getEndAt(),
                v.getMaxUsesTotal(), v.isPublished() ? 1 : 0);
    }

   
    @Override
    public List<Voucher> findAll() {
        return null;
    }

    @Override
    public boolean update(Voucher t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }

    @Override
    public Voucher findById(int id) {
        return null;
    }
}
