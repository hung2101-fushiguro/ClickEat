package com.clickeat.dal.interfaces;

import com.clickeat.model.Cart;

public interface ICartDAO extends IGenericDAO<Cart> {
    
    // Tìm giỏ hàng đang Hoạt động (ACTIVE) của Khách hàng đã đăng nhập
    Cart getActiveCartByCustomerId(int customerId);
    
    // Tìm giỏ hàng đang Hoạt động của Khách vãng lai (Guest)
    Cart getActiveCartByGuestId(String guestId);
    
    // Tạo giỏ hàng mới cho Khách hàng đã đăng nhập
    boolean createNewCart(int customerId);
    
    // Tạo giỏ hàng mới cho Khách vãng lai
    boolean createNewGuestCart(String guestId);
}