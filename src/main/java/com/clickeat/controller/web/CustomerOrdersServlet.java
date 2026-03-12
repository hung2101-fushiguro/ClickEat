package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "CustomerOrdersServlet", urlPatterns = {"/my-orders"})
public class CustomerOrdersServlet extends HttpServlet {

    private static final List<String> TERMINAL_STATUSES
            = Arrays.asList("DELIVERED", "CANCELLED", "MERCHANT_REJECTED", "FAILED");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null) {
            statusFilter = "all";
        }

        OrderDAO orderDAO = new OrderDAO();
        List<Order> allOrders = orderDAO.getCustomerOrders(account.getId());

        List<Order> filteredOrders;
        switch (statusFilter) {
            case "active":
                filteredOrders = allOrders.stream()
                        .filter(o -> !TERMINAL_STATUSES.contains(o.getOrderStatus()))
                        .collect(Collectors.toList());
                break;
            case "DELIVERED":
                filteredOrders = allOrders.stream()
                        .filter(o -> "DELIVERED".equals(o.getOrderStatus()))
                        .collect(Collectors.toList());
                break;
            case "cancelled":
                filteredOrders = allOrders.stream()
                        .filter(o -> Arrays.asList("CANCELLED", "MERCHANT_REJECTED", "FAILED").contains(o.getOrderStatus()))
                        .collect(Collectors.toList());
                break;
            default:
                filteredOrders = allOrders;
        }

        request.setAttribute("orders", filteredOrders);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("cartCount", 0);
        request.getRequestDispatcher("/views/web/my-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("CANCEL".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                OrderDAO orderDAO = new OrderDAO();
                Order order = orderDAO.getOrderByIdAndCustomer(orderId, account.getId());
                if (order != null && "CREATED".equals(order.getOrderStatus())) {
                    orderDAO.updateOrderStatus(orderId, "CANCELLED");
                    request.getSession().setAttribute("toastMsg", "Đã hủy đơn hàng thành công.");
                } else {
                    request.getSession().setAttribute("toastError", "Không thể hủy đơn hàng ở trạng thái này.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("toastError", "Đơn hàng không hợp lệ.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/my-orders");
    }
}
