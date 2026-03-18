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
        if (account == null || !"MERCHANT".equals(account.getRole())) {
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

            Voucher ownVoucher = voucherDAO.findById(voucherId);
            if (ownVoucher == null || ownVoucher.getMerchantUserId() != account.getId()) {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để cập nhật.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            if (publish) {
                if (!"ACTIVE".equalsIgnoreCase(ownVoucher.getStatus())) {
                    request.getSession().setAttribute("promotionError", "Chỉ voucher ACTIVE mới có thể publish.");
                    response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                    return;
                }

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                if (ownVoucher.getEndAt() != null && now.after(ownVoucher.getEndAt())) {
                    request.getSession().setAttribute("promotionError", "Voucher đã hết hạn, không thể publish lại.");
                    response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                    return;
                }
            }

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

        String title = trimToEmpty(request.getParameter("title"));
        String code = trimToEmpty(request.getParameter("code")).toUpperCase();
        String type = trimToEmpty(request.getParameter("type")).toUpperCase();
        String startDate = trimToEmpty(request.getParameter("startDate"));
        String endDate = trimToEmpty(request.getParameter("endDate"));

        if (title.isEmpty() || code.isEmpty() || (!"PERCENT".equals(type) && !"FIXED".equals(type))) {
            request.getSession().setAttribute("promotionError", "Thông tin voucher không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        try {
            double discountValue = Double.parseDouble(trimToEmpty(request.getParameter("value")));
            double minOrderAmount = parseNonNegativeDouble(request.getParameter("minOrder"), 0);
            int maxUsesTotal = parsePositiveInt(request.getParameter("maxUses"), 1);

            java.time.LocalDate start = java.time.LocalDate.parse(startDate);
            java.time.LocalDate end = java.time.LocalDate.parse(endDate);
            if (start.isAfter(end)) {
                request.getSession().setAttribute("promotionError", "Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }
            if (discountValue <= 0) {
                request.getSession().setAttribute("promotionError", "Giá trị giảm phải lớn hơn 0.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }
            if ("PERCENT".equals(type) && discountValue > 100) {
                request.getSession().setAttribute("promotionError", "Voucher phần trăm không thể vượt quá 100%.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            Voucher v = new Voucher();
            v.setMerchantUserId((int) account.getId());
            v.setTitle(title);
            v.setCode(code);
            v.setDiscountType(type);
            v.setDiscountValue(discountValue);
            v.setMinOrderAmount(minOrderAmount);
            v.setMaxUsesTotal(maxUsesTotal);
            v.setStatus("ACTIVE");
            v.setStartAt(java.sql.Timestamp.valueOf(start + " 00:00:00"));
            v.setEndAt(java.sql.Timestamp.valueOf(end + " 23:59:59"));
            v.setPublished(true);

            int created = voucherDAO.insert(v);
            request.getSession().setAttribute(created > 0 ? "promotionSuccess" : "promotionError", created > 0 ? "Tạo voucher thành công." : "Không thể tạo voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("promotionError", "Dữ liệu voucher không hợp lệ hoặc bị trùng mã.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private double parseNonNegativeDouble(String value, double defaultValue) {
        try {
            double parsed = Double.parseDouble(trimToEmpty(value));
            return Math.max(parsed, 0);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(trimToEmpty(value));
            return parsed > 0 ? parsed : defaultValue;
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
