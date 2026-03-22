package com.clickeat.dal.impl;

import com.clickeat.model.CustomerProfile;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class CustomerProfileDAO extends AbstractDAO<CustomerProfile> {

    @Override
    protected CustomerProfile mapRow(ResultSet rs) throws SQLException {
        CustomerProfile cp = new CustomerProfile();
        cp.setUserId(rs.getInt("user_id"));

        Object defaultAddressId = rs.getObject("default_address_id");
        cp.setDefaultAddressId(defaultAddressId != null ? rs.getInt("default_address_id") : null);

        cp.setFoodPreferences(rs.getString("food_preferences"));
        cp.setAllergies(rs.getString("allergies"));
        cp.setHealthGoal(rs.getString("health_goal"));

        Object dailyTarget = rs.getObject("daily_calorie_target");
        cp.setDailyCalorieTarget(dailyTarget != null ? rs.getInt("daily_calorie_target") : null);

        cp.setCreatedAt(rs.getTimestamp("created_at"));
        cp.setUpdatedAt(rs.getTimestamp("updated_at"));
        return cp;
    }

    public CustomerProfile findByUserId(int userId) {
        String sql = "SELECT * FROM CustomerProfiles WHERE user_id = ?";
        return queryOne(sql, userId);
    }

    public void ensureExists(int userId) {
        String sql = """
            IF NOT EXISTS (SELECT 1 FROM CustomerProfiles WHERE user_id = ?)
            BEGIN
                INSERT INTO CustomerProfiles(user_id, created_at, updated_at)
                VALUES(?, SYSUTCDATETIME(), SYSUTCDATETIME())
            END
        """;
        update(sql, userId, userId);
    }

    public boolean updateProfile(CustomerProfile cp) {
        String sql = """
            UPDATE CustomerProfiles
            SET food_preferences = ?,
                allergies = ?,
                health_goal = ?,
                daily_calorie_target = ?,
                updated_at = SYSUTCDATETIME()
            WHERE user_id = ?
        """;
        return update(sql,
                cp.getFoodPreferences(),
                cp.getAllergies(),
                cp.getHealthGoal(),
                cp.getDailyCalorieTarget(),
                cp.getUserId()) > 0;
    }

    @Override
    public List<CustomerProfile> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(CustomerProfile t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(CustomerProfile t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public CustomerProfile findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}