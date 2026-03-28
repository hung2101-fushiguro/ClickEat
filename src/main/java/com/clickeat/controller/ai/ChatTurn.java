package com.clickeat.controller.ai;

import java.util.ArrayList;
import java.util.List;

// ── Shared value types ────────────────────────────────────────────────────────

/** Immutable conversation turn. */
public final class ChatTurn {
    private final String role;
    private final String text;

    public ChatTurn(String role, String text) {
        this.role = role == null ? "user" : role;
        this.text = text == null ? "" : text;
    }

    public String role() { return role; }
    public String text() { return text; }

    /** Legacy getters kept for JSP EL compatibility. */
    public String getRole() { return role; }
    public String getText() { return text; }
}
