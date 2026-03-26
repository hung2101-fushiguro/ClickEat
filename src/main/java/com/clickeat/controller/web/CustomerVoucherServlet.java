package com.clickeat.controller.web;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;

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
        if (account == null) {
            return;
        }

        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort");
        int page = parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 10;

        VoucherDAO voucherDAO = new VoucherDAO();
        int totalVouchers = voucherDAO.countAvailableVouchersForCustomer(account.getId(), keyword);
        int totalPages = Math.max(1, (int) Math.ceil(totalVouchers / (double) pageSize));
        if (page > totalPages) {
            page = totalPages;
        }

        List<Voucher> vouchers = voucherDAO.searchAvailableVouchersForCustomer(
                account.getId(), keyword, sort, page, pageSize
        );

        request.setAttribute("vouchers", vouchers);
        request.setAttribute("keyword", keyword);
        request.setAttribute("sort", sort);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalVouchers", totalVouchers);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/views/web/vouchers.jsp").forward(request, response);
    }

    private int parsePositiveInt(String raw, int defaultValue) {
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            int value = Integer.parseInt(raw);
            return value > 0 ? value : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }
}
