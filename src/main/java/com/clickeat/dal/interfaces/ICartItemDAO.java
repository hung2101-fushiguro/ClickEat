package com.clickeat.dal.interfaces;

import java.util.List;

import com.clickeat.model.CartItem;

public interface ICartItemDAO extends IGenericDAO<CartItem> {

    // Lấy toàn bộ danh sách món ăn có trong 1 giỏ hàng cụ thể (Cực kỳ quan trọng cho trang Checkout)
    List<CartItem> getItemsByCartId(int cartId);

    // Kiểm tra xem 1 món ăn cụ thể đã tồn tại trong giỏ hàng này chưa
    CartItem checkItemExist(int cartId, int foodItemId);

    // Kiểm tra món với cấu hình size/topping cụ thể
    CartItem checkItemExist(int cartId, int foodItemId, String optionSignature);

    // Cập nhật lại số lượng của món ăn (khi khách bấm nút + hoặc -)
    boolean updateQuantity(int cartItemId, int newQuantity);
}
