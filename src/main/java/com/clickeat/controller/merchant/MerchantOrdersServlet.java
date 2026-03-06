package com.clickeat.controller.merchant;

import com.clickeat.config.DBContext;
import com.clickeat.model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/merchant/orders")
public class MerchantOrdersServlet extends HttpServlet {

    private static final Map<String, String> STATUS_TABS = new LinkedHashMap<>();

    static {
        STATUS_TABS.put("ALL", "Tất cả");
        STATUS_TABS.put("CREATED", "Mới");
        STATUS_TABS.put("MERCHANT_ACCEPTED", "Đang nấu");
        STATUS_TABS.put("READY_FOR_PICKUP", "Sẵn sàng");
        STATUS_TABS.put("DELIVERING", "Đang giao");
        STATUS_TABS.put("DELIVERED", "Hoàn tất");
        STATUS_TABS.put("CANCELLED", "Đã hủy");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = (int) req.getSession().getAttribute("merchantId");
        String filterStatus = req.getParameter("status");
        if (filterStatus == null || filterStatus.isBlank() || "ALL".equals(filterStatus)) {
            filterStatus = null;
        }

        List<Order> orders = new ArrayList<>();
        int newOrderCount = 0;

        String sql = "SELECT * FROM Orders WHERE merchant_user_id = ? "
                + (filterStatus != null ? "AND order_status = ? " : "")
                + "ORDER BY created_at DESC";

        String sqlNew = "SELECT COUNT(*) FROM Orders WHERE merchant_user_id = ? AND order_status IN ('CREATED','PAID')";

        try (Connection conn = DBContext.getConnection()) {
            // Count new orders for badge
            try (PreparedStatement ps = conn.prepareStatement(sqlNew)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    newOrderCount = rs.getInt(1);
                }
            }
            // Fetch orders
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, merchantId);
                if (filterStatus != null) {
                    ps.setString(2, filterStatus);
                }
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Order o = new Order();
                    o.setId(rs.getInt("id"));
                    o.setOrderCode(rs.getString("order_code"));
                    o.setReceiverName(rs.getString("receiver_name"));
                    o.setReceiverPhone(rs.getString("receiver_phone"));
                    o.setDeliveryAddressLine(rs.getString("delivery_address_line"));
                    o.setOrderStatus(rs.getString("order_status"));
                    o.setTotalAmount(rs.getDouble("total_amount"));
                    o.setCreatedAt(rs.getTimestamp("created_at"));
                    o.setDeliveredAt(rs.getTimestamp("delivered_at"));
                    orders.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Build tab list for EL
        List<Map<String, String>> tabList = new ArrayList<>();
        for (Map.Entry<String, String> e : STATUS_TABS.entrySet()) {
            Map<String, String> tab = new HashMap<>();
            tab.put("key", e.getKey());
            tab.put("value", e.getValue());
            tabList.add(tab);
        }

        req.setAttribute("orders", orders);
        req.setAttribute("statusTabs", tabList);
        req.setAttribute("newOrderCount", newOrderCount);
        req.getRequestDispatcher("/views/merchant/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String orderIdStr = req.getParameter("orderId");

        if (action != null && orderIdStr != null) {
            int orderId = Integer.parseInt(orderIdStr);
            String newStatus = switch (action) {
                case "accept" ->
                    "MERCHANT_ACCEPTED";
                case "ready" ->
                    "READY_FOR_PICKUP";
                case "cancel" ->
                    "CANCELLED";
                default ->
                    null;
            };

            if (newStatus != null) {
                String sql = newStatus.equals("READY_FOR_PICKUP")
                        ? "UPDATE Orders SET order_status = ?, ready_at = GETDATE() WHERE id = ?"
                        : "UPDATE Orders SET order_status = ? WHERE id = ?";
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        String referer = req.getHeader("Referer");
        resp.sendRedirect(referer != null ? referer : req.getContextPath() + "/merchant/orders");
    }
}
