package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.UUID;

import com.clickeat.dao.MerchantDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/merchant/register")
public class MerchantRegisterServlet extends HttpServlet {

    private final MerchantDAO merchantDAO = new MerchantDAO();

    // ── GET: show registration form (redirect if already logged in) ──────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("merchantId") != null) {
            resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
            return;
        }
        req.getRequestDispatcher("/views/merchant/register.jsp").forward(req, resp);
    }

    // ── POST: validate fields and create account ─────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // ── Check if registering via Google OAuth ────────────────────────────
        HttpSession httpSession = req.getSession(false);
        String googleSub = (httpSession != null) ? (String) httpSession.getAttribute("googleSignup_sub") : null;
        boolean viaGoogle = "true".equals(req.getParameter("viaGoogle")) && googleSub != null;

        String ownerName = trim(req.getParameter("ownerName"));
        String shopName = trim(req.getParameter("shopName"));
        String email = trim(req.getParameter("email"));
        String phone = trim(req.getParameter("phone"));
        String shopPhone = trim(req.getParameter("shopPhone"));
        String shopAddress = trim(req.getParameter("shopAddress"));
        String password = viaGoogle ? UUID.randomUUID().toString() : req.getParameter("password");

        // ── Validation ───────────────────────────────────────────────────────
        String error = viaGoogle
                ? validateBasic(ownerName, shopName, email, phone, shopAddress)
                : validate(ownerName, shopName, email, phone, password, shopAddress);
        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/views/merchant/register.jsp").forward(req, resp);
            return;
        }

        // Use owner phone as shop phone if the merchant left it blank
        if (shopPhone == null || shopPhone.isEmpty()) {
            shopPhone = phone;
        }

        // ── Create account ───────────────────────────────────────────────────
        try {
            long newUserId = merchantDAO.create(
                    ownerName,
                    email,
                    password,
                    phone,
                    shopName,
                    shopPhone,
                    shopAddress,
                    "", "", // provinceCode, provinceName
                    "", "", // districtCode, districtName
                    "", "" // wardCode, wardName
            );

            // ── Link Google account if registering via Google ────────────────
            if (viaGoogle && httpSession != null) {
                linkGoogleAccount(newUserId, googleSub);
                String picture = (String) httpSession.getAttribute("googleSignup_picture");
                if (picture != null && !picture.isBlank()) {
                    updateAvatar(newUserId, picture);
                }
                httpSession.removeAttribute("googleSignup_sub");
                httpSession.removeAttribute("googleSignup_name");
                httpSession.removeAttribute("googleSignup_email");
                httpSession.removeAttribute("googleSignup_picture");
            }

            resp.sendRedirect(req.getContextPath() + "/merchant/register?success=true");

        } catch (SQLIntegrityConstraintViolationException e) {
            req.setAttribute("error", "Email này đã được đăng ký. Vui lòng dùng email khác hoặc đăng nhập.");
            req.getRequestDispatcher("/views/merchant/register.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("MerchantRegisterServlet: DB error", e);
            req.setAttribute("error", "Đã xảy ra lỗi khi tạo tài khoản. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/views/merchant/register.jsp").forward(req, resp);
        }
    }

    // ── Validate with password (regular sign-up) ─────────────────────────────
    private String validate(String ownerName, String shopName, String email,
            String phone, String password, String shopAddress) {
        String base = validateBasic(ownerName, shopName, email, phone, shopAddress);
        if (base != null) {
            return base;
        }
        if (password == null || password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }
        return null;
    }

    // ── Validate without password (Google sign-up) ───────────────────────────
    private String validateBasic(String ownerName, String shopName, String email,
            String phone, String shopAddress) {
        if (ownerName == null || ownerName.isEmpty()) {
            return "Vui lòng nhập họ tên chủ cửa hàng.";
        }
        if (shopName == null || shopName.isEmpty()) {
            return "Vui lòng nhập tên nhà hàng / quán ăn.";
        }
        if (email == null || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Vui lòng nhập email hợp lệ.";
        }
        if (phone == null || phone.length() < 9) {
            return "Vui lòng nhập số điện thoại hợp lệ.";
        }
        if (shopAddress == null || shopAddress.isEmpty()) {
            return "Vui lòng nhập địa chỉ cửa hàng.";
        }
        return null;
    }

    // ── Link Google sub to user account ─────────────────────────────────────
    private void linkGoogleAccount(long userId, String googleSub) throws SQLException {
        String sql = "INSERT INTO dbo.UserAuthProviders (user_id, provider, provider_user_id) VALUES (?, 'GOOGLE', ?)";
        try (java.sql.Connection c = com.clickeat.config.DataSourceConfig.getConnection(); java.sql.PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, googleSub);
            ps.executeUpdate();
        }
    }

    // ── Update merchant avatar from Google profile picture ───────────────────
    private void updateAvatar(long userId, String pictureUrl) {
        String sql = "UPDATE dbo.MerchantProfiles SET avatar_url = ? WHERE user_id = ?";
        try (java.sql.Connection c = com.clickeat.config.DataSourceConfig.getConnection(); java.sql.PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, pictureUrl);
            ps.setLong(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            getServletContext().log("Failed to update avatar for userId=" + userId, e);
        }
    }

    private String trim(String s) {
        return s != null ? s.trim() : null;
    }
}
