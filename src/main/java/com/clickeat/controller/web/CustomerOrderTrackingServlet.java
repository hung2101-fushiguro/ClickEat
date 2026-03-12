package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerOrderTrackingServlet", urlPatterns = {"/track-order"})
public class CustomerOrderTrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(idParam);
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderByIdAndCustomer(orderId, account.getId());

            if (order == null) {
                request.getSession().setAttribute("toastError", "Không tìm thấy đơn hàng.");
                response.sendRedirect(request.getContextPath() + "/my-orders");
                return;
            }

            OrderItemDAO orderItemDAO = new OrderItemDAO();
            List<OrderItem> items = orderItemDAO.getItemsByOrderId(orderId);

            RatingDAO ratingDAO = new RatingDAO();
            boolean hasRatedMerchant = ratingDAO.hasRatedOrder(orderId, account.getId(), "MERCHANT");

            request.setAttribute("order", order);
            request.setAttribute("items", items);
            request.setAttribute("hasRatedMerchant", hasRatedMerchant);
            request.setAttribute("cartCount", 0);
            request.getRequestDispatcher("/views/web/track-order.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
        }
    }
}
