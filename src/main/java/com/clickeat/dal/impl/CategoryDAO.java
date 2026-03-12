/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.Category;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class CategoryDAO extends AbstractDAO<Category> {

    @Override
    protected Category mapRow(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setId(rs.getInt("id"));
        c.setMerchantUserId(rs.getInt("merchant_user_id"));
        c.setName(rs.getString("name"));
        c.setActive(rs.getBoolean("is_active"));
        c.setSortOrder(rs.getInt("sort_order"));
        return c;
    }

    @Override
    public List<Category> findAll() {
        return query("SELECT * FROM Categories ORDER BY sort_order ASC");
    }

    @Override
    public Category findById(int id) {
        return queryOne("SELECT * FROM Categories WHERE id = ?", id);
    }

    @Override
    public int insert(Category c) {
        String sql = "INSERT INTO Categories (merchant_user_id, name, is_active, sort_order) VALUES (?, ?, ?, ?)";
        return update(sql, c.getMerchantUserId(), c.getName(), c.isActive(), c.getSortOrder());
    }

    @Override
    public boolean update(Category c) {
        String sql = "UPDATE Categories SET name = ?, is_active = ?, sort_order = ? WHERE id = ?";
        return update(sql, c.getName(), c.isActive(), c.getSortOrder(), c.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        return update("DELETE FROM Categories WHERE id = ?", id) > 0;
    }

    public List<Category> getByMerchantId(int merchantId) {
        String sql = "SELECT * FROM Categories WHERE merchant_user_id = ? ORDER BY sort_order ASC";
        return query(sql, merchantId);
    }
}
