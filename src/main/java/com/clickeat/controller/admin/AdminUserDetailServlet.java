/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.admin;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminUserDetailServlet", urlPatterns = {"/admin/user-detail"})
public class AdminUserDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra quyền Admin
        User admin = (User) request.getSession().getAttribute("account");
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int targetUserId = Integer.parseInt(request.getParameter("id"));
            UserDAO userDAO = new UserDAO();
            User targetUser = userDAO.findById(targetUserId);

            if (targetUser != null) {
                OrderDAO orderDAO = new OrderDAO();
                List<Order> historyOrders = orderDAO.getOrderHistoryByUser(targetUserId, targetUser.getRole());

                // Tính toán các chỉ số thống kê (KPI)
                int totalCompleted = 0;
                int totalCancelled = 0;
                double totalMoney = 0; // Khách thì là Tổng chi, Quán thì là Doanh thu, Shipper thì là Tiền ship

                for (Order o : historyOrders) {
                    if ("DELIVERED".equals(o.getOrderStatus())) {
                        totalCompleted++;
                        if ("CUSTOMER".equals(targetUser.getRole()) || "MERCHANT".equals(targetUser.getRole())) {
                            totalMoney += o.getTotalAmount();
                        } else if ("SHIPPER".equals(targetUser.getRole())) {
                            totalMoney += o.getDeliveryFee();
                        }
                    } else if ("CANCELLED".equals(o.getOrderStatus())) {
                        totalCancelled++;
                    }
                }

                request.setAttribute("targetUser", targetUser);
                request.setAttribute("historyOrders", historyOrders);
                request.setAttribute("totalCompleted", totalCompleted);
                request.setAttribute("totalCancelled", totalCancelled);
                request.setAttribute("totalMoney", totalMoney);

                request.getRequestDispatcher("/views/admin/user-detail.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=users");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=users");
        }
    }
}
