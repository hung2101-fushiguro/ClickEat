package com.clickeat.controller.ai;

import java.io.IOException;

import com.clickeat.dal.impl.AITrainingEventDAO;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AIFeedbackServlet", urlPatterns = {"/ai/feedback"})
public class AIFeedbackServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || account.getRole() == null || !"CUSTOMER".equalsIgnoreCase(account.getRole().trim())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long eventId = parseLong(request.getParameter("eventId"));
        int score = parseScore(request.getParameter("score"));
        String note = request.getParameter("note");
        String category = request.getParameter("category");
        String groundTruth = request.getParameter("groundTruth");
        String errorType = request.getParameter("errorType");

        if (eventId <= 0 || score == 0) {
            response.sendRedirect(request.getContextPath() + "/ai?fb=invalid");
            return;
        }

        AITrainingEventDAO dao = new AITrainingEventDAO();
        boolean ok = dao.updateFeedback(eventId, account.getId(), score, note, category, groundTruth, errorType);

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/ai?fb=ok");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/ai?fb=fail");
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value);
        } catch (Exception e) {
            return 0;
        }
    }

    private int parseScore(String raw) {
        if (raw == null || raw.isBlank()) {
            return 0;
        }
        String normalized = raw.trim();
        if ("1".equals(normalized) || "up".equalsIgnoreCase(normalized) || "like".equalsIgnoreCase(normalized)) {
            return 1;
        }
        if ("-1".equals(normalized) || "down".equalsIgnoreCase(normalized) || "dislike".equalsIgnoreCase(normalized)) {
            return -1;
        }
        return 0;
    }
}
