package com.clickeat.controller.web;

import com.clickeat.util.VonageVerifyUtil;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "VerifyOtpServlet", urlPatterns = {"/guest-verify-otp"})
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        PrintWriter out = response.getWriter();

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String addressLine = trim(request.getParameter("addressLine"));
        String otpCode = trim(request.getParameter("otpCode"));

        // fallback từ session nếu hidden input bị rỗng
        if (isBlank(fullName)) {
            fullName = stringSession(session, "guestFullName");
        }
        if (isBlank(email)) {
            email = stringSession(session, "guestEmail");
        }
        if (isBlank(phone)) {
            phone = stringSession(session, "guestPhone");
        }
        if (isBlank(addressLine)) {
            addressLine = stringSession(session, "guestAddress");
        }

        if (isBlank(fullName) || isBlank(email) || isBlank(phone) || isBlank(addressLine)) {
            out.print("{\"success\":false,\"message\":\"Thông tin giao hàng không hợp lệ. Vui lòng nhập lại.\"}");
            return;
        }

        if (isBlank(otpCode)) {
            out.print("{\"success\":false,\"message\":\"Vui lòng nhập mã OTP.\"}");
            return;
        }

        if (!otpCode.matches("^\\d{6}$")) {
            out.print("{\"success\":false,\"message\":\"Mã OTP phải gồm đúng 6 chữ số.\"}");
            return;
        }

        String normalizedPhone = VonageVerifyUtil.normalizePhoneToE164VN(phone);

        if (normalizedPhone == null
                || normalizedPhone.isBlank()
                || !normalizedPhone.matches("^\\+[1-9]\\d{8,14}$")) {
            out.print("{\"success\":false,\"message\":\"Số điện thoại không hợp lệ.\"}");
            return;
        }

        String requestId = (String) session.getAttribute("guestVerifyRequestId");
        Long expiresAt = (Long) session.getAttribute("guestOtpExpiresAt");
        long now = System.currentTimeMillis();

        if (requestId == null || requestId.isBlank() || expiresAt == null) {
            out.print("{\"success\":false,\"expired\":true,\"message\":\"Phiên xác thực OTP không tồn tại. Vui lòng gửi lại mã.\"}");
            return;
        }

        if (now > expiresAt) {
            session.removeAttribute("guestVerifyRequestId");
            session.removeAttribute("guestOtpExpiresAt");
            out.print("{\"success\":false,\"expired\":true,\"message\":\"Mã OTP đã hết hạn. Vui lòng bấm Gửi lại mã OTP.\"}");
            return;
        }

        boolean approved = VonageVerifyUtil.verifyOtp(requestId, otpCode);

        if (!approved) {
            out.print("{\"success\":false,\"message\":\"Mã OTP không chính xác hoặc không hợp lệ.\"}");
            return;
        }

        session.setAttribute("guestVerified", true);
        session.setAttribute("guestFullName", fullName);
        session.setAttribute("guestEmail", email);
        session.setAttribute("guestPhone", phone);
        session.setAttribute("guestPhoneE164", normalizedPhone);
        session.setAttribute("guestAddress", addressLine);

        session.removeAttribute("guestVerifyRequestId");
        session.removeAttribute("guestOtpExpiresAt");

        out.print("{\"success\":true,\"redirect\":\"" + request.getContextPath() + "/checkout\"}");
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private String stringSession(HttpSession session, String key) {
        Object value = session.getAttribute(key);
        return value == null ? "" : value.toString();
    }
}
