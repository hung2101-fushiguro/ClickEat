package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.model.OrderItem;

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
        try {
            item.setSelectedSize(rs.getString("selected_size"));
        } catch (SQLException ignored) {
        }
        try {
            item.setSelectedToppings(rs.getString("selected_toppings"));
        } catch (SQLException ignored) {
        }
        try {
            double optionExtraPrice = rs.getDouble("option_extra_price");
            item.setOptionExtraPrice(rs.wasNull() ? null : optionExtraPrice);
        } catch (SQLException ignored) {
        }
        return item;
    }

    public List<OrderItem> getItemsByOrderId(int orderId) {
        return query("SELECT * FROM OrderItems WHERE order_id = ?", orderId);
    }

    @Override
    public int insert(OrderItem t) {
        Double optionExtraPrice = t.getOptionExtraPrice();
        double safeOptionExtra = optionExtraPrice == null ? 0d : optionExtraPrice.doubleValue();
        String sql = """
            INSERT INTO OrderItems(order_id, food_item_id, item_name_snapshot, unit_price_snapshot, quantity, note, selected_size, selected_toppings, option_extra_price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        return update(sql,
                t.getOrderId(),
                t.getFoodItemId(),
                t.getItemNameSnapshot(),
                t.getUnitPriceSnapshot(),
                t.getQuantity(),
                t.getNote(),
                t.getSelectedSize(),
                t.getSelectedToppings(),
                safeOptionExtra);
    }

    @Override
    public List<OrderItem> findAll() {
        return null;
    }

    @Override
    public OrderItem findById(int id) {
        return null;
    }

    @Override
    public boolean update(OrderItem t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
