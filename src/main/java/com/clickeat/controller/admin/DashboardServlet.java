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
        
        // Không cần check session hay Role ở đây nữa vì Filter đã chặn ngoài cửa rồi.
        // Cứ lọt được vào hàm này nghĩa là CHẮC CHẮN 100% là Admin hợp lệ.
        
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
}