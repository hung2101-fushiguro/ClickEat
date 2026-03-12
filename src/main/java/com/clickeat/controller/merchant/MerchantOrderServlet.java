package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "MerchantOrderServlet", urlPatterns = {"/merchant/orders"})
public class MerchantOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) {
            tab = "pending";
        }

        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getOrdersByMerchantAndStatus(account.getId(), tab);

        request.setAttribute("orders", orders);
        request.setAttribute("currentTab", tab);
        request.setAttribute("currentPage", "orders");

        request.getRequestDispatcher("/views/merchant/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        long orderId = Long.parseLong(request.getParameter("orderId"));
        String currentTab = request.getParameter("tab"); // Để redirect về đúng tab cũ

        OrderDAO orderDAO = new OrderDAO();

        try {
            if ("accept".equals(action)) {

                orderDAO.updateOrderStatus(orderId, account.getId(), "PREPARING");
            } else if ("ready".equals(action)) {

                orderDAO.updateOrderStatus(orderId, account.getId(), "READY_FOR_PICKUP");
            } else if ("cancel".equals(action)) {

                orderDAO.updateOrderStatus(orderId, account.getId(), "MERCHANT_REJECTED");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (currentTab == null) {
            currentTab = "pending";
        }
        response.sendRedirect(request.getContextPath() + "/merchant/orders?tab=" + currentTab);
    }
}
