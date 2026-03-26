/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import java.io.IOException;

import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
        if (action != null) {
            action = action.trim();
        }
        if (action == null || action.isEmpty()) {
            action = "create";
        }
        VoucherDAO voucherDAO = new VoucherDAO();

        if ("togglePublish".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher ownVoucher = voucherDAO.findById(voucherId);

            if (ownVoucher == null || ownVoucher.getMerchantUserId() != account.getId()) {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để cập nhật publish.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            boolean nextPublish = !ownVoucher.isPublished();
            if (nextPublish && !"ACTIVE".equalsIgnoreCase(ownVoucher.getStatus())) {
                request.getSession().setAttribute("promotionError", "Voucher đang tạm dừng. Hãy kích hoạt trước khi hiển thị cho khách.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            boolean ok = voucherDAO.togglePublishByMerchant(voucherId, account.getId(), nextPublish);
            if (ok) {
                request.getSession().setAttribute("promotionSuccess", nextPublish ? "Voucher đã được hiển thị cho khách." : "Voucher đã được ẩn khỏi khách hàng.");
            } else {
                request.getSession().setAttribute("promotionError", "Không thể cập nhật trạng thái hiển thị voucher (DB không ghi nhận thay đổi).");
            }
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        if ("archive".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher ownVoucher = voucherDAO.findById(voucherId);
            if (ownVoucher != null && ownVoucher.getMerchantUserId() == account.getId()) {
                voucherDAO.softDelete(voucherId);
                request.getSession().setAttribute("promotionSuccess", "Voucher đã được lưu trữ.");
            } else {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để lưu trữ.");
            }
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }
        if ("toggleStatus".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher ownVoucher = voucherDAO.findById(voucherId);
            if (ownVoucher == null || ownVoucher.getMerchantUserId() != account.getId()) {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để đổi trạng thái.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            String nextStatus = "ACTIVE".equalsIgnoreCase(ownVoucher.getStatus()) ? "INACTIVE" : "ACTIVE";
            boolean ok = voucherDAO.updateStatusByMerchant(voucherId, account.getId(), nextStatus);
            request.getSession().setAttribute(ok ? "promotionSuccess" : "promotionError",
                    ok ? ("ACTIVE".equals(nextStatus) ? "Voucher đã được kích hoạt." : "Voucher đã được tạm dừng.")
                            : "Không thể cập nhật trạng thái voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        if ("edit".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher ownVoucher = voucherDAO.findById(voucherId);
            if (ownVoucher == null || ownVoucher.getMerchantUserId() != account.getId()) {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để chỉnh sửa.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            String codeParam = request.getParameter("code");
            String titleParam = request.getParameter("title");
            String typeParam = request.getParameter("type");
            String valueParam = request.getParameter("value");
            String minOrderParam = request.getParameter("minOrder");
            String maxUsesParam = request.getParameter("maxUses");
            String startDateParam = request.getParameter("startDate");
            String endDateParam = request.getParameter("endDate");

            if (isBlank(titleParam) || isBlank(valueParam) || isBlank(minOrderParam)
                    || isBlank(maxUsesParam) || isBlank(startDateParam) || isBlank(endDateParam)) {
                request.getSession().setAttribute("promotionError", "Thiếu thông tin bắt buộc để chỉnh sửa voucher.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            String normalizedType = normalizeDiscountType(typeParam);
            if (normalizedType == null) {
                request.getSession().setAttribute("promotionError", "Loại giảm giá không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            Voucher toUpdate = new Voucher();
            toUpdate.setId(voucherId);
            toUpdate.setCode(isBlank(codeParam) ? ownVoucher.getCode() : codeParam.trim().toUpperCase());
            toUpdate.setTitle(titleParam);
            toUpdate.setDiscountType(normalizedType);

            try {
                double discountValue = Double.parseDouble(valueParam);
                double minOrderAmount = Double.parseDouble(minOrderParam);
                int maxUses = Integer.parseInt(maxUsesParam);
                java.sql.Timestamp startAt = java.sql.Timestamp.valueOf(startDateParam + " 00:00:00");
                java.sql.Timestamp endAt = java.sql.Timestamp.valueOf(endDateParam + " 23:59:59");

                if (!isValidVoucherNumbers(discountValue, minOrderAmount, maxUses)) {
                    request.getSession().setAttribute("promotionError", "Giá trị voucher không hợp lệ. Vui lòng kiểm tra lại.");
                    response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                    return;
                }
                if (startAt.after(endAt)) {
                    request.getSession().setAttribute("promotionError", "Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.");
                    response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                    return;
                }

                toUpdate.setDiscountValue(discountValue);
                toUpdate.setMinOrderAmount(minOrderAmount);
                toUpdate.setMaxUsesTotal(maxUses);
                toUpdate.setStartAt(startAt);
                toUpdate.setEndAt(endAt);
            } catch (IllegalArgumentException ex) {
                request.getSession().setAttribute("promotionError", "Dữ liệu voucher không hợp lệ. Vui lòng kiểm tra lại.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            boolean ok = voucherDAO.updateByMerchant(toUpdate, account.getId());
            request.getSession().setAttribute(ok ? "promotionSuccess" : "promotionError",
                    ok ? "Đã cập nhật voucher thành công." : "Không thể cập nhật voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        if (!"create".equals(action)) {
            request.getSession().setAttribute("promotionError", "Hành động không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        String titleParam = request.getParameter("title");
        String codeParam = request.getParameter("code");
        String typeParam = request.getParameter("type");
        String valueParam = request.getParameter("value");
        String minOrderParam = request.getParameter("minOrder");
        String maxUsesParam = request.getParameter("maxUses");
        String startDateParam = request.getParameter("startDate");
        String endDateParam = request.getParameter("endDate");

        if (isBlank(titleParam) || isBlank(codeParam) || isBlank(typeParam)
                || isBlank(valueParam) || isBlank(minOrderParam) || isBlank(maxUsesParam)
                || isBlank(startDateParam) || isBlank(endDateParam)) {
            request.getSession().setAttribute("promotionError", "Thiếu thông tin bắt buộc để tạo voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        String normalizedType = normalizeDiscountType(typeParam);
        if (normalizedType == null) {
            request.getSession().setAttribute("promotionError", "Loại giảm giá không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        if ("toggleStatus".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher ownVoucher = voucherDAO.findById(voucherId);
            if (ownVoucher == null || ownVoucher.getMerchantUserId() != account.getId()) {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để đổi trạng thái.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            String nextStatus = "ACTIVE".equalsIgnoreCase(ownVoucher.getStatus()) ? "INACTIVE" : "ACTIVE";
            boolean ok = voucherDAO.updateStatusByMerchant(voucherId, account.getId(), nextStatus);
            request.getSession().setAttribute(ok ? "promotionSuccess" : "promotionError",
                    ok ? ("ACTIVE".equals(nextStatus) ? "Voucher đã được kích hoạt." : "Voucher đã được tạm dừng.")
                            : "Không thể cập nhật trạng thái voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        if ("edit".equals(action)) {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher ownVoucher = voucherDAO.findById(voucherId);
            if (ownVoucher == null || ownVoucher.getMerchantUserId() != account.getId()) {
                request.getSession().setAttribute("promotionError", "Không tìm thấy voucher hợp lệ để chỉnh sửa.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            String codeParam = request.getParameter("code");
            String titleParam = request.getParameter("title");
            String typeParam = request.getParameter("type");
            String valueParam = request.getParameter("value");
            String minOrderParam = request.getParameter("minOrder");
            String maxUsesParam = request.getParameter("maxUses");
            String startDateParam = request.getParameter("startDate");
            String endDateParam = request.getParameter("endDate");

            if (isBlank(titleParam) || isBlank(valueParam) || isBlank(minOrderParam)
                    || isBlank(maxUsesParam) || isBlank(startDateParam) || isBlank(endDateParam)) {
                request.getSession().setAttribute("promotionError", "Thiếu thông tin bắt buộc để chỉnh sửa voucher.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            String normalizedType = normalizeDiscountType(typeParam);
            if (normalizedType == null) {
                request.getSession().setAttribute("promotionError", "Loại giảm giá không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            Voucher toUpdate = new Voucher();
            toUpdate.setId(voucherId);
            toUpdate.setCode(isBlank(codeParam) ? ownVoucher.getCode() : codeParam.trim().toUpperCase());
            toUpdate.setTitle(titleParam);
            toUpdate.setDiscountType(normalizedType);

            try {
                double discountValue = Double.parseDouble(valueParam);
                double minOrderAmount = Double.parseDouble(minOrderParam);
                int maxUses = Integer.parseInt(maxUsesParam);
                java.sql.Timestamp startAt = java.sql.Timestamp.valueOf(startDateParam + " 00:00:00");
                java.sql.Timestamp endAt = java.sql.Timestamp.valueOf(endDateParam + " 23:59:59");

                if (!isValidVoucherNumbers(discountValue, minOrderAmount, maxUses)) {
                    request.getSession().setAttribute("promotionError", "Giá trị voucher không hợp lệ. Vui lòng kiểm tra lại.");
                    response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                    return;
                }
                if (startAt.after(endAt)) {
                    request.getSession().setAttribute("promotionError", "Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.");
                    response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                    return;
                }

                toUpdate.setDiscountValue(discountValue);
                toUpdate.setMinOrderAmount(minOrderAmount);
                toUpdate.setMaxUsesTotal(maxUses);
                toUpdate.setStartAt(startAt);
                toUpdate.setEndAt(endAt);
            } catch (IllegalArgumentException ex) {
                request.getSession().setAttribute("promotionError", "Dữ liệu voucher không hợp lệ. Vui lòng kiểm tra lại.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            boolean ok = voucherDAO.updateByMerchant(toUpdate, account.getId());
            request.getSession().setAttribute(ok ? "promotionSuccess" : "promotionError",
                    ok ? "Đã cập nhật voucher thành công." : "Không thể cập nhật voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        if (!"create".equals(action)) {
            request.getSession().setAttribute("promotionError", "Hành động không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        String titleParam = request.getParameter("title");
        String codeParam = request.getParameter("code");
        String typeParam = request.getParameter("type");
        String valueParam = request.getParameter("value");
        String minOrderParam = request.getParameter("minOrder");
        String maxUsesParam = request.getParameter("maxUses");
        String startDateParam = request.getParameter("startDate");
        String endDateParam = request.getParameter("endDate");

        if (isBlank(titleParam) || isBlank(codeParam) || isBlank(typeParam)
                || isBlank(valueParam) || isBlank(minOrderParam) || isBlank(maxUsesParam)
                || isBlank(startDateParam) || isBlank(endDateParam)) {
            request.getSession().setAttribute("promotionError", "Thiếu thông tin bắt buộc để tạo voucher.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        String normalizedType = normalizeDiscountType(typeParam);
        if (normalizedType == null) {
            request.getSession().setAttribute("promotionError", "Loại giảm giá không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }

        Voucher v = new Voucher();
        v.setMerchantUserId((int) account.getId());
        v.setTitle(titleParam);
        v.setCode(codeParam.trim().toUpperCase());
        v.setDiscountType(normalizedType);
        try {
            double discountValue = Double.parseDouble(valueParam);
            double minOrderAmount = Double.parseDouble(minOrderParam);
            int maxUses = Integer.parseInt(maxUsesParam);
            java.sql.Timestamp startAt = java.sql.Timestamp.valueOf(startDateParam + " 00:00:00");
            java.sql.Timestamp endAt = java.sql.Timestamp.valueOf(endDateParam + " 23:59:59");

            if (!isValidVoucherNumbers(discountValue, minOrderAmount, maxUses)) {
                request.getSession().setAttribute("promotionError", "Giá trị voucher không hợp lệ. Vui lòng kiểm tra lại.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }
            if (startAt.after(endAt)) {
                request.getSession().setAttribute("promotionError", "Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.");
                response.sendRedirect(request.getContextPath() + "/merchant/promotions");
                return;
            }

            v.setDiscountValue(discountValue);
            v.setMinOrderAmount(minOrderAmount);
            v.setMaxUsesTotal(maxUses);
            v.setStartAt(startAt);
            v.setEndAt(endAt);
        } catch (IllegalArgumentException ex) {
            request.getSession().setAttribute("promotionError", "Dữ liệu voucher không hợp lệ. Vui lòng kiểm tra lại.");
            response.sendRedirect(request.getContextPath() + "/merchant/promotions");
            return;
        }
        v.setStatus("ACTIVE");
        v.setPublished(false);

        int created = voucherDAO.insert(v);
        request.getSession().setAttribute(created > 0 ? "promotionSuccess" : "promotionError", created > 0 ? "Tạo voucher thành công ở trạng thái nháp (chưa hiển thị)." : "Không thể tạo voucher.");
        response.sendRedirect(request.getContextPath() + "/merchant/promotions");
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String normalizeDiscountType(String rawType) {
        if (isBlank(rawType)) {
            return null;
        }

        String normalized = rawType.trim().toUpperCase();
        if ("PERCENT".equals(normalized) || "FIXED".equals(normalized)) {
            return normalized;
        }
        return null;
    }

    private boolean isValidVoucherNumbers(double discountValue, double minOrderAmount, int maxUses) {
        return discountValue > 0 && minOrderAmount >= 0 && maxUses > 0;
    }
}

