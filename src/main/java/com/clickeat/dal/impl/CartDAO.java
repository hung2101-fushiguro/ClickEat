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
        cart.setId((int) rs.getLong("id"));

        // Xử lý cẩn thận Customer ID (vì có thể NULL nếu là Guest)
        int customerId = rs.getInt("customer_user_id");
        if (!rs.wasNull()) {
            cart.setCustomerUserId(customerId); // Truyền số int bình thường (sẽ tự auto-box thành Integer)
        } else {
            cart.setCustomerUserId(null); // Bây giờ gán null thoải mái không bị lỗi nữa
        }

        // Xử lý Guest ID (UNIQUEIDENTIFIER trong SQL trả về kiểu String)
        String guestId = rs.getString("guest_id");
        if (!rs.wasNull()) {
            cart.setGuestId(guestId);
        } else {
            cart.setGuestId(null);
        }
        int merchantId = rs.getInt("merchant_user_id");
        if (!rs.wasNull()) {
            cart.setMerchantUserId(merchantId);
        } else {
            cart.setMerchantUserId(0); // Nếu null thì gán là 0
        }

        cart.setStatus(rs.getString("status"));
        cart.setCreatedAt(rs.getTimestamp("created_at"));
        cart.setUpdatedAt(rs.getTimestamp("updated_at"));
        return cart;
    }

    // --- CÁC HÀM TỪ ICARTDAO ---
    @Override
    public Cart getActiveCartByCustomerId(int customerId) {
        String sql = "SELECT * FROM Carts WHERE customer_user_id = ? AND status = 'ACTIVE'";
        return queryOne(sql, customerId);
    }

    @Override
    public Cart getActiveCartByGuestId(String guestId) {
        String sql = "SELECT * FROM Carts WHERE guest_id = ? AND status = 'ACTIVE'";
        return queryOne(sql, guestId);
    }

    @Override
    public boolean createNewCart(int customerId) {
        String sql = "INSERT INTO Carts (customer_user_id, status) VALUES (?, 'ACTIVE')";
        return update(sql, customerId) > 0;
    }

    @Override
    public boolean createNewGuestCart(String guestId) {
        String sql = "INSERT INTO Carts (guest_id, status) VALUES (?, 'ACTIVE')";
        return update(sql, guestId) > 0;
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
        // Hàm này dùng nếu bạn cần insert đối tượng Cart đầy đủ
        String sql = "INSERT INTO Carts (customer_user_id, guest_id, status) VALUES (?, ?, ?)";
        return update(sql, cart.getCustomerUserId(), cart.getGuestId(), cart.getStatus());
    }

    @Override
    public boolean update(Cart cart) {
        // Thường dùng để update status thành 'CHECKED_OUT' sau khi thanh toán xong
        String sql = "UPDATE Carts SET status = ?, updated_at = SYSUTCDATETIME() WHERE id = ?";
        return update(sql, cart.getStatus(), cart.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        // Với Giỏ hàng, chúng ta không xóa cứng mà thường đổi trạng thái thành INACTIVE hoặc xóa sạch CartItems
        String sql = "UPDATE Carts SET status = 'INACTIVE', updated_at = SYSUTCDATETIME() WHERE id = ?";
        return update(sql, id) > 0;
    }
}
