package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderIssueDAO;
import com.clickeat.dal.impl.ShipperDAO;
import com.clickeat.dal.impl.ShipperWalletDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderIssue;
import com.clickeat.model.ShipperWallet;
import com.clickeat.model.User;
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

        // 1. Lấy thông tin Ví tiền & Doanh thu
        ShipperWalletDAO walletDAO = new ShipperWalletDAO();
        ShipperWallet wallet = walletDAO.getWalletByShipperId(account.getId());
        double currentBalance = (wallet != null) ? wallet.getBalance() : 0;

        OrderDAO orderDAO = new OrderDAO();
        double todayIncome = orderDAO.getIncomeToday(account.getId());
        double weekIncome = orderDAO.getIncomeThisWeek(account.getId());
        int todayOrders = orderDAO.countDeliveredOrdersToday(account.getId()); // Thêm số đơn

        request.setAttribute("currentBalance", currentBalance);
        request.setAttribute("todayIncome", todayIncome);
        request.setAttribute("weekIncome", weekIncome);
        request.setAttribute("todayOrders", todayOrders); // Gửi số đơn sang JSP

        // Dữ liệu Biểu đồ (Tách thành 2 chuỗi String để nạp vào Javascript)
        java.util.Map<String, Double> chartData = orderDAO.getLast7DaysIncome(account.getId());
        String chartLabels = "'" + String.join("','", chartData.keySet()) + "'";
        String chartValues = chartData.values().toString().replaceAll("[\\[\\]]", "");

        request.setAttribute("chartLabels", chartLabels);
        request.setAttribute("chartValues", chartValues);

        // 2. Trạng thái Online
        ShipperDAO shipperDAO = new ShipperDAO();
        boolean isOnline = shipperDAO.checkIsOnline(account.getId());
        request.setAttribute("isOnline", isOnline);

        //3.
        List<Order> currentOrders = orderDAO.getCurrentOrdersForShipper(account.getId());
        request.setAttribute("currentOrders", currentOrders);

        // Đơn hàng đang chờ
        List<Order> availableOrders = orderDAO.getAvailableOrdersForShipper();
        request.setAttribute("availableOrders", availableOrders);

        MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
        request.setAttribute("merchantDAO", merchantDAO);

        // 4. LẤY DANH SÁCH SỰ CỐ ĐÃ BÁO CÁO
        OrderIssueDAO issueDAO = new OrderIssueDAO();
        List<OrderIssue> reportedIssues = issueDAO.getIssuesByShipperId(account.getId());
        request.setAttribute("reportedIssues", reportedIssues);

        // 5. Chuyển hướng
        String tab = request.getParameter("tab");
        request.setAttribute("activeTab", (tab != null) ? tab : "overview");

        request.getRequestDispatcher("/views/shipper/dashboard.jsp").forward(request, response);
    }
}
