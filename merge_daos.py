import os

def insert_methods(target_file, methods_text):
    with open(target_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    last_brace_idx = content.rfind('}')
    if last_brace_idx != -1:
        new_content = content[:last_brace_idx] + "\n" + methods_text + "\n}\n"
        with open(target_file, 'w', encoding='utf-8') as f:
            f.write(new_content)

mp_methods = """
    public MerchantProfile getByUserId(long userId) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, userId);
    }

    public boolean updateStoreInfo(long userId, String name, String phone, String address, String avatar) {
        String sql = "UPDATE MerchantProfiles SET shop_name = ?, shop_phone = ?, shop_address_line = ?, shop_avatar = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
        return update(sql, name, phone, address, avatar, userId) > 0;
    }

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
        return update(sql, isOpen, userId) > 0;
    }
"""

voucher_methods = """
    public boolean togglePublishByMerchant(int voucherId, int merchantId, boolean publish) {
        String sql = "UPDATE Vouchers SET is_published = ?, updated_at = SYSUTCDATETIME() WHERE id = ? AND merchant_user_id = ?";
        return update(sql, publish, voucherId, merchantId) > 0;
    }
"""

food_methods = """
    public java.util.List<com.clickeat.model.FoodItem> getPromotedFoods(int limit) {
        if (limit <= 0) limit = 12;
        String sql = "SELECT fi.*, mp.shop_name AS merchant_name, c.name AS category_name, " +
               "CASE WHEN fi.id % 4 = 1 THEN 27 WHEN fi.id % 4 = 2 THEN 16 WHEN fi.id % 4 = 3 THEN 24 ELSE 19 END AS discount_percent, " +
               "CASE WHEN fi.id % 4 = 1 THEN ROUND(fi.price / 0.73, 0) WHEN fi.id % 4 = 2 THEN ROUND(fi.price / 0.84, 0) WHEN fi.id % 4 = 3 THEN ROUND(fi.price / 0.76, 0) ELSE ROUND(fi.price / 0.81, 0) END AS original_price " +
               "FROM FoodItems fi " +
               "INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id " +
               "INNER JOIN Categories c ON c.id = fi.category_id " +
               "WHERE fi.is_available = 1 AND mp.status = 'APPROVED' " +
               "ORDER BY discount_percent DESC, fi.id DESC " +
               "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        return query(sql, limit);
    }

    public boolean toggleStatus(int itemId, int merchantId, boolean isAvailable) {
        return toggleStatus(itemId, merchantId, isAvailable, null);
    }

    public boolean toggleStatus(int itemId, int merchantId, boolean isAvailable, String reason) {
        String sqlWithReason = "UPDATE FoodItems SET is_available = ?, out_of_stock_reason = ?, updated_at = SYSUTCDATETIME() WHERE id = ? AND merchant_user_id = ?";
        String finalReason = isAvailable ? null : reason;
        int updated = update(sqlWithReason, isAvailable, finalReason, itemId, merchantId);
        if (updated > 0) return true;
        String fallbackSql = "UPDATE FoodItems SET is_available = ?, updated_at = SYSUTCDATETIME() WHERE id = ? AND merchant_user_id = ?";
        return update(fallbackSql, isAvailable, itemId, merchantId) > 0;
    }

    public int bulkToggleStatus(java.util.List<Integer> itemIds, int merchantId, boolean isAvailable, String reason) {
        if (itemIds == null || itemIds.isEmpty()) return 0;
        int affected = 0;
        for (Integer itemId : itemIds) {
            if (itemId == null) continue;
            if (toggleStatus(itemId, merchantId, isAvailable, reason)) affected++;
        }
        return affected;
    }
"""

order_methods = """
    public java.util.List<com.clickeat.model.Order> getOrdersByMerchantAndStatus(int merchantId, String statusGroup, String statusFilter, String fromDateTime, String toDateTime) {
        String sql = "SELECT * FROM Orders WHERE merchant_user_id = ? ";
        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(merchantId);

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            String normalized = statusFilter.trim().toUpperCase();
            if ("PENDING".equals(normalized)) sql += "AND order_status IN ('CREATED', 'PAID') ";
            else if ("CONFIRMED".equals(normalized)) sql += "AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ";
            else if ("CANCELLED".equals(normalized)) sql += "AND order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') ";
            else { sql += "AND order_status = ? "; params.add(normalized); }
        } else if ("pending".equals(statusGroup)) { sql += "AND order_status IN ('CREATED', 'PAID') "; }
        else if ("preparing".equals(statusGroup)) { sql += "AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') "; }
        else if ("ready".equals(statusGroup)) { sql += "AND order_status IN ('READY_FOR_PICKUP', 'DELIVERING', 'PICKED_UP') "; }
        else if ("completed".equals(statusGroup)) { sql += "AND order_status IN ('DELIVERED', 'CANCELLED', 'FAILED', 'MERCHANT_REJECTED', 'REFUNDED') "; }

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

    public boolean transitionMerchantOrderStatus(long orderId, int merchantId, String newStatus, String note) {
        String targetStatus = normalizeStatusForWrite(newStatus);
        String currentStatus = null;
        String fetchSql = "SELECT order_status FROM Orders WHERE id = ? AND merchant_user_id = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(fetchSql)) {
            ps.setLong(1, orderId); ps.setInt(2, merchantId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) currentStatus = rs.getString("order_status");
            }
        } catch (java.sql.SQLException e) { return false; }

        if (currentStatus == null) return false;
        String fromStatus = normalizeStatusForTransition(currentStatus);
        if (!isMerchantTransitionAllowed(fromStatus, targetStatus)) return false;
        if (fromStatus.equals(targetStatus)) return true;

        String updateSql = "UPDATE Orders SET order_status = ?, "
                + "accepted_at = CASE WHEN ? = 'PREPARING' AND accepted_at IS NULL THEN SYSUTCDATETIME() ELSE accepted_at END, "
                + "ready_at = CASE WHEN ? = 'READY_FOR_PICKUP' AND ready_at IS NULL THEN SYSUTCDATETIME() ELSE ready_at END, "
                + "cancelled_at = CASE WHEN ? = 'CANCELLED' AND cancelled_at IS NULL THEN SYSUTCDATETIME() ELSE cancelled_at END "
                + "WHERE id = ? AND merchant_user_id = ? AND order_status = ?";

        try (java.sql.Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (java.sql.PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, targetStatus); ps.setString(2, targetStatus); ps.setString(3, targetStatus); ps.setString(4, targetStatus);
                ps.setLong(5, orderId); ps.setInt(6, merchantId); ps.setString(7, currentStatus);
                if (ps.executeUpdate() <= 0) { conn.rollback(); return false; }
            }
            String historySql = "INSERT INTO OrderStatusHistory(order_id, from_status, to_status, updated_by_role, updated_by_user_id, note, created_at) VALUES (?, ?, ?, 'MERCHANT', ?, ?, SYSUTCDATETIME())";
            try (java.sql.PreparedStatement hs = conn.prepareStatement(historySql)) {
                hs.setLong(1, orderId); hs.setString(2, currentStatus); hs.setString(3, targetStatus);
                hs.setInt(4, merchantId); hs.setString(5, note); hs.executeUpdate();
            }
            conn.commit(); return true;
        } catch (java.sql.SQLException e) { return false; }
    }

    private String normalizeStatusForWrite(String status) {
        if (status == null) return "";
        String normalized = status.trim().toUpperCase();
        if ("MERCHANT_REJECTED".equals(normalized)) return "CANCELLED";
        if ("PENDING".equals(normalized)) return "CREATED";
        if ("CONFIRMED".equals(normalized)) return "PREPARING";
        return normalized;
    }

    private String normalizeStatusForTransition(String status) {
        if (status == null) return "";
        String normalized = status.trim().toUpperCase();
        if ("PAID".equals(normalized) || "CREATED".equals(normalized)) return "PENDING";
        if ("MERCHANT_ACCEPTED".equals(normalized) || "PREPARING".equals(normalized)) return "CONFIRMED";
        if ("MERCHANT_REJECTED".equals(normalized)) return "CANCELLED";
        return normalized;
    }

    private boolean isMerchantTransitionAllowed(String fromStatus, String targetStatus) {
        if ("PENDING".equals(fromStatus)) return "PREPARING".equals(targetStatus) || "CANCELLED".equals(targetStatus);
        if ("CONFIRMED".equals(fromStatus)) return "READY_FOR_PICKUP".equals(targetStatus) || "CANCELLED".equals(targetStatus);
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
                    summary.put("cancelRate", rs.getInt("orders_today") == 0 ? 0.0 : (canceledToday * 100.0 / rs.getInt("orders_today")));
                    summary.put("voucherUsed7d", rs.getInt("voucher_used_7d"));
                    summary.put("voucherNotUsed7d", rs.getInt("voucher_not_used_7d"));
                }
            }
        } catch (java.sql.SQLException e) {}
        return summary;
    }

    public java.util.Map<Integer, Integer> getOrderCountByHourToday(int merchantId) {
        java.util.Map<Integer, Integer> result = new java.util.LinkedHashMap<>();
        for (int hour = 0; hour <= 23; hour++) result.put(hour, 0);
        String sql = "SELECT DATEPART(HOUR, created_at) AS hour_of_day, COUNT(*) AS total_orders FROM Orders WHERE merchant_user_id = ? AND CAST(created_at AS DATE) = CAST(GETDATE() AS DATE) GROUP BY DATEPART(HOUR, created_at)";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) result.put(rs.getInt("hour_of_day"), rs.getInt("total_orders"));
            }
        } catch (java.sql.SQLException e) {}
        return result;
    }

    public com.clickeat.model.Order findByCode(String orderCode) {
        String sql = "SELECT o.*, mp.shop_name FROM Orders o LEFT JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id WHERE o.order_code = ?";
        return queryOne(sql, orderCode);
    }
"""

base_dir = "c:/Users/DELL/Desktop/ClickEat-main (2)/src/main/java/com/clickeat/dal/impl/"
insert_methods(base_dir + "MerchantProfileDAO.java", mp_methods)
insert_methods(base_dir + "VoucherDAO.java", voucher_methods)
insert_methods(base_dir + "FoodItemDAO.java", food_methods)
insert_methods(base_dir + "OrderDAO.java", order_methods)
print("Merge complete.")
