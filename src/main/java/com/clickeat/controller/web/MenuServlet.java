package com.clickeat.controller.web;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.model.FoodItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MenuServlet", urlPatterns = {"/menu"})
public class MenuServlet extends HttpServlet {

    private static final double DEFAULT_MAX_DELIVERY_KM = 12;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort");
        int page = parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 12;

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

        double maxDistanceKm = getConfigDouble("clickeat.shipping.maxDistanceKm", DEFAULT_MAX_DELIVERY_KM);
        boolean hasCustomerLocation = customerLat != null && customerLng != null;

        FoodItemDAO foodItemDAO = new FoodItemDAO();
        int totalItems = foodItemDAO.countPublicMenuFoods(keyword, customerLat, customerLng, maxDistanceKm);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) pageSize));
        if (page > totalPages) {
            page = totalPages;
        }

        List<FoodItem> foods = foodItemDAO.searchPublicMenuFoods(keyword, sort, page, pageSize, customerLat, customerLng, maxDistanceKm);

        request.setAttribute("foods", foods);
        request.setAttribute("keyword", keyword);
        request.setAttribute("sort", sort);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("customerLat", customerLat);
        request.setAttribute("customerLng", customerLng);
        request.setAttribute("hasCustomerLocation", hasCustomerLocation);

        request.getRequestDispatcher("/views/web/menu.jsp").forward(request, response);
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
            return Double.valueOf(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private double getConfigDouble(String key, double defaultValue) {
        String value = System.getProperty(key);
        if (value == null || value.isBlank()) {
            String envKey = key.toUpperCase().replace('.', '_');
            value = System.getenv(envKey);
        }
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
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
}
