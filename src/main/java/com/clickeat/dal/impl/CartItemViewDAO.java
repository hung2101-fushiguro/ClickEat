package com.clickeat.dal.impl;

import com.clickeat.model.CartItemView;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class CartItemViewDAO extends AbstractDAO<CartItemView> {

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
        return v;
    }

    public List<CartItemView> getByCartId(int cartId) {
        String sql = """
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
            WHERE ci.cart_id = ?
            ORDER BY ci.id DESC
        """;
        return query(sql, cartId);
    }

    @Override
    public List<CartItemView> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(CartItemView t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(CartItemView t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public CartItemView findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}