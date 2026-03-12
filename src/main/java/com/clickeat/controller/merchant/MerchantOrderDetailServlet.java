package com.clickeat.controller.merchant;

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
import java.io.IOException;
import java.util.List;

@WebServlet(name = "MerchantOrderDetailServlet", urlPatterns = {"/merchant/orders/detail"})
public class MerchantOrderDetailServlet extends HttpServlet {

    // 1. HIỂN THỊ TRANG CHI TIẾT
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(request.getParameter("id"));

            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.findById(orderId);

            // Bảo mật: Chặn đứng nếu đơn hàng không tồn tại hoặc không phải của Quán này
            // Lưu ý: Nếu model Order của bạn dùng tên khác (ví dụ getMerchantUserId()), hãy sửa lại cho khớp nhé
            if (order == null || order.getMerchantId() != account.getId()) {
                response.sendRedirect(request.getContextPath() + "/merchant/orders");
                return;
            }

            // Lấy danh sách các món ăn trong đơn
            OrderItemDAO orderItemDAO = new OrderItemDAO();
            List<OrderItem> items = orderItemDAO.getItemsByOrderId(orderId);

            // Ném dữ liệu ra JSP
            request.setAttribute("order", order);
            request.setAttribute("items", items);
            request.setAttribute("currentPage", "orders"); // Sáng nút ở Sidebar

            request.getRequestDispatcher("/views/merchant/order-detail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/merchant/orders");
        }
    }

    // 2. XỬ LÝ NÚT BẤM (Nhận đơn, Từ chối, Xong) TẠI TRANG CHI TIẾT
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            String action = request.getParameter("action");
            int orderId = Integer.parseInt(request.getParameter("orderId"));

            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.findById(orderId);

            // Đảm bảo thao tác thuộc về đúng chủ quán
            if (order != null && order.getMerchantId() == account.getId()) {

                if ("accept".equals(action)) {
                    // Cập nhật trạng thái thành Đang chuẩn bị (Đã thêm account.getId() vào)
                    orderDAO.updateOrderStatus(orderId, account.getId(), "PREPARING");

                } else if ("reject".equals(action)) {
                    // Từ chối đơn (Đã thêm account.getId() vào)
                    orderDAO.updateOrderStatus(orderId, account.getId(), "MERCHANT_REJECTED");

                } else if ("ready".equals(action)) {
                    // Món đã xong, đợi Shipper (Đã thêm account.getId() vào)
                    orderDAO.updateOrderStatus(orderId, account.getId(), "READY_FOR_PICKUP");
                }
            }

            // Xử lý xong thì tải lại ngay trang chi tiết đó để thấy trạng thái mới
            response.sendRedirect(request.getContextPath() + "/merchant/orders/detail?id=" + orderId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/merchant/orders");
        }
    }
}
