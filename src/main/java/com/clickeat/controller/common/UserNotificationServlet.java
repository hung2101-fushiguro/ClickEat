package com.clickeat.controller.common;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

import com.clickeat.dal.impl.NotificationDAO;
import com.clickeat.model.Notification;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "UserNotificationServlet", urlPatterns = {"/customer/notifications", "/shipper/notifications"})
public class UserNotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (!isAuthorizedByPath(account, request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        NotificationDAO notificationDAO = new NotificationDAO();
        int unread = notificationDAO.countUnreadForUser(account.getId());
        List<Notification> items = notificationDAO.getRecentForUser(account.getId(), 10);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(toJson(unread, items));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (!isAuthorizedByPath(account, request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        NotificationDAO notificationDAO = new NotificationDAO();
        boolean ok = notificationDAO.markAllReadForUser(account.getId());

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\": " + ok + "}");
    }

    private boolean isAuthorizedByPath(User account, String path) {
        if (account == null || account.getRole() == null || path == null) {
            return false;
        }
        String role = account.getRole().trim().toUpperCase();
        if (path.startsWith("/customer/")) {
            return "CUSTOMER".equals(role);
        }
        if (path.startsWith("/shipper/")) {
            return "SHIPPER".equals(role);
        }
        return false;
    }

    private String toJson(int unread, List<Notification> items) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"unread\":").append(unread).append(",\"items\":[");
        SimpleDateFormat formatter = new SimpleDateFormat("dd/MM HH:mm");

        for (int i = 0; i < items.size(); i++) {
            Notification item = items.get(i);
            if (i > 0) {
                sb.append(',');
            }
            String content = item.getContent() == null ? "" : item.getContent();
            String time = item.getCreatedAt() == null ? "" : formatter.format(item.getCreatedAt());

            sb.append("{\"content\":\"").append(escapeJson(content))
                    .append("\",\"time\":\"").append(escapeJson(time))
                    .append("\",\"isRead\":").append(item.isRead())
                    .append("}");
        }

        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String raw) {
        if (raw == null) {
            return "";
        }
        return raw
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
