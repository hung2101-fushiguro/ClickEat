package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.dal.interfaces.ICartItemDAO;
import com.clickeat.model.CartItem;

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
        try {
            item.setOptionSignature(rs.getString("option_signature"));
        } catch (SQLException ignored) {
        }
        return item;
    }

    // --- CÁC HÀM TỪ ICARTITEMDAO ---
    @Override
    public List<CartItem> getItemsByCartId(int cartId) {
        String sql = "SELECT * FROM CartItems WHERE cart_id = ?";
        return query(sql, cartId);
    }

    @Override
    public CartItem checkItemExist(int cartId, int foodItemId) {
        return checkItemExist(cartId, foodItemId, "");
    }

    @Override
    public CartItem checkItemExist(int cartId, int foodItemId, String optionSignature) {
        String sql = "SELECT * FROM CartItems WHERE cart_id = ? AND food_item_id = ? AND ISNULL(option_signature, '') = ?";
        return queryOne(sql, cartId, foodItemId, safeText(optionSignature));
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
        String sql = "INSERT INTO CartItems (cart_id, food_item_id, quantity, unit_price_snapshot, note, selected_size, selected_toppings, option_extra_price, option_signature) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String safeNote = (item.getNote() == null) ? "" : item.getNote();
        Double optionExtraPrice = item.getOptionExtraPrice();
        double safeOptionExtra = optionExtraPrice == null ? 0d : optionExtraPrice.doubleValue();

        return update(sql,
                item.getCartId(),
                item.getFoodItemId(),
                item.getQuantity(),
                item.getUnitPriceSnapshot(),
                safeNote,
                safeText(item.getSelectedSize()),
                safeText(item.getSelectedToppings()),
                safeOptionExtra,
                safeText(item.getOptionSignature()));
    }

    @Override
    public boolean update(CartItem item) {
        String sql = "UPDATE CartItems SET cart_id = ?, food_item_id = ?, quantity = ?, unit_price_snapshot = ?, note = ?, selected_size = ?, selected_toppings = ?, option_extra_price = ?, option_signature = ? WHERE id = ?";
        Double optionExtraPrice = item.getOptionExtraPrice();
        double safeOptionExtra = optionExtraPrice == null ? 0d : optionExtraPrice.doubleValue();
        return update(sql,
                item.getCartId(),
                item.getFoodItemId(),
                item.getQuantity(),
                item.getUnitPriceSnapshot(),
                item.getNote(),
                safeText(item.getSelectedSize()),
                safeText(item.getSelectedToppings()),
                safeOptionExtra,
                safeText(item.getOptionSignature()),
                item.getId()) > 0;
    }

    private String safeText(String value) {
        return value == null ? "" : value.trim();
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM CartItems WHERE id = ?";
        return update(sql, id) > 0;
    }
}
