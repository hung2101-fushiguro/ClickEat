package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IFoodItemDAO;
import com.clickeat.model.FoodItem;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class FoodItemDAO extends AbstractDAO<FoodItem> implements IFoodItemDAO {

    @Override
    protected FoodItem mapRow(ResultSet rs) throws SQLException {
        FoodItem food = new FoodItem();

        food.setId(rs.getInt("id"));
        food.setMerchantUserId(rs.getInt("merchant_user_id"));
        food.setCategoryId(rs.getInt("category_id"));
        food.setName(rs.getString("name"));
        food.setDescription(rs.getString("description"));
        food.setPrice(rs.getDouble("price"));
        food.setImageUrl(resolveFoodImage(
                rs.getString("image_url"),
                getNullableString(rs, "category_name"),
                rs.getString("name"),
                rs.getBoolean("is_fried")
        ));
        food.setAvailable(rs.getBoolean("is_available"));
        food.setFried(rs.getBoolean("is_fried"));

        int calories = rs.getInt("calories");
        food.setCalories(rs.wasNull() ? null : calories);

        double protein = rs.getDouble("protein_g");
        food.setProteinG(rs.wasNull() ? null : protein);

        double carbs = rs.getDouble("carbs_g");
        food.setCarbsG(rs.wasNull() ? null : carbs);

        double fat = rs.getDouble("fat_g");
        food.setFatG(rs.wasNull() ? null : fat);

        food.setCreatedAt(rs.getTimestamp("created_at"));
        food.setUpdatedAt(rs.getTimestamp("updated_at"));

        food.setMerchantName(getNullableString(rs, "merchant_name"));
        food.setCategoryName(getNullableString(rs, "category_name"));

        int discountPercent = getNullableInt(rs, "discount_percent", 0);
        food.setDiscountPercent(discountPercent);

        double originalPrice = getNullableDouble(rs, "original_price", 0);
        if (originalPrice <= 0 && discountPercent > 0) {
            originalPrice = Math.round(food.getPrice() / (1 - discountPercent / 100.0));
        }
        food.setOriginalPrice(originalPrice);

        return food;
    }

    @Override
    public List<FoodItem> getTopFoods(int limit) {
        if (limit <= 0) {
            limit = 6;
        }

        String sql = """
        SELECT fi.*,
               mp.shop_name AS merchant_name,
               c.name AS category_name,
               CASE
                   WHEN fi.id % 4 = 1 THEN 27
                   WHEN fi.id % 4 = 2 THEN 16
                   WHEN fi.id % 4 = 3 THEN 24
                   ELSE 19
               END AS discount_percent,
               CASE
                   WHEN fi.id % 4 = 1 THEN ROUND(fi.price / 0.73, 0)
                   WHEN fi.id % 4 = 2 THEN ROUND(fi.price / 0.84, 0)
                   WHEN fi.id % 4 = 3 THEN ROUND(fi.price / 0.76, 0)
                   ELSE ROUND(fi.price / 0.81, 0)
               END AS original_price
        FROM FoodItems fi
        INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id
        INNER JOIN Categories c ON c.id = fi.category_id
        WHERE fi.is_available = 1
          AND mp.status = 'APPROVED'
        ORDER BY fi.id DESC
        OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY
    """;

        return query(sql, limit);
    }

    @Override
    public List<FoodItem> findByMerchant(int merchantUserId) {
        String sql = """
            SELECT fi.*, mp.shop_name AS merchant_name, c.name AS category_name
            FROM FoodItems fi
            INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id
            INNER JOIN Categories c ON c.id = fi.category_id
            WHERE fi.merchant_user_id = ?
              AND fi.is_available = 1
            ORDER BY fi.id DESC
        """;
        return query(sql, merchantUserId);
    }

    @Override
    public List<FoodItem> searchByName(String keyword) {
        String sql = """
            SELECT fi.*, mp.shop_name AS merchant_name, c.name AS category_name
            FROM FoodItems fi
            INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id
            INNER JOIN Categories c ON c.id = fi.category_id
            WHERE fi.name LIKE ?
              AND fi.is_available = 1
              AND mp.status = N'APPROVED'
            ORDER BY fi.id DESC
        """;
        return query(sql, "%" + keyword + "%");
    }

    @Override
    public List<FoodItem> findAll() {
        return query("SELECT * FROM FoodItems");
    }

    @Override
    public FoodItem findById(int id) {
        return queryOne("SELECT * FROM FoodItems WHERE id = ?", id);
    }

    @Override
    public int insert(FoodItem food) {
        String sql = """
            INSERT INTO FoodItems
            (merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """;
        return update(sql,
                food.getMerchantUserId(),
                food.getCategoryId(),
                food.getName(),
                food.getDescription(),
                food.getPrice(),
                food.getImageUrl(),
                food.isAvailable(),
                food.isFried());
    }

    @Override
    public boolean update(FoodItem food) {
        String sql = """
            UPDATE FoodItems
            SET name = ?, description = ?, price = ?, image_url = ?, is_available = ?, is_fried = ?
            WHERE id = ?
        """;
        return update(sql,
                food.getName(),
                food.getDescription(),
                food.getPrice(),
                food.getImageUrl(),
                food.isAvailable(),
                food.isFried(),
                food.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        String sql = "UPDATE FoodItems SET is_available = 0 WHERE id = ?";
        return update(sql, id) > 0;
    }

    private String getNullableString(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (SQLException e) {
            return null;
        }
    }

    private int getNullableInt(ResultSet rs, String column, int defaultValue) {
        try {
            return rs.getInt(column);
        } catch (SQLException e) {
            return defaultValue;
        }
    }

    private double getNullableDouble(ResultSet rs, String column, double defaultValue) {
        try {
            return rs.getDouble(column);
        } catch (SQLException e) {
            return defaultValue;
        }
    }

    private String resolveFoodImage(String dbImage, String categoryName, String foodName, boolean isFried) {
        if (dbImage != null && !dbImage.trim().isEmpty()) {
            return dbImage;
        }

        String key = ((categoryName == null ? "" : categoryName) + " "
                + (foodName == null ? "" : foodName)).toLowerCase();

        if (key.contains("burger")) {
            return "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1200&auto=format&fit=crop";
        }
        if (key.contains("trà") || key.contains("coca") || key.contains("đồ uống")) {
            return "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=1200&auto=format&fit=crop";
        }
        if (key.contains("kem") || key.contains("flan") || key.contains("tráng miệng")) {
            return "https://images.unsplash.com/photo-1563805042-7684c019e1cb?q=80&w=1200&auto=format&fit=crop";
        }
        if (key.contains("combo")) {
            return "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=1200&auto=format&fit=crop";
        }
        if (isFried || key.contains("gà")) {
            return "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1200&auto=format&fit=crop";
        }

        return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1200&auto=format&fit=crop";
    }

    public List<FoodItem> findStoreFoods(int merchantUserId, Integer categoryId, String keyword, String filter) {
        StringBuilder sql = new StringBuilder("""
        SELECT fi.*,
               mp.shop_name AS merchant_name,
               c.name AS category_name,
               CASE
                   WHEN fi.id % 4 = 1 THEN 27
                   WHEN fi.id % 4 = 2 THEN 16
                   WHEN fi.id % 4 = 3 THEN 24
                   ELSE 19
               END AS discount_percent,
               CASE
                   WHEN fi.id % 4 = 1 THEN ROUND(fi.price / 0.73, 0)
                   WHEN fi.id % 4 = 2 THEN ROUND(fi.price / 0.84, 0)
                   WHEN fi.id % 4 = 3 THEN ROUND(fi.price / 0.76, 0)
                   ELSE ROUND(fi.price / 0.81, 0)
               END AS original_price
        FROM FoodItems fi
        INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id
        INNER JOIN Categories c ON c.id = fi.category_id
        WHERE fi.merchant_user_id = ?
          AND fi.is_available = 1
          AND mp.status = 'APPROVED'
    """);

        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(merchantUserId);

        if (categoryId != null) {
            sql.append(" AND fi.category_id = ? ");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (fi.name LIKE ? OR fi.description LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if ("banchay".equalsIgnoreCase(filter)) {
            sql.append(" ORDER BY discount_percent DESC, fi.id DESC ");
        } else if ("giamgia".equalsIgnoreCase(filter)) {
            sql.append(" ORDER BY original_price - fi.price DESC, fi.id DESC ");
        } else {
            sql.append(" ORDER BY fi.id DESC ");
        }

        return query(sql.toString(), params.toArray());
    }

    public FoodItem findStoreFoodById(int foodId) {
        String sql = """
        SELECT fi.*,
               mp.shop_name AS merchant_name,
               c.name AS category_name,
               CASE
                   WHEN fi.id % 4 = 1 THEN 27
                   WHEN fi.id % 4 = 2 THEN 16
                   WHEN fi.id % 4 = 3 THEN 24
                   ELSE 19
               END AS discount_percent,
               CASE
                   WHEN fi.id % 4 = 1 THEN ROUND(fi.price / 0.73, 0)
                   WHEN fi.id % 4 = 2 THEN ROUND(fi.price / 0.84, 0)
                   WHEN fi.id % 4 = 3 THEN ROUND(fi.price / 0.76, 0)
                   ELSE ROUND(fi.price / 0.81, 0)
               END AS original_price
        FROM FoodItems fi
        INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id
        INNER JOIN Categories c ON c.id = fi.category_id
        WHERE fi.id = ?
    """;
        return queryOne(sql, foodId);
    }

    public List<FoodItem> getByMerchantId(int merchantId) {
        String sql = "SELECT * FROM FoodItems WHERE merchant_user_id = ? ORDER BY id DESC";
        return query(sql, merchantId);
    }
    
    public boolean toggleStatus(int itemId, int merchantId, boolean isAvailable) {
        String sql = "UPDATE FoodItems SET is_available = ?, updated_at = SYSUTCDATETIME() WHERE id = ? AND merchant_user_id = ?";
        return update(sql, isAvailable, itemId, merchantId) > 0;
    }

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

    public List<FoodItem> getAllAvailableFoods() {
        String sql = """
            SELECT fi.*,
                   mp.shop_name AS merchant_name,
                   c.name AS category_name,
                   CASE
                       WHEN fi.id % 4 = 1 THEN 27
                       WHEN fi.id % 4 = 2 THEN 16
                       WHEN fi.id % 4 = 3 THEN 24
                       ELSE 19
                   END AS discount_percent,
                   CASE
                       WHEN fi.id % 4 = 1 THEN ROUND(fi.price / 0.73, 0)
                       WHEN fi.id % 4 = 2 THEN ROUND(fi.price / 0.84, 0)
                       WHEN fi.id % 4 = 3 THEN ROUND(fi.price / 0.76, 0)
                       ELSE ROUND(fi.price / 0.81, 0)
                   END AS original_price
            FROM FoodItems fi
            INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id
            INNER JOIN Categories c ON c.id = fi.category_id
            WHERE fi.is_available = 1
              AND mp.status = 'APPROVED'
            ORDER BY c.name, fi.id DESC
        """;
        return query(sql);
    }

    public List<FoodItem> getFoodsByCategoryName(String categoryName) {
        String sql = """
            SELECT fi.*,
                   mp.shop_name AS merchant_name,
                   c.name AS category_name,
                   CASE
                       WHEN fi.id % 4 = 1 THEN 27
                       WHEN fi.id % 4 = 2 THEN 16
                       WHEN fi.id % 4 = 3 THEN 24
                       ELSE 19
                   END AS discount_percent,
                   CASE
                       WHEN fi.id % 4 = 1 THEN ROUND(fi.price / 0.73, 0)
                       WHEN fi.id % 4 = 2 THEN ROUND(fi.price / 0.84, 0)
                       WHEN fi.id % 4 = 3 THEN ROUND(fi.price / 0.76, 0)
                       ELSE ROUND(fi.price / 0.81, 0)
                   END AS original_price
            FROM FoodItems fi
            INNER JOIN MerchantProfiles mp ON mp.user_id = fi.merchant_user_id
            INNER JOIN Categories c ON c.id = fi.category_id
            WHERE fi.is_available = 1
              AND mp.status = 'APPROVED'
              AND (UPPER(c.name) = UPPER(?) OR UPPER(fi.name) LIKE UPPER(?))
            ORDER BY fi.id DESC
        """;
        return query(sql, categoryName, "%" + categoryName + "%");
    }

}
