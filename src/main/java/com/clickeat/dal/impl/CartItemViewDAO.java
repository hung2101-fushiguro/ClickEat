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
            ci.quantity AS quantity
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
        v.setImageUrl(normalizeImageUrl(rs.getString("image_url")));
        v.setUnitPrice(rs.getDouble("unit_price"));
        v.setQuantity(rs.getInt("quantity"));
        return v;
    }

    private String normalizeImageUrl(String rawImage) {
        if (rawImage == null) {
            return null;
        }

        String normalized = rawImage.trim();
        if (normalized.isEmpty()) {
            return normalized;
        }

        if (normalized.startsWith("http://")
                || normalized.startsWith("https://")
                || normalized.startsWith("data:")
                || normalized.startsWith("/")) {
            return normalized;
        }
        return "/assets/images/" + normalized;
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