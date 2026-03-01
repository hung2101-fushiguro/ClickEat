package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.ShipperDAO;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperStatusServlet", urlPatterns = {"/shipper/toggle-status"})
public class ShipperStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        boolean isOnline = Boolean.parseBoolean(request.getParameter("isOnline"));
        
        ShipperDAO shipperDAO = new ShipperDAO();
        boolean success = shipperDAO.updateOnlineStatus(account.getId(), isOnline);
        
        if(success) {
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(isOnline ? "ONLINE" : "OFFLINE");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}