package com.clickeat.util;

import com.clickeat.model.User;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public final class RememberMeUtil {

    public static final String COOKIE_NAME = "CLICKEAT_REMEMBER";
    private static final int COOKIE_MAX_AGE = 60 * 60 * 24 * 30;

    private static final String DEFAULT_SECRET =
            "ClickEat_RememberMe_Secret_2026_ChangeThis_WhenDeploying";

    private RememberMeUtil() {
    }

    public record RememberedLogin(int userId, long expiresAt, String signature) {
    }

    public static void createRememberMeCookie(HttpServletRequest request,
                                              HttpServletResponse response,
                                              User user) {
        long expiresAt = System.currentTimeMillis() + (COOKIE_MAX_AGE * 1000L);
        String signature = sign(user, expiresAt);
        String rawToken = user.getId() + ":" + expiresAt + ":" + signature;
        String encodedToken = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(rawToken.getBytes(StandardCharsets.UTF_8));

        Cookie cookie = new Cookie(COOKIE_NAME, encodedToken);
        cookie.setHttpOnly(true);
        cookie.setMaxAge(COOKIE_MAX_AGE);
        cookie.setPath(getCookiePath(request));
        cookie.setSecure(request.isSecure());

        response.addHeader("Set-Cookie",
                buildSetCookieHeader(cookie, "Lax"));
    }

    public static void clearRememberMeCookie(HttpServletRequest request,
                                             HttpServletResponse response) {
        Cookie cookie = new Cookie(COOKIE_NAME, "");
        cookie.setHttpOnly(true);
        cookie.setMaxAge(0);
        cookie.setPath(getCookiePath(request));
        cookie.setSecure(request.isSecure());

        response.addHeader("Set-Cookie",
                buildSetCookieHeader(cookie, "Lax"));
    }

    public static RememberedLogin parseAndValidate(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null || cookies.length == 0) {
            return null;
        }

        for (Cookie cookie : cookies) {
            if (!COOKIE_NAME.equals(cookie.getName())) {
                continue;
            }

            try {
                String decoded = new String(
                        Base64.getUrlDecoder().decode(cookie.getValue()),
                        StandardCharsets.UTF_8
                );

                String[] parts = decoded.split(":");
                if (parts.length != 3) {
                    return null;
                }

                int userId = Integer.parseInt(parts[0]);
                long expiresAt = Long.parseLong(parts[1]);
                String signature = parts[2];

                if (System.currentTimeMillis() > expiresAt) {
                    return null;
                }

                return new RememberedLogin(userId, expiresAt, signature);
            } catch (Exception e) {
                return null;
            }
        }

        return null;
    }

    public static boolean isSignatureValid(RememberedLogin rememberedLogin, User user) {
        if (rememberedLogin == null || user == null) {
            return false;
        }

        String expected = sign(user, rememberedLogin.expiresAt());
        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                rememberedLogin.signature().getBytes(StandardCharsets.UTF_8)
        );
    }

    private static String sign(User user, long expiresAt) {
        try {
            String payload = user.getId()
                    + "|"
                    + safe(user.getEmail())
                    + "|"
                    + safe(user.getPhone())
                    + "|"
                    + safe(user.getPasswordHash())
                    + "|"
                    + safe(user.getRole())
                    + "|"
                    + safe(user.getStatus())
                    + "|"
                    + expiresAt;

            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec keySpec = new SecretKeySpec(
                    getSecret().getBytes(StandardCharsets.UTF_8),
                    "HmacSHA256"
            );
            mac.init(keySpec);
            byte[] signatureBytes = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));

            return Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(signatureBytes);
        } catch (Exception e) {
            throw new IllegalStateException("Cannot sign remember-me token", e);
        }
    }

    private static String getSecret() {
        String env = System.getenv("CLICKEAT_REMEMBER_ME_SECRET");
        if (env != null && !env.isBlank()) {
            return env;
        }

        String prop = System.getProperty("clickeat.remember.secret");
        if (prop != null && !prop.isBlank()) {
            return prop;
        }

        return DEFAULT_SECRET;
    }

    private static String safe(String value) {
        return value == null ? "" : value;
    }

    private static String getCookiePath(HttpServletRequest request) {
        String contextPath = request.getContextPath();
        return (contextPath == null || contextPath.isBlank()) ? "/" : contextPath;
    }

    private static String buildSetCookieHeader(Cookie cookie, String sameSite) {
        StringBuilder sb = new StringBuilder();
        sb.append(cookie.getName()).append("=").append(cookie.getValue() == null ? "" : cookie.getValue());
        sb.append("; Max-Age=").append(cookie.getMaxAge());
        sb.append("; Path=").append(cookie.getPath());
        sb.append("; HttpOnly");
        if (cookie.getSecure()) {
            sb.append("; Secure");
        }
        if (sameSite != null && !sameSite.isBlank()) {
            sb.append("; SameSite=").append(sameSite);
        }
        return sb.toString();
    }
}