package com.clickeat.controller.auth;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.dao.MerchantDAO;
import com.clickeat.model.Merchant;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect already-logged-in users
        HttpSession existing = request.getSession(false);
        if (existing != null) {
            if (existing.getAttribute("merchantId") != null) {
                response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
                return;
            }
            User u = (User) existing.getAttribute("account");
            if (u != null) {
                redirectByRole(u, request, response);
                return;
            }
        }
        request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.isBlank() || password.isBlank()) {
            request.setAttribute("error", "Vui lòng nhập tài khoản và mật khẩu.");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
            return;
        }

        // --- 1. Try normal users (ADMIN, SHIPPER, CUSTOMER) ---
        UserDAO userDAO = new UserDAO();
        User user = userDAO.checkLogin(username.trim(), password);

        if (user != null) {
            if ("INACTIVE".equals(user.getStatus())) {
                HttpSession s = request.getSession();
                s.setAttribute("bannedUserId", user.getId());
                response.sendRedirect(request.getContextPath() + "/banned");
                return;
            }
            HttpSession session = request.getSession(true);
            session.setAttribute("account", user);
            redirectByRole(user, request, response);
            return;
        }

        // --- 2. Try merchant (BCrypt password, login by email or phone) ---
        try {
            MerchantDAO merchantDAO = new MerchantDAO();
            Optional<Merchant> opt = merchantDAO.findByEmail(username.trim());
            if (opt.isEmpty()) {
                opt = merchantDAO.findByPhone(username.trim());
            }
            if (opt.isPresent()) {
                Merchant merchant = opt.get();
                if (!merchantDAO.verifyPassword(password, merchant.getPasswordHash())) {
                    request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
                    request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
                    return;
                }
                if (!"ACTIVE".equalsIgnoreCase(merchant.getUserStatus())) {
                    request.setAttribute("error", "Tài khoản đã bị khóa. Vui lòng liên hệ hỗ trợ.");
                    request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
                    return;
                }
                HttpSession session = request.getSession(true);
                session.setAttribute("merchantId", merchant.getUserId());
                session.setAttribute("merchantName", merchant.getFullName());
                session.setAttribute("merchantEmail", merchant.getEmail());
                session.setAttribute("merchantShopName",
                        merchant.getShopName() != null ? merchant.getShopName() : merchant.getFullName());
                session.setAttribute("merchantIsOpen", merchant.isAcceptingOrders());
                response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
                return;
            }
        } catch (SQLException e) {
            // fall through to error
        }

        request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
        request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
    }

    private void redirectByRole(User user, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String ctx = request.getContextPath();
        switch (user.getRole()) {
            case "ADMIN" ->
                response.sendRedirect(ctx + "/admin/dashboard");
            case "SHIPPER" ->
                response.sendRedirect(ctx + "/shipper/dashboard");
            default ->
                response.sendRedirect(ctx + "/home");
        }
    }
}
