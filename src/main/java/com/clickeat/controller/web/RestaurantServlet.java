package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.Rating;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RestaurantServlet", urlPatterns = {"/restaurant"})
public class RestaurantServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            long merchantId = Long.parseLong(idParam);

            MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
            MerchantProfile merchant = merchantDAO.getByUserId(merchantId);

            if (merchant == null || !"APPROVED".equals(merchant.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            FoodItemDAO foodDAO = new FoodItemDAO();
            List<FoodItem> foods = foodDAO.findByMerchant((int) merchantId);

            RatingDAO ratingDAO = new RatingDAO();
            double avgRating = ratingDAO.getAverageRating((int) merchantId);
            int totalRatings = ratingDAO.getTotalCount((int) merchantId);
            List<Rating> reviews = ratingDAO.getLatestReviewsForRestaurant((int) merchantId, 8);

            // Cart count for header
            int cartCount = 0;
            User account = (User) request.getSession().getAttribute("account");
            if (account != null) {
                CartDAO cartDAO = new CartDAO();
                CartItemDAO cartItemDAO = new CartItemDAO();
                Cart cart = cartDAO.getActiveCartByCustomerId(account.getId());
                if (cart != null) {
                    List<CartItem> cartItems = cartItemDAO.getItemsByCartId(cart.getId());
                    if (cartItems != null) {
                        cartCount = cartItems.size();
                    }
                }
            }

            request.setAttribute("merchant", merchant);
            request.setAttribute("foods", foods);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("totalRatings", totalRatings);
            request.setAttribute("reviews", reviews);
            request.setAttribute("cartCount", cartCount);
            request.getRequestDispatcher("/views/web/restaurant.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
