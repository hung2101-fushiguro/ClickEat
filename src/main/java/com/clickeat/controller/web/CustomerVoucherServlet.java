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

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        if (requestedWith != null && "XMLHttpRequest".equalsIgnoreCase(requestedWith.trim())) {
            return true;
        }

        String accept = request.getHeader("Accept");
        return accept != null && accept.toLowerCase().contains("application/json");
    }

    private String jsonEscape(String raw) {
        if (raw == null) {
            return "";
        }
        return raw
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private void respondSaveResult(HttpServletRequest request, HttpServletResponse response,
            String returnUrl, HttpSession session, boolean success, String message) throws IOException {
        if (isAjaxRequest(request)) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + jsonEscape(message) + "\"}");
            return;
        }

        if (success) {
            session.setAttribute("toastMsg", message);
        } else {
            session.setAttribute("toastError", message);
        }
        response.sendRedirect(request.getContextPath() + returnUrl);
    }

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

        HttpSession session = request.getSession();
        String voucherIdRaw = request.getParameter("voucherId");
        if (voucherIdRaw != null) {
            voucherIdRaw = voucherIdRaw.trim();
        }

        if (voucherIdRaw == null || voucherIdRaw.isBlank()) {
            respondSaveResult(request, response, returnUrl, session, false,
                    "Không tìm thấy voucher để lưu.");
            return;
        }

        int voucherId;
        try {
            voucherId = Integer.parseInt(voucherIdRaw);
        } catch (NumberFormatException e) {
            respondSaveResult(request, response, returnUrl, session, false,
                    "Voucher không hợp lệ.");
            return;
        }

        VoucherDAO voucherDAO = new VoucherDAO();
        CustomerVoucherDAO customerVoucherDAO = new CustomerVoucherDAO();

        Voucher voucher = voucherDAO.findPublicActiveById(voucherId);
        if (voucher == null) {
            respondSaveResult(request, response, returnUrl, session, false,
                    "Voucher không tồn tại hoặc đã hết hạn.");
            return;
        }

        if (voucher.getCode() == null || voucher.getCode().isBlank()) {
            respondSaveResult(request, response, returnUrl, session, false,
                    "Voucher chưa có mã hợp lệ.");
            return;
        }

        boolean alreadySaved = customerVoucherDAO.isSaved(account.getId(), voucherId);
        if (alreadySaved) {
            respondSaveResult(request, response, returnUrl, session, true,
                    "Voucher này đã có trong kho của bạn.");
            return;
        }

        boolean ok = customerVoucherDAO.saveVoucher(account.getId(), voucherId, voucher.getCode().trim());
        if (ok) {
            respondSaveResult(request, response, returnUrl, session, true,
                    "Đã lưu voucher vào kho của bạn.");
        } else {
            respondSaveResult(request, response, returnUrl, session, false,
                    "Không thể lưu voucher lúc này.");
        }
    }
}
