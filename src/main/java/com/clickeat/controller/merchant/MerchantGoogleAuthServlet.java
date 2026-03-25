package com.clickeat.controller.merchant;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MerchantGoogleAuthServlet", urlPatterns = {"/merchant/auth/google"})
public class MerchantGoogleAuthServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String mode = trim(request.getParameter("mode")).toLowerCase();
        if (!"login".equals(mode)) {
            mode = "register";
        }

        String credential = request.getParameter("credential");
        if (credential == null || credential.isBlank()) {
            request.getSession(true).setAttribute("googleError", "Không nhận được thông tin đăng nhập Google.");
            response.sendRedirect(request.getContextPath() + ("login".equals(mode) ? "/login" : "/merchant/register"));
            return;
        }

        try {
            String[] parts = credential.split("\\.");
            if (parts.length < 2) {
                throw new IllegalArgumentException("Invalid JWT format");
            }

            byte[] payloadBytes = Base64.getUrlDecoder().decode(parts[1]);
            String payload = new String(payloadBytes, StandardCharsets.UTF_8);

            String sub = extractJsonString(payload, "sub");
            String email = extractJsonString(payload, "email");
            String name = extractJsonString(payload, "name");

            if (sub == null || sub.isBlank() || email == null || email.isBlank()) {
                throw new IllegalArgumentException("Missing required Google fields");
            }

            UserDAO userDAO = new UserDAO();
            HttpSession session = request.getSession(true);

            User existedBySub = userDAO.findByGoogleSub(sub);
            if (existedBySub != null) {
                if (!"MERCHANT".equalsIgnoreCase(existedBySub.getRole())) {
                    session.setAttribute("googleError", "Google này đã liên kết với tài khoản không phải Merchant.");
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                if ("INACTIVE".equalsIgnoreCase(existedBySub.getStatus())) {
                    session.setAttribute("googleError", "Tài khoản Merchant đang bị khóa hoặc vô hiệu hóa.");
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                session.setAttribute("account", existedBySub);
                session.removeAttribute("googleError");
                response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
                return;
            }

            if ("login".equals(mode)) {
                User existedByEmail = userDAO.findByEmail(email);
                if (existedByEmail != null) {
                    if (!"MERCHANT".equalsIgnoreCase(existedByEmail.getRole())) {
                        session.setAttribute("googleError", "Email Google này đã có tài khoản nhưng không phải Merchant.");
                        response.sendRedirect(request.getContextPath() + "/login");
                        return;
                    }

                    userDAO.linkGoogleProvider(existedByEmail.getId(), sub);
                    session.setAttribute("account", existedByEmail);
                    session.removeAttribute("googleError");
                    response.sendRedirect(request.getContextPath() + "/merchant/dashboard");
                    return;
                }

                session.setAttribute("googleError", "Chưa có tài khoản Merchant cho Google này. Vui lòng đăng ký trước.");
            }

            session.setAttribute("googleSignup_sub", sub);
            session.setAttribute("googleSignup_email", email);
            session.setAttribute("googleSignup_name", name == null ? "" : name);
            if (!"login".equals(mode)) {
                session.removeAttribute("googleError");
            }

            response.sendRedirect(request.getContextPath() + "/merchant/register");
        } catch (Exception ex) {
            request.getSession(true).setAttribute("googleError", "Không thể xác thực Google. Vui lòng thử lại.");
            response.sendRedirect(request.getContextPath() + ("login".equals(mode) ? "/login" : "/merchant/register"));
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String extractJsonString(String json, String key) {
        String pattern = "\"" + key + "\"";
        int keyPos = json.indexOf(pattern);
        if (keyPos < 0) {
            return null;
        }

        int colonPos = json.indexOf(':', keyPos + pattern.length());
        if (colonPos < 0) {
            return null;
        }

        int firstQuote = json.indexOf('"', colonPos + 1);
        if (firstQuote < 0) {
            return null;
        }

        int secondQuote = json.indexOf('"', firstQuote + 1);
        if (secondQuote < 0) {
            return null;
        }

        return json.substring(firstQuote + 1, secondQuote);
    }
}
