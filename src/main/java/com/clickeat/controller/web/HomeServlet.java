package com.clickeat.controller.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

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
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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

        if (account != null) {
            String role = account.getRole();
            if ("MERCHANT".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
                return;
            }
            if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                return;
            }
            if ("SHIPPER".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
                return;
            }
        }

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
            } // Nếu chưa đăng nhập thì lấy cart theo guestId
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
            Double customerLat = parseCoordinate(request.getParameter("shippingLat"));
            Double customerLng = parseCoordinate(request.getParameter("shippingLng"));

            if (customerLat == null || customerLng == null) {
                customerLat = parseCoordinate(stringSession(session, "customer_home_latitude"));
                customerLng = parseCoordinate(stringSession(session, "customer_home_longitude"));
            }
            if (customerLat == null || customerLng == null) {
                customerLat = parseCoordinate(readCookie(request, "ce_home_lat"));
                customerLng = parseCoordinate(readCookie(request, "ce_home_lng"));
            }

            if (customerLat != null && customerLng != null) {
                session.setAttribute("customer_home_latitude", String.valueOf(customerLat));
                session.setAttribute("customer_home_longitude", String.valueOf(customerLng));
            }

            merchants = merchantProfileDAO.searchApprovedStores(
                    null,
                    null,
                    null,
                    customerLat != null && customerLng != null ? "near" : "rating",
                    customerLat,
                    customerLng
            );

            if (merchants != null && merchants.size() > 6) {
                merchants = new ArrayList<>(merchants.subList(0, 6));
            }
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

    private String readCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null || name == null) {
            return null;
        }
        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }

    private String stringSession(HttpSession session, String key) {
        Object value = session.getAttribute(key);
        return value == null ? null : value.toString();
    }

    private Double parseCoordinate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
