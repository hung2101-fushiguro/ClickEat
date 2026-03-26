package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

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
        request.setAttribute("activeTab", request.getSession().getAttribute("activeTab"));

        request.getSession().removeAttribute("successMsg");
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

            if (current != null) {
                current.setShopName(shopName);
                current.setShopPhone(shopPhone);
                current.setShopAddressLine(shopAddress);
                current.setShopAvatar(finalAvatar);
                current.setMinOrderAmount(minOrderAmount);
                current.setIsOpen(isOpen);
                dao.update(current);
            }

            // Cập nhật lại tên hiển thị trên Sidebar (nếu có lưu trên Session)
            request.getSession().setAttribute("merchantName", shopName);
            request.getSession().setAttribute("merchantShopName", shopName);
            request.getSession().setAttribute("merchantIsOpen", isOpen);
            request.getSession().setAttribute("successMsg", "Cập nhật hồ sơ cửa hàng thành công!");

        } else if ("hours".equals(tab)) {
            String businessHours = request.getParameter("businessHours");
            MerchantProfile current = dao.findById((int) userId);
            if (current != null) {
                current.setBusinessHours(businessHours);
                dao.update(current);
            }
            request.getSession().setAttribute("successMsg", "Đã lưu thiết lập Giờ mở cửa!");
        } else if ("security".equals(tab)) {
            // === XỬ LÝ ĐỔI MẬT KHẨU ===
            String currentPw = request.getParameter("currentPw");
            String newPw = request.getParameter("newPw");

            // Lấy lại mật khẩu thật từ Database để đối chiếu
            // (Giả sử bạn có UserDAO và hàm getById)
            com.clickeat.dal.impl.UserDAO userDAO = new com.clickeat.dal.impl.UserDAO();
            User currentUserInfo = userDAO.findById((int) userId);

            if (currentUserInfo != null && currentUserInfo.getPasswordHash().equals(currentPw)) {
                // Mật khẩu cũ khớp -> Cho phép đổi sang mật khẩu mới
                userDAO.changePassword((int) userId, newPw); // Cần đảm bảo UserDAO của bạn có hàm này
                request.getSession().setAttribute("successMsg", "Đổi mật khẩu thành công!");
            } else {
                // Sai mật khẩu cũ
                request.getSession().setAttribute("errorMsg", "Mật khẩu hiện tại không chính xác!");
            }
        } else if ("notify".equals(tab)) {
            String notifyData = request.getParameter("notifyData");
            MerchantProfile current = dao.findById((int) userId);
            if (current != null) {
                current.setNotificationSettings(notifyData);
                dao.update(current);
            }
            request.getSession().setAttribute("successMsg", "Đã lưu cài đặt thông báo!");
        }

        // Lưu lại tab vừa thao tác để trang tự động mở đúng tab
        request.getSession().setAttribute("activeTab", tab);
        response.sendRedirect(request.getContextPath() + "/merchant/settings");
    }
}
