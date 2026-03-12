/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderIssueDAO;
import com.clickeat.model.OrderIssue;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperReportServlet", urlPatterns = {"/shipper/report-issue"})
public class ShipperReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderId = request.getParameter("orderId");
        request.setAttribute("orderId", orderId);
        request.getRequestDispatcher("/views/shipper/report-issue.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User account = (User) request.getSession().getAttribute("account");
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String issueType = request.getParameter("issueType");
        String description = request.getParameter("description");

        // 1. Lưu báo cáo sự cố vào Database
        OrderIssue issue = new OrderIssue();
        issue.setOrderId(orderId);
        issue.setReporterUserId(account.getId());
        issue.setIssueType(issueType);
        issue.setDescription(description);
        
        OrderIssueDAO issueDAO = new OrderIssueDAO();
        issueDAO.insert(issue);

        // 2. Hủy đơn hàng và cập nhật giờ hủy
        OrderDAO orderDAO = new OrderDAO();
        String sqlCancel = "UPDATE Orders SET order_status = 'CANCELLED', cancelled_at = GETDATE() WHERE id = ?";
        orderDAO.update(sqlCancel, orderId);

        // 3. Thông báo và đưa về trang chủ
        request.getSession().setAttribute("toastError", "Đã báo cáo sự cố và Hủy đơn hàng!");
        response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
    }
}