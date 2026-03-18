package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import java.io.IOException;
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
        if (passRaw != null) {
            passRaw = passRaw.trim();
        }

        if (userRaw == null || userRaw.isEmpty() || passRaw == null || passRaw.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ tài khoản và mật khẩu!");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.checkLogin(userRaw, passRaw);

        if (user != null) {
            HttpSession session = request.getSession();

            if ("INACTIVE".equals(user.getStatus())) {
                session.setAttribute("bannedUserId", user.getId());

                response.sendRedirect(request.getContextPath() + "/banned");
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
                        session.setAttribute("merchantIsOpen", profile.getIsOpen() == null ? true : profile.getIsOpen());
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
