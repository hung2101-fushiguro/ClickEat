package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IOrderDAO;
import com.clickeat.model.Order;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
        if (columns.contains("id")) {
            order.setId(rs.getInt("id"));
        }
        if (columns.contains("order_code")) {
            order.setOrderCode(rs.getString("order_code"));
        }

        // Bắt các trường hợp hay đặt tên khác nhau
        if (columns.contains("customer_user_id")) {
            order.setCustomerUserId(rs.getInt("customer_user_id"));
        } else if (columns.contains("customer_id")) {
            order.setCustomerUserId(rs.getInt("customer_id"));
        }

        if (columns.contains("merchant_user_id")) {
            order.setMerchantId(rs.getInt("merchant_user_id"));
        } else if (columns.contains("merchant_id")) {
            order.setMerchantId(rs.getInt("merchant_id"));
        }

        if (columns.contains("shipper_user_id")) {
            order.setShipperUserId(rs.getInt("shipper_user_id"));
        } else if (columns.contains("shipper_id")) {
            order.setShipperUserId(rs.getInt("shipper_id"));
        }

        if (columns.contains("guest_id")) {
            order.setGuestId(rs.getString("guest_id"));
        }
        if (columns.contains("receiver_name")) {
            order.setReceiverName(rs.getString("receiver_name"));
        }
        if (columns.contains("receiver_phone")) {
            order.setReceiverPhone(rs.getString("receiver_phone"));
        }
        if (columns.contains("delivery_address_line")) {
            order.setDeliveryAddressLine(rs.getString("delivery_address_line"));
        }
        if (columns.contains("province_code")) {
            order.setProvinceCode(rs.getString("province_code"));
        }
        if (columns.contains("province_name")) {
            order.setProvinceName(rs.getString("province_name"));
        }
        if (columns.contains("district_code")) {
            order.setDistrictCode(rs.getString("district_code"));
        }
        if (columns.contains("district_name")) {
            order.setDistrictName(rs.getString("district_name"));
        }
        if (columns.contains("ward_code")) {
            order.setWardCode(rs.getString("ward_code"));
        }
        if (columns.contains("ward_name")) {
            order.setWardName(rs.getString("ward_name"));
        }
        if (columns.contains("latitude")) {
            order.setLatitude(rs.getDouble("latitude"));
        }
        if (columns.contains("longitude")) {
            order.setLongitude(rs.getDouble("longitude"));
        }
        if (columns.contains("delivery_note")) {
            order.setDeliveryNote(rs.getString("delivery_note"));
        }
        if (columns.contains("payment_method")) {
            order.setPaymentMethod(rs.getString("payment_method"));
        }
        if (columns.contains("payment_status")) {
            order.setPaymentStatus(rs.getString("payment_status"));
        }
        if (columns.contains("order_status")) {
            order.setOrderStatus(rs.getString("order_status"));
        }
        if (columns.contains("subtotal_amount")) {
            order.setSubtotalAmount(rs.getDouble("subtotal_amount"));
        }
        if (columns.contains("delivery_fee")) {
            order.setDeliveryFee(rs.getDouble("delivery_fee"));
        }
        if (columns.contains("discount_amount")) {
            order.setDiscountAmount(rs.getDouble("discount_amount"));
        }
        if (columns.contains("total_amount")) {
            order.setTotalAmount(rs.getDouble("total_amount"));
        }
        if (columns.contains("created_at")) {
            order.setCreatedAt(rs.getTimestamp("created_at"));
        }
        if (columns.contains("accepted_at")) {
            order.setAcceptedAt(rs.getTimestamp("accepted_at"));
        }
        if (columns.contains("ready_at")) {
            order.setReadyAt(rs.getTimestamp("ready_at"));
        }
        if (columns.contains("picked_up_at")) {
            order.setPickedUpAt(rs.getTimestamp("picked_up_at"));
        }
        if (columns.contains("delivered_at")) {
            order.setDeliveredAt(rs.getTimestamp("delivered_at"));
        }
        if (columns.contains("cancelled_at")) {
            order.setCancelledAt(rs.getTimestamp("cancelled_at"));
        }

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

    @Override
    public List<Order> getCurrentOrdersForShipper(int shipperId) {
        // Đã sửa ORDER BY updated_at thành ORDER BY created_at
        String sql = "SELECT * FROM Orders WHERE shipper_user_id = ? AND order_status IN ('DELIVERING', 'PICKED_UP') ORDER BY created_at DESC";
        return query(sql, shipperId);
    }

    public boolean yieldOrder(int orderId, int shipperId) {
        String sql = "UPDATE Orders SET shipper_user_id = NULL, order_status = 'READY_FOR_PICKUP' WHERE id = ? AND shipper_user_id = ?";
        return update(sql, orderId, shipperId) > 0;
    }

    @Override
    public boolean updateOrderStatus(int orderId, String newStatus) {
        String sql;
        if ("PICKED_UP".equals(newStatus)) {
            // Đã lấy hàng -> Ghi lại giờ lấy
            sql = "UPDATE Orders SET order_status = ?, picked_up_at = GETDATE() WHERE id = ?";
        } else if ("DELIVERED".equals(newStatus)) {
            // Giao thành công -> Ghi lại giờ giao
            sql = "UPDATE Orders SET order_status = ?, delivered_at = GETDATE() WHERE id = ?";
        } else {
            sql = "UPDATE Orders SET order_status = ? WHERE id = ?";
        }
        return update(sql, newStatus, orderId) > 0;
    }

    public double getIncomeToday(int shipperId) {
        String sql = "SELECT SUM(delivery_fee) as total FROM Orders WHERE shipper_user_id = ? AND order_status = 'DELIVERED' AND CAST(delivered_at AS DATE) = CAST(GETDATE() AS DATE)";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getIncomeThisWeek(int shipperId) {
        String sql = "SELECT SUM(delivery_fee) as total FROM Orders WHERE shipper_user_id = ? AND order_status = 'DELIVERED' AND DATEPART(wk, delivered_at) = DATEPART(wk, GETDATE()) AND DATEPART(yy, delivered_at) = DATEPART(yy, GETDATE())";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    //Đếm số đơn hoàn thành hôm nay
    @Override
    public int countDeliveredOrdersToday(int shipperId) {
        String sql = "SELECT COUNT(id) as total FROM Orders WHERE shipper_user_id = ? AND order_status = 'DELIVERED' AND CAST(delivered_at AS DATE) = CAST(GETDATE() AS DATE)";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public Map<String, Double> getLast7DaysIncome(int shipperId) {
        Map<String, Double> incomeMap = new LinkedHashMap<>();

        // Khởi tạo 7 ngày gần nhất với giá trị 0
        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 6; i >= 0; i--) {
            incomeMap.put(today.minusDays(i).format(formatter), 0.0);
        }

        String sql = "SELECT CAST(delivered_at AS DATE) as delivery_date, SUM(delivery_fee) as daily_income "
                + "FROM Orders "
                + "WHERE shipper_user_id = ? AND order_status = 'DELIVERED' AND delivered_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) "
                + "GROUP BY CAST(delivered_at AS DATE)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date dbDate = rs.getDate("delivery_date");
                    String dateStr = dbDate.toLocalDate().format(formatter);
                    if (incomeMap.containsKey(dateStr)) {
                        incomeMap.put(dateStr, rs.getDouble("daily_income"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return incomeMap;
    }
    @Override
    public List<Order> getHistoryOrdersForShipper(int shipperId) {
        String sql = "SELECT * FROM Orders WHERE shipper_user_id = ? AND order_status IN ('DELIVERED', 'CANCELLED') ORDER BY created_at DESC";
        return query(sql, shipperId);
    }

    @Override
    public List<Order> findAll() {
        return query("SELECT * FROM Orders ORDER BY created_at DESC");
    }

    @Override
    public Order findById(int id) {
        return queryOne("SELECT * FROM Orders WHERE id = ?", id);
    }

    @Override
    public int insert(Order order) {
        return 0;
    }

    @Override
    public boolean update(Order order) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
