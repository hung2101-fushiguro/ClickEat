package com.clickeat.controller.merchant;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.clickeat.config.DataSourceConfig;
import com.clickeat.dao.MerchantDAO;
import com.clickeat.model.Merchant;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Handles "Sign in with Google" for the merchant portal.
 *
 * Flow: 1. GIS (Google Identity Services) returns a credential (JWT ID token)
 * via JS callback. 2. JS submits that credential as a POST to this servlet. 3.
 * Servlet verifies the token, looks up (or creates) the merchant account, then
 * sets session and redirects to the dashboard.
 *
 * Configuration: Set the Google Client ID in web.xml context-param
 * "google.client.id".
 */
@WebServlet("/merchant/auth/google")
public class GoogleAuthServlet extends HttpServlet {

    private static final Logger log = Logger.getLogger(GoogleAuthServlet.class.getName());

    private final MerchantDAO merchantDAO = new MerchantDAO();

    // ── POST: receive credential from GIS callback ───────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String credential = req.getParameter("credential");
        if (credential == null || credential.isBlank()) {
            redirectWithError(req, resp, "Không nhận được thông tin xác thực từ Google.");
            return;
        }

        String clientId = getServletContext().getInitParameter("google.client.id");
        if (clientId == null || clientId.isBlank() || clientId.startsWith("YOUR_")) {
            log.severe("google.client.id is not configured in web.xml");
            redirectWithError(req, resp, "Google Sign-In chưa được cấu hình. Vui lòng liên hệ quản trị viên.");
            return;
        }

        // ── Verify the ID token ──────────────────────────────────────────────
        GoogleIdToken idToken;
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(clientId))
                    .build();
            idToken = verifier.verify(credential);
        } catch (GeneralSecurityException | IOException e) {
            log.log(Level.WARNING, "Google ID token verification failed", e);
            redirectWithError(req, resp, "Xác thực Google thất bại. Vui lòng thử lại.");
            return;
        }

        if (idToken == null) {
            redirectWithError(req, resp, "Mã xác thực Google không hợp lệ hoặc đã hết hạn.");
            return;
        }

        Payload payload = idToken.getPayload();
        String googleSub = payload.getSubject();          // unique Google user ID
        String email = payload.getEmail();
        String name = (String) payload.get("name");
        String picture = (String) payload.get("picture");

        if (name == null || name.isBlank()) {
            name = email.split("@")[0];
        }

        // ── Find existing merchant by Google provider link ───────────────────
        try {
            Long userId = findUserIdByGoogleSub(googleSub);

            if (userId != null) {
                // Existing Google-linked account → log in
                logInByUserId(userId, req, resp);
                return;
            }

            // ── Try to find by email ─────────────────────────────────────────
            Optional<Merchant> existing = merchantDAO.findByEmail(email);

            if (existing.isPresent()) {
                Merchant merchant = existing.get();
                // Link this Google account to the existing merchant
                linkGoogleAccount(merchant.getUserId(), googleSub);
                createSession(req, merchant);
                resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
                return;
            }

            // ── New user: redirect to registration form with Google pre-fill ─
            HttpSession newSession = req.getSession(true);
            newSession.setAttribute("googleSignup_sub", googleSub);
            newSession.setAttribute("googleSignup_name", name);
            newSession.setAttribute("googleSignup_email", email);
            newSession.setAttribute("googleSignup_picture", picture != null ? picture : "");
            resp.sendRedirect(req.getContextPath() + "/merchant/register");

        } catch (SQLException e) {
            log.log(Level.SEVERE, "DB error during Google auth", e);
            redirectWithError(req, resp, "Đã xảy ra lỗi máy chủ. Vui lòng thử lại sau.");
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    /**
     * Look up user_id from UserAuthProviders by Google sub.
     */
    private Long findUserIdByGoogleSub(String googleSub) throws SQLException {
        String sql = "SELECT user_id FROM dbo.UserAuthProviders WHERE provider = 'GOOGLE' AND provider_user_id = ?";
        try (Connection c = DataSourceConfig.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, googleSub);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    /**
     * Insert a row into UserAuthProviders so future logins skip email lookup.
     */
    private void linkGoogleAccount(long userId, String googleSub) throws SQLException {
        String sql = "INSERT INTO dbo.UserAuthProviders (user_id, provider, provider_user_id) VALUES (?, 'GOOGLE', ?)";
        try (Connection c = DataSourceConfig.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, googleSub);
            ps.executeUpdate();
        }
    }

    /**
     * Update the merchant's avatar URL from their Google profile picture.
     */
    private void updateAvatar(long userId, String pictureUrl) {
        String sql = "UPDATE dbo.MerchantProfiles SET avatar_url = ? WHERE user_id = ?";
        try (Connection c = DataSourceConfig.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, pictureUrl);
            ps.setLong(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            log.log(Level.WARNING, "Failed to update avatar for userId=" + userId, e);
        }
    }

    /**
     * Load merchant by userId, set session, redirect to dashboard.
     */
    private void logInByUserId(long userId, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        Optional<Merchant> opt = merchantDAO.findById(userId);
        if (opt.isEmpty()) {
            redirectWithError(req, resp, "Không tìm thấy tài khoản. Vui lòng thử lại.");
            return;
        }
        createSession(req, opt.get());
        resp.sendRedirect(req.getContextPath() + "/merchant/dashboard");
    }

    /**
     * Create HTTP session with merchant identity attributes.
     */
    private void createSession(HttpServletRequest req, Merchant merchant) {
        HttpSession session = req.getSession(true);
        session.setAttribute("merchantId", merchant.getUserId());
        session.setAttribute("merchantName", merchant.getFullName());
        session.setAttribute("shopStatus", merchant.getShopStatus());
    }

    /**
     * Redirect back to login page with an error message.
     */
    private void redirectWithError(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException {
        String referer = req.getHeader("Referer");
        String target = (referer != null && referer.contains("/register"))
                ? req.getContextPath() + "/merchant/register"
                : req.getContextPath() + "/merchant/login";
        try {
            req.getSession(true).setAttribute("googleError", msg);
        } catch (Exception ignored) {
        }
        resp.sendRedirect(target);
    }
}
