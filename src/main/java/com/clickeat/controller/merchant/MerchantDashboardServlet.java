/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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

        Map<String, Object> summary = Collections.emptyMap();
        Map<Integer, Integer> hourlyOrders = new LinkedHashMap<>();
        for (int hour = 0; hour <= 23; hour++) {
            hourlyOrders.put(hour, 0);
        }

        MerchantProfile merchantProfile = null;
        OrderDAO orderDAO = new OrderDAO();
        try {
            summary = orderDAO.getDashboardSummary(account.getId());
            hourlyOrders = orderDAO.getOrderCountByHourToday(account.getId());
            request.setAttribute("topFoods", orderDAO.getTopSellingFoods(account.getId(), 5));
            merchantProfile = new MerchantProfileDAO().findById(account.getId());
        } catch (Exception ex) {
            request.setAttribute("topFoods", Collections.emptyList());
        }

        request.setAttribute("todayRevenue", summary.getOrDefault("revenueToday", 0d));
        request.setAttribute("yesterdayRevenue", summary.getOrDefault("revenueYesterday", 0d));
        request.setAttribute("revenue7d", summary.getOrDefault("revenue7d", 0d));
        request.setAttribute("todayOrders", summary.getOrDefault("ordersToday", 0));
        request.setAttribute("canceledToday", summary.getOrDefault("canceledToday", 0));
        request.setAttribute("cancelRate", summary.getOrDefault("cancelRate", 0d));
        request.setAttribute("voucherUsed7d", summary.getOrDefault("voucherUsed7d", 0));
        request.setAttribute("voucherNotUsed7d", summary.getOrDefault("voucherNotUsed7d", 0));
        request.setAttribute("hourlyOrders", hourlyOrders);

        if (merchantProfile != null) {
            request.setAttribute("merchantStatus", merchantProfile.getStatus());
            request.setAttribute("merchantRejectionReason", merchantProfile.getRejectionReason());
            request.setAttribute("merchantIsOpen", merchantProfile.getIsOpen() == null || merchantProfile.getIsOpen());
        }

        request.setAttribute("currentPage", "dashboard");

        request.getRequestDispatcher("/views/merchant/dashboard.jsp").forward(request, response);
    }
}
