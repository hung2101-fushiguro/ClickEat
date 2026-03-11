package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

import com.clickeat.config.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/merchant/notifications")
public class MerchantNotificationsServlet extends HttpServlet {

    /**
     * GET /merchant/notifications — returns JSON {unread:N, items:[...]}
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Object attr = req.getSession().getAttribute("merchantId");
        if (attr == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"unauthorized\"}");
            return;
        }
        int merchantId = ((Number) attr).intValue();

        int unread = 0;
        StringBuilder items = new StringBuilder("[");
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM HH:mm");

        try (Connection conn = DBContext.getConnection()) {
            // unread count
            String countSql = "SELECT COUNT(*) FROM Notifications WHERE user_id=? AND is_read=0";
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    unread = rs.getInt(1);
                }
            }

            // TOP 10 recent notifications
            String listSql = "SELECT TOP 10 id, type, content, is_read, created_at "
                    + "FROM Notifications WHERE user_id=? ORDER BY created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                boolean first = true;
                while (rs.next()) {
                    if (!first) {
                        items.append(",");
                    }
                    first = false;
                    long id = rs.getLong("id");
                    String type = rs.getString("type");
                    String content = rs.getString("content");
                    boolean isRead = rs.getBoolean("is_read");
                    Timestamp ts = rs.getTimestamp("created_at");
                    String time = ts != null ? sdf.format(ts) : "";
                    items.append("{\"id\":").append(id)
                            .append(",\"type\":\"").append(escape(type)).append("\"")
                            .append(",\"content\":\"").append(escape(content)).append("\"")
                            .append(",\"isRead\":").append(isRead)
                            .append(",\"time\":\"").append(time).append("\"")
                            .append("}");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        items.append("]");

        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"unread\":" + unread + ",\"items\":" + items + "}");
    }

    /**
     * POST /merchant/notifications — mark all notifications as read
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Object attr = req.getSession().getAttribute("merchantId");
        if (attr == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        int merchantId = ((Number) attr).intValue();

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(
                "UPDATE Notifications SET is_read=1 WHERE user_id=? AND is_read=0")) {
            ps.setInt(1, merchantId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"ok\":true}");
    }

    private static String escape(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
