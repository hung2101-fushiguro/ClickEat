package com.clickeat.controller.web;

import com.clickeat.util.VonageVerifyUtil;
import com.clickeat.util.VonageVerifyUtil.SendOtpResult;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "SendOtpServlet", urlPatterns = {"/guest-send-otp"})
public class SendOtpServlet extends HttpServlet {

    private static final long OTP_EXPIRE_MILLIS = 2 * 60 * 1000; // 2 phút
    private static final long RESEND_COOLDOWN_MILLIS = 10 * 1000; // 10 giây

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String addressLine = trim(request.getParameter("addressLine"));

        if (isBlank(fullName) || isBlank(email) || isBlank(phone) || isBlank(addressLine)) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin trước khi gửi mã OTP.");
            refillRequest(request, fullName, email, phone, addressLine);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("error", "Email không hợp lệ.");
            refillRequest(request, fullName, email, phone, addressLine);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        String normalizedPhone = VonageVerifyUtil.normalizePhoneToE164VN(phone);

        if (normalizedPhone == null
                || normalizedPhone.isBlank()
                || !normalizedPhone.matches("^\\+[1-9]\\d{8,14}$")) {

            request.setAttribute("error", "Số điện thoại không hợp lệ. Vui lòng nhập đúng số di động.");
            refillRequest(request, fullName, email, phone, addressLine);
            request.setAttribute("normalizedPhone", normalizedPhone);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();

        Long lastSentAt = (Long) session.getAttribute("guestOtpLastSentAt");
        long now = System.currentTimeMillis();

        if (lastSentAt != null && now - lastSentAt < RESEND_COOLDOWN_MILLIS) {
            long remainMillis = RESEND_COOLDOWN_MILLIS - (now - lastSentAt);
            long remainSeconds = (long) Math.ceil(remainMillis / 1000.0);

            request.setAttribute("error", "Bạn vừa yêu cầu mã OTP. Vui lòng chờ " + remainSeconds + " giây rồi thử lại.");
            refillRequest(request, fullName, email, phone, addressLine);

            Long expiresAt = (Long) session.getAttribute("guestOtpExpiresAt");
            if (expiresAt != null && expiresAt > now) {
                request.setAttribute("otpSent", true);
                request.setAttribute("otpExpiresAt", expiresAt);
            }

            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        SendOtpResult result = VonageVerifyUtil.sendOtp(normalizedPhone);

        refillRequest(request, fullName, email, phone, addressLine);
        request.setAttribute("normalizedPhone", normalizedPhone);

        if (result.isSuccess()) {
            long expiresAt = now + OTP_EXPIRE_MILLIS;

            session.setAttribute("guestPhoneE164", normalizedPhone);
            session.setAttribute("guestVerifyRequestId", result.getRequestId());
            session.setAttribute("guestOtpExpiresAt", expiresAt);
            session.setAttribute("guestOtpLastSentAt", now);

            // lưu trước dữ liệu guest để sang bước verify / checkout dùng luôn
            session.setAttribute("guestFullName", fullName);
            session.setAttribute("guestEmail", email);
            session.setAttribute("guestPhone", phone);
            session.setAttribute("guestAddress", addressLine);

            request.setAttribute("otpSent", true);
            request.setAttribute("otpExpiresAt", expiresAt);
            request.setAttribute("message", "Mã OTP đã được gửi đến số điện thoại của bạn.");
        } else {
            request.setAttribute("error", "Không thể gửi OTP.");
            request.setAttribute("debugError", result.getErrorMessage());
        }

        request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
    }

    private void refillRequest(HttpServletRequest request, String fullName, String email, String phone, String addressLine) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("addressLine", addressLine);
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
