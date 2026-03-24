package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
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
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final CartItemDAO cartItemDAO = new CartItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        String guestId = (String) session.getAttribute("guestId");

        int cartCount = 0;
        List<FoodItem> foods = new ArrayList<>();
        List<Voucher> vouchers = new ArrayList<>();
        List<MerchantProfile> merchants = new ArrayList<>();

        try {
            Cart cart = null;

            // Nếu đã đăng nhập thì lấy cart theo customer
            if (account != null) {
                cart = cartDAO.getActiveCartByCustomerId(account.getId());
            }
            // Nếu chưa đăng nhập thì lấy cart theo guestId
            else if (guestId != null && !guestId.trim().isEmpty()) {
                cart = cartDAO.getActiveCartByGuestId(guestId);
            }

            if (cart != null) {
                List<CartItem> items = cartItemDAO.getItemsByCartId(cart.getId());
                if (items != null) {
                    for (CartItem item : items) {
                        cartCount += item.getQuantity(); // đếm tổng số lượng món
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("cartError", e.getMessage());
        }

        try {
            foods = foodItemDAO.getTopFoods(8);
            System.out.println("foods size = " + (foods == null ? "null" : foods.size()));
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("foodsError", e.getMessage());
        }

        try {
            vouchers = voucherDAO.getActiveVouchers(4);
            System.out.println("vouchers size = " + (vouchers == null ? "null" : vouchers.size()));
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("vouchersError", e.getMessage());
        }

        try {
            merchants = merchantProfileDAO.getFeaturedMerchants(6);
            System.out.println("merchants size = " + (merchants == null ? "null" : merchants.size()));
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("merchantsError", e.getMessage());
        }

        if (foods == null) {
            foods = new ArrayList<>();
        }
        if (vouchers == null) {
            vouchers = new ArrayList<>();
        }
        if (merchants == null) {
            merchants = new ArrayList<>();
        }

        request.setAttribute("cartCount", cartCount);
        request.setAttribute("foods", foods);
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("merchants", merchants);

        request.getRequestDispatcher("/views/web/home.jsp").forward(request, response);
    }
}