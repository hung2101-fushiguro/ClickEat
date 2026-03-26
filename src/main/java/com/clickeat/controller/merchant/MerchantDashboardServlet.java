/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
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

        MerchantProfile profile = new MerchantProfileDAO().findById(account.getId());
        if (profile != null) {
            request.getSession().setAttribute("merchantShopName", profile.getShopName());
            request.getSession().setAttribute("merchantIsOpen", profile.getIsOpen() == null ? Boolean.TRUE : profile.getIsOpen());
        }

        OrderDAO orderDAO = new OrderDAO();
        String fromDateRaw = request.getParameter("fromDate");
        String toDateRaw = request.getParameter("toDate");

        LocalDate fromDate = parseDate(fromDateRaw);
        LocalDate toDate = parseDate(toDateRaw);

        boolean hasAnyRangeInput = (fromDateRaw != null && !fromDateRaw.isBlank()) || (toDateRaw != null && !toDateRaw.isBlank());
        boolean hasValidRange = fromDate != null && toDate != null && !fromDate.isAfter(toDate);

        if (hasAnyRangeInput && !hasValidRange) {
            request.setAttribute("dashboardError", "Khoảng ngày không hợp lệ. Vui lòng chọn đúng định dạng và Từ ngày không lớn hơn Đến ngày.");
        }

        Map<String, Object> summary = hasValidRange
                ? orderDAO.getDashboardSummaryByDateRange(account.getId(), fromDate, toDate)
                : orderDAO.getDashboardSummary(account.getId());

        request.setAttribute("todayRevenue", summary.getOrDefault("revenueToday", 0d));
        request.setAttribute("yesterdayRevenue", summary.getOrDefault("revenueYesterday", 0d));
        request.setAttribute("revenue7d", summary.getOrDefault("revenue7d", 0d));
        request.setAttribute("todayOrders", summary.getOrDefault("ordersToday", 0));
        request.setAttribute("canceledToday", summary.getOrDefault("canceledToday", 0));
        request.setAttribute("cancelRate", summary.getOrDefault("cancelRate", 0d));
        request.setAttribute("voucherUsed7d", summary.getOrDefault("voucherUsed7d", 0));
        request.setAttribute("voucherNotUsed7d", summary.getOrDefault("voucherNotUsed7d", 0));
        request.setAttribute("topFoods", hasValidRange
                ? orderDAO.getTopSellingFoodsInRange(account.getId(), 5, fromDate, toDate)
                : orderDAO.getTopSellingFoods(account.getId(), 5));
        request.setAttribute("hourlyOrders", hasValidRange
                ? orderDAO.getOrderCountByHourInRange(account.getId(), fromDate, toDate)
                : orderDAO.getOrderCountByHourToday(account.getId()));
        request.setAttribute("fromDate", fromDateRaw == null ? "" : fromDateRaw);
        request.setAttribute("toDate", toDateRaw == null ? "" : toDateRaw);
        request.setAttribute("isRangeMode", hasValidRange);

        request.setAttribute("currentPage", "dashboard");

        request.getRequestDispatcher("/views/merchant/dashboard.jsp").forward(request, response);
    }

    private LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException ignored) {
            return null;
        }
    }
}
