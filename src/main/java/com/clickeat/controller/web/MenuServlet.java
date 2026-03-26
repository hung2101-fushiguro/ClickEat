package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.FoodItem;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "MenuServlet", urlPatterns = {"/menu"})
public class MenuServlet extends HttpServlet {

    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final CartItemDAO cartItemDAO = new CartItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String categoryParam = request.getParameter("category");
        List<FoodItem> foods;

        if (categoryParam != null && !categoryParam.trim().isEmpty()) {
            foods = foodItemDAO.getFoodsByCategoryName(categoryParam.trim());
            request.setAttribute("selectedCategory", categoryParam.trim());
        } else {
            foods = foodItemDAO.getAllAvailableFoods();
        }

        // Group foods by category name for display
        Map<String, List<FoodItem>> groupedFoods = new LinkedHashMap<>();
        if (foods != null) {
            groupedFoods = foods.stream()
                    .collect(Collectors.groupingBy(
                            f -> f.getCategoryName() != null ? f.getCategoryName() : "Khác",
                            LinkedHashMap::new,
                            Collectors.toList()
                    ));
        }

        // Get cart count for header
        int cartCount = 0;
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        String guestId = (String) session.getAttribute("guestId");

        try {
            Cart cart = null;
            if (account != null) {
                cart = cartDAO.getActiveCartByCustomerId(account.getId());
            } else if (guestId != null && !guestId.trim().isEmpty()) {
                cart = cartDAO.getActiveCartByGuestId(guestId);
            }

            if (cart != null) {
                List<CartItem> items = cartItemDAO.getItemsByCartId(cart.getId());
                if (items != null) {
                    for (CartItem item : items) {
                        cartCount += item.getQuantity();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("groupedFoods", groupedFoods);
        request.setAttribute("cartCount", cartCount);
        request.getRequestDispatcher("/views/web/menu.jsp").forward(request, response);
    }
}
