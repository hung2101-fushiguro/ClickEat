package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/merchant/login")
public class MerchantLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If already logged in, redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("merchantId") != null) {
            resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
            return;
        }
        req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
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

        UserDAO userDAO = new UserDAO();
        // checkLogin compares password_hash directly → assumes plaintext or pre-hashed
        User user = userDAO.checkLogin(email.trim(), password);

        if (user == null) {
            req.setAttribute("error", "Email hoặc mật khẩu không chính xác.");
            req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
            return;
        }

        if (!"MERCHANT".equalsIgnoreCase(user.getRole())) {
            req.setAttribute("error", "Tài khoản này không phải Merchant.");
            req.getRequestDispatcher("/views/merchant/login.jsp").forward(req, resp);
            return;
        }

        // Load merchant profile for shop name
        MerchantProfileDAO profileDAO = new MerchantProfileDAO();
        MerchantProfile profile = profileDAO.findById(user.getId());

        HttpSession session = req.getSession(true);
        session.setAttribute("merchantId", user.getId());
        session.setAttribute("merchantName", user.getFullName());
        session.setAttribute("merchantEmail", user.getEmail());
        session.setAttribute("merchantShopName", profile != null ? profile.getShopName() : user.getFullName());

        resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
    }
}
