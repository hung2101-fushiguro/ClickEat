package com.clickeat.controller.web;

import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerVoucherServlet", urlPatterns = {"/customer/vouchers"})
public class CustomerVoucherServlet extends HttpServlet {

    private User getLoggedCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User account = (User) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        if (!"CUSTOMER".equalsIgnoreCase(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return null;
        }

        return account;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = getLoggedCustomer(request, response);
        if (account == null) return;

        VoucherDAO voucherDAO = new VoucherDAO();
        List<Voucher> vouchers = voucherDAO.getAvailableVouchersForCustomer(account.getId());

        request.setAttribute("vouchers", vouchers);
        request.getRequestDispatcher("/views/web/vouchers.jsp").forward(request, response);
    }
}