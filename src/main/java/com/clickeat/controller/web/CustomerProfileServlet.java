package com.clickeat.controller.web;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerProfileServlet", urlPatterns = {"/my-account"})
public class CustomerProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User freshUser = userDAO.findById(account.getId());

        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getOrderHistoryByUser(account.getId(), "CUSTOMER");
        long completedCount = orders.stream().filter(o -> "DELIVERED".equals(o.getOrderStatus())).count();
        double totalSpent = orders.stream()
                .filter(o -> "DELIVERED".equals(o.getOrderStatus()))
                .mapToDouble(Order::getTotalAmount).sum();

        request.setAttribute("user", freshUser);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("totalSpent", totalSpent);
        request.setAttribute("cartCount", 0);
        request.getRequestDispatcher("/views/web/my-account.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"CUSTOMER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        UserDAO userDAO = new UserDAO();

        if ("UPDATE_PROFILE".equals(action)) {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");

            if (fullName == null || fullName.trim().isEmpty()) {
                request.getSession().setAttribute("toastError", "Họ tên không được để trống.");
            } else if (userDAO.checkDuplicateForUpdate(phone.trim(), email.trim(), account.getId())) {
                request.getSession().setAttribute("toastError", "Số điện thoại hoặc Email đã được tài khoản khác sử dụng.");
            } else {
                String sql = "UPDATE Users SET full_name = ?, email = ?, phone = ?, updated_at = GETDATE() WHERE id = ?";
                userDAO.update(sql, fullName.trim(), email.trim(), phone.trim(), account.getId());
                User refreshed = userDAO.findById(account.getId());
                request.getSession().setAttribute("account", refreshed);
                request.getSession().setAttribute("toastMsg", "Cập nhật thông tin thành công!");
            }

        } else if ("CHANGE_PASSWORD".equals(action)) {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || newPassword.length() < 6) {
                request.getSession().setAttribute("toastError", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            } else if (!newPassword.equals(confirmPassword)) {
                request.getSession().setAttribute("toastError", "Xác nhận mật khẩu không khớp.");
            } else {
                User check = userDAO.checkLogin(account.getPhone(), oldPassword);
                if (check == null) {
                    request.getSession().setAttribute("toastError", "Mật khẩu hiện tại không đúng.");
                } else {
                    userDAO.changePassword(account.getId(), newPassword);
                    request.getSession().setAttribute("toastMsg", "Đổi mật khẩu thành công!");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/my-account");
    }
}
