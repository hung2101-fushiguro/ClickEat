/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "MerchantDashboardServlet", urlPatterns = {"/merchant/dashboard"})
public class MerchantDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Map<String, Object> summary = orderDAO.getDashboardSummary(account.getId());

        request.setAttribute("todayRevenue", summary.getOrDefault("revenueToday", 0d));
        request.setAttribute("yesterdayRevenue", summary.getOrDefault("revenueYesterday", 0d));
        request.setAttribute("revenue7d", summary.getOrDefault("revenue7d", 0d));
        request.setAttribute("todayOrders", summary.getOrDefault("ordersToday", 0));
        request.setAttribute("canceledToday", summary.getOrDefault("canceledToday", 0));
        request.setAttribute("cancelRate", summary.getOrDefault("cancelRate", 0d));
        request.setAttribute("voucherUsed7d", summary.getOrDefault("voucherUsed7d", 0));
        request.setAttribute("voucherNotUsed7d", summary.getOrDefault("voucherNotUsed7d", 0));
        request.setAttribute("topFoods", orderDAO.getTopSellingFoods(account.getId(), 5));
        request.setAttribute("hourlyOrders", orderDAO.getOrderCountByHourToday(account.getId()));

        request.setAttribute("currentPage", "dashboard");

        request.getRequestDispatcher("/views/merchant/dashboard.jsp").forward(request, response);
    }
}
