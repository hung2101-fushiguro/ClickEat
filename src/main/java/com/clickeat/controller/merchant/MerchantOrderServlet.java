package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.NotificationDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MerchantOrderServlet", urlPatterns = {"/merchant/orders"})
public class MerchantOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) {
            tab = "pending";
        }
        String statusFilter = request.getParameter("status");
        String fromDateTime = request.getParameter("from");
        String toDateTime = request.getParameter("to");
        int page = 1;
        try {
            String pageRaw = request.getParameter("page");
            if (pageRaw != null) {
                page = Integer.parseInt(pageRaw);
            }
        } catch (NumberFormatException ignored) {
            page = 1;
        }
        int pageSize = 10;

        OrderDAO orderDAO = new OrderDAO();
        int totalOrders = orderDAO.countOrdersByMerchantAndStatus(account.getId(), tab, statusFilter, fromDateTime, toDateTime);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) pageSize));
        if (page > totalPages) {
            page = totalPages;
        }
        List<Order> orders = orderDAO.getOrdersByMerchantAndStatus(account.getId(), tab, statusFilter, fromDateTime, toDateTime, page, pageSize);

        request.setAttribute("orders", orders);
        request.setAttribute("currentTab", tab);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("fromDateTime", fromDateTime);
        request.setAttribute("toDateTime", toDateTime);
        request.setAttribute("currentPageNum", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("currentPage", "orders");

        request.setAttribute("successMsg", request.getSession().getAttribute("merchantOrderSuccess"));
        request.setAttribute("errorMsg", request.getSession().getAttribute("merchantOrderError"));
        request.getSession().removeAttribute("merchantOrderSuccess");
        request.getSession().removeAttribute("merchantOrderError");

        request.getRequestDispatcher("/views/merchant/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        long orderId = Long.parseLong(request.getParameter("orderId"));
        String currentTab = request.getParameter("tab"); // Để redirect về đúng tab cũ
        String statusFilter = request.getParameter("status");
        String fromDateTime = request.getParameter("from");
        String toDateTime = request.getParameter("to");
        String cancelReason = request.getParameter("cancelReason");

        OrderDAO orderDAO = new OrderDAO();
        boolean success = false;
        String message = null;

        try {
            if ("accept".equals(action)) {
                success = orderDAO.transitionMerchantOrderStatus(orderId, account.getId(), "PREPARING", "Merchant accepted order");
                message = success ? "Đã nhận đơn và chuyển sang ĐANG CHUẨN BỊ." : "Không thể nhận đơn do trạng thái không hợp lệ.";
            } else if ("ready".equals(action)) {
                success = orderDAO.transitionMerchantOrderStatus(orderId, account.getId(), "READY_FOR_PICKUP", "Merchant marked ready for pickup");
                message = success ? "Đơn đã sẵn sàng để shipper lấy." : "Không thể chuyển sang SẴN SÀNG LẤY HÀNG.";
            } else if ("cancel".equals(action)) {
                success = orderDAO.transitionMerchantOrderStatus(orderId, account.getId(), "CANCELLED", cancelReason);
                message = success ? "Đơn đã được hủy." : "Không thể hủy đơn ở trạng thái hiện tại.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Có lỗi khi cập nhật đơn hàng.";
        }

        if (success) {
            Order changedOrder = orderDAO.findById((int) orderId);
            if (changedOrder != null && changedOrder.getCustomerUserId() > 0) {
                NotificationDAO notificationDAO = new NotificationDAO();
                if ("accept".equals(action)) {
                    notificationDAO.createForUser(changedOrder.getCustomerUserId(), "ORDER", "Đơn #" + changedOrder.getOrderCode() + " đã được quán xác nhận và đang chuẩn bị.");
                } else if ("ready".equals(action)) {
                    notificationDAO.createForUser(changedOrder.getCustomerUserId(), "ORDER", "Đơn #" + changedOrder.getOrderCode() + " đã sẵn sàng để shipper lấy.");
                } else if ("cancel".equals(action)) {
                    notificationDAO.createForUser(changedOrder.getCustomerUserId(), "ORDER", "Đơn #" + changedOrder.getOrderCode() + " đã bị quán hủy.");
                }
            }
        }

        if (message != null) {
            if (success) {
                request.getSession().setAttribute("merchantOrderSuccess", message);
            } else {
                request.getSession().setAttribute("merchantOrderError", message);
            }
        }

        if (currentTab == null) {
            currentTab = "pending";
        }
        StringBuilder redirect = new StringBuilder(request.getContextPath() + "/merchant/orders?tab=" + currentTab);
        if (statusFilter != null && !statusFilter.isBlank()) {
            redirect.append("&status=").append(java.net.URLEncoder.encode(statusFilter, java.nio.charset.StandardCharsets.UTF_8));
        }
        if (fromDateTime != null && !fromDateTime.isBlank()) {
            redirect.append("&from=").append(java.net.URLEncoder.encode(fromDateTime, java.nio.charset.StandardCharsets.UTF_8));
        }
        if (toDateTime != null && !toDateTime.isBlank()) {
            redirect.append("&to=").append(java.net.URLEncoder.encode(toDateTime, java.nio.charset.StandardCharsets.UTF_8));
        }
        response.sendRedirect(redirect.toString());
    }
}
