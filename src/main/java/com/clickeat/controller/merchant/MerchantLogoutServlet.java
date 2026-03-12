package com.clickeat.controller.merchant;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MerchantLogoutServlet", urlPatterns = {"/merchant/logout"})
public class MerchantLogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy session hiện tại (không tạo mới nếu chưa có)
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Hủy session (Xóa sạch thông tin đăng nhập của merchant)
            session.invalidate();
        }
        
        
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
