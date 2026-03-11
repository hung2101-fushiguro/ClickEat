package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.clickeat.config.DBContext;
import com.clickeat.model.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
        STATUS_TABS.put("MERCHANT_REJECTED", "Đã từ chối");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();

        // ─── AJAX detail endpoint ───────────────────────────────────────
        if ("detail".equals(req.getParameter("action"))) {
            handleDetailJson(req, resp, merchantId);
            return;
        }

        String filterStatus = req.getParameter("status");
        if (filterStatus == null || filterStatus.isBlank() || "ALL".equals(filterStatus)) {
            filterStatus = null;
        }

        List<Order> orders = new ArrayList<>();
        int newOrderCount = 0;
        final int PAGE_SIZE = 20;
        int page = 1;
        try {
            page = Math.max(1, Integer.parseInt(req.getParameter("page")));
        } catch (Exception ignored) {
        }
        int offset = (page - 1) * PAGE_SIZE;
        int totalOrders = 0;

        String countSql = "SELECT COUNT(*) FROM Orders WHERE merchant_user_id = ? "
                + (filterStatus != null ? "AND order_status = ? " : "");

        String sql = "SELECT * FROM Orders WHERE merchant_user_id = ? "
                + (filterStatus != null ? "AND order_status = ? " : "")
                + "ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

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
            // Total count for pagination
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setInt(1, merchantId);
                if (filterStatus != null) {
                    ps.setString(2, filterStatus);
                }
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    totalOrders = rs.getInt(1);
                }
            }
            // Fetch orders
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int pi = 1;
                ps.setInt(pi++, merchantId);
                if (filterStatus != null) {
                    ps.setString(pi++, filterStatus);
                }
                ps.setInt(pi++, offset);
                ps.setInt(pi, PAGE_SIZE);
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

        int totalPages = (int) Math.ceil((double) totalOrders / PAGE_SIZE);
        if (totalPages < 1) {
            totalPages = 1;
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
        req.setAttribute("filterStatus", filterStatus != null ? filterStatus : "ALL");
        req.setAttribute("currentPageNum", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalOrders", totalOrders);
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
            String cancelReason = req.getParameter("cancelReason");
            String prepStr = req.getParameter("prepMinutes");
            Integer prepMinutes = null;
            if (prepStr != null && !prepStr.isBlank()) {
                try {
                    prepMinutes = Integer.parseInt(prepStr);
                } catch (NumberFormatException ignored) {
                }
            }

            String newStatus = switch (action) {
                case "accept" ->
                    "MERCHANT_ACCEPTED";
                case "ready" ->
                    "READY_FOR_PICKUP";
                case "cancel" ->
                    "CANCELLED";
                case "reject" ->
                    "MERCHANT_REJECTED";
                default ->
                    null;
            };

            if (newStatus != null) {
                String sql;
                boolean hasReason = cancelReason != null && !cancelReason.isBlank();
                if (newStatus.equals("READY_FOR_PICKUP")) {
                    sql = "UPDATE Orders SET order_status=?, ready_at=GETDATE() WHERE id=?";
                } else if (newStatus.equals("MERCHANT_ACCEPTED") && prepMinutes != null) {
                    sql = "UPDATE Orders SET order_status=?, accepted_at=GETDATE(), estimated_prep_minutes=? WHERE id=?";
                } else if ((newStatus.equals("CANCELLED") || newStatus.equals("MERCHANT_REJECTED")) && hasReason) {
                    sql = "UPDATE Orders SET order_status=?, cancelled_at=GETDATE(), cancel_reason=? WHERE id=?";
                } else if (newStatus.equals("MERCHANT_ACCEPTED")) {
                    sql = "UPDATE Orders SET order_status=?, accepted_at=GETDATE() WHERE id=?";
                } else if (newStatus.equals("MERCHANT_REJECTED") || newStatus.equals("CANCELLED")) {
                    sql = "UPDATE Orders SET order_status=?, cancelled_at=GETDATE() WHERE id=?";
                } else {
                    sql = "UPDATE Orders SET order_status=? WHERE id=?";
                }
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    if (newStatus.equals("MERCHANT_ACCEPTED") && prepMinutes != null) {
                        ps.setInt(2, prepMinutes);
                        ps.setInt(3, orderId);
                    } else if ((newStatus.equals("CANCELLED") || newStatus.equals("MERCHANT_REJECTED")) && hasReason) {
                        ps.setString(2, cancelReason);
                        ps.setInt(3, orderId);
                    } else {
                        ps.setInt(2, orderId);
                    }
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        String referer = req.getHeader("Referer");
        resp.sendRedirect(referer != null ? referer : req.getContextPath() + "/merchant/orders");
    }

    // ─── JSON: return order items for detail modal ─────────────────────
    private void handleDetailJson(HttpServletRequest req, HttpServletResponse resp, int merchantId)
            throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendError(400);
            return;
        }
        int orderId;
        try {
            orderId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendError(400);
            return;
        }

        String sql = "SELECT oi.item_name_snapshot, oi.quantity, oi.unit_price_snapshot, oi.note "
                + "FROM OrderItems oi "
                + "JOIN Orders o ON o.id = oi.order_id "
                + "WHERE oi.order_id = ? AND o.merchant_user_id = ?";

        StringBuilder sb = new StringBuilder("[");
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, merchantId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    sb.append(",");
                }
                first = false;
                String name = rs.getString("item_name_snapshot");
                if (name == null) {
                    name = "Món ăn";
                }
                double price = rs.getDouble("unit_price_snapshot");
                int qty = rs.getInt("quantity");
                String notes = rs.getString(
                        "note");
                sb.append("{\"name\":\"").append(escape(name)).append("\"")
                        .append(",\"qty\":").append(qty)
                        .append(",\"price\":").append(price);
                if (notes != null && !notes.isBlank()) {
                    sb.append(",\"notes\":\"").append(escape(notes)).append("\"");
                }
                sb.append("}");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        sb.append("]");
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(sb.toString());
    }

    private static String escape(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
