package com.clickeat.controller.web;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "OrderTrackingServlet", urlPatterns = {"/guest-order-tracking"})
public class OrderTrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String orderCode = request.getParameter("code");
        
        if (orderCode != null && !orderCode.trim().isEmpty()) {
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderByCode(orderCode.trim());
            
            if (order != null) {
                // Fetch order items to display
                OrderItemDAO orderItemDAO = new OrderItemDAO();
                List<OrderItem> orderItems = orderItemDAO.getItemsByOrderId(order.getId());
                
                request.setAttribute("order", order);
                request.setAttribute("orderItems", orderItems);
                request.setAttribute("searched", true);
            } else {
                request.setAttribute("error", "Không tìm thấy đơn hàng với mã này. Ký tự phân biệt chữ hoa/thường.");
                request.setAttribute("searched", true);
            }
            request.setAttribute("code", orderCode.trim());
        }
        
        request.getRequestDispatcher("/views/web/guest-order-tracking.jsp").forward(request, response);
    }
}
