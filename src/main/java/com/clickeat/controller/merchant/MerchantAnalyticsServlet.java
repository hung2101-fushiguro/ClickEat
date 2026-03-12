/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 *
 * @author DELL
 */
@WebServlet(name = "MerchantAnalyticsServlet", urlPatterns = {"/merchant/analytics"})
public class MerchantAnalyticsServlet extends HttpServlet {

    /**
     *
     * @param request
     * @param response
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String periodStr = request.getParameter("period");
        int days = (periodStr != null) ? Integer.parseInt(periodStr) : 7;

        OrderDAO orderDAO = new OrderDAO();
        Map<String, Double> revenueData = orderDAO.getRevenueByPeriod(account.getId(), days);
        List<Map<String, Object>> topFoods = orderDAO.getTopSellingFoods(account.getId(), 5);

        request.setAttribute("revenueData", revenueData);
        request.setAttribute("topFoods", topFoods);
        request.setAttribute("period", days);
        request.setAttribute("currentPage", "analytics");

        request.getRequestDispatcher("/views/merchant/analytics.jsp").forward(request, response);
    }
}
