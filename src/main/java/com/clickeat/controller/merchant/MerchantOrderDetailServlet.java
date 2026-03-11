package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/merchant/orders/detail")
public class MerchantOrderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Object merchantIdAttr = req.getSession().getAttribute("merchantId");
        if (merchantIdAttr == null) {
            resp.sendRedirect(req.getContextPath() + "/merchant/login");
            return;
        }
        int merchantId = ((Number) merchantIdAttr).intValue();

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/merchant/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/merchant/orders");
            return;
        }

        Order order = null;
        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = DBContext.getConnection()) {
            // Load order and verify merchant ownership
            String sqlOrder = "SELECT * FROM Orders WHERE id = ? AND merchant_user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                ps.setInt(1, orderId);
                ps.setInt(2, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setOrderCode(rs.getString("order_code"));
                    order.setCustomerUserId(rs.getInt("customer_user_id"));
                    order.setShipperUserId(rs.getInt("shipper_user_id"));
                    order.setReceiverName(rs.getString("receiver_name"));
                    order.setReceiverPhone(rs.getString("receiver_phone"));
                    order.setDeliveryAddressLine(rs.getString("delivery_address_line"));
                    order.setDeliveryNote(rs.getString("delivery_note"));
                    order.setOrderStatus(rs.getString("order_status"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setSubtotalAmount(rs.getDouble("subtotal_amount"));
                    order.setDeliveryFee(rs.getDouble("delivery_fee"));
                    order.setDiscountAmount(rs.getDouble("discount_amount"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setCreatedAt(rs.getTimestamp("created_at"));
                    order.setAcceptedAt(rs.getTimestamp("accepted_at"));
                    order.setReadyAt(rs.getTimestamp("ready_at"));
                    order.setPickedUpAt(rs.getTimestamp("picked_up_at"));
                    order.setDeliveredAt(rs.getTimestamp("delivered_at"));
                    order.setCancelledAt(rs.getTimestamp("cancelled_at"));
                }
            }

            if (order == null) {
                resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                return;
            }

            // Load order items
            String sqlItems = "SELECT * FROM OrderItems WHERE order_id = ? ORDER BY id";
            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                ps.setInt(1, orderId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setId(rs.getInt("id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setItemNameSnapshot(rs.getString("item_name_snapshot"));
                    item.setUnitPriceSnapshot(rs.getDouble("unit_price_snapshot"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setNote(rs.getString("note"));
                    items.add(item);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("order", order);
        req.setAttribute("items", items);
        req.getRequestDispatcher("/views/merchant/order-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        Object merchantIdAttr = req.getSession().getAttribute("merchantId");
        if (merchantIdAttr == null) {
            resp.sendRedirect(req.getContextPath() + "/merchant/login");
            return;
        }
        int merchantId = ((Number) merchantIdAttr).intValue();

        String idStr = req.getParameter("orderId");
        String action = req.getParameter("action");

        if (idStr != null && action != null) {
            int orderId;
            try {
                orderId = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/merchant/orders");
                return;
            }

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
                if ("READY_FOR_PICKUP".equals(newStatus)) {
                    sql = "UPDATE Orders SET order_status=?, ready_at=GETDATE() WHERE id=? AND merchant_user_id=?";
                } else if ("MERCHANT_ACCEPTED".equals(newStatus) && prepMinutes != null) {
                    sql = "UPDATE Orders SET order_status=?, accepted_at=GETDATE(), estimated_prep_minutes=? WHERE id=? AND merchant_user_id=?";
                } else if (("CANCELLED".equals(newStatus) || "MERCHANT_REJECTED".equals(newStatus)) && cancelReason != null && !cancelReason.isBlank()) {
                    sql = "UPDATE Orders SET order_status=?, cancelled_at=GETDATE(), cancel_reason=? WHERE id=? AND merchant_user_id=?";
                } else if ("MERCHANT_ACCEPTED".equals(newStatus)) {
                    sql = "UPDATE Orders SET order_status=?, accepted_at=GETDATE() WHERE id=? AND merchant_user_id=?";
                } else if ("CANCELLED".equals(newStatus) || "MERCHANT_REJECTED".equals(newStatus)) {
                    sql = "UPDATE Orders SET order_status=?, cancelled_at=GETDATE() WHERE id=? AND merchant_user_id=?";
                } else {
                    sql = "UPDATE Orders SET order_status=? WHERE id=? AND merchant_user_id=?";
                }
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    if (("MERCHANT_ACCEPTED".equals(newStatus) && prepMinutes != null)
                            || (("CANCELLED".equals(newStatus) || "MERCHANT_REJECTED".equals(newStatus)) && cancelReason != null && !cancelReason.isBlank())) {
                        if ("MERCHANT_ACCEPTED".equals(newStatus)) {
                            ps.setInt(2, prepMinutes);
                        } else {
                            ps.setString(2, cancelReason);
                        }
                        ps.setInt(3, orderId);
                        ps.setInt(4, merchantId);
                    } else {
                        ps.setInt(2, orderId);
                        ps.setInt(3, merchantId);
                    }
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            resp.sendRedirect(req.getContextPath() + "/merchant/orders/detail?id=" + idStr);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/orders");
    }
}
