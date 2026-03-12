/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

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
import java.io.IOException;
import java.util.List;

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

            MerchantWalletDAO walletDAO = new MerchantWalletDAO();
            MerchantWallet wallet = walletDAO.getWalletByMerchantId(merchantId);

            // Kiểm tra số dư có đủ để rút không
            if (wallet != null && wallet.getBalance() >= amount && amount >= 50000) {
                // 1. Trừ tiền trong ví
                boolean deducted = walletDAO.deductBalance(merchantId, amount);

                // 2. Nếu trừ tiền thành công, tạo lệnh Rút tiền
                if (deducted) {
                    MerchantWithdrawal w = new MerchantWithdrawal();
                    w.setMerchantUserId(merchantId);
                    w.setAmount(amount);
                    w.setBankName(bankName);
                    w.setBankAccountNumber(accNum);

                    MerchantWithdrawalDAO withdrawDAO = new MerchantWithdrawalDAO();
                    withdrawDAO.insertRequest(w);

                    // Thêm thông báo thành công
                    request.getSession().setAttribute("msg", "Đã gửi yêu cầu rút tiền thành công!");
                }
            } else {
                request.getSession().setAttribute("error", "Số dư không đủ hoặc số tiền rút không hợp lệ!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/merchant/wallet");
    }
}
