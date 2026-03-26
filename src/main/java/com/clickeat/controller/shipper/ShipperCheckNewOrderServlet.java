package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.User; 
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ShipperCheckNewOrderServlet", urlPatterns = {"/shipper/check-new-orders"})
public class ShipperCheckNewOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int currentAvailableCount = 0;
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account != null) {
            OrderDAO orderDAO = new OrderDAO();
            currentAvailableCount = orderDAO.getAvailableOrdersForShipper((int) account.getId()).size();
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"count\": " + currentAvailableCount + "}");
            out.flush();
        }
    }
}