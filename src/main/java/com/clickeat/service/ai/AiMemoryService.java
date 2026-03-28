package com.clickeat.service.ai;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.clickeat.controller.ai.StructuredAiResponse;
import com.clickeat.controller.ai.StructuredAiResponse.MemoryWritebackEntry;
import com.clickeat.dal.impl.AIUserPreferenceSignalDAO;
import com.clickeat.dal.impl.CustomerProfileDAO;
import com.clickeat.model.CustomerProfile;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Manages two layers of preference memory:
 *   1. Session-scoped keyword signals (fast, ephemeral).
 *   2. DB-persisted signals via {@link AIUserPreferenceSignalDAO}.
 * Also applies structured memory writeback from AI responses to CustomerProfile.
 */
public final class AiMemoryService {

    private static final String SESSION_KEY = "aiPreferenceMemory";
    private final AIUserPreferenceSignalDAO signalDAO = new AIUserPreferenceSignalDAO();

    // ── Learned-preference context for prompt ─────────────────────────────────

    public String buildLearnedPreferenceContext(HttpServletRequest req, int userId) {
        Map<String, Integer> merged = new LinkedHashMap<>(getSessionMemory(req));

        // Merge with DB signals (sum weights)
        signalDAO.getTopSignals(userId, 12).forEach((k, v) ->
                merged.merge(k, v, Integer::sum));

        if (merged.isEmpty())
            return "- Chưa có dữ liệu học thói quen từ chat trước trong phiên này.";

        List<Map.Entry<String, Integer>> sorted = new ArrayList<>(merged.entrySet());
        sorted.sort((a, b) -> Integer.compare(b.getValue(), a.getValue()));

        StringBuilder sb = new StringBuilder();
        int count = 0;
        for (Map.Entry<String, Integer> e : sorted) {
            sb.append("- ").append(e.getKey()).append(" (ưu tiên ").append(e.getValue()).append(")\n");
            if (++count >= 6) break;
        }
        return sb.toString().trim();
    }

    // ── Update session memory from incoming message ───────────────────────────

    public void updateFromMessage(HttpServletRequest req, int userId, String message) {
        if (message == null || message.isBlank()) return;
        Map<String, Integer> memory = getSessionMemory(req);
        String n = normalize(message);

        record Signal(String matchKey, String signalKey, String label) {}
        List<Signal> signals = List.of(
                new Signal("ga ran|ga chien",          "fried-chicken",        "Ưa món gà rán/chiên"),
                new Signal("banh trang|cuon",           "roll-snack",           "Thích món cuốn và ăn vặt"),
                new Signal("\\bcom\\b",                 "rice-meal",            "Quan tâm nhóm món cơm"),
                new Signal("bun|pho|\\bmi\\b",          "noodle-soup",          "Hay chọn món nước/noodle"),
                new Signal("tra sua|do uong|nuoc",      "drink-choice",         "Quan tâm đồ uống"),
                new Signal("healthy|eat clean|giam can","healthy-focus",        "Ưu tiên món healthy/kiểm soát calo"),
                new Signal("an dem|khuya",              "late-night",           "Nhu cầu ăn khuya"),
                new Signal("khong hanh|di ung",         "ingredient-constraint","Có ràng buộc nguyên liệu khi chọn món")
        );

        for (Signal s : signals) {
            if (matchesAny(n, s.matchKey().split("\\|"))) {
                increment(memory, s.label());
                signalDAO.incrementSignal(userId, s.signalKey(), s.label());
            }
        }
        req.getSession().setAttribute(SESSION_KEY, memory);
    }

    // ── Structured writeback to CustomerProfile ───────────────────────────────

    public void applyWriteback(CustomerProfileDAO profileDAO,
                               CustomerProfile profile,
                               int userId,
                               StructuredAiResponse response) {
        if (response == null || response.memoryWritebacks().isEmpty()) return;

        CustomerProfile target = profile;
        if (target == null) {
            profileDAO.ensureExists(userId);
            target = profileDAO.findByUserId(userId);
            if (target == null) {
                target = new CustomerProfile();
                target.setUserId(userId);
            }
        }

        boolean dirty = false;
        for (MemoryWritebackEntry entry : response.memoryWritebacks()) {
            if (entry.confidence < 0.75) continue;
            String key   = entry.key.toLowerCase(Locale.ROOT);
            String value = entry.value;
            if (key.isBlank() || value.isBlank()) continue;

            switch (key) {
                case "food_preferences" -> { target.setFoodPreferences(merge(target.getFoodPreferences(), value)); dirty = true; }
                case "allergies"        -> { target.setAllergies(merge(target.getAllergies(), value)); dirty = true; }
                case "health_goal"      -> { target.setHealthGoal(value); dirty = true; }
                default                 -> signalDAO.incrementSignal(userId, "wb-" + key, "Tín hiệu AI: " + key + "=" + value);
            }
        }
        if (dirty) profileDAO.updateProfile(target);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    @SuppressWarnings("unchecked")
    private Map<String, Integer> getSessionMemory(HttpServletRequest req) {
        Map<String, Integer> mem = (Map<String, Integer>) req.getSession().getAttribute(SESSION_KEY);
        if (mem == null) {
            mem = new LinkedHashMap<>();
            req.getSession().setAttribute(SESSION_KEY, mem);
        }
        return mem;
    }

    private void increment(Map<String, Integer> mem, String key) {
        mem.merge(key, 1, Integer::sum);
    }

    private boolean matchesAny(String text, String[] patterns) {
        for (String p : patterns) if (text.matches(".*" + p + ".*")) return true;
        return false;
    }

    private String merge(String old, String next) {
        String o = old == null ? "" : old.trim();
        String n = next == null ? "" : next.trim();
        if (n.isEmpty()) return o;
        if (o.isEmpty()) return n;
        if (normalize(o).contains(normalize(n))) return o;
        return o + "; " + n;
    }

    private static String normalize(String v) {
        if (v == null) return "";
        String low = v.toLowerCase(Locale.ROOT).trim();
        return java.text.Normalizer.normalize(low, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
    }
}
