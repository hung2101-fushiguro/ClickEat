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
import java.util.ArrayList;
import java.util.HashMap;
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
        if (columns.contains("shop_name")) {
            order.setShopName(rs.getString("shop_name"));
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
        return getOrdersByMerchantAndStatus(merchantId, statusGroup, null, null, null);
    }

    public List<Order> getOrdersByMerchantAndStatus(int merchantId, String statusGroup, String statusFilter, String fromDateTime, String toDateTime) {
        String sql = "SELECT * FROM Orders WHERE merchant_user_id = ? ";
        List<Object> params = new ArrayList<>();
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

        if (fromDateTime != null && !fromDateTime.trim().isEmpty()) {
            sql += "AND created_at >= ? ";
            params.add(java.sql.Timestamp.valueOf(fromDateTime.trim().replace("T", " ") + ":00"));
        }

        if (toDateTime != null && !toDateTime.trim().isEmpty()) {
            sql += "AND created_at <= ? ";
            params.add(java.sql.Timestamp.valueOf(toDateTime.trim().replace("T", " ") + ":59"));
        }

        sql += "ORDER BY created_at DESC";
        return query(sql, params.toArray());
    }

    public boolean updateOrderStatus(long orderId, int merchantId, String newStatus) {
        return transitionMerchantOrderStatus(orderId, merchantId, newStatus, null);
    }

    public boolean transitionMerchantOrderStatus(long orderId, int merchantId, String newStatus, String note) {
        String targetStatus = normalizeStatusForWrite(newStatus);

        String currentStatus = null;
        String fetchSql = "SELECT order_status FROM Orders WHERE id = ? AND merchant_user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(fetchSql)) {
            ps.setLong(1, orderId);
            ps.setInt(2, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentStatus = rs.getString("order_status");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
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

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, targetStatus);
                ps.setString(2, targetStatus);
                ps.setString(3, targetStatus);
                ps.setString(4, targetStatus);
                ps.setLong(5, orderId);
                ps.setInt(6, merchantId);
                ps.setString(7, currentStatus);

                int updated = ps.executeUpdate();
                if (updated <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            String historySql = "INSERT INTO OrderStatusHistory(order_id, from_status, to_status, updated_by_role, updated_by_user_id, note, created_at) "
                    + "VALUES (?, ?, ?, 'MERCHANT', ?, ?, SYSUTCDATETIME())";

            try (PreparedStatement hs = conn.prepareStatement(historySql)) {
                hs.setLong(1, orderId);
                hs.setString(2, currentStatus);
                hs.setString(3, targetStatus);
                hs.setInt(4, merchantId);
                hs.setString(5, note);
                hs.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
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

    public Map<String, Object> getDashboardSummary(int merchantId) {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND CAST(o.created_at AS DATE) = CAST(GETDATE() AS DATE) THEN o.total_amount ELSE 0 END) AS revenue_today, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND CAST(o.created_at AS DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE)) THEN o.total_amount ELSE 0 END) AS revenue_yesterday, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) THEN o.total_amount ELSE 0 END) AS revenue_7d, "
                + "SUM(CASE WHEN CAST(o.created_at AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS orders_today, "
                + "SUM(CASE WHEN CAST(o.created_at AS DATE) = CAST(GETDATE() AS DATE) AND o.order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') THEN 1 ELSE 0 END) AS canceled_today, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) AND o.discount_amount > 0 THEN 1 ELSE 0 END) AS voucher_used_7d, "
                + "SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) AND ISNULL(o.discount_amount, 0) <= 0 THEN 1 ELSE 0 END) AS voucher_not_used_7d "
                + "FROM Orders o WHERE o.merchant_user_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double revenueToday = rs.getDouble("revenue_today");
                    double revenueYesterday = rs.getDouble("revenue_yesterday");
                    double revenue7d = rs.getDouble("revenue_7d");
                    int ordersToday = rs.getInt("orders_today");
                    int canceledToday = rs.getInt("canceled_today");
                    int voucherUsed7d = rs.getInt("voucher_used_7d");
                    int voucherNotUsed7d = rs.getInt("voucher_not_used_7d");

                    double cancelRate = ordersToday == 0 ? 0 : (canceledToday * 100.0 / ordersToday);

                    summary.put("revenueToday", revenueToday);
                    summary.put("revenueYesterday", revenueYesterday);
                    summary.put("revenue7d", revenue7d);
                    summary.put("ordersToday", ordersToday);
                    summary.put("canceledToday", canceledToday);
                    summary.put("cancelRate", cancelRate);
                    summary.put("voucherUsed7d", voucherUsed7d);
                    summary.put("voucherNotUsed7d", voucherNotUsed7d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return summary;
    }

    public Map<Integer, Integer> getOrderCountByHourToday(int merchantId) {
        Map<Integer, Integer> result = new LinkedHashMap<>();
        for (int hour = 0; hour <= 23; hour++) {
            result.put(hour, 0);
        }

        String sql = "SELECT DATEPART(HOUR, created_at) AS hour_of_day, COUNT(*) AS total_orders "
                + "FROM Orders "
                + "WHERE merchant_user_id = ? AND CAST(created_at AS DATE) = CAST(GETDATE() AS DATE) "
                + "GROUP BY DATEPART(HOUR, created_at)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int hour = rs.getInt("hour_of_day");
                    result.put(hour, rs.getInt("total_orders"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
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

    @Override
    public List<Order> findAll() {
        return query("SELECT * FROM Orders ORDER BY created_at DESC");
    }

    @Override
    public Order findById(int id) {
        return queryOne("SELECT * FROM Orders WHERE id = ?", id);
    }

    public Order findByCode(String orderCode) {
        String sql = "SELECT o.*, mp.shop_name FROM Orders o "
                + "LEFT JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id "
                + "WHERE o.order_code = ?";
        return queryOne(sql, orderCode);
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

    // --- Customer-facing queries ---
    public List<Order> getCustomerOrders(int customerId) {
        String sql = "SELECT o.*, mp.shop_name FROM Orders o "
                + "LEFT JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id "
                + "WHERE o.customer_user_id = ? ORDER BY o.created_at DESC";
        return query(sql, customerId);
    }

    public Order getOrderByIdAndCustomer(int orderId, int customerId) {
        String sql = "SELECT o.*, mp.shop_name FROM Orders o "
                + "LEFT JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id "
                + "WHERE o.id = ? AND o.customer_user_id = ?";
        return queryOne(sql, orderId, customerId);
    }

    public String getCustomerFoodHistory(int customerId, int days) {
        String sql = "SELECT TOP 12 oi.item_name_snapshot, SUM(oi.quantity) AS total_qty "
                + "FROM Orders o "
                + "JOIN OrderItems oi ON oi.order_id = o.id "
                + "WHERE o.customer_user_id = ? AND o.created_at >= DATEADD(day, -?, GETDATE()) "
                + "GROUP BY oi.item_name_snapshot "
                + "ORDER BY total_qty DESC";

        List<Object[]> rows = queryRaw(sql, customerId, days);
        if (rows.isEmpty()) {
            return "Không có lịch sử ăn uống gần đây.";
        }

        StringBuilder sb = new StringBuilder();
        for (Object[] row : rows) {
            sb.append("- ")
                    .append(String.valueOf(row[0]))
                    .append(" (")
                    .append(((Number) row[1]).intValue())
                    .append(" phần)\n");
        }
        return sb.toString();
    }

    public String getAvailableMenuContext() {
        String sql = "SELECT TOP 100 fi.name, fi.price, mp.shop_name "
                + "FROM FoodItems fi "
                + "JOIN MerchantProfiles mp ON fi.merchant_user_id = mp.user_id "
                + "WHERE fi.is_available = 1 AND mp.status = 'APPROVED' "
                + "ORDER BY mp.shop_name ASC, fi.name ASC";

        List<Object[]> rows = queryRaw(sql);
        if (rows.isEmpty()) {
            return "Chưa có thực đơn khả dụng trong hệ thống.";
        }

        StringBuilder sb = new StringBuilder();
        for (Object[] row : rows) {
            sb.append("- ")
                    .append(String.valueOf(row[0]))
                    .append(" | ")
                    .append(String.valueOf(row[1]))
                    .append("đ | ")
                    .append(String.valueOf(row[2]))
                    .append("\n");
        }
        return sb.toString();
    }
}
