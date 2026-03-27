package com.clickeat.controller.web;

import com.clickeat.dal.impl.CustomerVoucherDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.CustomerVoucher;
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
        if (account == null) {
            return;
        }

        CustomerVoucherDAO customerVoucherDAO = new CustomerVoucherDAO();
        List<CustomerVoucher> savedVouchers = customerVoucherDAO.getSavedVouchersByCustomer(account.getId());

        request.setAttribute("savedVouchers", savedVouchers);
        request.getRequestDispatcher("/views/web/vouchers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = getLoggedCustomer(request, response);
        if (account == null) {
            return;
        }

        String action = request.getParameter("action");
        if (action != null) {
            action = action.trim();
        }

        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl == null || returnUrl.isBlank()) {
            returnUrl = "/promotions";
        }

        if (!returnUrl.startsWith("/")) {
            returnUrl = "/promotions";
        }

        if (!"save".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + returnUrl);
            return;
        }

        String voucherIdRaw = request.getParameter("voucherId");
        if (voucherIdRaw != null) {
            voucherIdRaw = voucherIdRaw.trim();
        }

        if (voucherIdRaw == null || voucherIdRaw.isBlank()) {
            request.getSession().setAttribute("toastError", "Không tìm thấy voucher để lưu.");
            response.sendRedirect(request.getContextPath() + returnUrl);
            return;
        }

        int voucherId;
        try {
            voucherId = Integer.parseInt(voucherIdRaw);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastError", "Voucher không hợp lệ.");
            response.sendRedirect(request.getContextPath() + returnUrl);
            return;
        }

        VoucherDAO voucherDAO = new VoucherDAO();
        CustomerVoucherDAO customerVoucherDAO = new CustomerVoucherDAO();

        Voucher voucher = voucherDAO.findPublicActiveById(voucherId);
        if (voucher == null) {
            request.getSession().setAttribute("toastError", "Voucher không tồn tại hoặc đã hết hạn.");
            response.sendRedirect(request.getContextPath() + returnUrl);
            return;
        }

        if (voucher.getCode() == null || voucher.getCode().isBlank()) {
            request.getSession().setAttribute("toastError", "Voucher chưa có mã hợp lệ.");
            response.sendRedirect(request.getContextPath() + returnUrl);
            return;
        }

        boolean alreadySaved = customerVoucherDAO.isSaved(account.getId(), voucherId);
        if (alreadySaved) {
            request.getSession().setAttribute("toastMsg", "Voucher này đã có trong kho của bạn.");
            response.sendRedirect(request.getContextPath() + returnUrl);
            return;
        }

        boolean ok = customerVoucherDAO.saveVoucher(account.getId(), voucherId, voucher.getCode().trim());
        if (ok) {
            request.getSession().setAttribute("toastMsg", "Đã lưu voucher vào kho của bạn.");
        } else {
            request.getSession().setAttribute("toastError", "Không thể lưu voucher lúc này.");
        }

        response.sendRedirect(request.getContextPath() + returnUrl);
    }
}
