package com.clickeat.controller.merchant;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

import com.clickeat.dal.impl.MessageDAO;
import com.clickeat.model.Message;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MerchantNotificationServlet", urlPatterns = {"/merchant/notifications"})
public class MerchantNotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        MessageDAO messageDAO = new MessageDAO();
        int unread = messageDAO.countUnreadForMerchant(account.getId());
        List<Message> items = messageDAO.getRecentNotificationsForMerchant(account.getId(), 10);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(toJson(unread, items));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        MessageDAO messageDAO = new MessageDAO();
        boolean ok = messageDAO.markAllReadForMerchant(account.getId());

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\": " + ok + "}");
    }

    private String toJson(int unread, List<Message> items) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"unread\":").append(unread).append(",\"items\":[");
        SimpleDateFormat formatter = new SimpleDateFormat("dd/MM HH:mm");

        for (int i = 0; i < items.size(); i++) {
            Message m = items.get(i);
            if (i > 0) {
                sb.append(',');
            }
            String content = m.getOtherPartyName() == null || m.getOtherPartyName().trim().isEmpty()
                    ? m.getContent()
                    : (m.getOtherPartyName() + ": " + m.getContent());
            String time = m.getCreatedAt() == null ? "" : formatter.format(m.getCreatedAt());

            sb.append("{\"content\":\"").append(escapeJson(content))
                    .append("\",\"time\":\"").append(escapeJson(time))
                    .append("\",\"isRead\":").append(m.isIsRead())
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