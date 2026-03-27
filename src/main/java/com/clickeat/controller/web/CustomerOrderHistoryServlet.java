package com.clickeat.controller.web;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.dal.impl.ShipperReviewDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerOrderHistoryServlet", urlPatterns = {"/customer/orders"})
public class CustomerOrderHistoryServlet extends HttpServlet {

    private User getLoggedCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User account = (User) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        if (!"CUSTOMER".equalsIgnoreCase(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return null;
        }

        return account;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = getLoggedCustomer(request, response);
        if (account == null) {
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        OrderItemDAO orderItemDAO = new OrderItemDAO();
        RatingDAO ratingDAO = new RatingDAO();
        ShipperReviewDAO shipperReviewDAO = new ShipperReviewDAO();
        List<Order> orders = orderDAO.getOrderHistoryByUser(account.getId(), "CUSTOMER");

        Map<Integer, Boolean> merchantRatedMap = new HashMap<>();
        Map<Integer, Boolean> shipperRatedMap = new HashMap<>();
        Map<Integer, List<OrderItem>> orderItemsMap = new HashMap<>();
        for (Order order : orders) {
            orderItemsMap.put(order.getId(), orderItemDAO.getItemsByOrderId(order.getId()));

            if (!"DELIVERED".equalsIgnoreCase(order.getOrderStatus())) {
                continue;
            }
            merchantRatedMap.put(order.getId(), ratingDAO.hasCustomerRatingForTarget(order.getId(), account.getId(), "MERCHANT"));
            if (order.getShipperUserId() > 0) {
                shipperRatedMap.put(order.getId(), shipperReviewDAO.hasCustomerReview(order.getId(), account.getId()));
            }
        }

        request.setAttribute("orders", orders);
        request.setAttribute("merchantRatedMap", merchantRatedMap);
        request.setAttribute("shipperRatedMap", shipperRatedMap);
        request.setAttribute("orderItemsMap", orderItemsMap);
        request.setAttribute("reviewStatus", request.getParameter("review"));
        request.getRequestDispatcher("/views/web/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User account = getLoggedCustomer(request, response);
        if (account == null) {
            return;
        }

        Integer orderId = parseIntOrNull(request.getParameter("orderId"));
        if (orderId == null || orderId <= 0) {
            redirectWithReviewStatus(response, request.getContextPath(), "invalid");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Map<String, Integer> targets = orderDAO.getRatingTargetsForDeliveredOrder(orderId, account.getId());
        if (targets == null) {
            redirectWithReviewStatus(response, request.getContextPath(), "invalid");
            return;
        }

        Integer merchantStars = parseIntOrNull(request.getParameter("merchantStars"));
        Integer shipperStars = parseIntOrNull(request.getParameter("shipperStars"));
        String merchantComment = request.getParameter("merchantComment");
        String shipperComment = request.getParameter("shipperComment");

        RatingDAO ratingDAO = new RatingDAO();
        ShipperReviewDAO shipperReviewDAO = new ShipperReviewDAO();

        boolean savedAny = false;

        int merchantId = targets.getOrDefault("merchantUserId", 0);
        if (merchantId > 0 && merchantStars != null && merchantStars >= 1 && merchantStars <= 5
                && !ratingDAO.hasCustomerRatingForTarget(orderId, account.getId(), "MERCHANT")) {
            savedAny = ratingDAO.insertCustomerRating(orderId, account.getId(), "MERCHANT", merchantId, merchantStars, merchantComment) || savedAny;
        }

        int shipperId = targets.getOrDefault("shipperUserId", 0);
        if (shipperId > 0 && shipperStars != null && shipperStars >= 1 && shipperStars <= 5
                && !shipperReviewDAO.hasCustomerReview(orderId, account.getId())) {
            savedAny = shipperReviewDAO.insertReview(orderId, shipperId, account.getId(), shipperStars, shipperComment) || savedAny;
        }

        if (savedAny) {
            redirectWithReviewStatus(response, request.getContextPath(), "success");
        } else {
            redirectWithReviewStatus(response, request.getContextPath(), "exists");
        }
    }

    private Integer parseIntOrNull(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(raw.strip());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void redirectWithReviewStatus(HttpServletResponse response, String contextPath, String status) throws IOException {
        String encoded = URLEncoder.encode(status, StandardCharsets.UTF_8);
        response.sendRedirect(contextPath + "/customer/orders?review=" + encoded);
    }
}
