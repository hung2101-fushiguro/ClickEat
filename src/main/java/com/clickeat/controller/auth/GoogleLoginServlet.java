package com.clickeat.controller.auth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet(name = "GoogleLoginServlet", urlPatterns = {"/google-login"})
public class GoogleLoginServlet extends HttpServlet {

    private static final String CLIENT_ID = "225189851661-pobij3uem6fsnos6ftm09rftdvadiavc.apps.googleusercontent.com";
    private static final String REDIRECT_URI = "http://localhost:8080/ClickEat2/google-callback";
    private static final String SCOPE = "openid email profile";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String state = generateState();
        req.getSession(true).setAttribute("OAUTH_STATE", state);

        String url = "https://accounts.google.com/o/oauth2/v2/auth"
                + "?client_id=" + enc(CLIENT_ID)
                + "&redirect_uri=" + enc(REDIRECT_URI)
                + "&response_type=code"
                + "&scope=" + enc(SCOPE)
                + "&state=" + enc(state)
                + "&prompt=consent";

        resp.sendRedirect(url);
    }

    private static String enc(String s) { return URLEncoder.encode(s, StandardCharsets.UTF_8); }

    private static String generateState() {
        byte[] b = new byte[24];
        new SecureRandom().nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }
}