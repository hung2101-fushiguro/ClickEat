package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.ShipperDAO;
import com.clickeat.model.Order;
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

        // 1. Dữ liệu tổng quan (Tạm thời Mockup)
        request.setAttribute("currentBalance", 1500000); 
        request.setAttribute("todayIncome", 350000);
        request.setAttribute("weekIncome", 2100000);
        
        // 2. Kiểm tra trạng thái Online hiện tại của Shipper
        ShipperDAO shipperDAO = new ShipperDAO();
        boolean isOnline = shipperDAO.checkIsOnline(account.getId());
        request.setAttribute("isOnline", isOnline);

        // 3. LẤY DANH SÁCH ĐƠN HÀNG TỪ DATABASE VÀ TRUYỀN SANG JSP
        OrderDAO orderDAO = new OrderDAO();
        Order currentOrder = orderDAO.getCurrentOrderForShipper(account.getId());
        request.setAttribute("currentOrder", currentOrder);
        List<Order> availableOrders = orderDAO.getAvailableOrdersForShipper();
        request.setAttribute("availableOrders", availableOrders);
        // 4. Truyền MerchantDAO sang để JSP lấy được tên Quán ăn
        MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
        request.setAttribute("merchantDAO", merchantDAO);

        request.setAttribute("activeTab", "overview");
        request.getRequestDispatcher("/views/shipper/dashboard.jsp").forward(request, response);
    }
}