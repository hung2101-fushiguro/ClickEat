package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemViewDAO;
import com.clickeat.dal.impl.CategoryDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItemView;
import com.clickeat.model.Category;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "StoreDetailServlet", urlPatterns = {"/store-detail"})
public class StoreDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/store");
            return;
        }

        int merchantId;
        try {
            merchantId = Integer.parseInt(idRaw);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/store");
            return;
        }

        String keyword = request.getParameter("keyword");
        String filter = request.getParameter("filter");
        String categoryRaw = request.getParameter("category");
        Integer categoryId = null;

        if (categoryRaw != null && !categoryRaw.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryRaw);
            } catch (Exception e) {
                categoryId = null;
            }
        }

        MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
        MerchantProfile store = merchantDAO.findApprovedStoreById(merchantId);
        if (store == null) {
            response.sendRedirect(request.getContextPath() + "/store");
            return;
        }

        CategoryDAO categoryDAO = new CategoryDAO();
        FoodItemDAO foodDAO = new FoodItemDAO();

        List<Category> categories = categoryDAO.getActiveByMerchant(merchantId);
        List<FoodItem> foods = foodDAO.findStoreFoods(merchantId, categoryId, keyword, filter);

        bindCartForStore(request, merchantId);

        request.setAttribute("store", store);
        request.setAttribute("categories", categories);
        request.setAttribute("foods", foods);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("keyword", keyword);
        request.setAttribute("filter", filter);

        request.getRequestDispatcher("/views/web/store-detail.jsp").forward(request, response);
    }

    private void bindCartForStore(HttpServletRequest request, int merchantId) {
        HttpSession session = request.getSession();
        int cartCount = 0;
        double cartTotal = 0;
        List<CartItemView> popupCartItems = Collections.emptyList();
        List<CartItemView> storeCartItems = Collections.emptyList();

        CartDAO cartDAO = new CartDAO();
        CartItemViewDAO cartItemViewDAO = new CartItemViewDAO();

        try {
            Cart cart = null;
            User account = (User) session.getAttribute("account");
            String guestId = (String) session.getAttribute("guestId");

            if (account != null) {
                cart = cartDAO.getActiveCartByCustomerId(account.getId());
            } else if (guestId != null && !guestId.isBlank()) {
                cart = cartDAO.getActiveCartByGuestId(guestId);
            }

            if (cart != null) {
                popupCartItems = cartItemViewDAO.getByCartId(cart.getId());

                if (popupCartItems == null) {
                    popupCartItems = Collections.emptyList();
                }

                for (CartItemView item : popupCartItems) {
                    cartCount += item.getQuantity();
                    cartTotal += item.getLineTotal();
                }

                Integer cartMerchantUserId = cart.getMerchantUserId();
                if (cartMerchantUserId != null && cartMerchantUserId == merchantId) {
                    storeCartItems = popupCartItems;
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi bind cart store-detail: " + e.getMessage());
            e.printStackTrace();
        }

        request.setAttribute("cartItems", popupCartItems);
        request.setAttribute("cartCount", cartCount);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("storeCartItems", storeCartItems);

        String queryString = request.getQueryString();
        String currentUrl = request.getRequestURI();
        if (queryString != null && !queryString.isBlank()) {
            currentUrl += "?" + queryString;
        }
        request.setAttribute("lastStoreUrl", currentUrl);
    }
}