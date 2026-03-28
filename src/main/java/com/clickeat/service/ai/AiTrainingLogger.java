package com.clickeat.service.ai;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.clickeat.controller.ai.ChatTurn;
import com.clickeat.controller.ai.StructuredAiResponse;
import com.clickeat.dal.impl.AITrainingEventDAO;
import com.clickeat.model.AITrainingEvent;
import com.clickeat.model.CustomerProfile;
import com.clickeat.service.ai.AiPromptBuilder.PromptContext;

/**
 * Persists training events and emits structured telemetry logs.
 */
public class AiTrainingLogger {

    private static final Logger LOGGER = Logger.getLogger(AiTrainingLogger.class.getName());

    public long log(int userId,
            String userMessage,
            PromptContext ctx,
            CustomerProfile profile,
            String aiReply) {
        try {
            AITrainingEvent event = new AITrainingEvent();
            event.setUserId(userId);
            event.setUserMessage(userMessage);
            event.setSystemContext(buildCompactContext(ctx));
            event.setConversationContext(historyToString(ctx.history()));
            event.setAiReply(aiReply);
            event.setHasProfile(profile != null);
            event.setHealthGoal(profile == null ? null : profile.getHealthGoal());
            return new AITrainingEventDAO().insertEvent(event);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AiTrainingLogger] Failed to insert training event", e);
            return 0;
        }
    }

    public void logTelemetry(int userId,
            String provider,
            String userMessage,
            String rawOutput,
            StructuredAiResponse response) {
        try {
            int recs = response == null ? 0 : response.recommendations().size();
            int writebacks = response == null ? 0 : response.memoryWritebacks().size();
            boolean ok = response != null && response.parsedJson();
            boolean fb = response != null && response.usedFallbackRecommendations();

            LOGGER.info(() -> String.format(
                    "[AIChat] userId=%d provider=%s parseOk=%s fallback=%s intent=%s clarification=%s recs=%d writebacks=%d msgLen=%d rawLen=%d",
                    userId, safe(provider, "unknown"), ok, fb,
                    response == null ? "" : safe(response.intent(), ""),
                    response != null && response.needsClarification(),
                    recs, writebacks,
                    safe(userMessage, "").length(),
                    safe(rawOutput, "").length()));

            if (!ok || fb) {
                String snippet = safe(rawOutput, "").replaceAll("\\s+", " ").trim();
                if (snippet.length() > 260) {
                    snippet = snippet.substring(0, 260) + "...";
                }
                LOGGER.warning("[AIChat] structured parse degraded"
                        + " parseOk=" + ok + " fallback=" + fb
                        + " reason=" + (response == null ? "unknown" : safe(response.parseFailureReason(), "unknown"))
                        + " snippet=" + snippet);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AIChat] Failed to emit telemetry", e);
        }
    }

    private String buildCompactContext(PromptContext ctx) {
        String menu = ctx.menuContext() == null ? "" : ctx.menuContext();
        if (menu.length() > 8000) {
            menu = menu.substring(0, 8000);
        }
        String profile = ctx.profile() == null ? "no-profile" : "profile-present";
        return "PROFILE:" + profile + "\nMENU_SNIPPET:\n" + menu;
    }

    private String historyToString(List<ChatTurn> history) {
        if (history == null || history.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (ChatTurn t : history) {
            sb.append("[").append(t.role()).append("] ").append(t.text()).append("\n");
        }
        return sb.toString();
    }

    private static String safe(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }
}