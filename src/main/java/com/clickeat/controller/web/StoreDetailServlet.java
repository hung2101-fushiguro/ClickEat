package com.clickeat.controller.web;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemViewDAO;
import com.clickeat.dal.impl.CategoryDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItemView;
import com.clickeat.model.Category;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StoreDetailServlet", urlPatterns = {"/store-detail"})
public class StoreDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
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
            String sort = request.getParameter("sort");
            int page = parsePositiveInt(request.getParameter("page"), 1);
            int pageSize = 12;
            String categoryRaw = request.getParameter("category");
            Integer categoryId = null;

            if (categoryRaw != null && !categoryRaw.trim().isEmpty()) {
                try {
                    categoryId = Integer.parseInt(categoryRaw);
                } catch (Exception ignored) {
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
            VoucherDAO voucherDAO = new VoucherDAO();

            List<Category> categories = categoryDAO.getActiveByMerchant(merchantId);
            int totalFoods = foodDAO.countStoreFoods(merchantId, categoryId, keyword);
            int totalPages = Math.max(1, (int) Math.ceil(totalFoods / (double) pageSize));
            if (page > totalPages) {
                page = totalPages;
            }
            List<FoodItem> foods = foodDAO.findStoreFoodsPaged(merchantId, categoryId, keyword, filter, sort, page, pageSize);
            List<Voucher> storeVouchers = voucherDAO.findPublishedByMerchant(merchantId);

            bindCartForStore(request, merchantId);

            request.setAttribute("store", store);
            request.setAttribute("categories", categories);
            request.setAttribute("foods", foods);
            request.setAttribute("storeVouchers", storeVouchers);
            request.setAttribute("selectedCategory", categoryId);
            request.setAttribute("keyword", keyword);
            request.setAttribute("filter", filter);
            request.setAttribute("sort", sort);
            request.setAttribute("page", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalFoods", totalFoods);
            request.setAttribute("totalPages", totalPages);

            request.getRequestDispatcher("/views/web/store-detail.jsp").forward(request, response);
        } catch (Exception ex) {
            if (!response.isCommitted()) {
                response.sendRedirect(request.getContextPath() + "/store");
            }
        }
    }

    private int parsePositiveInt(String raw, int defaultValue) {
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            int value = Integer.parseInt(raw);
            return value > 0 ? value : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private void bindCartForStore(HttpServletRequest request, int merchantId) {
        HttpSession session = request.getSession();
        int cartCount = 0;
        double cartTotal = 0;
        List<CartItemView> popupCartItems = Collections.emptyList();
        List<CartItemView> storeCartItems = Collections.emptyList();

        CartDAO cartDAO = new CartDAO();
        CartItemViewDAO cartItemViewDAO = new CartItemViewDAO();

        Integer cartMerchantUserId = null;

        try {
            Cart cart = null;
            User account = (User) session.getAttribute("account");
            String guestId = (String) session.getAttribute("guestId");
            if (guestId == null || guestId.isBlank()) {
                guestId = (String) session.getAttribute("guest_id");
            }
            if (guestId != null && !guestId.isBlank()) {
                session.setAttribute("guestId", guestId);
                session.setAttribute("guest_id", guestId);
            }

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

                cartMerchantUserId = cart.getMerchantUserId();

                if (cartMerchantUserId != null && cartMerchantUserId.equals(merchantId)) {
                    storeCartItems = popupCartItems;
                }
            }

        } catch (Exception ignored) {
        }

        request.setAttribute("cartItems", popupCartItems);
        request.setAttribute("cartCount", cartCount);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("storeCartItems", storeCartItems);

        String ctx = request.getContextPath();

        if (cartMerchantUserId != null && !popupCartItems.isEmpty()) {
            request.setAttribute("lastStoreUrl", ctx + "/store-detail?id=" + cartMerchantUserId);
        } else {
            request.setAttribute("lastStoreUrl", ctx + "/store-detail?id=" + merchantId);
        }
    }
}
