package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.UUID;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MerchantRegisterServlet", urlPatterns = {"/merchant/register", "/merchant-register"})
public class MerchantRegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/merchant/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String ownerName = trim(request.getParameter("ownerName"));
        String shopName = trim(request.getParameter("shopName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String shopPhone = trim(request.getParameter("shopPhone"));
        String shopAddress = trim(request.getParameter("shopAddress"));
        String password = trim(request.getParameter("password"));
        String businessType = trim(request.getParameter("businessType"));
        String sourcePlatform = normalizeSourcePlatform(request.getParameter("sourcePlatform"));
        String provinceCode = valueOrDefault(request.getParameter("provinceCode"), "N/A");
        String provinceName = valueOrDefault(request.getParameter("provinceName"), "N/A");
        String districtCode = valueOrDefault(request.getParameter("districtCode"), "N/A");
        String districtName = valueOrDefault(request.getParameter("districtName"), "N/A");
        String wardCode = valueOrDefault(request.getParameter("wardCode"), "N/A");
        String wardName = valueOrDefault(request.getParameter("wardName"), "N/A");
        double latitude = parseDoubleOrDefault(request.getParameter("latitude"), 0.0);
        double longitude = parseDoubleOrDefault(request.getParameter("longitude"), 0.0);
        boolean viaGoogle = "true".equalsIgnoreCase(trim(request.getParameter("viaGoogle")));

        HttpSession session = request.getSession(false);
        String googleSub = "";
        String googleEmail = "";
        String googleName = "";
        if (viaGoogle && session != null) {
            googleSub = trim((String) session.getAttribute("googleSignup_sub"));
            googleEmail = trim((String) session.getAttribute("googleSignup_email"));
            googleName = trim((String) session.getAttribute("googleSignup_name"));
        }

        if (viaGoogle) {
            if (googleSub.isEmpty() || googleEmail.isEmpty()) {
                fail(request, response, "Phiên đăng ký Google không hợp lệ, vui lòng chọn Đăng ký bằng Google lại.");
                return;
            }
            email = googleEmail;
            if (ownerName.isEmpty()) {
                ownerName = googleName;
            }
        }

        if (ownerName.isEmpty() || shopName.isEmpty() || email.isEmpty() || phone.isEmpty() || shopAddress.isEmpty()) {
            fail(request, response, "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            return;
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            fail(request, response, "Email không đúng định dạng.");
            return;
        }
        if (!phone.matches("^0\\d{9,10}$")) {
            fail(request, response, "Số điện thoại không đúng định dạng Việt Nam.");
            return;
        }
        if (shopPhone.isEmpty()) {
            shopPhone = phone;
        }

        if (!viaGoogle && password.length() < 6) {
            fail(request, response, "Mật khẩu phải có ít nhất 6 ký tự.");
            return;
        }
        if (viaGoogle) {
            password = "google_" + UUID.randomUUID();
        }

        UserDAO userDAO = new UserDAO();
        MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();

        if (viaGoogle) {
            User existedBySub = userDAO.findByGoogleSub(googleSub);
            if (existedBySub != null) {
                if (!"MERCHANT".equalsIgnoreCase(existedBySub.getRole())) {
                    fail(request, response, "Google này đã liên kết với tài khoản không phải Merchant.");
                    return;
                }
                fail(request, response, "Google này đã có tài khoản Merchant, vui lòng đăng nhập.");
                return;
            }
        }

        User existedByPhone = userDAO.findByPhoneAnyStatus(phone);
        User existedByEmail = userDAO.findByEmailAnyStatus(email);

        if (existedByPhone != null && existedByEmail != null && existedByPhone.getId() != existedByEmail.getId()) {
            fail(request, response, "Số điện thoại hoặc email đã thuộc về tài khoản khác.");
            return;
        }

        User existedUser = existedByPhone != null ? existedByPhone : existedByEmail;

        if (existedUser != null) {
            if (!"MERCHANT".equalsIgnoreCase(existedUser.getRole())) {
                fail(request, response, "Số điện thoại hoặc email này đã thuộc về tài khoản không phải Merchant.");
                return;
            }

            MerchantProfile existedProfile = merchantProfileDAO.findById(existedUser.getId());
            String profileStatus = existedProfile == null ? "" : trim(existedProfile.getStatus()).toUpperCase();

            if ("APPROVED".equals(profileStatus)) {
                fail(request, response, "Tài khoản Merchant đã được duyệt. Vui lòng đăng nhập.");
                return;
            }
            if ("PENDING".equals(profileStatus)) {
                fail(request, response, "Hồ sơ Merchant đang chờ duyệt, không thể gửi lại lúc này.");
                return;
            }

            String passwordToSave = viaGoogle ? null : password;
            boolean userUpdated = userDAO.reactivateMerchantForReapply(
                    existedUser.getId(), ownerName, email, phone, passwordToSave);
            if (!userUpdated) {
                fail(request, response, "Không thể cập nhật lại hồ sơ Merchant. Vui lòng thử lại.");
                return;
            }

            if (viaGoogle) {
                userDAO.linkGoogleProvider(existedUser.getId(), googleSub);
            }

            MerchantProfile profile = new MerchantProfile();
            profile.setUserId(existedUser.getId());
            profile.setShopName(shopName);
            profile.setShopPhone(shopPhone);
            profile.setShopAddressLine(shopAddress);
            profile.setProvinceCode(provinceCode);
            profile.setProvinceName(provinceName);
            profile.setDistrictCode(districtCode);
            profile.setDistrictName(districtName);
            profile.setWardCode(wardCode);
            profile.setWardName(wardName);
            profile.setLatitude(latitude);
            profile.setLongitude(longitude);
            profile.setStatus("PENDING");
            profile.setSourcePlatform(sourcePlatform.isBlank() ? null : sourcePlatform);
            profile.setNote(buildNote(ownerName, businessType, sourcePlatform));

            boolean profileSaved = existedProfile == null
                    ? merchantProfileDAO.insert(profile) > 0
                    : merchantProfileDAO.update(profile);

            if (!profileSaved) {
                fail(request, response, "Không thể cập nhật hồ sơ cửa hàng. Vui lòng thử lại.");
                return;
            }

            if (session != null) {
                session.removeAttribute("googleSignup_sub");
                session.removeAttribute("googleSignup_email");
                session.removeAttribute("googleSignup_name");
            }

            response.sendRedirect(request.getContextPath() + "/merchant/register?success=true");
            return;
        }

        User merchantUser = new User();
        merchantUser.setFullName(ownerName);
        merchantUser.setEmail(email);
        merchantUser.setPhone(phone);
        merchantUser.setPasswordHash(password);
        merchantUser.setRole("MERCHANT");

        int merchantUserId = userDAO.insert(merchantUser);
        if (merchantUserId <= 0) {
            fail(request, response, "Không thể tạo tài khoản merchant. Vui lòng thử lại.");
            return;
        }

        if (viaGoogle) {
            userDAO.linkGoogleProvider(merchantUserId, googleSub);
        }

        MerchantProfile profile = new MerchantProfile();
        profile.setUserId(merchantUserId);
        profile.setShopName(shopName);
        profile.setShopPhone(shopPhone);
        profile.setShopAddressLine(shopAddress);
        profile.setProvinceCode(provinceCode);
        profile.setProvinceName(provinceName);
        profile.setDistrictCode(districtCode);
        profile.setDistrictName(districtName);
        profile.setWardCode(wardCode);
        profile.setWardName(wardName);
        profile.setLatitude(latitude);
        profile.setLongitude(longitude);
        profile.setStatus("PENDING");
        profile.setSourcePlatform(sourcePlatform.isBlank() ? null : sourcePlatform);
        profile.setNote(buildNote(ownerName, businessType, sourcePlatform));

        int profileInserted = merchantProfileDAO.insert(profile);
        if (profileInserted <= 0) {
            MerchantProfile existedProfile = merchantProfileDAO.findById(merchantUserId);
            if (existedProfile != null) {
                response.sendRedirect(request.getContextPath() + "/merchant/register?success=true");
                return;
            }
            userDAO.deleteHard(merchantUserId);
            fail(request, response, "Không thể tạo hồ sơ cửa hàng. Vui lòng thử lại.");
            return;
        }

        if (session != null) {
            session.removeAttribute("googleSignup_sub");
            session.removeAttribute("googleSignup_email");
            session.removeAttribute("googleSignup_name");
        }

        response.sendRedirect(request.getContextPath() + "/merchant/register?success=true");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String valueOrDefault(String value, String defaultValue) {
        String normalized = trim(value);
        return normalized.isEmpty() ? defaultValue : normalized;
    }

    private double parseDoubleOrDefault(String value, double defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private String normalizeSourcePlatform(String value) {
        String normalized = trim(value).toUpperCase();
        if ("GRABFOOD".equals(normalized) || "SHOPEEFOOD".equals(normalized) || "OTHER".equals(normalized)) {
            return normalized;
        }
        return "";
    }

    private String buildNote(String ownerName, String businessType, String sourcePlatform) {
        String business = businessType.isBlank() ? "N/A" : businessType;
        String platform = sourcePlatform.isBlank() ? "N/A" : sourcePlatform;
        return "owner=" + ownerName + ";businessType=" + business + ";sourcePlatform=" + platform;
    }

    private void fail(HttpServletRequest request, HttpServletResponse response, String msg)
            throws ServletException, IOException {
        request.setAttribute("error", msg);
        request.getRequestDispatcher("/views/merchant/register.jsp").forward(request, response);
    }
}
