package com.clickeat.controller.merchant;

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

@WebServlet(name = "MerchantNotificationServlet", urlPatterns = {"/merchant/notifications"})
public class MerchantNotificationServlet extends HttpServlet {

    private boolean isMerchant(User account) {
        return account != null
                && account.getRole() != null
                && "MERCHANT".equalsIgnoreCase(account.getRole().trim());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (!isMerchant(account)) {
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
        if (!isMerchant(account)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        NotificationDAO notificationDAO = new NotificationDAO();
        boolean ok = notificationDAO.markAllReadForUser(account.getId());

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\": " + ok + "}");
    }

    private String toJson(int unread, List<Notification> items) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"unread\":").append(unread).append(",\"items\":[");
        SimpleDateFormat formatter = new SimpleDateFormat("dd/MM HH:mm");

        for (int i = 0; i < items.size(); i++) {
            Notification m = items.get(i);
            if (i > 0) {
                sb.append(',');
            }
            String content = String.valueOf(m.getContent() == null ? "" : m.getContent());
            String time = m.getCreatedAt() == null ? "" : formatter.format(m.getCreatedAt());

            sb.append("{\"content\":\"").append(escapeJson(content))
                    .append("\",\"time\":\"").append(escapeJson(time))
                    .append("\",\"isRead\":").append(m.isRead())
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
