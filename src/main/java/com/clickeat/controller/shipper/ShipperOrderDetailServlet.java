/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperOrderDetailServlet", urlPatterns = {"/shipper/order-detail"})
public class ShipperOrderDetailServlet extends HttpServlet {

    // HIỂN THỊ TRANG CHI TIẾT
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int orderId = Integer.parseInt(request.getParameter("id"));
        
        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.findById(orderId);

        if (order != null) {
            // Lấy thông tin Quán
            MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
            MerchantProfile merchant = merchantDAO.findById(order.getMerchantId());
            
            // Lấy danh sách Món ăn
            OrderItemDAO orderItemDAO = new OrderItemDAO();
            List<OrderItem> items = orderItemDAO.getItemsByOrderId(orderId);

            request.setAttribute("order", order);
            request.setAttribute("merchant", merchant);
            request.setAttribute("items", items);
        }

        request.getRequestDispatcher("/views/shipper/order-detail.jsp").forward(request, response);
    }

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User account = (User) request.getSession().getAttribute("account");
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        
        OrderDAO orderDAO = new OrderDAO();
        boolean isSuccess = orderDAO.claimOrder(orderId, account.getId());
        
        if (isSuccess) {
            request.getSession().setAttribute("toastMsg", "Nhận đơn thành công! Hãy di chuyển đến quán.");
        } else {
            request.getSession().setAttribute("toastError", "Rất tiếc, đơn hàng đã bị tài xế khác nhận mất!");
        }
        
        // Nhận xong quay về Dashboard (Bài sau ta sẽ làm trang "Đơn đang giao")
        response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
    }
}
