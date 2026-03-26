package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.ICartItemDAO;
import com.clickeat.model.CartItem;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class CartItemDAO extends AbstractDAO<CartItem> implements ICartItemDAO {

    @Override
    protected CartItem mapRow(ResultSet rs) throws SQLException {
        CartItem item = new CartItem();
        item.setId((int) rs.getLong("id"));
        item.setCartId((int) rs.getLong("cart_id"));
        item.setFoodItemId((int) rs.getLong("food_item_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setUnitPriceSnapshot(rs.getDouble("unit_price_snapshot"));
        item.setNote(rs.getString("note"));
        // Optional display fields from JOIN
        try { item.setName(rs.getString("food_name")); } catch (SQLException ignored) {}
        try { item.setImageUrl(rs.getString("image_url")); } catch (SQLException ignored) {}
        return item;
    }

    // --- CÁC HÀM TỪ ICARTITEMDAO ---
    @Override
    public List<CartItem> getItemsByCartId(int cartId) {
        String sql = """
            SELECT ci.*, fi.name AS food_name, fi.image_url
            FROM CartItems ci
            LEFT JOIN FoodItems fi ON fi.id = ci.food_item_id
            WHERE ci.cart_id = ?
        """;
        return query(sql, cartId);
    }

    @Override
    public CartItem checkItemExist(int cartId, int foodItemId) {
        String sql = "SELECT * FROM CartItems WHERE cart_id = ? AND food_item_id = ?";
        return queryOne(sql, cartId, foodItemId);
    }

    @Override
    public boolean updateQuantity(int cartItemId, int newQuantity) {
        String sql = "UPDATE CartItems SET quantity = ? WHERE id = ?";
        return update(sql, newQuantity, cartItemId) > 0;
    }

    // --- CÁC HÀM BẮT BUỘC TỪ IGENERICDAO ---
    @Override
    public List<CartItem> findAll() {
        return query("SELECT * FROM CartItems");
    }

    @Override
    public CartItem findById(int id) {
        return queryOne("SELECT * FROM CartItems WHERE id = ?", id);
    }

    @Override
    public int insert(CartItem item) {
        String sql = "INSERT INTO CartItems (cart_id, food_item_id, quantity, unit_price_snapshot, note) VALUES (?, ?, ?, ?, ?)";
        String safeNote = (item.getNote() == null) ? "" : item.getNote();

        return update(sql, item.getCartId(), item.getFoodItemId(), item.getQuantity(), item.getUnitPriceSnapshot(), safeNote);
    }

    @Override
    public boolean update(CartItem item) {
        String sql = "UPDATE CartItems SET cart_id = ?, food_item_id = ?, quantity = ?, unit_price_snapshot = ?, note = ? WHERE id = ?";
        return update(sql, item.getCartId(), item.getFoodItemId(), item.getQuantity(), item.getUnitPriceSnapshot(), item.getNote(), item.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM CartItems WHERE id = ?";
        return update(sql, id) > 0;
    }
}
