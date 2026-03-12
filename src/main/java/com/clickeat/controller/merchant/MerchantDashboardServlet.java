/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.MerchantDAO;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "MerchantDashboardServlet", urlPatterns = {"/merchant/dashboard"})
public class MerchantDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        
        MerchantDAO merchantDAO = new MerchantDAO();
        double[] todayStats = merchantDAO.getTodayStats(account.getId());

        
        request.setAttribute("todayRevenue", todayStats[0]);
        request.setAttribute("todayOrders", (int) todayStats[1]);
        
        
        request.setAttribute("currentPage", "dashboard");

        
        request.getRequestDispatcher("/views/merchant/dashboard.jsp").forward(request, response);
    }
}
