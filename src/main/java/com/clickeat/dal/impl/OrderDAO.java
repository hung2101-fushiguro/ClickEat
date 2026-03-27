package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import com.clickeat.dal.interfaces.IOrderDAO;
import com.clickeat.model.CustomerProfile;
import com.clickeat.model.FoodItem;
import com.clickeat.model.Order;

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

    public Order getOrderByCode(String orderCode) {
        if (orderCode == null || orderCode.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT * FROM Orders WHERE order_code = ?";
        List<Order> list = query(sql, orderCode.trim());
        return list.isEmpty() ? null : list.get(0);
    }


    /**
     * Lấy các đơn hàng đã giao hôm qua của customer, kèm tên quán và avatar.
     * Dùng để hiển thị widget "Đã ăn hôm qua" trên trang AI Chat.
     */
    public List<Map<String, Object>> getYesterdayOrdersWithMerchant(long customerId) {
        List<Map<String, Object>> result = new java.util.ArrayList<>();
        String sql = "SELECT TOP (5) o.id, o.order_code, o.delivered_at, o.total_amount, "
                + "mp.shop_name, mp.shop_avatar "
                + "FROM Orders o "
                + "JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id "
                + "WHERE o.customer_user_id = ? "
                + "AND o.order_status = 'DELIVERED' "
                + "AND CAST(o.delivered_at AS DATE) = CAST(DATEADD(day, -1, GETDATE()) AS DATE) "
                + "ORDER BY o.delivered_at DESC";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long orderId = rs.getLong("id");
                    Map<String, Object> row = new java.util.LinkedHashMap<>();
                    row.put("orderId", orderId);
                    row.put("orderCode", rs.getString("order_code"));
                    row.put("shopName", rs.getString("shop_name"));
                    row.put("shopAvatar", rs.getString("shop_avatar"));
                    row.put("deliveredAt", rs.getTimestamp("delivered_at"));
                    row.put("totalAmount", rs.getDouble("total_amount"));
                    row.put("itemSummary", getOrderItemsSummary(conn, orderId, 3));
                    row.put("totalItems", getOrderItemsCount(conn, orderId));
                    result.add(row);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    private String getOrderItemsSummary(Connection conn, long orderId, int maxItems) {
        String sql = "SELECT TOP (?) oi.item_name_snapshot, oi.quantity "
                + "FROM OrderItems oi WHERE oi.order_id = ? ORDER BY oi.id ASC";
        List<String> lines = new ArrayList<>();

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, maxItems));
            ps.setLong(2, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("item_name_snapshot");
                    int qty = rs.getInt("quantity");
                    if (name != null && !name.isBlank()) {
                        lines.add((qty > 1 ? qty + "x " : "") + name.trim());
                    }
                }
            }
        } catch (SQLException e) {
            return "";
        }

        return String.join(", ", lines);
    }

    private int getOrderItemsCount(Connection conn, long orderId) {
        String sql = "SELECT ISNULL(SUM(quantity), 0) AS total_qty FROM OrderItems WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_qty");
                }
            }
        } catch (SQLException e) {
            return 0;
        }
        return 0;
    }

    /**
     * Lấy quán được đặt nhiều nhất (yêu thích nhất) của customer. Dùng để hiển
     * thị widget "Cửa hàng yêu thích" trên trang AI Chat.
     */
    public Map<String, Object> getFavoriteMerchant(long customerId) {
        String sql = "SELECT TOP (1) mp.shop_name, mp.shop_avatar, "
                + "COALESCE(rt.avg_rating, 0) AS avg_rating, "
                + "COUNT(o.id) AS order_count "
                + "FROM Orders o "
                + "JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id "
                + "LEFT JOIN ("
                + "    SELECT r.target_user_id, AVG(CAST(r.stars AS FLOAT)) AS avg_rating "
                + "    FROM Ratings r "
                + "    WHERE r.target_type = 'MERCHANT' "
                + "    GROUP BY r.target_user_id"
                + ") rt ON rt.target_user_id = mp.user_id "
                + "WHERE o.customer_user_id = ? AND o.order_status = 'DELIVERED' "
                + "GROUP BY mp.user_id, mp.shop_name, mp.shop_avatar, rt.avg_rating "
                + "ORDER BY order_count DESC";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> row = new java.util.LinkedHashMap<>();
                    row.put("shopName", rs.getString("shop_name"));
                    row.put("shopAvatar", rs.getString("shop_avatar"));
                    double rating = rs.getDouble("avg_rating");
                    row.put("avgRating", rating > 0 ? String.format("%.1f", rating) : "Mới");
                    row.put("orderCount", rs.getInt("order_count"));
                    return row;
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<String> getTopOrderedFoodNames(long customerId, int days, int limit) {
        int safeDays = Math.max(1, Math.min(days, 60));
        int safeLimit = Math.max(1, Math.min(limit, 5));
        List<String> foods = new ArrayList<>();

        String sql = "SELECT TOP (?) fi.name, COUNT(oi.id) AS times_ordered "
                + "FROM Orders o "
                + "JOIN OrderItems oi ON o.id = oi.order_id "
                + "JOIN FoodItems fi ON oi.food_item_id = fi.id "
                + "WHERE o.customer_user_id = ? "
                + "AND o.order_status = 'DELIVERED' "
                + "AND o.created_at >= DATEADD(DAY, -?, GETDATE()) "
                + "GROUP BY fi.name "
                + "ORDER BY times_ordered DESC, MAX(o.created_at) DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeLimit);
            ps.setLong(2, customerId);
            ps.setInt(3, safeDays);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("name");
                    if (name != null && !name.isBlank()) {
                        foods.add(name.trim());
                    }
                }
            }
        } catch (SQLException e) {
            return new ArrayList<>();
        }

        return foods;
    }

    // Thêm hàm này vào OrderDAO.java
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

    public String getPersonalizedMenuContext(CustomerProfile profile, int limit) {
        if (profile == null) {
            return getAvailableMenuContext();
        }

        int safeLimit = Math.max(5, Math.min(limit, 40));
        String sql = "SELECT TOP 200 m.shop_name, c.name AS category_name, f.name AS food_name, f.description, "
                + "f.price, f.is_fried, f.calories, f.protein_g, f.carbs_g, f.fat_g "
                + "FROM FoodItems f "
                + "JOIN Categories c ON f.category_id = c.id "
                + "JOIN MerchantProfiles m ON f.merchant_user_id = m.user_id "
                + "WHERE f.is_available = 1 AND m.status = 'APPROVED'";

        Set<String> allergyTokens = splitTokens(profile.getAllergies());
        Set<String> preferenceTokens = splitTokens(profile.getFoodPreferences());
        String goal = safe(profile.getHealthGoal());
        int dailyCalorieTarget = profile.getDailyCalorieTarget() == null ? 0 : profile.getDailyCalorieTarget();

        List<MenuCandidate> candidates = new ArrayList<>();
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql); java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String shopName = rs.getString("shop_name");
                String category = rs.getString("category_name");
                String foodName = rs.getString("food_name");
                String description = rs.getString("description");
                long price = rs.getLong("price");
                boolean isFried = rs.getBoolean("is_fried");
                int calories = rs.getInt("calories");
                double protein = rs.getDouble("protein_g");
                double carbs = rs.getDouble("carbs_g");
                double fat = rs.getDouble("fat_g");

                String textBag = normalizeText(foodName + " " + category + " " + safe(description));
                if (containsAnyToken(textBag, allergyTokens)) {
                    continue;
                }

                double score = scoreByPreference(textBag, preferenceTokens);
                score += scoreByHealthGoal(goal, isFried, calories, protein, carbs, fat, dailyCalorieTarget);
                candidates.add(new MenuCandidate(shopName, category, foodName, price, isFried, calories, protein, carbs, fat, score));
            }
        } catch (SQLException e) {
            return getAvailableMenuContext();
        }

        if (candidates.isEmpty()) {
            return "Không tìm thấy món phù hợp với hồ sơ dị ứng/mục tiêu sức khỏe hiện tại.";
        }

        candidates.sort(Comparator.comparingDouble(MenuCandidate::score).reversed());
        StringBuilder sb = new StringBuilder("THỰC ĐƠN CÁ NHÂN HÓA CHO KHÁCH (đã lọc dị ứng và ưu tiên mục tiêu sức khỏe):\n");
        int count = 0;
        for (MenuCandidate c : candidates) {
            if (count >= safeLimit) {
                break;
            }
            count++;
            sb.append("- Quán [").append(c.shopName).append("]")
                    .append(" | Thể loại: ").append(c.category)
                    .append(" | Món: ").append(c.foodName)
                    .append(" (").append(c.price).append("đ)")
                    .append(c.isFried ? " [Đồ chiên]" : " [Không chiên]")
                    .append(c.calories > 0 ? " [" + c.calories + " kcal]" : "")
                    .append(c.protein > 0 ? " [Protein " + trimDouble(c.protein) + "g]" : "")
                    .append(" [Điểm ").append(trimDouble(c.score)).append("]")
                    .append("\n");
        }
        return sb.toString();
    }

    public List<FoodItem> getRecommendedFoodCards(CustomerProfile profile,
            String query,
            int limit,
            Double userLatitude,
            Double userLongitude) {
        int safeLimit = Math.max(2, Math.min(limit, 6));
        double maxDeliveryKm = resolveMaxDeliveryKm();
        String sql = "SELECT TOP 250 f.id, f.merchant_user_id, f.category_id, f.name, f.description, "
                + "f.price, f.image_url, f.is_fried, f.calories, f.protein_g, f.carbs_g, f.fat_g, "
                + "c.name AS category_name, m.shop_name, m.latitude AS shop_latitude, m.longitude AS shop_longitude "
                + "FROM FoodItems f "
                + "JOIN Categories c ON f.category_id = c.id "
                + "JOIN MerchantProfiles m ON f.merchant_user_id = m.user_id "
                + "WHERE f.is_available = 1 AND m.status = 'APPROVED'";

        Set<String> allergyTokens = profile == null ? new HashSet<>() : splitTokens(profile.getAllergies());
        Set<String> preferenceTokens = profile == null ? new HashSet<>() : splitTokens(profile.getFoodPreferences());
        String goal = profile == null ? "" : safe(profile.getHealthGoal());
        int dailyCalorieTarget = profile == null || profile.getDailyCalorieTarget() == null ? 0 : profile.getDailyCalorieTarget();
        Set<String> queryTokens = splitSearchTokens(query);

        List<CardCandidate> candidates = new ArrayList<>();
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql); java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String foodName = rs.getString("name");
                String category = rs.getString("category_name");
                String description = rs.getString("description");
                String textBag = normalizeText(foodName + " " + category + " " + safe(description));

                if (containsAnyToken(textBag, allergyTokens)) {
                    continue;
                }

                boolean matchedQuery = queryTokens.isEmpty() || containsAnyToken(textBag, queryTokens);
                double score = matchedQuery ? 3.0 : 0.0;
                score += scoreByPreference(textBag, preferenceTokens);
                score += scoreByHealthGoal(goal,
                        rs.getBoolean("is_fried"),
                        rs.getInt("calories"),
                        rs.getDouble("protein_g"),
                        rs.getDouble("carbs_g"),
                        rs.getDouble("fat_g"),
                        dailyCalorieTarget);

                if (!queryTokens.isEmpty() && !matchedQuery) {
                    score -= 0.8;
                }

                Double shopLat = toNullableDouble(rs.getObject("shop_latitude"));
                Double shopLng = toNullableDouble(rs.getObject("shop_longitude"));
                Double distanceKm = distanceKm(userLatitude, userLongitude, shopLat, shopLng);

                if (distanceKm != null && maxDeliveryKm > 0 && distanceKm > maxDeliveryKm) {
                    continue;
                }
                score += scoreByDistance(distanceKm);

                FoodItem item = new FoodItem();
                item.setId(rs.getInt("id"));
                item.setMerchantUserId(rs.getInt("merchant_user_id"));
                item.setCategoryId(rs.getInt("category_id"));
                item.setName(foodName);
                item.setDescription(description);
                item.setPrice(rs.getDouble("price"));
                item.setImageUrl(rs.getString("image_url"));
                item.setFried(rs.getBoolean("is_fried"));
                item.setCalories(rs.getInt("calories"));
                item.setProteinG(rs.getDouble("protein_g"));
                item.setCarbsG(rs.getDouble("carbs_g"));
                item.setFatG(rs.getDouble("fat_g"));
                item.setCategoryName(category);
                item.setMerchantName(rs.getString("shop_name"));

                candidates.add(new CardCandidate(item, score));
            }
        } catch (SQLException e) {
            return new ArrayList<>();
        }

        candidates.sort(Comparator.comparingDouble(CardCandidate::score).reversed());
        List<FoodItem> result = new ArrayList<>();
        for (CardCandidate candidate : candidates) {
            result.add(candidate.item);
            if (result.size() >= safeLimit) {
                break;
            }
        }
        return result;
    }

    private Set<String> splitSearchTokens(String raw) {
        Set<String> tokens = new HashSet<>();
        String normalized = normalizeText(raw);
        if (normalized.isEmpty()) {
            return tokens;
        }
        String[] parts = normalized.split("[^a-z0-9]+");
        for (String part : parts) {
            if (part.length() >= 2) {
                tokens.add(part);
            }
        }
        return tokens;
    }

    private double scoreByDistance(Double distanceKm) {
        if (distanceKm == null) {
            return 0;
        }
        if (distanceKm <= 2) {
            return 2.5;
        }
        if (distanceKm <= 5) {
            return 1.5;
        }
        if (distanceKm <= 8) {
            return 0.7;
        }
        if (distanceKm <= 12) {
            return 0.2;
        }
        return -0.8;
    }

    private Double toNullableDouble(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.doubleValue();
        }
        try {
            return Double.parseDouble(String.valueOf(value));
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private Double distanceKm(Double lat1, Double lng1, Double lat2, Double lng2) {
        if (!isValidCoord(lat1, lng1) || !isValidCoord(lat2, lng2)) {
            return null;
        }
        double r = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return r * c;
    }

    private boolean isValidCoord(Double lat, Double lng) {
        return lat != null && lng != null
                && lat >= -90 && lat <= 90
                && lng >= -180 && lng <= 180;
    }

    private double resolveMaxDeliveryKm() {
        double fallback = 12.0;
        String fromProperty = System.getProperty("clickeat.shipping.maxDistanceKm");
        if (fromProperty != null && !fromProperty.isBlank()) {
            try {
                return Math.max(0, Double.parseDouble(fromProperty.trim()));
            } catch (NumberFormatException ignored) {
                return fallback;
            }
        }

        String fromEnv = System.getenv("CLICKEAT_SHIPPING_MAX_DISTANCE_KM");
        if (fromEnv != null && !fromEnv.isBlank()) {
            try {
                return Math.max(0, Double.parseDouble(fromEnv.trim()));
            } catch (NumberFormatException ignored) {
                return fallback;
            }
        }
        return fallback;
    }

    private double scoreByPreference(String textBag, Set<String> preferenceTokens) {
        if (preferenceTokens.isEmpty()) {
            return 0;
        }
        double score = 0;
        for (String token : preferenceTokens) {
            if (token.length() < 2) {
                continue;
            }
            if (textBag.contains(token)) {
                score += 2.0;
            }
        }
        return score;
    }

    private double scoreByHealthGoal(String goal, boolean isFried, int calories, double protein, double carbs, double fat, int dailyCalorieTarget) {
        String normalizedGoal = normalizeText(goal);
        double score = 0;

        if (normalizedGoal.contains("giam can") || normalizedGoal.contains("eat clean") || normalizedGoal.contains("healthy")) {
            if (!isFried) {
                score += 1.5;
            } else {
                score -= 2.5;
            }
            if (calories > 0 && calories <= 550) {
                score += 1.5;
            } else if (calories > 750) {
                score -= 1.5;
            }
        }

        if (normalizedGoal.contains("tang co") || normalizedGoal.contains("muscle") || normalizedGoal.contains("protein")) {
            if (protein >= 25) {
                score += 2.0;
            } else if (protein >= 15) {
                score += 1.0;
            }
            if (calories > 350 && calories < 850) {
                score += 0.5;
            }
        }

        if (normalizedGoal.contains("tieu duong") || normalizedGoal.contains("it duong") || normalizedGoal.contains("giam duong")) {
            if (calories > 700) {
                score -= 1.5;
            }
            if (!isFried) {
                score += 1.0;
            }
        }

        if (dailyCalorieTarget > 0 && calories > 0) {
            double expectedMealCalories = dailyCalorieTarget / 3.0;
            double delta = Math.abs(calories - expectedMealCalories);
            if (delta <= 120) {
                score += 1.0;
            } else if (delta > 300) {
                score -= 0.5;
            }
        }

        if (fat > 0 && fat <= 18) {
            score += 0.4;
        }
        if (carbs > 0 && carbs > 90) {
            score -= 0.4;
        }
        return score;
    }

    private String normalizeText(String raw) {
        if (raw == null) {
            return "";
        }
        String normalized = Normalizer.normalize(raw, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT)
                .trim();
        return normalized;
    }

    private String safe(String text) {
        return text == null ? "" : text;
    }

    private Set<String> splitTokens(String raw) {
        Set<String> tokens = new HashSet<>();
        String normalized = normalizeText(raw);
        if (normalized.isEmpty()) {
            return tokens;
        }
        String[] parts = normalized.split("[,;|\\n\\r\\t]");
        for (String part : parts) {
            String token = part.trim();
            if (token.length() >= 2) {
                tokens.add(token);
            }
        }
        return tokens;
    }

    private boolean containsAnyToken(String text, Set<String> tokens) {
        if (tokens.isEmpty()) {
            return false;
        }
        for (String token : tokens) {
            if (text.contains(token)) {
                return true;
            }
        }
        return false;
    }

    private String trimDouble(double value) {
        if (Math.abs(value - Math.rint(value)) < 0.0001) {
            return String.valueOf((long) Math.rint(value));
        }
        return String.format(Locale.US, "%.1f", value);
    }

    private static final class MenuCandidate {

        private final String shopName;
        private final String category;
        private final String foodName;
        private final long price;
        private final boolean isFried;
        private final int calories;
        private final double protein;
        private final double carbs;
        private final double fat;
        private final double score;

        private MenuCandidate(String shopName, String category, String foodName, long price, boolean isFried,
                int calories, double protein, double carbs, double fat, double score) {
            this.shopName = shopName;
            this.category = category;
            this.foodName = foodName;
            this.price = price;
            this.isFried = isFried;
            this.calories = calories;
            this.protein = protein;
            this.carbs = carbs;
            this.fat = fat;
            this.score = score;
        }

        private double score() {
            return score;
        }
    }

    private static final class CardCandidate {

        private final FoodItem item;
        private final double score;

        private CardCandidate(FoodItem item, double score) {
            this.item = item;
            this.score = score;
        }

        private double score() {
            return score;
        }
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

    public Map<String, Integer> getRatingTargetsForDeliveredOrder(int orderId, int customerId) {
        String sql = "SELECT merchant_user_id, shipper_user_id "
                + "FROM Orders "
                + "WHERE id = ? AND customer_user_id = ? AND order_status = 'DELIVERED'";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                Map<String, Integer> result = new HashMap<>();
                result.put("merchantUserId", rs.getInt("merchant_user_id"));

                int shipperId = rs.getInt("shipper_user_id");
                if (rs.wasNull()) {
                    shipperId = 0;
                }
                result.put("shipperUserId", shipperId);
                return result;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
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

    @Override
    public List<Order> findAll() {
        return query("SELECT * FROM Orders ORDER BY created_at DESC");
    }

    @Override
    public Order findById(int id) {
        return queryOne("SELECT * FROM Orders WHERE id = ?", id);
    }

    public Order findById(Connection conn, int id) throws SQLException {
        String sql = "SELECT * FROM Orders WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public int insert(Order order) {
        return insert(null, order);
    }

    public int insert(Connection conn, Order order) {
        String sql = """
        INSERT INTO Orders(
            order_code, customer_user_id, guest_id, merchant_user_id, shipper_user_id,
            receiver_name, receiver_phone, delivery_address_line,
            province_code, province_name, district_code, district_name, ward_code, ward_name,
            latitude, longitude, delivery_note,
            payment_method, payment_status, order_status,
            subtotal_amount, delivery_fee, discount_amount, total_amount,
            created_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSUTCDATETIME())
    """;

        Object[] params = new Object[]{
            order.getOrderCode(),
            order.getCustomerUserId() == 0 ? null : order.getCustomerUserId(),
            order.getGuestId(),
            order.getMerchantId(),
            order.getShipperUserId() == 0 ? null : order.getShipperUserId(),
            order.getReceiverName(),
            order.getReceiverPhone(),
            order.getDeliveryAddressLine(),
            order.getProvinceCode(),
            order.getProvinceName(),
            order.getDistrictCode(),
            order.getDistrictName(),
            order.getWardCode(),
            order.getWardName(),
            order.getLatitude() == 0 ? null : order.getLatitude(),
            order.getLongitude() == 0 ? null : order.getLongitude(),
            order.getDeliveryNote(),
            order.getPaymentMethod(),
            order.getPaymentStatus(),
            order.getOrderStatus(),
            order.getSubtotalAmount(),
            order.getDeliveryFee(),
            order.getDiscountAmount(),
            order.getTotalAmount()
        };

        try {
            if (conn != null) {
                return update(conn, sql, params);
            }
            return update(sql, params);
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
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

    public com.clickeat.model.Order findByCode(String orderCode) {
        String sql = "SELECT o.*, mp.shop_name FROM Orders o LEFT JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id WHERE o.order_code = ?";
        return queryOne(sql, orderCode);
    }

    public String generateOrderCode() {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
        return "CE-" + sdf.format(new java.util.Date());
    }

    public boolean updatePaymentAndOrderStatus(int orderId, String paymentStatus, String orderStatus) {
        String sql = """
        UPDATE Orders
        SET payment_status = ?,
            order_status = ?
        WHERE id = ?
    """;
        return update(sql, paymentStatus, orderStatus, orderId) > 0;
    }

    public boolean markPaidByVnpay(int orderId) {
        return markPaidByVnpay(null, orderId);
    }

    public boolean markPaidByVnpay(Connection conn, int orderId) {
        String sql = """
        UPDATE Orders
        SET payment_status = 'PAID',
            order_status = 'PAID'
        WHERE id = ?
    """;
        try {
            if (conn != null) {
                return update(conn, sql, orderId) > 0;
            }
            return update(sql, orderId) > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean markPaymentFailed(int orderId) {
        return markPaymentFailed(null, orderId);
    }

    public boolean markPaymentFailed(Connection conn, int orderId) {
        String sql = """
        UPDATE Orders
        SET payment_status = 'FAILED',
            order_status = 'FAILED'
        WHERE id = ?
    """;
        try {
            if (conn != null) {
                return update(conn, sql, orderId) > 0;
            }
            return update(sql, orderId) > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public int releaseExpiredOrders() {
        String sql = """
            UPDATE Orders
            SET order_status = 'FAILED'
            WHERE order_status IN ('CREATED', 'PAID')
              AND created_at < DATEADD(MINUTE, -30, SYSUTCDATETIME())
        """;
        return update(sql);
    }

    public int countOrdersByMerchantAndStatus(int merchantId, String statusGroup, String statusFilter, String fromDateTime, String toDateTime) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Orders WHERE merchant_user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(merchantId);

        appendMerchantOrderFilters(sql, params, statusGroup, statusFilter, fromDateTime, toDateTime);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            return 0;
        }
        return 0;
    }

    public List<Order> getOrdersByMerchantAndStatus(int merchantId, String statusGroup, String statusFilter, String fromDateTime, String toDateTime, int page, int pageSize) {
        StringBuilder sql = new StringBuilder("SELECT * FROM Orders WHERE merchant_user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(merchantId);

        appendMerchantOrderFilters(sql, params, statusGroup, statusFilter, fromDateTime, toDateTime);
        sql.append(" ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        int offset = Math.max(0, (page - 1) * pageSize);
        params.add(offset);
        params.add(pageSize);

        return query(sql.toString(), params.toArray());
    }

    public Map<String, Integer> getOrderStatusBreakdown(int merchantId, int days) {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = """
            SELECT order_status, COUNT(*) AS total
            FROM Orders
            WHERE merchant_user_id = ?
              AND created_at >= DATEADD(DAY, -?, SYSUTCDATETIME())
            GROUP BY order_status
        """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getString("order_status"), rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            return result;
        }
        return result;
    }

    public Map<String, Object> getDashboardSummaryByDateRange(int merchantId, LocalDate fromDate, LocalDate toDate) {
        Map<String, Object> summary = new HashMap<>();
        String sql = """
            SELECT
                SUM(CASE WHEN o.order_status = 'DELIVERED' THEN o.total_amount ELSE 0 END) AS revenue_today,
                SUM(CASE WHEN o.order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') THEN 1 ELSE 0 END) AS canceled_today,
                COUNT(*) AS orders_today,
                SUM(CASE WHEN o.order_status = 'DELIVERED' AND o.discount_amount > 0 THEN 1 ELSE 0 END) AS voucher_used_7d,
                SUM(CASE WHEN o.order_status = 'DELIVERED' AND ISNULL(o.discount_amount, 0) <= 0 THEN 1 ELSE 0 END) AS voucher_not_used_7d
            FROM Orders o
            WHERE o.merchant_user_id = ?
              AND CAST(o.created_at AS DATE) BETWEEN ? AND ?
        """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setDate(2, Date.valueOf(fromDate));
            ps.setDate(3, Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double revenue = rs.getDouble("revenue_today");
                    int orders = rs.getInt("orders_today");
                    int canceled = rs.getInt("canceled_today");
                    summary.put("revenueToday", revenue);
                    summary.put("revenueYesterday", 0d);
                    summary.put("revenue7d", revenue);
                    summary.put("ordersToday", orders);
                    summary.put("canceledToday", canceled);
                    summary.put("cancelRate", orders == 0 ? 0d : (canceled * 100.0 / orders));
                    summary.put("voucherUsed7d", rs.getInt("voucher_used_7d"));
                    summary.put("voucherNotUsed7d", rs.getInt("voucher_not_used_7d"));
                }
            }
        } catch (SQLException e) {
            return summary;
        }
        return summary;
    }

    public List<Map<String, Object>> getTopSellingFoodsInRange(int merchantId, int limit, LocalDate fromDate, LocalDate toDate) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?) item_name_snapshot, SUM(quantity) as TotalQty, SUM(unit_price_snapshot * quantity) as TotalRevenue
            FROM OrderItems oi
            JOIN Orders o ON oi.order_id = o.id
            WHERE o.merchant_user_id = ?
              AND o.order_status = 'DELIVERED'
              AND CAST(o.created_at AS DATE) BETWEEN ? AND ?
            GROUP BY item_name_snapshot
            ORDER BY TotalQty DESC
        """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, merchantId);
            ps.setDate(3, Date.valueOf(fromDate));
            ps.setDate(4, Date.valueOf(toDate));
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
            return list;
        }
        return list;
    }

    public Map<Integer, Integer> getOrderCountByHourInRange(int merchantId, LocalDate fromDate, LocalDate toDate) {
        Map<Integer, Integer> result = new LinkedHashMap<>();
        for (int hour = 0; hour <= 23; hour++) {
            result.put(hour, 0);
        }

        String sql = """
            SELECT DATEPART(HOUR, created_at) AS hour_of_day, COUNT(*) AS total_orders
            FROM Orders
            WHERE merchant_user_id = ?
              AND CAST(created_at AS DATE) BETWEEN ? AND ?
            GROUP BY DATEPART(HOUR, created_at)
        """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setDate(2, Date.valueOf(fromDate));
            ps.setDate(3, Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getInt("hour_of_day"), rs.getInt("total_orders"));
                }
            }
        } catch (SQLException e) {
            return result;
        }
        return result;
    }

    public boolean completeDeliveryWithProofAndSettlement(int orderId, int shipperId, String proofUrl) {
        // ==== SQL STATEMENTS ====
        // Lấy toàn bộ thông tin tài chính của đơn hàng
        String selectSql = "SELECT merchant_user_id, subtotal_amount, delivery_fee, discount_amount, "
                + "total_amount, payment_method FROM Orders WHERE id = ? AND shipper_user_id = ?";
        // Cập nhật trạng thái đơn + đánh dấu COD là đã thanh toán
        String updateOrderWithProofSql = "UPDATE Orders SET order_status = 'DELIVERED', delivered_at = SYSUTCDATETIME(), "
                + "payment_status = CASE WHEN UPPER(ISNULL(payment_method, '')) = 'COD' THEN 'PAID' ELSE payment_status END, "
                + "proof_image_url = ? WHERE id = ? AND shipper_user_id = ?";
        String updateOrderNoProofSql = "UPDATE Orders SET order_status = 'DELIVERED', delivered_at = SYSUTCDATETIME(), "
                + "payment_status = CASE WHEN UPPER(ISNULL(payment_method, '')) = 'COD' THEN 'PAID' ELSE payment_status END "
                + "WHERE id = ? AND shipper_user_id = ?";
        // SQL ví Shipper
        String addShipperWalletSql    = "UPDATE ShipperWallets SET balance = balance + ?, updated_at = SYSUTCDATETIME() WHERE shipper_user_id = ?";
        String deductShipperWalletSql = "UPDATE ShipperWallets SET balance = balance - ?, updated_at = SYSUTCDATETIME() WHERE shipper_user_id = ?";
        String insertShipperWalletSql = "INSERT INTO ShipperWallets (shipper_user_id, balance, updated_at) VALUES (?, ?, SYSUTCDATETIME())";
        // SQL ví Merchant (UPSERT-safe: chỉ tạo nếu chưa có)
        String ensureMerchantWalletSql = "INSERT INTO MerchantWallets (merchant_user_id, balance, updated_at) "
                + "SELECT ?, 0, SYSUTCDATETIME() WHERE NOT EXISTS (SELECT 1 FROM MerchantWallets WHERE merchant_user_id = ?)";
        String addMerchantWalletSql   = "UPDATE MerchantWallets SET balance = balance + ?, updated_at = SYSUTCDATETIME() WHERE merchant_user_id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // ── 1. Đọc thông tin tài chính đơn hàng ──────────────────
                int    merchantId    = 0;
                double subtotal      = 0;
                double deliveryFee   = 0;
                double discountAmt   = 0;
                String paymentMethod = "COD";

                try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, shipperId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false; // Đơn không tồn tại hoặc không thuộc shipper này
                        }
                        merchantId    = rs.getInt("merchant_user_id");
                        subtotal      = rs.getDouble("subtotal_amount");
                        deliveryFee   = rs.getDouble("delivery_fee");
                        discountAmt   = rs.getDouble("discount_amount");
                        String pm     = rs.getString("payment_method");
                        paymentMethod = (pm != null) ? pm.trim().toUpperCase() : "COD";
                    }
                }

                // ── 2. Cập nhật trạng thái đơn hàng ──────────────────────
                int updated;
                if (columnExists("Orders", "proof_image_url") && proofUrl != null && !proofUrl.isBlank()) {
                    try (PreparedStatement ps = conn.prepareStatement(updateOrderWithProofSql)) {
                        ps.setString(1, proofUrl);
                        ps.setInt(2, orderId);
                        ps.setInt(3, shipperId);
                        updated = ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(updateOrderNoProofSql)) {
                        ps.setInt(1, orderId);
                        ps.setInt(2, shipperId);
                        updated = ps.executeUpdate();
                    }
                }

                if (updated <= 0) {
                    conn.rollback();
                    return false;
                }

                // ── 3. Tính toán tài chính ────────────────────────────────
                // Tiền thuần quán ăn nhận = tiền hàng - giảm giá
                double merchantRevenue = Math.max(0, subtotal - discountAmt);
                boolean isCOD = "COD".equals(paymentMethod);

                if (isCOD) {
                    /*
                     * Luồng COD:
                     *   Khách đưa TIỀN MẶT (= total_amount) cho Shipper khi nhận hàng.
                     *   Shipper phải nộp lại phần tiền hàng (merchantRevenue) cho hệ thống.
                     *   Shipper chỉ được giữ: deliveryFee (phí giao hàng).
                     *
                     *   → Ví Shipper: + deliveryFee (thu nhập)
                     *                 - merchantRevenue (tiền hàng thu hộ phải trả lại)
                     *   → Ví Merchant: + merchantRevenue
                     */

                    // 3a. Cộng phí giao hàng vào ví Shipper
                    if (deliveryFee > 0) {
                        int walletUpdated;
                        try (PreparedStatement ps = conn.prepareStatement(addShipperWalletSql)) {
                            ps.setDouble(1, deliveryFee);
                            ps.setInt(2, shipperId);
                            walletUpdated = ps.executeUpdate();
                        }
                        if (walletUpdated <= 0) {
                            // Ví Shipper chưa tồn tại → tạo mới
                            try (PreparedStatement ps = conn.prepareStatement(insertShipperWalletSql)) {
                                ps.setInt(1, shipperId);
                                ps.setDouble(2, deliveryFee);
                                ps.executeUpdate();
                            }
                        }
                    }

                    // 3b. Trừ tiền thu hộ khỏi ví Shipper (nộp lại tiền hàng)
                    if (merchantRevenue > 0) {
                        try (PreparedStatement ps = conn.prepareStatement(deductShipperWalletSql)) {
                            ps.setDouble(1, merchantRevenue);
                            ps.setInt(2, shipperId);
                            ps.executeUpdate();
                        }
                    }

                } else {
                    /*
                     * Luồng VNPAY (thanh toán online):
                     *   Khách KHÔNG đưa tiền mặt cho Shipper.
                     *   Tiền đã nằm trong ví hệ thống ClickEat.
                     *   Shipper chỉ nhận phí giao hàng (deliveryFee).
                     *
                     *   → Ví Shipper: + deliveryFee
                     *   → Ví Merchant: + merchantRevenue
                     */

                    // 3a. Cộng phí ship vào ví Shipper
                    if (deliveryFee > 0) {
                        int walletUpdated;
                        try (PreparedStatement ps = conn.prepareStatement(addShipperWalletSql)) {
                            ps.setDouble(1, deliveryFee);
                            ps.setInt(2, shipperId);
                            walletUpdated = ps.executeUpdate();
                        }
                        if (walletUpdated <= 0) {
                            try (PreparedStatement ps = conn.prepareStatement(insertShipperWalletSql)) {
                                ps.setInt(1, shipperId);
                                ps.setDouble(2, deliveryFee);
                                ps.executeUpdate();
                            }
                        }
                    }
                }

                // ── 4. Cộng tiền hàng vào ví Merchant (cả COD lẫn VNPAY) ─
                if (merchantId > 0 && merchantRevenue > 0) {
                    // Đảm bảo hàng wallet tồn tại
                    try (PreparedStatement ps = conn.prepareStatement(ensureMerchantWalletSql)) {
                        ps.setInt(1, merchantId);
                        ps.setInt(2, merchantId);
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = conn.prepareStatement(addMerchantWalletSql)) {
                        ps.setDouble(1, merchantRevenue);
                        ps.setInt(2, merchantId);
                        ps.executeUpdate();
                    }
                }

                // ── 5. Commit toàn bộ trong 1 transaction ─────────────────
                conn.commit();
                return true;

            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
                return false;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public Map<String, Object> getCustomerTrackingSnapshot(int orderId, int customerUserId) {
        String sql = "SELECT o.id, o.order_code, o.order_status, o.payment_status, o.payment_method, o.delivery_address_line, "
                + "o.latitude AS customer_lat, o.longitude AS customer_lng, "
                + "o.shipper_user_id, sa.current_latitude AS shipper_lat, sa.current_longitude AS shipper_lng, sa.updated_at AS shipper_updated_at, "
                + "u.full_name AS shipper_name, u.phone AS shipper_phone "
                + "FROM Orders o "
                + "LEFT JOIN ShipperAvailability sa ON sa.shipper_user_id = o.shipper_user_id "
                + "LEFT JOIN Users u ON u.id = o.shipper_user_id "
                + "WHERE o.id = ? AND o.customer_user_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerUserId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                Map<String, Object> data = new LinkedHashMap<>();
                data.put("orderId", rs.getInt("id"));
                data.put("orderCode", rs.getString("order_code"));
                data.put("orderStatus", rs.getString("order_status"));
                data.put("paymentStatus", rs.getString("payment_status"));
                data.put("paymentMethod", rs.getString("payment_method"));
                data.put("deliveryAddress", rs.getString("delivery_address_line"));
                data.put("customerLat", rs.getObject("customer_lat") == null ? null : rs.getDouble("customer_lat"));
                data.put("customerLng", rs.getObject("customer_lng") == null ? null : rs.getDouble("customer_lng"));
                data.put("shipperUserId", rs.getObject("shipper_user_id") == null ? null : rs.getInt("shipper_user_id"));
                data.put("shipperLat", rs.getObject("shipper_lat") == null ? null : rs.getDouble("shipper_lat"));
                data.put("shipperLng", rs.getObject("shipper_lng") == null ? null : rs.getDouble("shipper_lng"));
                data.put("shipperName", rs.getString("shipper_name"));
                data.put("shipperPhone", rs.getString("shipper_phone"));
                java.sql.Timestamp updatedAt = rs.getTimestamp("shipper_updated_at");
                data.put("shipperUpdatedAt", updatedAt == null ? null : updatedAt.getTime());
                return data;
            }
        } catch (SQLException ex) {
            return null;
        }
    }

    public List<Order> getAvailableOrdersForShipper(int shipperId) {
        // 1) Lấy vị trí hiện tại của shipper
        Double shipperLat = null;
        Double shipperLng = null;
        String sqlShipper = "SELECT current_latitude, current_longitude FROM ShipperAvailability WHERE shipper_user_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sqlShipper)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    shipperLat = rs.getObject("current_latitude") != null ? rs.getDouble("current_latitude") : null;
                    shipperLng = rs.getObject("current_longitude") != null ? rs.getDouble("current_longitude") : null;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }

        // Nếu chưa có tọa độ shipper thì không hiển thị đơn (theo ràng buộc bán kính)
        if (!isValidCoord(shipperLat, shipperLng) || (shipperLat == 0d && shipperLng == 0d)) {
            return new ArrayList<>();
        }

        // 2) Lấy danh sách đơn chờ + tọa độ quán để lọc theo khoảng cách
        String sqlOrders = "SELECT o.*, mp.latitude AS shop_lat, mp.longitude AS shop_lng "
                + "FROM Orders o "
                + "JOIN MerchantProfiles mp ON o.merchant_user_id = mp.user_id "
                + "WHERE o.shipper_user_id IS NULL "
                + "AND o.order_status IN ('MERCHANT_ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP') "
                + "ORDER BY o.created_at ASC";

        List<Order> filteredOrders = new ArrayList<>();
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sqlOrders); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Double shopLat = rs.getObject("shop_lat") != null ? rs.getDouble("shop_lat") : null;
                Double shopLng = rs.getObject("shop_lng") != null ? rs.getDouble("shop_lng") : null;

                Double distKm = distanceKm(shipperLat, shipperLng, shopLat, shopLng);
                if (distKm != null && distKm <= 4.0) {
                    filteredOrders.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return filteredOrders;
    }

    private void appendMerchantOrderFilters(StringBuilder sql, List<Object> params, String statusGroup, String statusFilter, String fromDateTime, String toDateTime) {
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            String normalized = statusFilter.trim().toUpperCase();
            if ("PENDING".equals(normalized)) {
                sql.append("AND order_status IN ('CREATED', 'PAID') ");
            } else if ("CONFIRMED".equals(normalized)) {
                sql.append("AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ");
            } else if ("CANCELLED".equals(normalized)) {
                sql.append("AND order_status IN ('CANCELLED', 'MERCHANT_REJECTED', 'FAILED') ");
            } else {
                sql.append("AND order_status = ? ");
                params.add(normalized);
            }
        } else if ("pending".equals(statusGroup)) {
            sql.append("AND order_status IN ('CREATED', 'PAID') ");
        } else if ("preparing".equals(statusGroup)) {
            sql.append("AND order_status IN ('MERCHANT_ACCEPTED', 'PREPARING') ");
        } else if ("ready".equals(statusGroup)) {
            sql.append("AND order_status IN ('READY_FOR_PICKUP', 'DELIVERING', 'PICKED_UP') ");
        } else if ("completed".equals(statusGroup)) {
            sql.append("AND order_status IN ('DELIVERED', 'CANCELLED', 'FAILED', 'MERCHANT_REJECTED', 'REFUNDED') ");
        }

        if (fromDateTime != null && !fromDateTime.trim().isEmpty()) {
            sql.append("AND created_at >= ? ");
            params.add(java.sql.Timestamp.valueOf(fromDateTime.trim().replace("T", " ") + ":00"));
        }
        if (toDateTime != null && !toDateTime.trim().isEmpty()) {
            sql.append("AND created_at <= ? ");
            params.add(java.sql.Timestamp.valueOf(toDateTime.trim().replace("T", " ") + ":59"));
        }
    }
}
