/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserAppealDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "BannedServlet", urlPatterns = {"/banned"})
public class BannedServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer bannedUserId = (Integer) request.getSession().getAttribute("bannedUserId");
        if (bannedUserId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        com.clickeat.dal.impl.UserAppealDAO dao = new com.clickeat.dal.impl.UserAppealDAO();
        com.clickeat.model.UserAppeal latestAppeal = dao.getLatestAppeal(bannedUserId);
        request.setAttribute("latestAppeal", latestAppeal);

        request.getRequestDispatcher("/views/web/banned.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer bannedUserId = (Integer) request.getSession().getAttribute("bannedUserId");
        if (bannedUserId != null) {
            String reason = request.getParameter("reason");
            UserAppealDAO dao = new UserAppealDAO();
            dao.createAppeal(bannedUserId, reason);
            request.getSession().setAttribute("toastMsg", "Đã gửi đơn kháng cáo thành công! Admin sẽ xem xét.");
        }
        response.sendRedirect(request.getContextPath() + "/banned");
    }
}
