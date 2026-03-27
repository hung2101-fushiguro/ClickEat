package com.clickeat.controller.auth;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import com.clickeat.util.RememberMeUtil;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private void redirectByRole(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String contextPath = request.getContextPath();
        String redirect = request.getParameter("redirect");

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(contextPath + "/admin/dashboard");
        } else if ("SHIPPER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(contextPath + "/shipper/dashboard");
        } else if ("MERCHANT".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(contextPath + "/merchant/dashboard");
        } else {
            if (redirect != null && !redirect.isBlank()) {
                response.sendRedirect(redirect);
            } else {
                response.sendRedirect(contextPath + "/home");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            User account = (User) session.getAttribute("account");
            if (account != null) {
                redirectByRole(request, response, account);
                return;
            }
        }

        request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userRaw = request.getParameter("username");
        String passRaw = request.getParameter("password");
        String redirect = request.getParameter("redirect");
        boolean remember = request.getParameter("remember") != null;

        request.setAttribute("username", userRaw);
        request.setAttribute("remember", remember);
        request.setAttribute("redirect", redirect);

        UserDAO userDAO = new UserDAO();
        User user = userDAO.checkLogin(userRaw, passRaw);

        if (user == null) {
            request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
            return;
        }

        if ("INACTIVE".equalsIgnoreCase(user.getStatus())) {
            HttpSession bannedSession = request.getSession(true);
            bannedSession.setAttribute("bannedUserId", user.getId());
            response.sendRedirect(request.getContextPath() + "/banned");
            return;
        }

        HttpSession oldSession = request.getSession(false);

        String guestId = null;
        if (oldSession != null) {
            Object guestIdSnake = oldSession.getAttribute("guest_id");
            Object guestIdCamel = oldSession.getAttribute("guestId");

            if (guestIdSnake != null && !guestIdSnake.toString().isBlank()) {
                guestId = guestIdSnake.toString();
            } else if (guestIdCamel != null && !guestIdCamel.toString().isBlank()) {
                guestId = guestIdCamel.toString();
            }

            oldSession.invalidate();
        }

        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("account", user);
        newSession.setMaxInactiveInterval(60 * 60 * 24);

        if (redirect != null && !redirect.isBlank()) {
            newSession.setAttribute("postLoginRedirect", redirect);
        }

        if (guestId != null && !guestId.isBlank()) {
            newSession.setAttribute("guest_id", guestId);

            CartDAO cartDAO = new CartDAO();
            cartDAO.attachGuestCartToCustomer(guestId, user.getId());
        }

        if (remember) {
            RememberMeUtil.createRememberMeCookie(request, response, user);
        } else {
            RememberMeUtil.clearRememberMeCookie(request, response);
        }

        redirectByRole(request, response, user);
    }
}
