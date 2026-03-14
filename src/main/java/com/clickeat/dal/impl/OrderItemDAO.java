/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.model.OrderItem;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class OrderItemDAO extends AbstractDAO<OrderItem> {

    @Override
    protected OrderItem mapRow(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setId(rs.getInt("id"));
        item.setOrderId(rs.getInt("order_id"));
        item.setFoodItemId(rs.getInt("food_item_id"));
        item.setItemNameSnapshot(rs.getString("item_name_snapshot"));
        item.setUnitPriceSnapshot(rs.getDouble("unit_price_snapshot"));
        item.setQuantity(rs.getInt("quantity"));
        item.setNote(rs.getString("note"));
        return item;
    }
   
    public List<OrderItem> getItemsByOrderId(int orderId) {
        return query("SELECT * FROM OrderItems WHERE order_id = ?", orderId);
    }
    
    @Override public List<OrderItem> findAll() { return null; }
    @Override public OrderItem findById(int id) { return null; }
    @Override
    public int insert(OrderItem item) {
        String sql = """
            INSERT INTO OrderItems (
                order_id, food_item_id, item_name_snapshot, 
                unit_price_snapshot, quantity, note
            ) VALUES (?, ?, ?, ?, ?, ?)
        """;
        return update(sql, 
            item.getOrderId(),
            item.getFoodItemId(),
            item.getItemNameSnapshot(),
            item.getUnitPriceSnapshot(),
            item.getQuantity(),
            item.getNote()
        );
    }
    @Override public boolean update(OrderItem t) { return false; }
    @Override public boolean delete(int id) { return false; }
}
