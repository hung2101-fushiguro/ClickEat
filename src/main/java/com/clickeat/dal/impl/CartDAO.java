package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.dal.interfaces.ICartDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;

public class CartDAO extends AbstractDAO<Cart> implements ICartDAO {

    @Override
    protected Cart mapRow(ResultSet rs) throws SQLException {
        Cart cart = new Cart();

        cart.setId(rs.getInt("id"));
        Object customerIdObj = rs.getObject("customer_user_id");
        cart.setCustomerUserId(customerIdObj != null ? ((Number) customerIdObj).intValue() : null);
        cart.setGuestId(rs.getString("guest_id"));
        Object merchantIdObj = rs.getObject("merchant_user_id");
        cart.setMerchantUserId(merchantIdObj != null ? ((Number) merchantIdObj).intValue() : null);
        cart.setStatus(rs.getString("status"));
        cart.setCreatedAt(rs.getTimestamp("created_at"));
        cart.setUpdatedAt(rs.getTimestamp("updated_at"));

        return cart;
    }

    // --- CÁC HÀM TỪ ICARTDAO ---
    @Override
    public Cart getActiveCartByCustomerId(int customerId) {
        String sql = """
            SELECT * 
            FROM Carts 
            WHERE customer_user_id = ? 
              AND status = 'ACTIVE'
        """;
        return queryOne(sql, customerId);
    }

    @Override
    public Cart getActiveCartByGuestId(String guestId) {
        String sql = """
            SELECT * 
            FROM Carts
            WHERE guest_id = ?
              AND status = 'ACTIVE'
        """;
        return queryOne(sql, guestId);
    }

    @Override
    public boolean createNewCart(int customerId) {
        String sql = """
            INSERT INTO Carts (customer_user_id, status)
            VALUES (?, 'ACTIVE')
        """;
        return update(sql, customerId) > 0;
    }

    @Override
    public boolean createNewGuestCart(String guestId) {
        String sql = """
            INSERT INTO Carts (guest_id, status)
            VALUES (?, 'ACTIVE')
        """;
        return update(sql, guestId) > 0;
    }

    // Hàm này đang được CartServlet của bạn gọi
    public int createGuestCart(String guestId) {
        String sql = """
            INSERT INTO Carts (guest_id, merchant_user_id, status)
            VALUES (?, NULL, 'ACTIVE')
        """;
        return update(sql, guestId);
    }

    // --- CÁC HÀM BẮT BUỘC TỪ IGENERICDAO ---
    @Override
    public List<Cart> findAll() {
        return query("SELECT * FROM Carts");
    }

    @Override
    public Cart findById(int id) {
        return queryOne("SELECT * FROM Carts WHERE id = ?", id);
    }

    @Override
    public int insert(Cart cart) {
        String sql = """
            INSERT INTO Carts (customer_user_id, guest_id, merchant_user_id, status)
            VALUES (?, ?, ?, ?)
        """;
        return update(sql,
                cart.getCustomerUserId(),
                cart.getGuestId(),
                cart.getMerchantUserId(),
                cart.getStatus());
    }

