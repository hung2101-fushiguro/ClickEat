package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

import com.clickeat.dao.MerchantDAO;
import com.clickeat.model.Merchant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/merchant/login")
public class MerchantLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Redirect to unified login — all roles handled there
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("merchantId") != null) {
            resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ email và mật khẩu.");
            req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
            return;
        }

        MerchantDAO merchantDAO = new MerchantDAO();
        Optional<Merchant> opt;
        try {
            opt = merchantDAO.findByEmail(email.trim());
        } catch (SQLException e) {
            req.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu. Vui lòng thử lại.");
            req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
            return;
        }

        if (opt.isEmpty()) {
            req.setAttribute("error", "Email hoặc mật khẩu không chính xác.");
            req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
            return;
        }

        Merchant merchant = opt.get();

        // BCrypt-aware password check
        if (!merchantDAO.verifyPassword(password, merchant.getPasswordHash())) {
            req.setAttribute("error", "Email hoặc mật khẩu không chính xác.");
            req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
            return;
        }

        if (!"ACTIVE".equalsIgnoreCase(merchant.getUserStatus())) {
            req.setAttribute("error", "Tài khoản đã bị khóa. Vui lòng liên hệ hỗ trợ.");
            req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("merchantId", merchant.getUserId());
        session.setAttribute("merchantName", merchant.getFullName());
        session.setAttribute("merchantEmail", merchant.getEmail());
        session.setAttribute("merchantShopName", merchant.getShopName() != null ? merchant.getShopName() : merchant.getFullName());
        session.setAttribute("merchantIsOpen", merchant.isAcceptingOrders());

        resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
    }
}
