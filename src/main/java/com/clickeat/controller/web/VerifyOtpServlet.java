package com.clickeat.controller.web;

import com.clickeat.util.TwilioVerifyUtil;
import java.io.IOException;
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

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String addressLine = request.getParameter("addressLine");
        String otpCode = request.getParameter("otpCode");

        if (fullName != null) {
            fullName = fullName.trim();
        }
        if (email != null) {
            email = email.trim();
        }
        if (phone != null) {
            phone = phone.trim();
        }
        if (addressLine != null) {
            addressLine = addressLine.trim();
        }
        if (otpCode != null) {
            otpCode = otpCode.trim();
        }

        if (fullName == null || fullName.isBlank()
                || email == null || email.isBlank()
                || phone == null || phone.isBlank()
                || addressLine == null || addressLine.isBlank()
                || otpCode == null || otpCode.isBlank()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin và mã OTP.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("addressLine", addressLine);
            request.setAttribute("otpSent", true);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        String normalizedPhone = TwilioVerifyUtil.normalizePhoneToE164VN(phone);

        if (normalizedPhone == null || normalizedPhone.isBlank() || !normalizedPhone.startsWith("+")) {
            request.setAttribute("error", "Số điện thoại không hợp lệ. Vui lòng nhập đúng định dạng.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("addressLine", addressLine);
            request.setAttribute("otpSent", true);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        boolean approved = TwilioVerifyUtil.verifyOtp(normalizedPhone, otpCode);

        if (!approved) {
            request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("addressLine", addressLine);
            request.setAttribute("otpSent", true);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();

        session.setAttribute("guest_verified", true);
        session.setAttribute("guest_fullName", fullName);
        session.setAttribute("guest_email", email);
        session.setAttribute("guest_phone", phone);
        session.setAttribute("guest_phone_e164", normalizedPhone);
        session.setAttribute("guest_address", addressLine);

        response.sendRedirect(request.getContextPath() + "/checkout");
    }
}
