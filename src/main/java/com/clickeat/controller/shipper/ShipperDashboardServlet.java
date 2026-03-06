package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.ShipperDAO;
import com.clickeat.dal.impl.ShipperWalletDAO;
import com.clickeat.model.Order;
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

        
       
        ShipperWalletDAO walletDAO = new ShipperWalletDAO();
        ShipperWallet wallet = walletDAO.getWalletByShipperId(account.getId());
        double currentBalance = (wallet != null) ? wallet.getBalance() : 0;

        OrderDAO orderDAO = new OrderDAO();
        double todayIncome = orderDAO.getIncomeToday(account.getId());
        double weekIncome = orderDAO.getIncomeThisWeek(account.getId());

        request.setAttribute("currentBalance", currentBalance); 
        request.setAttribute("todayIncome", todayIncome);
        request.setAttribute("weekIncome", weekIncome);
        
        
        ShipperDAO shipperDAO = new ShipperDAO();
        boolean isOnline = shipperDAO.checkIsOnline(account.getId());
        request.setAttribute("isOnline", isOnline);
        Order currentOrder = orderDAO.getCurrentOrderForShipper(account.getId());
        request.setAttribute("currentOrder", currentOrder);
        List<Order> availableOrders = orderDAO.getAvailableOrdersForShipper();
        request.setAttribute("availableOrders", availableOrders);
        MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
        request.setAttribute("merchantDAO", merchantDAO);

        request.setAttribute("activeTab", "overview");
        request.getRequestDispatcher("/views/shipper/dashboard.jsp").forward(request, response);
    }
}