package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "OrderSuccessServlet", urlPatterns = {"/order-success"})
public class OrderSuccessServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderItemDAO orderItemDAO = new OrderItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String orderCode = request.getParameter("code");
        if (orderCode == null || orderCode.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1. Lấy thông tin Order từ Code
        Order order = orderDAO.findByCode(orderCode);
        
        // Bảo mật: Chỉ cho phép người đặt xem đơn hàng của mình
        if (order == null || order.getCustomerUserId() != account.getId()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 2. Lấy danh sách item của đơn hàng
        List<OrderItem> items = orderItemDAO.getItemsByOrderId(order.getId());

        // 3. Gửi sang JSP
        request.setAttribute("order", order);
        request.setAttribute("items", items);
        
        request.getRequestDispatcher("/views/web/order-success.jsp").forward(request, response);
    }
}
