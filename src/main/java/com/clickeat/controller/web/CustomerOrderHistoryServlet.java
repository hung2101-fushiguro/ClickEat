package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
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

    private boolean isActiveOrder(String status) {
        if (status == null) {
            return false;
        }
        status = status.trim().toUpperCase();

        return "CREATED".equals(status)
                || "PAID".equals(status)
                || "MERCHANT_ACCEPTED".equals(status)
                || "PREPARING".equals(status)
                || "READY_FOR_PICKUP".equals(status)
                || "DELIVERING".equals(status)
                || "PICKED_UP".equals(status);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = getLoggedCustomer(request, response);
        if (account == null) {
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        RatingDAO ratingDAO = new RatingDAO();

        List<Order> orders = orderDAO.getOrderHistoryByUser(account.getId(), "CUSTOMER");
        List<Order> activeOrders = new ArrayList<>();
        List<Order> historyOrders = new ArrayList<>();

        for (Order o : orders) {
            String status = o.getOrderStatus();

            if (isActiveOrder(status)) {
                activeOrders.add(o);
            } else {
                historyOrders.add(o);
            }

            boolean merchantRated = false;
            boolean shipperRated = false;

            try {
                merchantRated = ratingDAO.hasRatingForOrderAndTarget(o.getId(), "MERCHANT");
            } catch (Exception ignored) {
            }

            try {
                shipperRated = ratingDAO.hasRatingForOrderAndTarget(o.getId(), "SHIPPER");
            } catch (Exception ignored) {
            }

            request.setAttribute("merchantRated_" + o.getId(), merchantRated);
            request.setAttribute("shipperRated_" + o.getId(), shipperRated);
            request.setAttribute("fullyRated_" + o.getId(), merchantRated && (o.getShipperUserId() <= 0 || shipperRated));
        }

        request.setAttribute("activeOrders", activeOrders);
        request.setAttribute("historyOrders", historyOrders);

        request.getRequestDispatcher("/views/web/orders.jsp").forward(request, response);
    }
}
