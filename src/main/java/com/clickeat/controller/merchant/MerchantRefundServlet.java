package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.List; // Dùng OrderItemDAO thay vì OrderDetailDAO

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.RefundDAO; // Import đúng chuẩn của bạn
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.RefundRequest;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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

            if (order == null || order.getMerchantId() != account.getId()) {
                request.getSession().setAttribute("error", "Không tìm thấy đơn hàng hợp lệ để hoàn tiền.");
                response.sendRedirect(request.getContextPath() + "/merchant/orders");
                return;
            }

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

            if (amount <= 0 || reason == null || reason.trim().isEmpty()) {
                request.getSession().setAttribute("error", "Số tiền hoàn và lý do hoàn tiền không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/merchant/orders");
                return;
            }

            Order order = new OrderDAO().findById((int) orderId);
            if (order == null || order.getMerchantId() != account.getId()) {
                request.getSession().setAttribute("error", "Bạn không có quyền hoàn tiền cho đơn hàng này.");
                response.sendRedirect(request.getContextPath() + "/merchant/orders");
                return;
            }

            RefundRequest r = new RefundRequest();
            r.setOrderId(orderId);
            r.setMerchantUserId(account.getId());
            r.setRefundAmount(amount);
            r.setReason(reason.trim());

            boolean ok = new RefundDAO().processRefundForMerchant(r);
            if (ok) {
                request.getSession().setAttribute("msg", "Đã xử lý hoàn tiền thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể hoàn tiền (đơn không hợp lệ/đã hoàn trước đó/số tiền vượt quá tổng đơn).");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Không thể xử lý hoàn tiền do dữ liệu không hợp lệ.");
        }
        response.sendRedirect(request.getContextPath() + "/merchant/orders");
    }
}
