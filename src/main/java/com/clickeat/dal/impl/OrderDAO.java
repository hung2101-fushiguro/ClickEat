package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IOrderDAO;
import com.clickeat.model.Order;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class OrderDAO extends AbstractDAO<Order> implements IOrderDAO {

    @Override
    protected Order mapRow(ResultSet rs) throws SQLException {
        Order order = new Order();
        
        // 1. Lấy danh sách tất cả các cột đang CÓ THẬT trong SQL
        java.sql.ResultSetMetaData rsmd = rs.getMetaData();
        java.util.HashSet<String> columns = new java.util.HashSet<>();
        for (int i = 1; i <= rsmd.getColumnCount(); i++) {
            columns.add(rsmd.getColumnName(i).toLowerCase());
        }

        // 2. Chỉ map dữ liệu nếu cột đó tồn tại (Chống lỗi Invalid Column Name)
        if (columns.contains("id")) order.setId(rs.getInt("id"));
        if (columns.contains("order_code")) order.setOrderCode(rs.getString("order_code"));
        
        // Bắt các trường hợp hay đặt tên khác nhau
        if (columns.contains("customer_user_id")) order.setCustomerUserId(rs.getInt("customer_user_id"));
        else if (columns.contains("customer_id")) order.setCustomerUserId(rs.getInt("customer_id"));

        if (columns.contains("merchant_user_id")) order.setMerchantId(rs.getInt("merchant_user_id"));
        else if (columns.contains("merchant_id")) order.setMerchantId(rs.getInt("merchant_id"));

        if (columns.contains("shipper_user_id")) order.setShipperUserId(rs.getInt("shipper_user_id"));
        else if (columns.contains("shipper_id")) order.setShipperUserId(rs.getInt("shipper_id"));

        if (columns.contains("guest_id")) order.setGuestId(rs.getString("guest_id"));
        if (columns.contains("receiver_name")) order.setReceiverName(rs.getString("receiver_name"));
        if (columns.contains("receiver_phone")) order.setReceiverPhone(rs.getString("receiver_phone"));
        if (columns.contains("delivery_address_line")) order.setDeliveryAddressLine(rs.getString("delivery_address_line"));
        if (columns.contains("province_code")) order.setProvinceCode(rs.getString("province_code"));
        if (columns.contains("province_name")) order.setProvinceName(rs.getString("province_name"));
        if (columns.contains("district_code")) order.setDistrictCode(rs.getString("district_code"));
        if (columns.contains("district_name")) order.setDistrictName(rs.getString("district_name"));
        if (columns.contains("ward_code")) order.setWardCode(rs.getString("ward_code"));
        if (columns.contains("ward_name")) order.setWardName(rs.getString("ward_name"));
        if (columns.contains("latitude")) order.setLatitude(rs.getDouble("latitude"));
        if (columns.contains("longitude")) order.setLongitude(rs.getDouble("longitude"));
        if (columns.contains("delivery_note")) order.setDeliveryNote(rs.getString("delivery_note"));
        if (columns.contains("payment_method")) order.setPaymentMethod(rs.getString("payment_method"));
        if (columns.contains("payment_status")) order.setPaymentStatus(rs.getString("payment_status"));
        if (columns.contains("order_status")) order.setOrderStatus(rs.getString("order_status"));
        if (columns.contains("subtotal_amount")) order.setSubtotalAmount(rs.getDouble("subtotal_amount"));
        if (columns.contains("delivery_fee")) order.setDeliveryFee(rs.getDouble("delivery_fee"));
        if (columns.contains("discount_amount")) order.setDiscountAmount(rs.getDouble("discount_amount"));
        if (columns.contains("total_amount")) order.setTotalAmount(rs.getDouble("total_amount"));
        if (columns.contains("created_at")) order.setCreatedAt(rs.getTimestamp("created_at"));
        if (columns.contains("accepted_at")) order.setAcceptedAt(rs.getTimestamp("accepted_at"));
        if (columns.contains("ready_at")) order.setReadyAt(rs.getTimestamp("ready_at"));
        if (columns.contains("picked_up_at")) order.setPickedUpAt(rs.getTimestamp("picked_up_at"));
        if (columns.contains("delivered_at")) order.setDeliveredAt(rs.getTimestamp("delivered_at"));
        if (columns.contains("cancelled_at")) order.setCancelledAt(rs.getTimestamp("cancelled_at"));

        return order;
    }

    @Override
    public List<Order> getAvailableOrdersForShipper() {
        String sql = "SELECT * FROM Orders WHERE shipper_user_id IS NULL AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP') ORDER BY created_at ASC";
        return query(sql);
    }

    @Override
    public boolean claimOrder(int orderId, int shipperId) {
        // Đã xóa bỏ updated_at vì bảng Orders không có cột này
        String sql = "UPDATE Orders SET shipper_user_id = ?, order_status = 'DELIVERING' WHERE id = ? AND shipper_user_id IS NULL";
        return update(sql, shipperId, orderId) > 0;
    }

    @Override public List<Order> findAll() { return query("SELECT * FROM Orders ORDER BY created_at DESC"); }
    @Override public Order findById(int id) { return queryOne("SELECT * FROM Orders WHERE id = ?", id); }
    @Override public int insert(Order order) { return 0; }
    @Override public boolean update(Order order) { return false; }
    @Override public boolean delete(int id) { return false; }
}