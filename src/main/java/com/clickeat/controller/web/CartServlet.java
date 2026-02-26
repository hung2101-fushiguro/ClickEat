package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.FoodItem;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "view"; // Mặc định là xem giỏ hàng
        }

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        // Yêu cầu đăng nhập
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy ID chuẩn kiểu int từ User
        int customerId = account.getId(); 
        
        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();

        // --------------------------------------------------------
        // LUỒNG 1: THÊM MÓN VÀO GIỎ (ADD)
        // --------------------------------------------------------
        if ("add".equals(action)) {
            try {
                // Parse thẳng ra int, không dùng Long nữa
                int foodId = Integer.parseInt(request.getParameter("id"));
                
                FoodItemDAO foodDAO = new FoodItemDAO();
                FoodItem food = foodDAO.findById(foodId);

                if (food != null) {
                    Cart cart = cartDAO.getActiveCartByCustomerId(customerId);
                    if (cart == null) {
                        cartDAO.createNewCart(customerId);
                        cart = cartDAO.getActiveCartByCustomerId(customerId);
                    }

                    // Dùng int cho tất cả các ID
                    CartItem existItem = cartItemDAO.checkItemExist(cart.getId(), foodId);
                    
                    if (existItem != null) {
                        cartItemDAO.updateQuantity(existItem.getId(), existItem.getQuantity() + 1);
                    } else {
                        CartItem newItem = new CartItem();
                        newItem.setCartId(cart.getId());
                        newItem.setFoodItemId(foodId);
                        newItem.setQuantity(1);
                        newItem.setUnitPriceSnapshot(food.getPrice());
                        
                        cartItemDAO.insert(newItem);
                    }
                }
            } catch (Exception e) {
                System.out.println("Lỗi thêm vào giỏ: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/home");
        } 
        // --------------------------------------------------------
        // LUỒNG 2: XEM GIỎ HÀNG (VIEW)
        // --------------------------------------------------------
        else if ("view".equals(action)) {
            Cart cart = cartDAO.getActiveCartByCustomerId(customerId);
            
            if (cart != null) {
                List<CartItem> cartItems = cartItemDAO.getItemsByCartId(cart.getId());
                
                double totalMoney = 0;
                for (CartItem item : cartItems) {
                    totalMoney += (item.getQuantity() * item.getUnitPriceSnapshot());
                }
                
                request.setAttribute("cartItems", cartItems);
                request.setAttribute("totalMoney", totalMoney);
                
                FoodItemDAO foodDAO = new FoodItemDAO();
                request.setAttribute("foodDAO", foodDAO); 
            }
            
            request.getRequestDispatcher("/views/web/cart.jsp").forward(request, response);
        }
    }
}