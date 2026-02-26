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
            action = "view"; 
        }

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int customerId = account.getId(); 
        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        FoodItemDAO foodDAO = new FoodItemDAO();

        // --------------------------------------------------------
        // LUỒNG 1: THÊM MÓN VÀO GIỎ (ADD)
        // --------------------------------------------------------
        if ("add".equals(action)) {
            try {
                int foodId = Integer.parseInt(request.getParameter("id"));
                FoodItem food = foodDAO.findById(foodId);

                if (food != null) {
                    Cart cart = cartDAO.getActiveCartByCustomerId(customerId);
                    if (cart == null) {
                        cartDAO.createNewCart(customerId);
                        cart = cartDAO.getActiveCartByCustomerId(customerId);
                    }

                    // 🔥 LOGIC: KIỂM TRA 1 NHÀ HÀNG BẰNG JAVA 🔥
                    List<CartItem> currentItems = cartItemDAO.getItemsByCartId(cart.getId());
                    if (currentItems != null && !currentItems.isEmpty()) {
                        FoodItem firstFoodInCart = foodDAO.findById(currentItems.get(0).getFoodItemId());
                        // Nếu món mới không cùng quán với món đang có trong giỏ -> Chặn!
                        if (firstFoodInCart.getMerchantUserId() != food.getMerchantUserId()) {
                            session.setAttribute("toastError", "Giỏ hàng chỉ được chứa món từ 1 nhà hàng! Vui lòng xóa giỏ cũ.");
                            response.sendRedirect(request.getContextPath() + "/home");
                            return;
                        }
                    }

                    // Tiến hành thêm món
                    CartItem existItem = cartItemDAO.checkItemExist(cart.getId(), foodId);
                    boolean isSuccess = false;
                    
                    if (existItem != null) {
                        isSuccess = cartItemDAO.updateQuantity(existItem.getId(), existItem.getQuantity() + 1);
                    } else {
                        CartItem newItem = new CartItem();
                        newItem.setCartId(cart.getId());
                        newItem.setFoodItemId(foodId);
                        newItem.setQuantity(1);
                        newItem.setUnitPriceSnapshot(food.getPrice());
                        newItem.setNote(""); 
                        
                        isSuccess = (cartItemDAO.insert(newItem) > 0); 
                    }
                    
                    if (isSuccess) {
                        session.setAttribute("toastMsg", "Đã thêm món vào giỏ hàng!");
                    } else {
                        session.setAttribute("toastError", "Lỗi CSDL: Không thể thêm món.");
                    }
                }
            } catch (Exception e) {
                System.out.println("Lỗi thêm vào giỏ: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/home");
            return; 
        } 
        
        // --------------------------------------------------------
        // LUỒNG 2: XÓA MÓN KHỎI GIỎ (DELETE)
        // --------------------------------------------------------
        else if ("delete".equals(action)) {
            try {
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                boolean isSuccess = cartItemDAO.delete(itemId);
                
                if (isSuccess) {
                    session.setAttribute("toastMsg", "Đã xóa món ăn khỏi giỏ!");
                } else {
                    session.setAttribute("toastError", "Lỗi CSDL: Không thể xóa dòng này!");
                }
            } catch (Exception e) {
                System.out.println("Lỗi xóa: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            return;
        }

        // --------------------------------------------------------
        // LUỒNG 3: XEM GIỎ HÀNG (VIEW)
        // --------------------------------------------------------
        else if ("view".equals(action)) {
            Cart cart = cartDAO.getActiveCartByCustomerId(customerId);
            
            if (cart != null) {
                List<CartItem> cartItems = cartItemDAO.getItemsByCartId(cart.getId());
                double totalMoney = 0;
                
                if(cartItems != null) {
                    for (CartItem item : cartItems) {
                        totalMoney += (item.getQuantity() * item.getUnitPriceSnapshot());
                    }
                }
                
                request.setAttribute("cartItems", cartItems);
                request.setAttribute("totalMoney", totalMoney);
                request.setAttribute("foodDAO", foodDAO); 
            }
            
            request.getRequestDispatcher("/views/web/cart.jsp").forward(request, response);
            return; 
        }
    }
}