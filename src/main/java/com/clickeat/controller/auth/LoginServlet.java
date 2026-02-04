package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException; // Chú ý: JAKARTA
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    // 1. GET: Người dùng mở trang login -> Hiển thị file JSP
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
    }

    // 2. POST: Người dùng bấm nút "Đăng Nhập" -> Xử lý logic
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy dữ liệu từ form
        String userRaw = request.getParameter("username"); // name="username" bên JSP
        String passRaw = request.getParameter("password"); // name="password" bên JSP

        // Gọi DAO kiểm tra
        UserDAO userDAO = new UserDAO();
        User user = userDAO.checkLogin(userRaw, passRaw);

        if (user != null) {
            // A. Đăng nhập thành công
            HttpSession session = request.getSession();
            session.setAttribute("account", user); // Lưu user vào phiên làm việc

            // Điều hướng dựa vào Role (Admin hoặc Khách)
            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect("admin/dashboard"); // (Trang này tạo sau)
            } else {
                response.sendRedirect("home"); // (Trang này tạo sau)
            }
        } else {
            // B. Đăng nhập thất bại
            request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
        }
    }
}