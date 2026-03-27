package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
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

    public int insert(Connection conn, OrderItem t) throws SQLException {
        Double optionExtraPrice = t.getOptionExtraPrice();
        double safeOptionExtra = optionExtraPrice == null ? 0d : optionExtraPrice.doubleValue();
        String sql = """
            INSERT INTO OrderItems(order_id, food_item_id, item_name_snapshot, unit_price_snapshot, quantity, note, selected_size, selected_toppings, option_extra_price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        return update(conn, sql,
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

    public int[] insertBatch(Connection conn, List<OrderItem> items) throws SQLException {
        if (items == null || items.isEmpty()) {
            return new int[0];
        }

        String sql = """
            INSERT INTO OrderItems(order_id, food_item_id, item_name_snapshot, unit_price_snapshot, quantity, note, selected_size, selected_toppings, option_extra_price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.NO_GENERATED_KEYS)) {
            for (OrderItem t : items) {
                Double optionExtraPrice = t.getOptionExtraPrice();
                double safeOptionExtra = optionExtraPrice == null ? 0d : optionExtraPrice.doubleValue();

                ps.setObject(1, t.getOrderId());
                ps.setObject(2, t.getFoodItemId());
                ps.setObject(3, t.getItemNameSnapshot());
                ps.setObject(4, t.getUnitPriceSnapshot());
                ps.setObject(5, t.getQuantity());
                ps.setObject(6, t.getNote());
                ps.setObject(7, t.getSelectedSize());
                ps.setObject(8, t.getSelectedToppings());
                ps.setObject(9, safeOptionExtra);
                ps.addBatch();
            }
            return ps.executeBatch();
        }
    }

    public boolean hasBatchFailure(int[] batchResults) {
        if (batchResults == null) {
            return true;
        }
        for (int result : batchResults) {
            if (result == Statement.EXECUTE_FAILED) {
                return true;
            }
        }
        return false;
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
