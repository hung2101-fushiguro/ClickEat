package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CustomerOrderTrackingServlet", urlPatterns = {"/customer/order-tracking"})
public class CustomerOrderTrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equalsIgnoreCase(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("orderId");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.findById(orderId);

        if (order == null || order.getCustomerUserId() != account.getId()) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
            return;
        }

        request.setAttribute("order", order);
        request.getRequestDispatcher("/views/web/order-tracking.jsp").forward(request, response);
    }
}