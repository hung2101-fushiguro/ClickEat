package com.clickeat.controller.web;

import java.io.IOException;
import java.util.Map;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerOrderTrackingServlet", urlPatterns = {"/customer/order-tracking", "/order-tracking"})
public class CustomerOrderTrackingServlet extends HttpServlet {

    private User getLoggedCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User account = (User) session.getAttribute("account");
        if (account == null || account.getRole() == null || !"CUSTOMER".equalsIgnoreCase(account.getRole().trim())) {
            response.sendRedirect(request.getContextPath() + "/login");
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

        String orderIdRaw = request.getParameter("orderId");
        if (orderIdRaw == null || orderIdRaw.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdRaw.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Map<String, Object> snapshot = orderDAO.getCustomerTrackingSnapshot(orderId, account.getId());
        if (snapshot == null) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        String format = request.getParameter("format");
        if ("json".equalsIgnoreCase(format)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(toJson(snapshot));
            return;
        }

        request.setAttribute("tracking", snapshot);
        request.getRequestDispatcher("/views/web/order-tracking.jsp").forward(request, response);
    }

    private String toJson(Map<String, Object> data) {
        StringBuilder sb = new StringBuilder();
        sb.append('{');
        append(sb, "orderId", data.get("orderId"));
        append(sb, "orderCode", data.get("orderCode"));
        append(sb, "orderStatus", data.get("orderStatus"));
        append(sb, "paymentStatus", data.get("paymentStatus"));
        append(sb, "paymentMethod", data.get("paymentMethod"));
        append(sb, "deliveryAddress", data.get("deliveryAddress"));
        append(sb, "customerLat", data.get("customerLat"));
        append(sb, "customerLng", data.get("customerLng"));
        append(sb, "shipperUserId", data.get("shipperUserId"));
        append(sb, "shipperLat", data.get("shipperLat"));
        append(sb, "shipperLng", data.get("shipperLng"));
        append(sb, "shipperName", data.get("shipperName"));
        append(sb, "shipperPhone", data.get("shipperPhone"));
        append(sb, "shipperUpdatedAt", data.get("shipperUpdatedAt"));
        if (sb.charAt(sb.length() - 1) == ',') {
            sb.deleteCharAt(sb.length() - 1);
        }
        sb.append('}');
        return sb.toString();
    }

    private void append(StringBuilder sb, String key, Object value) {
        sb.append('"').append(escapeJson(key)).append('"').append(':');
        if (value == null) {
            sb.append("null,");
            return;
        }
        if (value instanceof Number || value instanceof Boolean) {
            sb.append(value).append(',');
            return;
        }
        sb.append('"').append(escapeJson(String.valueOf(value))).append('"').append(',');
    }

    private String escapeJson(String raw) {
        if (raw == null) {
            return "";
        }
        return raw
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
