package com.clickeat.controller.auth;

import java.io.IOException;

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

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userRaw = request.getParameter("username");
        String passRaw = request.getParameter("password");

        if (userRaw != null) {
            userRaw = userRaw.trim();
        }

        if (userRaw == null || userRaw.isEmpty() || passRaw == null || passRaw.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ tài khoản và mật khẩu!");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByCredentialsAnyStatus(userRaw, passRaw);

        if (user != null) {
            HttpSession session = request.getSession();

            String status = user.getStatus();

            if ("INACTIVE".equalsIgnoreCase(status)) {
                session.setAttribute("bannedUserId", user.getId());

                response.sendRedirect(request.getContextPath() + "/banned");
                return;
            }

            if (!"ACTIVE".equalsIgnoreCase(status)) {
                request.setAttribute("error", "Tài khoản chưa sẵn sàng đăng nhập. Vui lòng liên hệ hỗ trợ.");
                request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
                return;
            }

            session.setAttribute("account", user);

            switch (user.getRole()) {
                case "ADMIN" ->
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                case "SHIPPER" ->
                    response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
                case "MERCHANT" -> {
                    MerchantProfile profile = new MerchantProfileDAO().findById(user.getId());
                    if (profile != null) {
                        session.setAttribute("merchantShopName", profile.getShopName());
                        session.setAttribute("merchantName", profile.getShopName());
                        Boolean merchantIsOpen = profile.getIsOpen();
                        session.setAttribute("merchantIsOpen", merchantIsOpen != null ? merchantIsOpen : Boolean.TRUE);
                    }
                    response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
                }
                default ->
                    response.sendRedirect(request.getContextPath() + "/home");
            }
        } else {
            request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
        }
    }
}
