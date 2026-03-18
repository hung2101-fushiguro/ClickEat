/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.WithdrawalRequestDAO;
import com.clickeat.model.User;
import com.clickeat.model.WithdrawalRequest;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperWithdrawServlet", urlPatterns = {"/shipper/withdraw"})
public class ShipperWithdrawServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            double amount = Double.parseDouble(request.getParameter("amount"));
            String bankName = request.getParameter("bankName");
            String bankAccountNumber = request.getParameter("bankAccountNumber");

            if (amount < 50000) {
                request.getSession().setAttribute("toastError", "Số tiền rút tối thiểu là 50.000đ.");
                response.sendRedirect(request.getContextPath() + "/shipper/dashboard?tab=overview");
                return;
            }
            if (bankName == null || bankName.trim().isEmpty() || bankAccountNumber == null || bankAccountNumber.trim().isEmpty()) {
                request.getSession().setAttribute("toastError", "Vui lòng nhập đầy đủ thông tin tài khoản ngân hàng.");
                response.sendRedirect(request.getContextPath() + "/shipper/dashboard?tab=overview");
                return;
            }

            WithdrawalRequest req = new WithdrawalRequest();
            req.setShipperUserId(account.getId());
            req.setAmount(amount);
            req.setBankName(bankName.trim());
            req.setBankAccountNumber(bankAccountNumber.trim());

            WithdrawalRequestDAO dao = new WithdrawalRequestDAO();
            if (dao.createRequest(req)) {
                request.getSession().setAttribute("toastMsg", "Đã gửi yêu cầu rút tiền thành công! Vui lòng chờ Admin duyệt.");
            } else {
                request.getSession().setAttribute("toastError", "Không thể tạo yêu cầu rút tiền (số dư không đủ hoặc dữ liệu không hợp lệ).");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("toastError", "Dữ liệu nhập không hợp lệ.");
        }

        // Quay lại trang Dashboard Shipper (Tab Tổng quan)
        response.sendRedirect(request.getContextPath() + "/shipper/dashboard?tab=overview");
    }
}
