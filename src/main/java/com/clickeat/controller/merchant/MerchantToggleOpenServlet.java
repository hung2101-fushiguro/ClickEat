package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "MerchantToggleOpenServlet", urlPatterns = {"/merchant/toggle-open"})
public class MerchantToggleOpenServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        MerchantProfileDAO dao = new MerchantProfileDAO();
        MerchantProfile profile = dao.findById(account.getId());
        if (profile == null) {
            response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
            return;
        }

        boolean currentOpen = profile.getIsOpen() == null || profile.getIsOpen();
        boolean nextOpen = !currentOpen;
        boolean updated = dao.updateOpenState(account.getId(), nextOpen);

        if (updated) {
            request.getSession().setAttribute("merchantIsOpen", nextOpen);
        }
        response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
    }
}
