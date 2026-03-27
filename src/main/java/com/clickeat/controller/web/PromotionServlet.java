package com.clickeat.controller.web;

import com.clickeat.dal.impl.CustomerVoucherDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.CustomerVoucher;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "PromotionServlet", urlPatterns = {"/promotions"})
public class PromotionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User account = session == null ? null : (User) session.getAttribute("account");

        String keyword = request.getParameter("keyword");
        String tab = request.getParameter("tab");

        if (keyword == null) {
            keyword = "";
        }
        if (tab == null || tab.isBlank()) {
            tab = "all";
        }

        VoucherDAO voucherDAO = new VoucherDAO();
        CustomerVoucherDAO customerVoucherDAO = new CustomerVoucherDAO();

        List<Voucher> systemVouchers;
        Set<Integer> savedVoucherIds = new HashSet<>();

        if (account != null && "CUSTOMER".equalsIgnoreCase(account.getRole())) {
            List<CustomerVoucher> savedVouchers = customerVoucherDAO.getSavedVouchersByCustomer(account.getId());
            for (CustomerVoucher cv : savedVouchers) {
                savedVoucherIds.add(cv.getVoucherId());
            }

            if ("saved".equalsIgnoreCase(tab)) {
                systemVouchers = voucherDAO.searchPublicActiveVouchers(keyword, null);
                systemVouchers.removeIf(v -> !savedVoucherIds.contains(v.getId()));
            } else {
                systemVouchers = voucherDAO.searchPublicActiveVouchers(keyword, tab);
            }
        } else {
            if ("saved".equalsIgnoreCase(tab)) {
                systemVouchers = java.util.Collections.emptyList();
            } else if (keyword != null && !keyword.isBlank()) {
                systemVouchers = voucherDAO.searchPublicActiveVouchers(keyword, tab);
            } else {
                systemVouchers = voucherDAO.getAllPublicActiveVouchers();
            }
        }

        request.setAttribute("systemVouchers", systemVouchers);
        request.setAttribute("savedVoucherIds", savedVoucherIds);
        request.setAttribute("keyword", keyword);
        request.setAttribute("tab", tab);

        request.getRequestDispatcher("/views/web/promotions.jsp").forward(request, response);
    }
}