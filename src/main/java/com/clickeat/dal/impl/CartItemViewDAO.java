package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.model.CartItemView;

public class CartItemViewDAO extends AbstractDAO<CartItemView> {

    private static final String BASE_SELECT = """
        SELECT 
            ci.id AS cart_item_id,
            ci.cart_id AS cart_id,
            ci.food_item_id AS food_item_id,
            fi.name AS food_name,
            fi.image_url AS image_url,
            ci.unit_price_snapshot AS unit_price,
            ci.quantity AS quantity,
            ci.selected_size AS selected_size,
            ci.selected_toppings AS selected_toppings
        FROM dbo.CartItems ci
        JOIN dbo.FoodItems fi ON fi.id = ci.food_item_id
    """;

    @Override
    protected CartItemView mapRow(ResultSet rs) throws SQLException {
        CartItemView v = new CartItemView();
        v.setCartItemId(rs.getInt("cart_item_id"));
        v.setCartId(rs.getInt("cart_id"));
        v.setFoodItemId(rs.getInt("food_item_id"));
        v.setName(rs.getString("food_name"));
        v.setImageUrl(rs.getString("image_url"));
        v.setUnitPrice(rs.getDouble("unit_price"));
        v.setQuantity(rs.getInt("quantity"));
        String selectedSize = rs.getString("selected_size");
        String selectedToppings = rs.getString("selected_toppings");
        v.setSelectedSize(selectedSize);
        v.setSelectedToppings(selectedToppings);
        v.setOptionSummary(buildOptionSummary(selectedSize, selectedToppings));
        return v;
    }

    private String buildOptionSummary(String selectedSize, String selectedToppings) {
        StringBuilder summary = new StringBuilder();
        if (selectedSize != null && !selectedSize.isBlank()) {
            summary.append("Size ").append(selectedSize.trim());
        }
        if (selectedToppings != null && !selectedToppings.isBlank()) {
            if (summary.length() > 0) {
                summary.append(" • ");
            }
            summary.append(selectedToppings.trim());
        }
        return summary.toString();
    }

    public List<CartItemView> getByCartId(int cartId) {
        String sql = BASE_SELECT + """
            WHERE ci.cart_id = ?
            ORDER BY ci.id DESC
        """;
        return query(sql, cartId);
    }

    @Override
    public CartItemView findById(int id) {
        String sql = BASE_SELECT + """
            WHERE ci.id = ?
        """;
        List<CartItemView> list = query(sql, id);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public List<CartItemView> findAll() {
        String sql = BASE_SELECT + """
            ORDER BY ci.id DESC
        """;
        return query(sql);
    }

    @Override
    public int insert(CartItemView t) {
        throw new UnsupportedOperationException("CartItemViewDAO chi dung de doc du lieu hien thi.");
    }

    @Override
    public boolean update(CartItemView t) {
        throw new UnsupportedOperationException("CartItemViewDAO chi dung de doc du lieu hien thi.");
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("CartItemViewDAO chi dung de doc du lieu hien thi.");
    }
}
