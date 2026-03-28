package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.List;
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
        UserDAO userDAO = new UserDAO();

        Order order = orderDAO.findById(orderId);
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        HttpSession session = request.getSession(true);

// Nếu là đơn guest thì tiếp tục ghi nhớ đơn gần nhất trong session
if (order.getGuestId() != null && !order.getGuestId().isBlank()) {
    session.setAttribute("guestLastOrderId", order.getId());
    session.setAttribute("guestLastOrderCode", order.getOrderCode());
    session.setAttribute("guestHasTrackableOrder", true);
}

if (order.getCustomerUserId() > 0) {
    User account = (User) session.getAttribute("account");

    if (account == null || account.getId() != order.getCustomerUserId()) {
        User customer = userDAO.findById(order.getCustomerUserId());
        if (customer != null && "ACTIVE".equalsIgnoreCase(customer.getStatus())) {
            session.setAttribute("account", customer);
            session.setMaxInactiveInterval(60 * 60 * 24);
        }
    }
}

        List<OrderItem> orderItems = orderItemDAO.getItemsByOrderId(orderId);

        request.setAttribute("order", order);
        request.setAttribute("orderItems", orderItems);
        request.getRequestDispatcher("/views/web/payment-success.jsp").forward(request, response);
    }
}