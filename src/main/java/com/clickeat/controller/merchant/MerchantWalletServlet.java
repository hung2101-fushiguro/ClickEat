/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.MerchantWalletDAO;
import com.clickeat.dal.impl.MerchantWithdrawalDAO;
import com.clickeat.model.MerchantWallet;
import com.clickeat.model.MerchantWithdrawal;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MerchantWalletServlet", urlPatterns = {"/merchant/wallet"})
public class MerchantWalletServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int merchantId = (int) account.getId();
        MerchantWalletDAO walletDAO = new MerchantWalletDAO();
        MerchantWithdrawalDAO withdrawDAO = new MerchantWithdrawalDAO();

        // KHÔNG gọi synchronizeBalanceWithDeliveredIncome ở đây nữa:
        // Hàm đó tính lại balance từ đầu (overwrite), sẽ xung đột với logic
        // cộng tiền incremental được thực hiện ngay trong transaction giao hàng.
        // Balance giờ được quản lý chuẩn xác trong completeDeliveryWithProofAndSettlement.

        // Lấy số dư ví
        MerchantWallet wallet = walletDAO.getWalletByMerchantId(merchantId);

        // Lấy lịch sử rút tiền
        List<MerchantWithdrawal> history = withdrawDAO.getHistoryByMerchantId(merchantId);

        // Ném dữ liệu ra JSP
        request.setAttribute("wallet", wallet);
        request.setAttribute("withdrawHistory", history);
        request.setAttribute("currentPage", "wallet");

        request.getRequestDispatcher("/views/merchant/wallet.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            return;
        }

        try {
            int merchantId = (int) account.getId();
            double amount = Double.parseDouble(request.getParameter("amount"));
            String bankName = request.getParameter("bankName");
            String accNum = request.getParameter("accNum");

            if (amount < 50000 || bankName == null || bankName.trim().isEmpty() || accNum == null || accNum.trim().isEmpty()) {
                request.getSession().setAttribute("error", "Số dư không đủ hoặc số tiền rút không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/merchant/wallet");
                return;
            }

            MerchantWithdrawalDAO withdrawDAO = new MerchantWithdrawalDAO();
            boolean created = withdrawDAO.createRequestWithBalanceCheck(merchantId, amount, bankName.trim(), accNum.trim());
            if (created) {
                request.getSession().setAttribute("msg", "Đã gửi yêu cầu rút tiền thành công! Vui lòng chờ Admin duyệt.");
            } else {
                request.getSession().setAttribute("error", "Không thể tạo lệnh rút tiền (số dư không đủ hoặc có lệnh không hợp lệ).");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/merchant/wallet");
    }
}
