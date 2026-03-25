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

@WebServlet(name = "MerchantRegisterServlet", urlPatterns = {"/merchant-register"})
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

        if (userDAO.checkPhoneExist(phone)) {
            fail(request, response, "Số điện thoại đã tồn tại.");
            return;
        }
        if (userDAO.checkEmailExist(email)) {
            fail(request, response, "Email đã tồn tại.");
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
        profile.setProvinceCode("N/A");
        profile.setProvinceName("N/A");
        profile.setDistrictCode("N/A");
        profile.setDistrictName("N/A");
        profile.setWardCode("N/A");
        profile.setWardName("N/A");
        profile.setLatitude(latitude);
        profile.setLongitude(longitude);
        profile.setStatus("PENDING");
        profile.setSourcePlatform(sourcePlatform);
        profile.setNote(buildNote(ownerName, businessType, sourcePlatform));

        MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();
        int profileInserted = merchantProfileDAO.insert(profile);
        if (profileInserted <= 0) {
            userDAO.delete(merchantUserId);
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
        return "NONE";
    }

    private String buildNote(String ownerName, String businessType, String sourcePlatform) {
        String business = businessType.isBlank() ? "N/A" : businessType;
        return "owner=" + ownerName + ";businessType=" + business + ";sourcePlatform=" + sourcePlatform;
    }

    private void fail(HttpServletRequest request, HttpServletResponse response, String msg)
            throws ServletException, IOException {
        request.setAttribute("error", msg);
        request.getRequestDispatcher("/views/merchant/register.jsp").forward(request, response);
    }
}
