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
        food.setImageUrl(rs.getString("image_url"));
        food.setAvailable(rs.getBoolean("is_available"));
        food.setFried(rs.getBoolean("is_fried"));
        food.setCreatedAt(rs.getTimestamp("created_at"));
        food.setUpdatedAt(rs.getTimestamp("updated_at"));
        food.setCalories(rs.getInt("calories"));
        food.setProteinG(rs.getDouble("protein_g"));
        food.setCarbsG(rs.getDouble("carbs_g"));
        food.setFatG(rs.getDouble("fat_g"));
        return food;
    }

    @Override
    public List<FoodItem> getTopFoods(int limit) {

        String sql = "SELECT TOP (?) * FROM FoodItems WHERE is_available = 1 ORDER BY id DESC";
        return query(sql, limit);
    }

    @Override
    public List<FoodItem> findByMerchant(int merchantUserId) {

        String sql = "SELECT * FROM FoodItems WHERE merchant_user_id = ? AND is_available = 1";
        return query(sql, merchantUserId);
    }

    @Override
    public List<FoodItem> searchByName(String keyword) {

        String sql = "SELECT * FROM FoodItems WHERE name LIKE ? AND is_available = 1";
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

        String sql = "INSERT INTO FoodItems (merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        return update(sql, food.getMerchantUserId(), food.getCategoryId(), food.getName(),
                food.getDescription(), food.getPrice(), food.getImageUrl(),
                food.isAvailable(), food.isFried());
    }

    @Override
    public boolean update(FoodItem food) {

        String sql = "UPDATE FoodItems SET name = ?, description = ?, price = ?, image_url = ?, is_available = ?, is_fried = ? WHERE id = ?";
        return update(sql, food.getName(), food.getDescription(), food.getPrice(),
                food.getImageUrl(), food.isAvailable(), food.isFried(), food.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {

        String sql = "UPDATE FoodItems SET is_available = 0 WHERE id = ?";
        return update(sql, id) > 0;
    }

    public List<FoodItem> getByMerchantId(int merchantId) {
        String sql = "SELECT * FROM FoodItems WHERE merchant_user_id = ? ORDER BY id DESC";
        return query(sql, merchantId);
    }
    
    public boolean toggleStatus(int itemId, int merchantId, boolean isAvailable) {
        String sql = "UPDATE FoodItems SET is_available = ?, updated_at = SYSUTCDATETIME() WHERE id = ? AND merchant_user_id = ?";
        return update(sql, isAvailable, itemId, merchantId) > 0;
    }
}
