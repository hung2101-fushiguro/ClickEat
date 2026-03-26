/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.OrderDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperCheckNewOrderServlet", urlPatterns = {"/shipper/check-new-orders"})
public class ShipperCheckNewOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        OrderDAO orderDAO = new OrderDAO();
        // Đếm số lượng đơn hàng đang ở trạng thái "Chờ Shipper nhận"
        int currentAvailableCount = orderDAO.getAvailableOrdersForShipper().size();

        // Trả về dữ liệu dạng JSON cho Javascript đọc
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"count\": " + currentAvailableCount + "}");
            out.flush();
        }
    }
}
