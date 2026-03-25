package com.clickeat.controller.merchant;

import java.io.IOException;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MerchantSettingsServlet", urlPatterns = {"/merchant/settings"})
public class MerchantSettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long userId = account.getId();
        MerchantProfileDAO dao = new MerchantProfileDAO();
        MerchantProfile profile = dao.findById((int) userId);

        if (profile != null) {
            request.setAttribute("dbShopName", profile.getShopName());
            request.setAttribute("dbShopPhone", profile.getShopPhone());
            request.setAttribute("dbShopAddress", profile.getShopAddressLine());
            request.setAttribute("dbShopAvatar", profile.getShopAvatar());
            request.setAttribute("dbBusinessHours", profile.getBusinessHours());
            request.setAttribute("dbNotifySettings", profile.getNotificationSettings());
            request.setAttribute("dbMinOrderAmount", profile.getMinOrderAmount());
            request.setAttribute("dbIsOpen", profile.getIsOpen());
            request.setAttribute("dbMerchantStatus", profile.getStatus());
            request.setAttribute("dbRejectionReason", profile.getRejectionReason());

            request.getSession().setAttribute("merchantShopName", profile.getShopName());
            request.getSession().setAttribute("merchantIsOpen", profile.getIsOpen() == null ? true : profile.getIsOpen());
        }

        // Lấy thông báo thành công và tab hiện tại từ Session
        request.setAttribute("successMsg", request.getSession().getAttribute("successMsg"));
        request.setAttribute("errorMsg", request.getSession().getAttribute("errorMsg"));
        request.setAttribute("activeTab", request.getSession().getAttribute("activeTab"));

        request.getSession().removeAttribute("successMsg");
        request.getSession().removeAttribute("errorMsg");
        request.getSession().removeAttribute("activeTab");

        request.setAttribute("currentPage", "settings");
        request.getRequestDispatcher("/views/merchant/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long userId = account.getId();
        String tab = request.getParameter("tab");
        MerchantProfileDAO dao = new MerchantProfileDAO();

        if ("store".equals(tab)) {
            String shopName = request.getParameter("shopName");
            String shopPhone = request.getParameter("shopPhone");
            String shopAddress = request.getParameter("shopAddress");
            String avatarData = request.getParameter("avatarData");
            String minOrderRaw = request.getParameter("minOrderAmount");
            String isOpenRaw = request.getParameter("isOpen");

            MerchantProfile current = dao.findById((int) userId);
            String finalAvatar = (avatarData != null && !avatarData.trim().isEmpty()) ? avatarData : (current != null ? current.getShopAvatar() : null);
            Double minOrderAmount = null;
            if (minOrderRaw != null && !minOrderRaw.trim().isEmpty()) {
                minOrderAmount = Double.parseDouble(minOrderRaw.trim());
            }
            boolean isOpen = "on".equalsIgnoreCase(isOpenRaw) || "true".equalsIgnoreCase(isOpenRaw);

            boolean updatedStoreInfo = dao.updateStoreInfo(userId, shopName, shopPhone, shopAddress, finalAvatar);
            boolean updatedOpenState = dao.updateOpenState(userId, isOpen);
            boolean updatedMinOrder = dao.updateMinOrderAmount(userId, minOrderAmount);

            // Cập nhật lại tên hiển thị trên Sidebar (nếu có lưu trên Session)
            request.getSession().setAttribute("merchantName", shopName);
            request.getSession().setAttribute("merchantShopName", shopName);
            if (updatedOpenState) {
                request.getSession().setAttribute("merchantIsOpen", isOpen);
            }

            if (updatedStoreInfo && updatedOpenState && updatedMinOrder) {
                request.getSession().setAttribute("successMsg", "Cập nhật hồ sơ cửa hàng thành công!");
            } else if (updatedStoreInfo || updatedOpenState || updatedMinOrder) {
                request.getSession().setAttribute("successMsg", "Đã lưu một phần cài đặt cửa hàng.");
                request.getSession().setAttribute("errorMsg", "Một số trường chưa lưu được do schema DB chưa đầy đủ (is_open/min_order_amount). Vui lòng chạy patch DB mới nhất.");
            } else {
                request.getSession().setAttribute("errorMsg", "Không thể lưu cài đặt cửa hàng. Vui lòng kiểm tra schema DB.");
            }

        } else if ("hours".equals(tab)) {
            String businessHours = request.getParameter("businessHours");
            boolean ok = dao.updateBusinessHours(userId, businessHours);
            if (ok) {
                request.getSession().setAttribute("successMsg", "Đã lưu thiết lập Giờ mở cửa!");
            } else {
                request.getSession().setAttribute("errorMsg", "Không thể lưu giờ mở cửa (có thể DB thiếu cột business_hours).");
            }
        } else if ("security".equals(tab)) {
            // === XỬ LÝ ĐỔI MẬT KHẨU ===
            String currentPw = request.getParameter("currentPw");
            String newPw = request.getParameter("newPw");

            if (currentPw == null || currentPw.trim().isEmpty() || newPw == null || newPw.trim().isEmpty()) {
                request.getSession().setAttribute("errorMsg", "Vui lòng nhập đầy đủ mật khẩu hiện tại và mật khẩu mới.");
                request.getSession().setAttribute("activeTab", tab);
                response.sendRedirect(request.getContextPath() + "/merchant/settings");
                return;
            }

            String currentPwTrimmed = currentPw.trim();
            String newPwTrimmed = newPw.trim();
            if (newPwTrimmed.length() < 6) {
                request.getSession().setAttribute("errorMsg", "Mật khẩu mới phải có ít nhất 6 ký tự.");
                request.getSession().setAttribute("activeTab", tab);
                response.sendRedirect(request.getContextPath() + "/merchant/settings");
                return;
            }
            if (newPwTrimmed.equals(currentPwTrimmed)) {
                request.getSession().setAttribute("errorMsg", "Mật khẩu mới phải khác mật khẩu hiện tại.");
                request.getSession().setAttribute("activeTab", tab);
                response.sendRedirect(request.getContextPath() + "/merchant/settings");
                return;
            }

            // Lấy lại mật khẩu thật từ Database để đối chiếu
            // (Giả sử bạn có UserDAO và hàm getById)
            com.clickeat.dal.impl.UserDAO userDAO = new com.clickeat.dal.impl.UserDAO();
            boolean currentPasswordMatched = userDAO.isSameAsCurrentPassword((int) userId, currentPwTrimmed);

            if (currentPasswordMatched) {
                userDAO.changePassword((int) userId, newPwTrimmed);
                request.getSession().setAttribute("successMsg", "Đổi mật khẩu thành công!");
            } else {
                // Sai mật khẩu cũ
                request.getSession().setAttribute("errorMsg", "Mật khẩu hiện tại không chính xác!");
            }
        } else if ("notify".equals(tab)) {
            String notifyData = request.getParameter("notifyData");
            if (notifyData == null || notifyData.trim().isEmpty()) {
                notifyData = "{}";
            }
            boolean ok = dao.updateNotificationSettings(userId, notifyData);
            if (ok) {
                request.getSession().setAttribute("successMsg", "Đã lưu cài đặt thông báo!");
            } else {
                request.getSession().setAttribute("errorMsg", "Không thể lưu cài đặt thông báo (có thể DB thiếu cột notification_settings).");
            }
        }

        // Lưu lại tab vừa thao tác để trang tự động mở đúng tab
        request.getSession().setAttribute("activeTab", tab);
        response.sendRedirect(request.getContextPath() + "/merchant/settings");
    }
}
