/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperOrderTrackingServlet", urlPatterns = {"/shipper/order-tracking"})
public class ShipperOrderTrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
            return;
        }

        int orderId = Integer.parseInt(idParam);
        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.findById(orderId);

        if (order != null && order.getShipperUserId() == account.getId()) {
            MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
            MerchantProfile merchant = merchantDAO.findById(order.getMerchantId());
            
            request.setAttribute("order", order);
            request.setAttribute("merchant", merchant);
            request.getRequestDispatcher("/views/shipper/order-tracking.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String action = request.getParameter("action"); 

        OrderDAO orderDAO = new OrderDAO();
        boolean success = false;

        if ("picked_up".equals(action)) {
            success = orderDAO.updateOrderStatus(orderId, "PICKED_UP");
            if (success) {
                request.getSession().setAttribute("toastMsg", "Đã xác nhận lấy hàng! Vui lòng giao đến khách.");
            }
        } else if ("delivered".equals(action)) {
            
            success = orderDAO.updateOrderStatus(orderId, "DELIVERED");
            if (success) {
                request.getSession().setAttribute("toastMsg", "Giao hàng thành công! Đã hoàn thành đơn.");
                // (Sau này chúng ta có thể gọi hàm cộng tiền vào ShipperWallets ở đây)
            }
        }

        // Điều hướng sau khi cập nhật
        if ("delivered".equals(action) && success) {
            // Nếu giao xong rồi -> Đá về trang chủ Dashboard để săn đơn mới
            response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
        } else {
            // Nếu mới lấy hàng -> Load lại trang Tracking để đổi giao diện sang bước tiếp theo
            response.sendRedirect(request.getContextPath() + "/shipper/order-tracking?id=" + orderId);
        }
    }
}
