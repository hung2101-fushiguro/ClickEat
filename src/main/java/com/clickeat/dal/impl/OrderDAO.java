package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IOrderDAO;
import com.clickeat.model.Order;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

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

    public String getCustomerFoodHistory(long customerId, int days) {
        // Truy vấn các món đã đặt trong X ngày qua, kèm theo thông tin is_fried (đồ chiên) và lượng calo
        String sql = "SELECT fi.name, COUNT(oi.id) as times_ordered, fi.is_fried, fi.calories "
                + "FROM Orders o "
                + "JOIN OrderItems oi ON o.id = oi.order_id "
                + "JOIN FoodItems fi ON oi.food_item_id = fi.id "
                + "WHERE o.customer_user_id = ? AND o.created_at >= DATEADD(DAY, -?, GETDATE()) "
                + "GROUP BY fi.name, fi.is_fried, fi.calories";

        StringBuilder history = new StringBuilder("Lịch sử ăn uống trong " + days + " ngày qua:\n");
        boolean hasData = false;

        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setInt(2, days);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    hasData = true;
                    String name = rs.getString("name");
                    int times = rs.getInt("times_ordered");
                    boolean isFried = rs.getBoolean("is_fried");
                    int calories = rs.getInt("calories");

                    history.append("- Món: ").append(name)
                            .append(" | Đã ăn: ").append(times).append(" lần")
                            .append(" | Đồ chiên rán: ").append(isFried ? "Có" : "Không")
                            .append(" | Calo: ").append(calories).append(" kcal\n");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi khi truy xuất lịch sử ăn uống.";
        }

        if (!hasData) {
            return "Khách hàng chưa đặt món nào trên hệ thống trong " + days + " ngày qua.";
        }
        return history.toString();
    }

    public String getAvailableMenuContext() {
        // Chỉ lấy món ăn của nhà hàng đã được APPROVED và món ăn đang AVAILABLE
        String sql = "SELECT m.shop_name, c.name AS category_name, f.name AS food_name, f.price, f.is_fried, f.calories "
                + "FROM FoodItems f "
                + "JOIN Categories c ON f.category_id = c.id "
                + "JOIN MerchantProfiles m ON f.merchant_user_id = m.user_id "
                + "WHERE f.is_available = 1 AND m.status = 'APPROVED'";

        StringBuilder menu = new StringBuilder("DANH SÁCH MÓN ĂN HIỆN CÓ TRÊN HỆ THỐNG:\n");
        boolean hasData = false;

        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql); java.sql.ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                hasData = true;
                String shopName = rs.getString("shop_name");
                String category = rs.getString("category_name");
                String foodName = rs.getString("food_name");
                long price = rs.getLong("price");
                boolean isFried = rs.getBoolean("is_fried");
                int calories = rs.getInt("calories");

                // Format: [Tên Quán] - Thể loại: Cơm/Gà - Món: Gà rán (45000đ) - Chiên: Có, Calo: 500
                menu.append("- Quán [").append(shopName).append("] | Thể loại: ").append(category)
                        .append(" | Món: ").append(foodName).append(" (").append(price).append("đ)")
                        .append(isFried ? " [Đồ chiên]" : "")
                        .append(calories > 0 ? " [" + calories + " kcal]" : "")
                        .append("\n");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi truy xuất thực đơn.";
        }

        if (!hasData) {
            return "Hiện tại hệ thống chưa có món ăn nào mở bán.";
        }
        return menu.toString();
    }

    @Override
    public List<Order> getAvailableOrdersForShipper(int shipperId) {
        // Dùng CROSS JOIN để lấy vị trí Shipper và STDistance để đo khoảng cách < 3000 mét (3km)
        String sql = "SELECT o.* "
                + "FROM dbo.Orders o "
                + "JOIN dbo.MerchantProfiles m ON o.merchant_user_id = m.user_id "
                + "CROSS JOIN ( "
                + "    SELECT current_latitude, current_longitude "
                + "    FROM dbo.ShipperAvailability "
                + "    WHERE shipper_user_id = ? "
                + ") sa "
                + "WHERE o.shipper_user_id IS NULL "
                + "  AND o.order_status IN ('MERCHANT_ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP') "
                + "  AND m.latitude IS NOT NULL "
                + "  AND m.longitude IS NOT NULL "
                + "  AND sa.current_latitude IS NOT NULL "
                + "  AND sa.current_longitude IS NOT NULL "
                + "  AND geography::Point(sa.current_latitude, sa.current_longitude, 4326)"
                + "      .STDistance(geography::Point(m.latitude, m.longitude, 4326)) <= 3000 "
                + "ORDER BY o.created_at ASC";

        return query(sql, shipperId);
    }

    @Override
    public boolean claimOrder(int orderId, int shipperId) {
        // Đã bổ sung shipper_accepted_at = SYSUTCDATETIME()
        String sql = "UPDATE Orders "
                + "SET shipper_user_id = ?, "
                + "    order_status = 'DELIVERING', "
                + "    shipper_accepted_at = SYSUTCDATETIME() "
                + "WHERE id = ? AND shipper_user_id IS NULL";
        return update(sql, shipperId, orderId) > 0;
    }

    @Override
    public List<Order> getCurrentOrdersForShipper(int shipperId) {
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
    public List<Order> getOrderHistoryByUser(int userId, String role) {
        String sql = "";

        if ("CUSTOMER".equals(role)) {
            sql = "SELECT * FROM Orders WHERE customer_user_id = ? ORDER BY created_at DESC";
        } else if ("SHIPPER".equals(role)) {
            sql = "SELECT * FROM Orders WHERE shipper_user_id = ? ORDER BY created_at DESC";
        } else if ("MERCHANT".equals(role)) {
            sql = "SELECT * FROM Orders WHERE merchant_user_id = ? ORDER BY created_at DESC";
        } else {
            return new ArrayList<>();
        }

        return query(sql, userId);
    }

    public List<Order> getOrdersByMerchantAndStatus(int merchantId, String statusGroup) {
        String sql = "SELECT * FROM Orders WHERE merchant_user_id = ? ";

        if ("pending".equals(statusGroup)) {
            sql += "AND order_status = 'CREATED' ORDER BY created_at ASC";
        } else if ("preparing".equals(statusGroup)) {
            sql += "AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ORDER BY created_at ASC";
        } else if ("ready".equals(statusGroup)) {
            sql += "AND order_status = 'READY_FOR_PICKUP' ORDER BY created_at DESC";
        } else if ("completed".equals(statusGroup)) {
            sql += "AND order_status IN ('DELIVERED', 'CANCELLED', 'FAILED', 'MERCHANT_REJECTED') ORDER BY created_at DESC";
        } else {
            sql += "ORDER BY created_at DESC";
        }

        return query(sql, merchantId);
    }

    public boolean updateOrderStatus(long orderId, int merchantId, String newStatus) {
        String sql = "UPDATE Orders SET order_status = ?, updated_at = GETDATE() WHERE id = ? AND merchant_user_id = ?";
        return update(sql, newStatus, orderId, merchantId) > 0;
    }

    public Map<String, Double> getRevenueByPeriod(int merchantId, int days) {
        Map<String, Double> data = new LinkedHashMap<>();
        String sql = "SELECT CAST(created_at AS DATE) as OrderDate, SUM(total_amount) as DailyRevenue "
                + "FROM Orders "
                + "WHERE merchant_user_id = ? AND order_status = 'DELIVERED' "
                + "AND created_at >= DATEADD(day, -?, GETDATE()) "
                + "GROUP BY CAST(created_at AS DATE) "
                + "ORDER BY OrderDate ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    data.put(rs.getDate("OrderDate").toString(), rs.getDouble("DailyRevenue"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return data;
    }

// 2. Lấy danh sách 5 món ăn bán chạy nhất
    public List<Map<String, Object>> getTopSellingFoods(int merchantId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) item_name_snapshot, SUM(quantity) as TotalQty, SUM(unit_price_snapshot * quantity) as TotalRevenue "
                + "FROM OrderItems oi JOIN Orders o ON oi.order_id = o.id "
                + "WHERE o.merchant_user_id = ? AND o.order_status = 'DELIVERED' "
                + "GROUP BY item_name_snapshot "
                + "ORDER BY TotalQty DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("name", rs.getString("item_name_snapshot"));
                    map.put("qty", rs.getInt("TotalQty"));
                    map.put("revenue", rs.getDouble("TotalRevenue"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getTopSellingFoodsInRange(int merchantId, int limit, LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
            return getTopSellingFoods(merchantId, limit);
        }

        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) item_name_snapshot, SUM(quantity) AS TotalQty, SUM(unit_price_snapshot * quantity) AS TotalRevenue "
                + "FROM OrderItems oi "
                + "JOIN Orders o ON oi.order_id = o.id "
                + "WHERE o.merchant_user_id = ? AND o.order_status = 'DELIVERED' "
                + "AND o.created_at >= ? AND o.created_at < ? "
                + "GROUP BY item_name_snapshot "
                + "ORDER BY TotalQty DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, merchantId);
            ps.setTimestamp(3, Timestamp.valueOf(fromDate.atStartOfDay()));
            ps.setTimestamp(4, Timestamp.valueOf(toDate.plusDays(1).atStartOfDay()));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("name", rs.getString("item_name_snapshot"));
                    map.put("qty", rs.getInt("TotalQty"));
                    map.put("revenue", rs.getDouble("TotalRevenue"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Integer> getOrderStatusBreakdown(int merchantId, int days) {
        Map<String, Integer> result = new LinkedHashMap<>();
        result.put("CREATED", 0);
        result.put("PREPARING", 0);
        result.put("READY_FOR_PICKUP", 0);
        result.put("DELIVERING", 0);
        result.put("DELIVERED", 0);
        result.put("CANCELLED", 0);

        String sql = "SELECT order_status, COUNT(*) AS total "
                + "FROM Orders "
                + "WHERE merchant_user_id = ? "
                + "AND created_at >= DATEADD(day, -?, GETDATE()) "
                + "GROUP BY order_status";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setInt(2, days);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String rawStatus = rs.getString("order_status");
                    int count = rs.getInt("total");
                    String normalized = normalizeStatusForAnalytics(rawStatus);
                    result.put(normalized, result.getOrDefault(normalized, 0) + count);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

    public boolean completeDeliveryWithProofAndSettlement(int orderId, int shipperId, String proofImageUrl) {
        String selectSql = "SELECT delivery_fee, order_status FROM Orders WHERE id = ? AND shipper_user_id = ?";
        String updateOrderSql = "UPDATE Orders SET order_status = 'DELIVERED', delivered_at = SYSUTCDATETIME(), "
                + "proof_image_url = ?, payment_status = CASE WHEN payment_method = 'COD' THEN 'PAID' ELSE payment_status END "
                + "WHERE id = ? AND shipper_user_id = ? AND order_status IN ('PICKED_UP', 'DELIVERING')";
        String ensureWalletSql = "IF NOT EXISTS (SELECT 1 FROM ShipperWallets WHERE shipper_user_id = ?) "
                + "INSERT INTO ShipperWallets(shipper_user_id, balance, updated_at) VALUES (?, 0, SYSUTCDATETIME())";
        String creditWalletSql = "UPDATE ShipperWallets SET balance = balance + ?, updated_at = SYSUTCDATETIME() WHERE shipper_user_id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                double deliveryFee;
                String currentStatus;

                try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, shipperId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        deliveryFee = rs.getDouble("delivery_fee");
                        currentStatus = rs.getString("order_status");
                    }
                }

                if (currentStatus == null
                        || (!"PICKED_UP".equalsIgnoreCase(currentStatus)
                        && !"DELIVERING".equalsIgnoreCase(currentStatus))) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                    ps.setString(1, proofImageUrl);
                    ps.setInt(2, orderId);
                    ps.setInt(3, shipperId);
                    if (ps.executeUpdate() <= 0) {
                        conn.rollback();
                        return false;
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(ensureWalletSql)) {
                    ps.setInt(1, shipperId);
                    ps.setInt(2, shipperId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(creditWalletSql)) {
                    ps.setDouble(1, deliveryFee);
                    ps.setInt(2, shipperId);
                    if (ps.executeUpdate() <= 0) {
                        conn.rollback();
                        return false;
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            return false;
        }
    }

    private String normalizeStatusForAnalytics(String status) {
        if (status == null) {
            return "CANCELLED";
        }

        String normalized = status.trim().toUpperCase();
        if ("PAID".equals(normalized) || "CREATED".equals(normalized)) {
            return "CREATED";
        }
        if ("MERCHANT_ACCEPTED".equals(normalized) || "PREPARING".equals(normalized)) {
            return "PREPARING";
        }
        if ("READY_FOR_PICKUP".equals(normalized)) {
            return "READY_FOR_PICKUP";
        }
        if ("DELIVERING".equals(normalized) || "PICKED_UP".equals(normalized)) {
            return "DELIVERING";
        }
        if ("DELIVERED".equals(normalized)) {
            return "DELIVERED";
        }
        if ("CANCELLED".equals(normalized) || "MERCHANT_REJECTED".equals(normalized)
                || "FAILED".equals(normalized) || "REFUNDED".equals(normalized)) {
            return "CANCELLED";
        }
        return normalized;
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

    public java.util.List<com.clickeat.model.Order> getOrdersByMerchantAndStatus(int merchantId, String statusGroup, String statusFilter, String fromDateTime, String toDateTime) {
        return getOrdersByMerchantAndStatus(merchantId, statusGroup, statusFilter, fromDateTime, toDateTime, 1, 20);
    }

    public java.util.List<com.clickeat.model.Order> getOrdersByMerchantAndStatus(int merchantId, String statusGroup, String statusFilter, String fromDateTime, String toDateTime, int page, int pageSize) {
        String sql = "SELECT * FROM Orders WHERE merchant_user_id = ? ";
        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(merchantId);

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            String normalized = statusFilter.trim().toUpperCase();
            if ("PENDING".equals(normalized)) {
                sql += "AND order_status IN ('CREATED', 'PAID') ";
            } else if ("CONFIRMED".equals(normalized)) {
                sql += "AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ";
            } else if ("CANCELLED".equals(normalized)) {
                sql += "AND order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') ";
            } else {
                sql += "AND order_status = ? ";
                params.add(normalized);
            }
        } else if ("pending".equals(statusGroup)) {
            sql += "AND order_status IN ('CREATED', 'PAID') ";
        } else if ("preparing".equals(statusGroup)) {
            sql += "AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ";
        } else if ("ready".equals(statusGroup)) {
            sql += "AND order_status IN ('READY_FOR_PICKUP', 'DELIVERING', 'PICKED_UP') ";
        } else if ("completed".equals(statusGroup)) {
            sql += "AND order_status IN ('DELIVERED', 'CANCELLED', 'FAILED', 'MERCHANT_REJECTED', 'REFUNDED') ";
        }

        Timestamp fromTs = parseStartDateTime(fromDateTime);
        if (fromTs != null) {
            sql += "AND created_at >= ? ";
            params.add(fromTs);
        }
        Timestamp toTs = parseEndDateTime(toDateTime);
        if (toTs != null) {
            sql += "AND created_at <= ? ";
            params.add(toTs);
        }
        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, Math.min(pageSize, 100));
        int offset = (safePage - 1) * safePageSize;

        sql += "ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(offset);
        params.add(safePageSize);
        return query(sql, params.toArray());
    }

    public int countOrdersByMerchantAndStatus(int merchantId, String statusGroup, String statusFilter, String fromDateTime, String toDateTime) {
        String sql = "SELECT COUNT(*) AS total_count FROM Orders WHERE merchant_user_id = ? ";
        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(merchantId);

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            String normalized = statusFilter.trim().toUpperCase();
            if ("PENDING".equals(normalized)) {
                sql += "AND order_status IN ('CREATED', 'PAID') ";
            } else if ("CONFIRMED".equals(normalized)) {
                sql += "AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ";
            } else if ("CANCELLED".equals(normalized)) {
                sql += "AND order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') ";
            } else {
                sql += "AND order_status = ? ";
                params.add(normalized);
            }
        } else if ("pending".equals(statusGroup)) {
            sql += "AND order_status IN ('CREATED', 'PAID') ";
        } else if ("preparing".equals(statusGroup)) {
            sql += "AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ";
        } else if ("ready".equals(statusGroup)) {
            sql += "AND order_status IN ('READY_FOR_PICKUP', 'DELIVERING', 'PICKED_UP') ";
        } else if ("completed".equals(statusGroup)) {
            sql += "AND order_status IN ('DELIVERED', 'CANCELLED', 'FAILED', 'MERCHANT_REJECTED', 'REFUNDED') ";
        }

        Timestamp fromTs = parseStartDateTime(fromDateTime);
        if (fromTs != null) {
            sql += "AND created_at >= ? ";
            params.add(fromTs);
        }
        Timestamp toTs = parseEndDateTime(toDateTime);
        if (toTs != null) {
            sql += "AND created_at <= ? ";
            params.add(toTs);
        }

        java.util.List<Object[]> rows = queryRaw(sql, params.toArray());
        if (rows.isEmpty() || rows.get(0).length == 0 || rows.get(0)[0] == null) {
            return 0;
        }
        return ((Number) rows.get(0)[0]).intValue();
    }

    public boolean transitionMerchantOrderStatus(long orderId, int merchantId, String newStatus, String note) {
        String targetStatus = normalizeStatusForWrite(newStatus);
        String currentStatus = null;
        String fetchSql = "SELECT order_status FROM Orders WHERE id = ? AND merchant_user_id = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(fetchSql)) {
            ps.setLong(1, orderId);
            ps.setInt(2, merchantId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentStatus = rs.getString("order_status");
                }
            }
        } catch (java.sql.SQLException e) {
            return false;
        }

        if (currentStatus == null) {
            return false;
        }
        String fromStatus = normalizeStatusForTransition(currentStatus);
        if (!isMerchantTransitionAllowed(fromStatus, targetStatus)) {
            return false;
        }
        if (fromStatus.equals(targetStatus)) {
            return true;
        }

        String updateSql = "UPDATE Orders SET order_status = ?, "
                + "accepted_at = CASE WHEN ? = 'PREPARING' AND accepted_at IS NULL THEN SYSUTCDATETIME() ELSE accepted_at END, "
                + "ready_at = CASE WHEN ? = 'READY_FOR_PICKUP' AND ready_at IS NULL THEN SYSUTCDATETIME() ELSE ready_at END, "
                + "cancelled_at = CASE WHEN ? = 'CANCELLED' AND cancelled_at IS NULL THEN SYSUTCDATETIME() ELSE cancelled_at END "
                + "WHERE id = ? AND merchant_user_id = ? AND order_status = ?";

        try (java.sql.Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (java.sql.PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, targetStatus);
                ps.setString(2, targetStatus);
                ps.setString(3, targetStatus);
                ps.setString(4, targetStatus);
                ps.setLong(5, orderId);
                ps.setInt(6, merchantId);
                ps.setString(7, currentStatus);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }
            String historySql = "INSERT INTO OrderStatusHistory(order_id, from_status, to_status, updated_by_role, updated_by_user_id, note, created_at) VALUES (?, ?, ?, 'MERCHANT', ?, ?, SYSUTCDATETIME())";
            try (java.sql.PreparedStatement hs = conn.prepareStatement(historySql)) {
                hs.setLong(1, orderId);
                hs.setString(2, currentStatus);
                hs.setString(3, targetStatus);
                hs.setInt(4, merchantId);
                hs.setString(5, note);
                hs.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (java.sql.SQLException e) {
            return false;
        }
    }

    private String normalizeStatusForWrite(String status) {
        if (status == null) {
            return "";
        }
        String normalized = status.trim().toUpperCase();
        if ("MERCHANT_REJECTED".equals(normalized)) {
            return "CANCELLED";
        }
        if ("PENDING".equals(normalized)) {
            return "CREATED";
        }
        if ("CONFIRMED".equals(normalized)) {
            return "PREPARING";
        }
        return normalized;
    }

    private String normalizeStatusForTransition(String status) {
        if (status == null) {
            return "";
        }
        String normalized = status.trim().toUpperCase();
        if ("PAID".equals(normalized) || "CREATED".equals(normalized)) {
            return "PENDING";
        }
        if ("MERCHANT_ACCEPTED".equals(normalized) || "PREPARING".equals(normalized)) {
            return "CONFIRMED";
        }
        if ("MERCHANT_REJECTED".equals(normalized)) {
            return "CANCELLED";
        }
        return normalized;
    }

    private boolean isMerchantTransitionAllowed(String fromStatus, String targetStatus) {
        if ("PENDING".equals(fromStatus)) {
            return "PREPARING".equals(targetStatus) || "CANCELLED".equals(targetStatus);
        }
        if ("CONFIRMED".equals(fromStatus)) {
            return "READY_FOR_PICKUP".equals(targetStatus) || "CANCELLED".equals(targetStatus);
        }
        return false;
    }

    public java.util.Map<String, Object> getDashboardSummary(int merchantId) {
        java.util.Map<String, Object> summary = new java.util.HashMap<>();
        String sql = "SELECT "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND CAST(o.created_at AS DATE) = CAST(GETDATE() AS DATE) THEN o.total_amount ELSE 0 END) AS revenue_today, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND CAST(o.created_at AS DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE)) THEN o.total_amount ELSE 0 END) AS revenue_yesterday, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) THEN o.total_amount ELSE 0 END) AS revenue_7d, "
                + "SUM(CASE WHEN CAST(o.created_at AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS orders_today, "
                + "SUM(CASE WHEN CAST(o.created_at AS DATE) = CAST(GETDATE() AS DATE) AND o.order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') THEN 1 ELSE 0 END) AS canceled_today, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) AND o.discount_amount > 0 THEN 1 ELSE 0 END) AS voucher_used_7d, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) AND ISNULL(o.discount_amount, 0) <= 0 THEN 1 ELSE 0 END) AS voucher_not_used_7d "
                + "FROM Orders o WHERE o.merchant_user_id = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.put("revenueToday", rs.getDouble("revenue_today"));
                    summary.put("revenueYesterday", rs.getDouble("revenue_yesterday"));
                    summary.put("revenue7d", rs.getDouble("revenue_7d"));
                    summary.put("ordersToday", rs.getInt("orders_today"));
                    int canceledToday = rs.getInt("canceled_today");
                    summary.put("canceledToday", canceledToday);
                    summary.put("cancelRate", rs.getInt("orders_today") == 0 ? 0.0 : ((canceledToday * 100.0) / rs.getInt("orders_today")));
                    summary.put("voucherUsed7d", rs.getInt("voucher_used_7d"));
                    summary.put("voucherNotUsed7d", rs.getInt("voucher_not_used_7d"));
                }
            }
        } catch (java.sql.SQLException e) {
        }
        return summary;
    }

    public java.util.Map<String, Object> getDashboardSummaryByDateRange(int merchantId, LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
            return getDashboardSummary(merchantId);
        }

        java.util.Map<String, Object> summary = new java.util.HashMap<>();
        String sql = "SELECT "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' THEN o.total_amount ELSE 0 END) AS revenue_total, "
                + "COUNT(*) AS orders_total, "
                + "SUM(CASE WHEN o.order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') THEN 1 ELSE 0 END) AS canceled_total, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.discount_amount > 0 THEN 1 ELSE 0 END) AS voucher_used, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND ISNULL(o.discount_amount, 0) <= 0 THEN 1 ELSE 0 END) AS voucher_not_used "
                + "FROM Orders o "
                + "WHERE o.merchant_user_id = ? AND CAST(o.created_at AS DATE) BETWEEN ? AND ?";

        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setDate(2, Date.valueOf(fromDate));
            ps.setDate(3, Date.valueOf(toDate));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.put("revenueToday", rs.getDouble("revenue_total"));
                    summary.put("yesterdayRevenue", 0d);
                    summary.put("revenue7d", rs.getDouble("revenue_total"));
                    int totalOrders = rs.getInt("orders_total");
                    int canceledTotal = rs.getInt("canceled_total");
                    summary.put("ordersToday", totalOrders);
                    summary.put("canceledToday", canceledTotal);
                    summary.put("cancelRate", totalOrders == 0 ? 0.0 : ((canceledTotal * 100.0) / totalOrders));
                    summary.put("voucherUsed7d", rs.getInt("voucher_used"));
                    summary.put("voucherNotUsed7d", rs.getInt("voucher_not_used"));
                }
            }
        } catch (java.sql.SQLException e) {
        }
        return summary;
    }

    public java.util.Map<Integer, Integer> getOrderCountByHourToday(int merchantId) {
        java.util.Map<Integer, Integer> result = new java.util.LinkedHashMap<>();
        for (int hour = 0; hour <= 23; hour++) {
            result.put(hour, 0);
        }
        String sql = "SELECT DATEPART(HOUR, created_at) AS hour_of_day, COUNT(*) AS total_orders FROM Orders WHERE merchant_user_id = ? AND CAST(created_at AS DATE) = CAST(GETDATE() AS DATE) GROUP BY DATEPART(HOUR, created_at)";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getInt("hour_of_day"), rs.getInt("total_orders"));
                }
            }
        } catch (java.sql.SQLException e) {
        }
        return result;
    }

    public java.util.Map<Integer, Integer> getOrderCountByHourInRange(int merchantId, LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
            return getOrderCountByHourToday(merchantId);
        }

        java.util.Map<Integer, Integer> result = new java.util.LinkedHashMap<>();
        for (int hour = 0; hour <= 23; hour++) {
            result.put(hour, 0);
        }

        String sql = "SELECT DATEPART(HOUR, created_at) AS hour_of_day, COUNT(*) AS total_orders "
                + "FROM Orders "
                + "WHERE merchant_user_id = ? AND created_at >= ? AND created_at < ? "
                + "GROUP BY DATEPART(HOUR, created_at)";

        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setTimestamp(2, Timestamp.valueOf(fromDate.atStartOfDay()));
            ps.setTimestamp(3, Timestamp.valueOf(toDate.plusDays(1).atStartOfDay()));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getInt("hour_of_day"), rs.getInt("total_orders"));
                }
            }
        } catch (java.sql.SQLException e) {
        }

        return result;
    }

    private Timestamp parseStartDateTime(String dateTimeRaw) {
        if (dateTimeRaw == null || dateTimeRaw.trim().isEmpty()) {
            return null;
        }
        try {
            return Timestamp.valueOf(LocalDateTime.parse(dateTimeRaw.trim().replace(" ", "T")));
        } catch (DateTimeParseException ignored) {
            try {
                LocalDate date = LocalDate.parse(dateTimeRaw.trim());
                return Timestamp.valueOf(date.atStartOfDay());
            } catch (DateTimeParseException ignoredAgain) {
                return null;
            }
        }
    }

    private Timestamp parseEndDateTime(String dateTimeRaw) {
        if (dateTimeRaw == null || dateTimeRaw.trim().isEmpty()) {
            return null;
        }
        try {
            return Timestamp.valueOf(LocalDateTime.parse(dateTimeRaw.trim().replace(" ", "T")));
        } catch (DateTimeParseException ignored) {
            try {
                LocalDate date = LocalDate.parse(dateTimeRaw.trim());
                return Timestamp.valueOf(LocalDateTime.of(date, LocalTime.MAX));
            } catch (DateTimeParseException ignoredAgain) {
                return null;
            }
        }
    }

    public com.clickeat.model.Order findByCode(String orderCode) {
        String sql = "SELECT o.*, mp.shop_name FROM Orders o LEFT JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id WHERE o.order_code = ?";
        return queryOne(sql, orderCode);
    }

    // Hàm tự động nhả đơn hàng nếu Shipper ngâm quá 30 phút
    public int releaseExpiredOrders() {
        String sql = "UPDATE dbo.Orders "
                + "SET shipper_user_id = NULL, "
                + "    order_status = 'READY_FOR_PICKUP', "
                + "    shipper_accepted_at = NULL "
                + "WHERE order_status = 'DELIVERING' "
                + "  AND shipper_accepted_at IS NOT NULL "
                + "  AND DATEDIFF(MINUTE, shipper_accepted_at, SYSUTCDATETIME()) > 30";

        try {
            return update(sql);
        } catch (Exception e) {
            System.out.println("Lỗi quét thu hồi đơn hàng: " + e.getMessage());
            return 0;
        }
    }

}
