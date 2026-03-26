package com.clickeat.controller.web;

import java.io.IOException;

import com.clickeat.util.TwilioVerifyUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "SendOtpServlet", urlPatterns = {"/guest-send-otp"})
public class SendOtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String addressLine = request.getParameter("addressLine");
        String shippingLat = request.getParameter("shippingLat");
        String shippingLng = request.getParameter("shippingLng");

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
        if (shippingLat != null) {
            shippingLat = shippingLat.trim();
        }
        if (shippingLng != null) {
            shippingLng = shippingLng.trim();
        }

        if (fullName == null || fullName.isBlank()
                || email == null || email.isBlank()
                || phone == null || phone.isBlank()
                || addressLine == null || addressLine.isBlank()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin trước khi gửi mã OTP.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("addressLine", addressLine);
            request.setAttribute("shippingLat", shippingLat);
            request.setAttribute("shippingLng", shippingLng);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        String normalizedPhone = TwilioVerifyUtil.normalizePhoneToE164VN(phone);

        if (normalizedPhone == null
                || normalizedPhone.isBlank()
                || !normalizedPhone.matches("^\\+[1-9]\\d{8,14}$")) {

            request.setAttribute("error", "Số điện thoại không hợp lệ. Vui lòng nhập đúng số di động Việt Nam.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("addressLine", addressLine);
            request.setAttribute("shippingLat", shippingLat);
            request.setAttribute("shippingLng", shippingLng);
            request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
            return;
        }

        boolean sent = TwilioVerifyUtil.sendOtp(normalizedPhone);

        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("addressLine", addressLine);
        request.setAttribute("shippingLat", shippingLat);
        request.setAttribute("shippingLng", shippingLng);
        request.setAttribute("otpSent", sent);

        if (sent) {
            HttpSession session = request.getSession();
            session.setAttribute("guest_verified", false);
            session.setAttribute("guest_phone_e164", normalizedPhone);
            session.removeAttribute("guest_fullName");
            session.removeAttribute("guest_email");
            session.removeAttribute("guest_phone");
            session.removeAttribute("guest_address");
            session.removeAttribute("guest_latitude");
            session.removeAttribute("guest_longitude");

            request.setAttribute("message", "Mã OTP đã được gửi đến số điện thoại của bạn.");
        } else {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.removeAttribute("guest_phone_e164");
            }
            String twilioError = TwilioVerifyUtil.getLastError();
            if (twilioError == null || twilioError.isBlank()) {
                twilioError = "Không thể gửi OTP. Hãy kiểm tra Verify Service SID, số trial đã verify và số điện thoại định dạng +84.";
            }
            request.setAttribute("error", twilioError);
        }

        request.getRequestDispatcher("/views/web/guest-checkout.jsp").forward(request, response);
    }
}
