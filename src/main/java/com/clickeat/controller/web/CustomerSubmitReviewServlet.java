package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CustomerSubmitReviewServlet", urlPatterns = {"/customer/submit-review"})
public class CustomerSubmitReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equalsIgnoreCase(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderIdRaw = request.getParameter("orderId");
        if (orderIdRaw == null || orderIdRaw.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdRaw);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        RatingDAO ratingDAO = new RatingDAO();

        Map<String, Integer> targets = orderDAO.getRatingTargetsForDeliveredOrder(orderId, account.getId());
        if (targets == null) {
            response.sendRedirect(request.getContextPath() + "/customer/order-tracking?orderId=" + orderId);
            return;
        }

        int merchantUserId = targets.getOrDefault("merchantUserId", 0);
        int shipperUserId = targets.getOrDefault("shipperUserId", 0);

        int merchantStars = parseStars(request.getParameter("merchantStars"));
        String merchantComment = trim(request.getParameter("merchantComment"));

        int shipperStars = parseStars(request.getParameter("shipperStars"));
        String shipperComment = trim(request.getParameter("shipperComment"));

        if (merchantUserId > 0 && merchantStars >= 1 && merchantStars <= 5
                && !ratingDAO.hasCustomerRatingForTarget(orderId, account.getId(), "MERCHANT")) {
            ratingDAO.insertCustomerRating(orderId, account.getId(), "MERCHANT", merchantUserId, merchantStars, merchantComment);
        }

        if (shipperUserId > 0 && shipperStars >= 1 && shipperStars <= 5
                && !ratingDAO.hasCustomerRatingForTarget(orderId, account.getId(), "SHIPPER")) {
            ratingDAO.insertCustomerRating(orderId, account.getId(), "SHIPPER", shipperUserId, shipperStars, shipperComment);
        }

        response.sendRedirect(request.getContextPath() + "/home");
    }

    private int parseStars(String raw) {
        try {
            int v = Integer.parseInt(raw);
            return (v >= 1 && v <= 5) ? v : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}