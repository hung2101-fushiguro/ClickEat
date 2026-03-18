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
        request.setAttribute("successMsg", request.getSession().getAttribute("promotionSuccess"));
        request.setAttribute("errorMsg", request.getSession().getAttribute("promotionError"));
        request.getSession().removeAttribute("promotionSuccess");
        request.getSession().removeAttribute("promotionError");
        request.getRequestDispatcher("/views/merchant/promotions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        VoucherDAO voucherDAO = new VoucherDAO();

        if ("togglePublish".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            boolean publish = Boolean.parseBoolean(request.getParameter("publish"));
            boolean ok = voucherDAO.togglePublishByMerchant(voucherId, account.getId(), publish);
            request.getSession().setAttribute(ok ? "promotionSuccess" : "promotionError", ok ? "Đã cập nhật trạng thái publish voucher." : "Không thể cập nhật voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        if ("delete".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher ownVoucher = voucherDAO.findById(voucherId);
            if (ownVoucher != null && ownVoucher.getMerchantUserId() == account.getId()) {
                voucherDAO.softDelete(voucherId);
                request.getSession().setAttribute("promotionSuccess", "Đã ẩn voucher khỏi danh sách hoạt động.");
            } else {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để xóa.");
            }
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        Voucher v = new Voucher();
        v.setMerchantUserId((int) account.getId());
        v.setTitle(request.getParameter("title"));
        v.setCode(request.getParameter("code"));
        v.setDiscountType(request.getParameter("type").toUpperCase());
        v.setDiscountValue(Double.parseDouble(request.getParameter("value")));
        v.setMinOrderAmount(Double.parseDouble(request.getParameter("minOrder")));
        v.setMaxUsesTotal(Integer.parseInt(request.getParameter("maxUses")));
        v.setStatus("ACTIVE");
        v.setStartAt(java.sql.Timestamp.valueOf(request.getParameter("startDate") + " 00:00:00"));
        v.setEndAt(java.sql.Timestamp.valueOf(request.getParameter("endDate") + " 23:59:59"));
        v.setPublished(true);

        int created = voucherDAO.insert(v);
        request.getSession().setAttribute(created > 0 ? "promotionSuccess" : "promotionError", created > 0 ? "Tạo voucher thành công." : "Không thể tạo voucher.");
        response.sendRedirect(request.getContextPath() + "/merchant/promotions");
    }
}
