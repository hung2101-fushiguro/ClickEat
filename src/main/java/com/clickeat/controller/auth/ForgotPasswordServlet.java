package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import com.clickeat.util.MailUtil;
import com.clickeat.util.PasswordUtil;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private static final String SESSION_RESET_EMAIL = "fp_email";
    private static final String SESSION_RESET_OTP_HASH = "fp_otp_hash";
    private static final String SESSION_RESET_EXPIRES_AT = "fp_expires_at";
    private static final String SESSION_RESET_VERIFIED = "fp_verified";
    private static final int OTP_LIFETIME_SECONDS = 60;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        syncStepState(request);
        request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = trim(request.getParameter("action"));
        if (action == null) {
            action = "send-code";
        }

        switch (action) {
            case "send-code":
                handleSendCode(request, response);
                break;
            case "verify-code":
                handleVerifyCode(request, response);
                break;
            case "save-password":
                handleSavePassword(request, response);
                break;
            default:
                clearResetSession(request.getSession(false));
                request.setAttribute("error", "Yeu cau khong hop le.");
                request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
        }
    }

    private void handleSendCode(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            clearResetSession(oldSession);
        }

        String email = trim(request.getParameter("email"));
        request.setAttribute("email", email);

        if (isBlank(email) || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("error", "Dia chi email khong hop le.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByEmail(email);

        if (user == null) {
            request.setAttribute("error", "Email nay khong ton tai hoac tai khoan khong hoat dong.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        String otp = generateOtp();
        String otpHash = sha256Base64(otp);
        long expiresAt = System.currentTimeMillis() + (OTP_LIFETIME_SECONDS * 1000L);

        try {
            MailUtil.sendOtpMail(email, user.getFullName(), otp);

            HttpSession session = request.getSession(true);
            session.setAttribute(SESSION_RESET_EMAIL, email);
            session.setAttribute(SESSION_RESET_OTP_HASH, otpHash);
            session.setAttribute(SESSION_RESET_EXPIRES_AT, expiresAt);
            session.setAttribute(SESSION_RESET_VERIFIED, false);

            request.setAttribute("email", email);
            request.setAttribute("success", "Ma xac minh da duoc gui den email cua ban.");
            request.setAttribute("showVerifySection", true);
            request.setAttribute("expiresAt", expiresAt);
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("=== FORGOT PASSWORD SEND MAIL ERROR START ===");
            e.printStackTrace();
            System.out.println("=== FORGOT PASSWORD SEND MAIL ERROR END ===");

            HttpSession session = request.getSession(false);
            if (session != null) {
                clearResetSession(session);
            }

            request.setAttribute("email", email);
            request.setAttribute("error", "Khong the gui email luc nay. Vui long thu lai sau.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
        }
    }

    private void handleVerifyCode(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            request.setAttribute("error", "Phien khoi phuc da het. Vui long gui lai ma moi.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        String email = (String) session.getAttribute(SESSION_RESET_EMAIL);
        String expectedHash = (String) session.getAttribute(SESSION_RESET_OTP_HASH);
        Long expiresAt = (Long) session.getAttribute(SESSION_RESET_EXPIRES_AT);

        request.setAttribute("email", email);

        if (isBlank(email) || isBlank(expectedHash) || expiresAt == null) {
            clearResetSession(session);
            request.setAttribute("error", "Phien khoi phuc da het. Vui long gui lai ma moi.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        if (System.currentTimeMillis() > expiresAt) {
            clearResetSession(session);
            request.setAttribute("error", "Ma xac minh da het han. Vui long gui lai ma moi.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        String otpCode = normalizeOtp(request.getParameter("otpCode"));

        if (isBlank(otpCode) || !otpCode.matches("^\\d{6}$")) {
            request.setAttribute("error", "Ma xac minh phai gom dung 6 chu so.");
            request.setAttribute("showVerifySection", true);
            request.setAttribute("expiresAt", expiresAt);
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        String actualHash = sha256Base64(otpCode);
        if (!MessageDigest.isEqual(
                expectedHash.getBytes(StandardCharsets.UTF_8),
                actualHash.getBytes(StandardCharsets.UTF_8))) {

            request.setAttribute("error", "Ma xac minh khong dung.");
            request.setAttribute("showVerifySection", true);
            request.setAttribute("expiresAt", expiresAt);
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        session.setAttribute(SESSION_RESET_VERIFIED, true);

        request.setAttribute("email", email);
        request.setAttribute("success", "Xac minh thanh cong. Vui long nhap mat khau moi.");
        request.setAttribute("showVerifySection", true);
        request.setAttribute("showResetSection", true);
        request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
    }

    private void handleSavePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            request.setAttribute("error", "Phien khoi phuc da het. Vui long thuc hien lai.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        String email = (String) session.getAttribute(SESSION_RESET_EMAIL);
        Boolean verified = (Boolean) session.getAttribute(SESSION_RESET_VERIFIED);

        request.setAttribute("email", email);
        request.setAttribute("showVerifySection", true);
        request.setAttribute("showResetSection", true);

        if (isBlank(email) || verified == null || !verified) {
            clearResetSession(session);
            request.setAttribute("error", "Ban chua xac minh ma OTP hop le.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (isBlank(newPassword) || newPassword.length() < 6 || newPassword.length() > 100) {
            request.setAttribute("error", "Mat khau moi phai tu 6 den 100 ky tu.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Xac nhan mat khau khong khop.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByEmail(email);

        if (user == null) {
            clearResetSession(session);
            request.setAttribute("error", "Khong tim thay tai khoan de cap nhat.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        if (userDAO.isSameAsCurrentPassword(user.getId(), newPassword)) {
            request.setAttribute("error", "Mat khau moi khong duoc trung voi mat khau cu.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        String passwordHash = PasswordUtil.hashPassword(newPassword);
        boolean ok = userDAO.changePassword(user.getId(), passwordHash);

        if (!ok) {
            request.setAttribute("error", "Khong the luu mat khau moi. Vui long thu lai.");
            request.getRequestDispatcher("/views/web/forgot-password.jsp").forward(request, response);
            return;
        }

        clearResetSession(session);
        request.getSession().setAttribute("toastMsg", "Dat lai mat khau thanh cong. Vui long dang nhap lai.");
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void syncStepState(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }

        String email = (String) session.getAttribute(SESSION_RESET_EMAIL);
        Long expiresAt = (Long) session.getAttribute(SESSION_RESET_EXPIRES_AT);
        Boolean verified = (Boolean) session.getAttribute(SESSION_RESET_VERIFIED);

        if (!isBlank(email)) {
            request.setAttribute("email", email);
        }

        if (verified != null && verified) {
            request.setAttribute("showVerifySection", true);
            request.setAttribute("showResetSection", true);
            return;
        }

        if (expiresAt != null && System.currentTimeMillis() <= expiresAt) {
            request.setAttribute("showVerifySection", true);
            request.setAttribute("expiresAt", expiresAt);
        }
    }

    private void clearResetSession(HttpSession session) {
        if (session == null) {
            return;
        }
        session.removeAttribute(SESSION_RESET_EMAIL);
        session.removeAttribute(SESSION_RESET_OTP_HASH);
        session.removeAttribute(SESSION_RESET_EXPIRES_AT);
        session.removeAttribute(SESSION_RESET_VERIFIED);
    }

    private String generateOtp() {
        int otp = 100000 + new SecureRandom().nextInt(900000);
        return String.valueOf(otp);
    }

    private String sha256Base64(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new IllegalStateException("Cannot hash otp", e);
        }
    }

    private String normalizeOtp(String s) {
        if (s == null) {
            return null;
        }
        return s.replaceAll("\\D", "");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
