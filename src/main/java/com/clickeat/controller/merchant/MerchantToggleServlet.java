package com.clickeat.controller.merchant;

import java.io.IOException;

import com.clickeat.dao.MerchantDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/merchant/toggle-open")
public class MerchantToggleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("merchantId") == null) {
            resp.sendError(401);
            return;
        }

        long merchantId = ((Number) session.getAttribute("merchantId")).longValue();
        Boolean current = (Boolean) session.getAttribute("merchantIsOpen");
        boolean nowOpen = current == null || !current; // toggle

        try {
            new MerchantDAO().setAcceptingOrders(merchantId, nowOpen);
            session.setAttribute("merchantIsOpen", nowOpen);
        } catch (Exception e) {
            e.printStackTrace();
        }

        String referer = req.getHeader("Referer");
        resp.sendRedirect(referer != null ? referer : req.getContextPath() + "/merchant/dashboard");
    }
}
