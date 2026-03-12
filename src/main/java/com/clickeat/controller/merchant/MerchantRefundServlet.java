package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO; // Dùng OrderItemDAO thay vì OrderDetailDAO
import com.clickeat.dal.impl.RefundDAO;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem; // Import đúng chuẩn của bạn
import com.clickeat.model.RefundRequest;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "MerchantRefundServlet", urlPatterns = {"/merchant/refund"})
public class MerchantRefundServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long orderId = Long.parseLong(request.getParameter("id"));
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.findById((int) orderId);

            // ĐÃ SỬA: Gọi OrderItemDAO theo đúng model của bạn
            OrderItemDAO itemDAO = new OrderItemDAO();
            List<OrderItem> items = itemDAO.getItemsByOrderId((int) orderId);

            request.setAttribute("order", order);
            request.setAttribute("items", items);
            request.setAttribute("currentPage", "orders");

            request.getRequestDispatcher("/views/merchant/refund.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/merchant/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            return;
        }

        try {
            long orderId = Long.parseLong(request.getParameter("orderId"));
            double amount = Double.parseDouble(request.getParameter("totalRefund"));
            String reason = request.getParameter("reason");

            RefundRequest r = new RefundRequest();
            r.setOrderId(orderId);
            r.setMerchantUserId(account.getId());
            r.setRefundAmount(amount);
            r.setReason(reason);

            new RefundDAO().insertRefund(r);
            request.getSession().setAttribute("msg", "Đã xử lý hoàn tiền thành công!");

        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/merchant/orders");
    }
}