    @Override
    public boolean update(Cart cart) {
        String sql = """
            UPDATE Carts
            SET customer_user_id = ?,
                guest_id = ?,
                merchant_user_id = ?,
                status = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
        """;
        return update(sql,
                cart.getCustomerUserId(),
                cart.getGuestId(),
                cart.getMerchantUserId(),
                cart.getStatus(),
                cart.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        String sql = """
            UPDATE Carts
            SET status = 'INACTIVE',
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
        """;
        return update(sql, id) > 0;
    }

    public boolean clearMerchant(int cartId) {
        String sql = """
        UPDATE Carts
        SET merchant_user_id = NULL,
            updated_at = SYSUTCDATETIME()
        WHERE id = ?
    """;
        return update(sql, cartId) > 0;
    }

    public boolean markCartCheckedOut(int cartId) {
        String sql = "UPDATE Carts SET status = 'CHECKED_OUT' WHERE id = ?";
        return update(sql, cartId) > 0;
    }

    public boolean markCartCheckedOut(Connection conn, int cartId) throws SQLException {
        String sql = "UPDATE Carts SET status = 'CHECKED_OUT' WHERE id = ?";
        return update(conn, sql, cartId) > 0;
    }

    public boolean clearActiveCartByCustomerId(int customerId) {
        Cart activeCart = getActiveCartByCustomerId(customerId);
        if (activeCart == null) {
            return true;
        }

        CartItemDAO cartItemDAO = new CartItemDAO();
        cartItemDAO.deleteByCartId(activeCart.getId());

        return markCartCheckedOut(activeCart.getId());
    }

    public boolean clearActiveCartByGuestId(String guestId) {
        Cart activeCart = getActiveCartByGuestId(guestId);
        if (activeCart == null) {
            return true;
        }

        CartItemDAO cartItemDAO = new CartItemDAO();
        boolean deletedItems = cartItemDAO.deleteByCartId(activeCart.getId());
        boolean checkedOut = markCartCheckedOut(activeCart.getId());

        return deletedItems && checkedOut;
    }

    public boolean clearActiveCartByCustomerId(Connection conn, int customerId) throws SQLException {
        Cart activeCart = getActiveCartByCustomerId(conn, customerId);
        if (activeCart == null) {
            return true;
        }

        CartItemDAO cartItemDAO = new CartItemDAO();
        boolean deletedItems = cartItemDAO.deleteByCartId(conn, activeCart.getId());
        boolean checkedOut = markCartCheckedOut(conn, activeCart.getId());
        return deletedItems && checkedOut;
    }

    public boolean clearActiveCartByGuestId(Connection conn, String guestId) throws SQLException {
        Cart activeCart = getActiveCartByGuestId(conn, guestId);
        if (activeCart == null) {
            return true;
        }

        CartItemDAO cartItemDAO = new CartItemDAO();
        boolean deletedItems = cartItemDAO.deleteByCartId(conn, activeCart.getId());
        boolean checkedOut = markCartCheckedOut(conn, activeCart.getId());
        return deletedItems && checkedOut;
    }

    private Cart getActiveCartByCustomerId(Connection conn, int customerId) throws SQLException {
        String sql = "SELECT * FROM Carts WHERE customer_user_id = ? AND status = 'ACTIVE'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    private Cart getActiveCartByGuestId(Connection conn, String guestId) throws SQLException {
        String sql = "SELECT * FROM Carts WHERE guest_id = ? AND status = 'ACTIVE'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, guestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public boolean attachGuestCartToCustomer(String guestId, int customerId) {
        Cart guestCart = getActiveCartByGuestId(guestId);
        if (guestCart == null) {
            return true;
        }

        Cart customerCart = getActiveCartByCustomerId(customerId);

        if (customerCart == null) {
            String sql = "UPDATE Carts SET customer_user_id = ?, guest_id = NULL WHERE id = ?";
            return update(sql, customerId, guestCart.getId()) > 0;
        }

        CartItemDAO cartItemDAO = new CartItemDAO();
        List<CartItem> guestItems = cartItemDAO.getItemsByCartId(guestCart.getId());

        for (CartItem guestItem : guestItems) {
            CartItem existing = cartItemDAO.checkItemExist(
                    customerCart.getId(),
                    guestItem.getFoodItemId(),
                    guestItem.getOptionSignature()
            );
            if (existing != null) {
                int newQty = existing.getQuantity() + guestItem.getQuantity();
                cartItemDAO.updateQuantity(existing.getId(), newQty);
            } else {
                CartItem newItem = new CartItem();
                newItem.setCartId(customerCart.getId());
                newItem.setFoodItemId(guestItem.getFoodItemId());
                newItem.setQuantity(guestItem.getQuantity());
                newItem.setUnitPriceSnapshot(guestItem.getUnitPriceSnapshot());
                newItem.setNote(guestItem.getNote());
                newItem.setSelectedSize(guestItem.getSelectedSize());
                newItem.setSelectedToppings(guestItem.getSelectedToppings());
                newItem.setOptionExtraPrice(guestItem.getOptionExtraPrice());
                newItem.setOptionSignature(guestItem.getOptionSignature());
                cartItemDAO.insert(newItem);
            }
        }

        cartItemDAO.delete(guestCart.getId());
        markCartCheckedOut(guestCart.getId());
        return true;
    }
}
