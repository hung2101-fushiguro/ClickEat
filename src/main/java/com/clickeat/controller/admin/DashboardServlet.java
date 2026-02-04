package com.clickeat.controller.admin;

import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/admin/dashboard"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("account") : null;

        // Bảo mật: Phải đăng nhập VÀ phải là ADMIN mới được vào
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect("../login"); // Quay ra ngoài login
            return;
        }

        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
}