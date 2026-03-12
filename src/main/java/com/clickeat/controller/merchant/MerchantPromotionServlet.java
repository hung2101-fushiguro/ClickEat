/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 *
 * @author DELL
 */
@WebServlet(name = "MerchantPromotionServlet", urlPatterns = {"/merchant/promotions"})
public class MerchantPromotionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        VoucherDAO voucherDAO = new VoucherDAO();
        request.setAttribute("vouchers", voucherDAO.getByMerchantId((int) account.getId()));
        request.getRequestDispatcher("/views/merchant/promotions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");

        Voucher v = new Voucher();
        v.setMerchantUserId((int) account.getId());
        v.setTitle(request.getParameter("title"));
        v.setCode(request.getParameter("code"));
        v.setDiscountType(request.getParameter("type").toUpperCase());
        v.setDiscountValue(Double.parseDouble(request.getParameter("value")));
        v.setMinOrderAmount(Double.parseDouble(request.getParameter("minOrder")));
        v.setMaxUsesTotal(Integer.parseInt(request.getParameter("maxUses")));
        v.setStartAt(java.sql.Timestamp.valueOf(request.getParameter("startDate") + " 00:00:00"));
        v.setEndAt(java.sql.Timestamp.valueOf(request.getParameter("endDate") + " 23:59:59"));
        v.setPublished(true);

        new VoucherDAO().insert(v);
        response.sendRedirect(request.getContextPath() + "/merchant/promotions");
    }
}
