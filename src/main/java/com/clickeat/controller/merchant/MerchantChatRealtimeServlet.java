package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

import com.clickeat.dal.impl.MessageDAO;
import com.clickeat.model.Message;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MerchantChatRealtimeServlet", urlPatterns = {"/merchant/chat/realtime"})
public class MerchantChatRealtimeServlet extends HttpServlet {

    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equalsIgnoreCase(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        long withId = parseLong(request.getParameter("with"), -1L);
        if (withId <= 0) {
            writeJson(response, "{\"success\":false,\"error\":\"missing_with\"}");
            return;
        }

        long since = parseLong(request.getParameter("since"), 0L);
        MessageDAO dao = new MessageDAO();

        if (!dao.hasActiveDeliveryWindow(account.getId(), withId)) {
            dao.deleteConversationBetween(account.getId(), withId);
            writeJson(response, "{\"success\":false,\"error\":\"chat_closed\"}");
            return;
        }

        dao.markConversationRead(account.getId(), withId);

        List<Message> messages = since > 0
                ? dao.getChatHistorySince(account.getId(), withId, since)
                : dao.getChatHistory(account.getId(), withId);

        writeJson(response, toMessagesJson(true, messages));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equalsIgnoreCase(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        long withId = parseLong(request.getParameter("with"), -1L);
        String text = request.getParameter("message");

        if (withId <= 0 || text == null || text.trim().isEmpty()) {
            writeJson(response, "{\"success\":false,\"error\":\"invalid_payload\"}");
            return;
        }

        MessageDAO dao = new MessageDAO();
        if (!dao.hasActiveDeliveryWindow(account.getId(), withId)) {
            dao.deleteConversationBetween(account.getId(), withId);
            writeJson(response, "{\"success\":false,\"error\":\"chat_closed\"}");
            return;
        }

        boolean ok = dao.saveMessage(account.getId(), withId, text.trim());

        if (!ok) {
            writeJson(response, "{\"success\":false,\"error\":\"save_failed\"}");
            return;
        }

        Message latest = dao.getLatestBetween(account.getId(), withId);
        List<Message> payload = latest == null ? Collections.emptyList() : Collections.singletonList(latest);
        writeJson(response, toMessagesJson(true, payload));
    }

    private void writeJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json);
    }

    private long parseLong(String value, long fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private String toMessagesJson(boolean success, List<Message> messages) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"success\":").append(success).append(",\"messages\":[");

        long latestId = 0L;
        for (int i = 0; i < messages.size(); i++) {
            Message m = messages.get(i);
            if (i > 0) {
                sb.append(',');
            }
            latestId = Math.max(latestId, m.getId());
            sb.append('{')
                    .append("\"id\":").append(m.getId()).append(',')
                    .append("\"senderId\":").append(m.getSenderId()).append(',')
                    .append("\"receiverId\":").append(m.getReceiverId()).append(',')
                    .append("\"content\":\"").append(escapeJson(m.getContent())).append("\",")
                    .append("\"time\":\"").append(formatTime(m.getCreatedAt())).append("\"")
                    .append('}');
        }

        sb.append("],\"latestId\":").append(latestId).append('}');
        return sb.toString();
    }

    private String formatTime(Timestamp timestamp) {
        if (timestamp == null) {
            return "";
        }
        return timestamp.toInstant().atZone(ZoneId.systemDefault()).toLocalTime().format(TIME_FORMATTER);
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
