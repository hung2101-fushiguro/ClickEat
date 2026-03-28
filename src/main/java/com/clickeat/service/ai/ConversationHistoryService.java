package com.clickeat.service.ai;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.clickeat.controller.ai.ChatTurn;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Thread-safe conversation history stored in the HTTP session.
 * The history list is synchronized to guard against rare concurrent
 * requests from the same session (multiple browser tabs).
 */
public class ConversationHistoryService {

    private static final String SESSION_KEY = "aiConversationHistory";
    /** Max number of turns (user + model pairs) to retain. */
    private static final int MAX_TURNS = 8;

    /** Returns a snapshot of the current history (safe for reading). */
    @SuppressWarnings("unchecked")
    public List<ChatTurn> get(HttpServletRequest req) {
        synchronized (req.getSession()) {
            List<ChatTurn> h = (List<ChatTurn>) req.getSession().getAttribute(SESSION_KEY);
            return h == null ? List.of() : List.copyOf(h);
        }
    }

    /** Appends a turn and trims the list to the rolling window. */
    public void append(HttpServletRequest req, String role, String text) {
        synchronized (req.getSession()) {
            @SuppressWarnings("unchecked")
            List<ChatTurn> h = (List<ChatTurn>) req.getSession().getAttribute(SESSION_KEY);
            if (h == null) {
                h = new ArrayList<>();
                req.getSession().setAttribute(SESSION_KEY, h);
            }
            h.add(new ChatTurn(role, text == null ? "" : text));
            int max = MAX_TURNS * 2; // user + model per turn
            while (h.size() > max) {
                h.remove(0);
            }
        }
    }

    /** Builds a view-friendly list of maps for JSP EL rendering. */
    public List<Map<String, Object>> buildViewList(List<ChatTurn> history) {
        List<Map<String, Object>> view = new ArrayList<>();
        for (ChatTurn t : history) {
            boolean isModel = "model".equalsIgnoreCase(t.role());
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("role", t.role());
            row.put("isModel", isModel);
            row.put("text", t.text());
            view.add(row);
        }
        return view;
    }
}
