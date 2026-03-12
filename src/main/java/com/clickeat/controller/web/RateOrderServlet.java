package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RateOrderServlet", urlPatterns = {"/rate-order"})
public class RateOrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            int stars = Integer.parseInt(request.getParameter("stars"));
            String comment = request.getParameter("comment");
            if (comment == null) {
                comment = "";
            }

            if (stars < 1 || stars > 5) {
                request.getSession().setAttribute("toastError", "Số sao không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/track-order?id=" + orderId);
                return;
            }

            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderByIdAndCustomer(orderId, account.getId());

            if (order == null || !"DELIVERED".equals(order.getOrderStatus())) {
                request.getSession().setAttribute("toastError", "Đơn hàng không hợp lệ để đánh giá.");
                response.sendRedirect(request.getContextPath() + "/my-orders");
                return;
            }

            RatingDAO ratingDAO = new RatingDAO();
            if (ratingDAO.hasRatedOrder(orderId, account.getId(), "MERCHANT")) {
                request.getSession().setAttribute("toastError", "Bạn đã đánh giá đơn hàng này rồi.");
            } else {
                boolean ok = ratingDAO.submitRating(orderId, (long) account.getId(),
                        (long) order.getMerchantId(), "MERCHANT", stars, comment.trim());
                if (ok) {
                    request.getSession().setAttribute("toastMsg", "Cảm ơn bạn đã đánh giá!");
                } else {
                    request.getSession().setAttribute("toastError", "Có lỗi xảy ra, vui lòng thử lại.");
                }
            }
            response.sendRedirect(request.getContextPath() + "/track-order?id=" + orderId);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
        }
    }
}
