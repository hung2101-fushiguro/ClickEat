package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "GoogleCallbackServlet", urlPatterns = {"/google-callback"})
public class GoogleCallbackServlet extends HttpServlet {

    private static final String CLIENT_ID = "";
    private static final String CLIENT_SECRET = "";
    private static final String REDIRECT_URI = "http://localhost:8080/ClickEat2/google-callback";

    private static final String TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token";
    private static final String USERINFO_ENDPOINT = "https://www.googleapis.com/oauth2/v3/userinfo";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String code = req.getParameter("code");
        String state = req.getParameter("state");
        String err = req.getParameter("error");

        if (err != null) {
            req.getSession().setAttribute("error", "Google login bị hủy: " + err);
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        HttpSession session = req.getSession(false);
        String saved = session == null ? null : (String) session.getAttribute("OAUTH_STATE");
        if (saved == null || state == null || !saved.equals(state) || code == null) {
            req.getSession(true).setAttribute("error", "OAuth state không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String accessToken = exchange(code);
        JsonObject u = userInfo(accessToken);

        String email = get(u, "email");
        String name = get(u, "name");
        String sub = get(u, "sub");

        UserDAO dao = new UserDAO();

        // 1) đã link google theo sub -> login
        User user = dao.findByGoogleSub(sub);
        if (user != null) {
            session.setAttribute("account", user);
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // 2) email đã tồn tại -> link provider -> login
        user = dao.findByEmail(email);
        if (user != null) {
            dao.linkGoogleProvider(user.getId(), sub);
            session.setAttribute("account", user);
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // 3) user mới -> chuyển sang trang bổ sung
        session.setAttribute("GOOGLE_EMAIL", email);
        session.setAttribute("GOOGLE_NAME", name);
        session.setAttribute("GOOGLE_SUB", sub);

        resp.sendRedirect(req.getContextPath() + "/google-complete");
    }

    private String exchange(String code) throws IOException {
        String body
                = "code=" + enc(code)
                + "&client_id=" + enc(CLIENT_ID)
                + "&client_secret=" + enc(CLIENT_SECRET)
                + "&redirect_uri=" + enc(REDIRECT_URI)
                + "&grant_type=authorization_code";

        HttpURLConnection c = (HttpURLConnection) new URL(TOKEN_ENDPOINT).openConnection();
        c.setRequestMethod("POST");
        c.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        c.setDoOutput(true);
        try (OutputStream os = c.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        String json = readAll(c.getResponseCode() >= 400 ? c.getErrorStream() : c.getInputStream());
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        if (!obj.has("access_token")) {
            throw new IOException("Token error: " + json);
        }
        return obj.get("access_token").getAsString();
    }

    private JsonObject userInfo(String token) throws IOException {
        HttpURLConnection c = (HttpURLConnection) new URL(USERINFO_ENDPOINT).openConnection();
        c.setRequestMethod("GET");
        c.setRequestProperty("Authorization", "Bearer " + token);
        String json = readAll(c.getResponseCode() >= 400 ? c.getErrorStream() : c.getInputStream());
        return JsonParser.parseString(json).getAsJsonObject();
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private static String readAll(InputStream is) throws IOException {
        if (is == null) {
            return "";
        }
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            for (String line; (line = br.readLine()) != null;) {
                sb.append(line);
            }
            return sb.toString();
        }
    }

    private static String get(JsonObject o, String k) {
        return (o != null && o.has(k) && !o.get(k).isJsonNull()) ? o.get(k).getAsString() : null;
    }
}
