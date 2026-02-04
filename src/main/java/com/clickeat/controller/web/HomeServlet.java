package com.clickeat.controller.web;

import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy thông tin User từ Session
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        // 2. Nếu chưa đăng nhập -> Đẩy về trang Login ngay
        if (account == null) {
            response.sendRedirect("login");
            return;
        }

        // 3. (Sau này) Gọi FoodDAO để lấy danh sách món ăn hiển thị
        // List<FoodItem> list = foodDAO.findAll();
        // request.setAttribute("foods", list);

        // 4. Chuyển sang giao diện Home
        request.getRequestDispatcher("views/web/home.jsp").forward(request, response);
    }
}