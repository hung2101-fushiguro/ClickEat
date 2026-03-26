package com.clickeat.controller.web;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "PaymentSuccessServlet", urlPatterns = {"/payment-success"})
public class PaymentSuccessServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderIdRaw = request.getParameter("orderId");
        if (orderIdRaw == null || orderIdRaw.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdRaw);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        OrderItemDAO orderItemDAO = new OrderItemDAO();

        Order order = orderDAO.findById(orderId);
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Authorization: only the owner (logged-in customer or verified guest) may view this page
        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;
        String guestId = null;
        if (session != null) {
            guestId = (String) session.getAttribute("guest_id");
            if (guestId == null || guestId.isBlank()) {
                guestId = (String) session.getAttribute("guestId");
            }
            if (guestId != null && !guestId.isBlank()) {
                session.setAttribute("guest_id", guestId);
                session.setAttribute("guestId", guestId);
            }
        }
        Boolean guestVerified = session != null ? (Boolean) session.getAttribute("guest_verified") : null;

        boolean isOwner = false;
        if (account != null && order.getCustomerUserId() == account.getId()) {
            isOwner = true;
        } else if (Boolean.TRUE.equals(guestVerified) && guestId != null && guestId.equals(order.getGuestId())) {
            isOwner = true;
        }

        if (!isOwner) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<OrderItem> orderItems = orderItemDAO.getItemsByOrderId(orderId);

        request.setAttribute("order", order);
        request.setAttribute("orderItems", orderItems);
        request.getRequestDispatcher("/views/web/payment-success.jsp").forward(request, response);
    }
}
