package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.*;
import com.clickeat.model.*;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ShipperDashboardServlet", urlPatterns = {"/shipper/dashboard"})
public class ShipperDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1. Dữ liệu Tổng quan & Biểu đồ
        ShipperWalletDAO walletDAO = new ShipperWalletDAO();
        ShipperWallet wallet = walletDAO.getWalletByShipperId(account.getId());
        request.setAttribute("currentBalance", (wallet != null) ? wallet.getBalance() : 0);

        OrderDAO orderDAO = new OrderDAO();
        request.setAttribute("todayIncome", orderDAO.getIncomeToday(account.getId()));
        request.setAttribute("weekIncome", orderDAO.getIncomeThisWeek(account.getId()));
        request.setAttribute("todayOrders", orderDAO.countDeliveredOrdersToday(account.getId()));

        java.util.Map<String, Double> chartData = orderDAO.getLast7DaysIncome(account.getId());
        request.setAttribute("chartLabels", "'" + String.join("','", chartData.keySet()) + "'");
        request.setAttribute("chartValues", chartData.values().toString().replaceAll("[\\[\\]]", ""));

        // 2. Trạng thái Online
        ShipperDAO shipperDAO = new ShipperDAO();
        request.setAttribute("isOnline", shipperDAO.checkIsOnline(account.getId()));

        // 3. Quản lý Đơn hàng
        request.setAttribute("currentOrders", orderDAO.getCurrentOrdersForShipper(account.getId()));
        request.setAttribute("availableOrders", orderDAO.getAvailableOrdersForShipper());
        request.setAttribute("merchantDAO", new MerchantProfileDAO());

        // 4. Sự cố
        OrderIssueDAO issueDAO = new OrderIssueDAO();
        request.setAttribute("reportedIssues", issueDAO.getIssuesByShipperId(account.getId()));

        // 5. Lịch sử đơn hàng
        request.setAttribute("historyOrders", orderDAO.getHistoryOrdersForShipper(account.getId()));

        // 6. Đánh giá (Rating)
        ShipperReviewDAO reviewDAO = new ShipperReviewDAO();
        request.setAttribute("avgRating", reviewDAO.getAverageRating(account.getId()));
        request.setAttribute("totalReviews", reviewDAO.getTotalReviews(account.getId()));

        // Chuyển hướng Tab (Dựa vào URL param)
        String tab = request.getParameter("tab");
        request.setAttribute("activeTab", (tab != null) ? tab : "overview");

        request.getRequestDispatcher("/views/shipper/dashboard.jsp").forward(request, response);
    }
}
