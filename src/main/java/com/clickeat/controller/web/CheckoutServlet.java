package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    // HIỂN THỊ TRANG THANH TOÁN
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        // 1. Bắt buộc đăng nhập
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int customerId = account.getId(); 
        
        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();

        // 2. Lấy Giỏ hàng hiện tại
        Cart cart = cartDAO.getActiveCartByCustomerId(customerId);
        
        // Nếu không có giỏ hàng hoặc giỏ hàng trống thì đuổi về trang chủ
        if (cart == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<CartItem> cartItems = cartItemDAO.getItemsByCartId(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 3. Tính tiền
        double subTotal = 0;
        for (CartItem item : cartItems) {
            subTotal += (item.getQuantity() * item.getUnitPriceSnapshot());
        }
        
        double deliveryFee = 15000; // Phí ship mặc định tạm thời
        double totalAmount = subTotal + deliveryFee;

        // 4. Đẩy dữ liệu sang JSP
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subTotal", subTotal);
        request.setAttribute("deliveryFee", deliveryFee);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("user", account); // Truyền user sang để điền sẵn Tên, SĐT
        
        FoodItemDAO foodDAO = new FoodItemDAO();
        request.setAttribute("foodDAO", foodDAO); 

        // 5. Chuyển hướng
        request.getRequestDispatcher("/views/web/checkout.jsp").forward(request, response);
    }

    // XỬ LÝ KHI BẤM NÚT "ĐẶT HÀNG" (Sẽ code ở bước sau)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: Lưu vào bảng Orders, OrderItems, đổi trạng thái Carts thành CHECKED_OUT
    }
}