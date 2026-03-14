package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "GoogleCompleteServlet", urlPatterns = {"/google-complete"})
public class GoogleCompleteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("GOOGLE_EMAIL") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        String email = (String) session.getAttribute("GOOGLE_EMAIL");
        String name  = (String) session.getAttribute("GOOGLE_NAME");
        String sub   = (String) session.getAttribute("GOOGLE_SUB");

        String fullName = req.getParameter("full_name");
        String phone = req.getParameter("phone");

        String foodPreferences = req.getParameter("food_preferences");
        String allergies = req.getParameter("allergies");
        String healthGoal = req.getParameter("health_goal");
        String calStr = req.getParameter("daily_calorie_target");

        Integer dailyCal = null;
        try { if (calStr != null && !calStr.isBlank()) dailyCal = Integer.parseInt(calStr.trim()); }
        catch (Exception ignored) {}

        UserDAO dao = new UserDAO();

        // validate phone unique
        if (phone == null || phone.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập số điện thoại.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }
        phone = phone.trim();
        if (dao.checkPhoneExist(phone)) {
            req.setAttribute("error", "Số điện thoại đã tồn tại. Vui lòng dùng số khác.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (fullName == null || fullName.trim().isEmpty()) fullName = name;
        fullName = fullName.trim();

        long newUserId = dao.createGoogleUserReturnId(fullName, email, phone); // role CUSTOMER
        dao.createCustomerProfile(newUserId, foodPreferences, allergies, healthGoal, dailyCal);
        dao.linkGoogleProvider((int)newUserId, sub);

        User user = dao.findById((int)newUserId);
        session.setAttribute("account", user);

        // clear temp
        session.removeAttribute("GOOGLE_EMAIL");
        session.removeAttribute("GOOGLE_NAME");
        session.removeAttribute("GOOGLE_SUB");

        resp.sendRedirect(req.getContextPath() + "/home");
    }
}