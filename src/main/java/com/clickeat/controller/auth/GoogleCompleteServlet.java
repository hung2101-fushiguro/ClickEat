package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.regex.Pattern;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

@WebServlet(name = "GoogleCompleteServlet", urlPatterns = {"/google-complete"})
public class GoogleCompleteServlet extends HttpServlet {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^(0[3|5|7|8|9])[0-9]{8}$");
    private static final Pattern NAME_PATTERN = Pattern.compile("^[\\p{L}\\s'.-]{2,100}$");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("GOOGLE_EMAIL") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null
                || session.getAttribute("GOOGLE_EMAIL") == null
                || session.getAttribute("GOOGLE_SUB") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String email = safeTrim((String) session.getAttribute("GOOGLE_EMAIL"));
        String googleName = safeTrim((String) session.getAttribute("GOOGLE_NAME"));
        String sub = safeTrim((String) session.getAttribute("GOOGLE_SUB"));

        String fullName = safeTrim(req.getParameter("full_name"));
        String phone = safeTrim(req.getParameter("phone"));
        String password = safeTrim(req.getParameter("password"));
        String confirmPassword = safeTrim(req.getParameter("confirm_password"));

        String foodPreferences = safeTrim(req.getParameter("food_preferences"));
        String allergies = safeTrim(req.getParameter("allergies"));
        String healthGoal = safeTrim(req.getParameter("health_goal"));
        String calStr = safeTrim(req.getParameter("daily_calorie_target"));

        Integer dailyCal = null;

        if (fullName.isEmpty()) {
            fullName = googleName;
        }

        // -------------------------
        // Validate server-side
        // -------------------------
        if (email.isEmpty() || sub.isEmpty()) {
            req.setAttribute("error", "Phiên đăng nhập Google không hợp lệ. Vui lòng thử lại.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (fullName.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập họ và tên.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!NAME_PATTERN.matcher(fullName).matches()) {
            req.setAttribute("error", "Họ và tên không hợp lệ.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (phone.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập số điện thoại.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!PHONE_PATTERN.matcher(phone).matches()) {
            req.setAttribute("error", "Số điện thoại không đúng định dạng Việt Nam.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (password.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập mật khẩu.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 8 || password.length() > 50) {
            req.setAttribute("error", "Mật khẩu phải từ 8 đến 50 ký tự.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!isStrongPassword(password)) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!healthGoal.isEmpty() && healthGoal.length() > 100) {
            req.setAttribute("error", "Mục tiêu sức khoẻ không được vượt quá 100 ký tự.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!foodPreferences.isEmpty() && foodPreferences.length() > 500) {
            req.setAttribute("error", "Sở thích món ăn không được vượt quá 500 ký tự.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!allergies.isEmpty() && allergies.length() > 300) {
            req.setAttribute("error", "Thông tin dị ứng không được vượt quá 300 ký tự.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        if (!calStr.isEmpty()) {
            try {
                dailyCal = Integer.parseInt(calStr);
                if (dailyCal < 800 || dailyCal > 6000) {
                    req.setAttribute("error", "Calo mục tiêu nên nằm trong khoảng 800 đến 6000.");
                    req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException e) {
                req.setAttribute("error", "Calo mục tiêu không hợp lệ.");
                req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
                return;
            }
        }

        UserDAO dao = new UserDAO();

        if (dao.checkPhoneExist(phone)) {
            req.setAttribute("error", "Số điện thoại đã tồn tại. Vui lòng dùng số khác.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        // Nếu muốn chặn luôn trường hợp email Google đã tồn tại mà chưa link provider
        if (dao.checkEmailExist(email)) {
            req.setAttribute("error", "Email đã tồn tại trong hệ thống.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
            return;
        }

        try {
            String passwordHash = hashPassword(password);

            // Cần sửa UserDAO để nhận passwordHash
            long newUserId = dao.createGoogleUserReturnId(fullName, email, phone, passwordHash);

            dao.createCustomerProfile(newUserId, foodPreferences, allergies, healthGoal, dailyCal);
            dao.linkGoogleProvider((int) newUserId, sub);

            User user = dao.findById((int) newUserId);
            session.setAttribute("account", user);

            session.removeAttribute("GOOGLE_EMAIL");
            session.removeAttribute("GOOGLE_NAME");
            session.removeAttribute("GOOGLE_SUB");

            resp.sendRedirect(req.getContextPath() + "/home");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Không thể hoàn tất hồ sơ. Vui lòng thử lại.");
            req.getRequestDispatcher("/views/web/google-complete.jsp").forward(req, resp);
        }
    }

    private String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isStrongPassword(String password) {
        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;

        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) {
                hasUpper = true;
            } else if (Character.isLowerCase(c)) {
                hasLower = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            }
        }

        return hasUpper && hasLower && hasDigit;
    }

    private String hashPassword(String password) throws Exception {
        byte[] salt = generateSalt();
        byte[] hash = pbkdf2(password.toCharArray(), salt, 65536, 256);

        return Base64.getEncoder().encodeToString(salt) + ":" +
               Base64.getEncoder().encodeToString(hash);
    }

    private byte[] generateSalt() {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        return salt;
    }

    private byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength)
            throws Exception {
        PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
        SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        return skf.generateSecret(spec).getEncoded();
    }
}