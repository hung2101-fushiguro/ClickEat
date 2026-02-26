package com.clickeat.dal.interfaces;

import com.clickeat.model.CartItem;
import java.util.List;

public interface ICartItemDAO extends IGenericDAO<CartItem> {
    
    // Lấy toàn bộ danh sách món ăn có trong 1 giỏ hàng cụ thể (Cực kỳ quan trọng cho trang Checkout)
    List<CartItem> getItemsByCartId(int cartId);
    
    // Kiểm tra xem 1 món ăn cụ thể đã tồn tại trong giỏ hàng này chưa
    CartItem checkItemExist(int cartId, int foodItemId);
    
    // Cập nhật lại số lượng của món ăn (khi khách bấm nút + hoặc -)
    boolean updateQuantity(int cartItemId, int newQuantity);
}