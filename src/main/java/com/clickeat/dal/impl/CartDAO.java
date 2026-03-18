package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.ICartDAO;
import com.clickeat.model.Cart;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

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
}