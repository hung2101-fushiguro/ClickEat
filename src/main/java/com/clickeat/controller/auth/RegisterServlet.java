/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    // Hiển thị form đăng ký
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
    }

    // Xử lý khi người dùng bấm nút Đăng ký
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Giữ font tiếng Việt không bị lỗi font khi lưu vào DB
        request.setCharacterEncoding("UTF-8");

        // 1. Lấy dữ liệu từ JSP và trim khoảng trắng
        String fullName = request.getParameter("fullName");
        if (fullName != null) {
            fullName = fullName.trim();
        }

        String email = request.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        String phone = request.getParameter("phone");
        if (phone != null) {
            phone = phone.trim();
        }

        String password = request.getParameter("password");
        if (password != null) {
            password = password.trim();
        }

        String confirmPassword = request.getParameter("confirmPassword");
        if (confirmPassword != null) {
            confirmPassword = confirmPassword.trim();
        }

        // 2. Validate dữ liệu bắt buộc
        if (fullName == null || fullName.isEmpty()
                || email == null || email.isEmpty()
                || phone == null || phone.isEmpty()
                || password == null || password.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        // Validate đơn giản theo format chung
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("error", "Email không đúng định dạng!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        if (!phone.matches("^0\\d{9,10}$")) {
            request.setAttribute("error", "Số điện thoại không đúng định dạng!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        // 3. Kiểm tra mật khẩu khớp nhau
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();

        // 4. Kiểm tra trùng lặp (Logic DAO bạn đã viết sẵn)
        if (userDAO.checkPhoneExist(phone)) {
            request.setAttribute("error", "Số điện thoại này đã được đăng ký!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.checkEmailExist(email)) {
            request.setAttribute("error", "Email này đã được đăng ký!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        // 5. Tạo Object User và lưu xuống DB
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setPhone(phone);
        newUser.setPasswordHash(password); // Lưu ý: Thực tế chỗ này cần mã hóa MD5/BCrypt
        newUser.setRole("CUSTOMER");       // Mặc định đăng ký mới là Khách hàng

        int newId = userDAO.insert(newUser);

        // 6. Kiểm tra kết quả
        if (newId > 0) {
            // Đăng ký thành công, đẩy về trang Login kèm thông báo
            request.setAttribute("message", "Đăng ký thành công! Vui lòng đăng nhập.");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
        } else {
            // Lỗi hệ thống/DB
            request.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại sau!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
        }
    }
}
