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

@WebServlet(name = "ShipperOrderDetailServlet", urlPatterns = {"/shipper/order-detail"})
public class ShipperOrderDetailServlet extends HttpServlet {

    // Hiển thị chi tiết đơn hàng
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

        // Chỉ cho phép xem nếu đơn hàng tồn tại
        if (order != null) {
            MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
            MerchantProfile merchant = merchantDAO.findById(order.getMerchantId());

            request.setAttribute("order", order);
            request.setAttribute("merchant", merchant);
            request.getRequestDispatcher("/views/shipper/order-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String action = request.getParameter("action"); // Lấy biến action từ form

        OrderDAO orderDAO = new OrderDAO();

        // 1. XỬ LÝ NHƯỜNG ĐƠN (Hủy nhận)
        if ("yield".equals(action)) {
            boolean success = orderDAO.yieldOrder(orderId, account.getId());

            if (success) {
                request.getSession().setAttribute("toastMsg", "Đã nhường đơn thành công cho tài xế khác!");
            } else {
                request.getSession().setAttribute("toastError", "Không thể nhường đơn lúc này.");
            }
        } // 2. XỬ LÝ NHẬN ĐƠN (Mặc định)
        else {
            boolean success = orderDAO.claimOrder(orderId, account.getId());

            if (success) {
                request.getSession().setAttribute("toastMsg", "Nhận đơn thành công! Hãy di chuyển đến quán.");
            } else {
                request.getSession().setAttribute("toastError", "Đơn hàng đã bị người khác nhận hoặc không tồn tại.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/shipper/dashboard?tab=orders");
    }
}
