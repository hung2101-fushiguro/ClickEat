package com.clickeat.service.ai;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.logging.Logger;

import org.json.JSONArray;
import org.json.JSONObject;

import com.clickeat.controller.ai.ChatTurn;

/**
 * Stateless AI API gateway.
 * A single shared HttpClient is reused across all requests (connection pooling).
 * Falls back from OpenAI → Gemini → null automatically.
 */
public final class AiApiService {

    private static final Logger LOGGER = Logger.getLogger(AiApiService.class.getName());

    private static final String OPENAI_URL = "https://api.openai.com/v1/chat/completions";
    private static final String GEMINI_URL_TPL =
            "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s";

    // Increased from 220 to avoid JSON truncation mid-stream
    private static final int MAX_TOKENS = 800;

    /** Shared across all servlet instances / threads. */
    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    private final String openAiKey;
    private final String openAiModel;
    private final String geminiKey;
    private final String geminiModel;

    public AiApiService(String openAiKey, String openAiModel,
                        String geminiKey, String geminiModel) {
        this.openAiKey = openAiKey;
        this.openAiModel = openAiModel != null ? openAiModel : "gpt-4o-mini";
        this.geminiKey = geminiKey != null ? geminiKey : "";
        this.geminiModel = geminiModel != null ? geminiModel : "gemini-2.5-flash";
    }

    public record AiResult(String rawText, String provider) {}

    /** Try OpenAI first; fall back to Gemini; return empty result if both fail. */
    public AiResult call(String systemPrompt, String userMessage, List<ChatTurn> history) {
        if (openAiKey != null && !openAiKey.isBlank() && !openAiKey.startsWith("sk-YOUR")) {
            String text = callOpenAi(systemPrompt, userMessage, history);
            if (text != null) return new AiResult(text, "openai");
        }

        if (!geminiKey.isBlank() && !geminiKey.startsWith("AIza_YOUR")) {
            String text = callGemini(systemPrompt, userMessage, history);
            if (text != null) return new AiResult(text, "gemini");
        }

        return new AiResult(null, "none");
    }

    // ── OpenAI ────────────────────────────────────────────────────────────────

    private String callOpenAi(String system, String userMsg, List<ChatTurn> history) {
        try {
            JSONArray messages = new JSONArray();
            messages.put(new JSONObject().put("role", "system").put("content", system));
            for (ChatTurn t : history) {
                String role = "model".equalsIgnoreCase(t.role()) ? "assistant" : "user";
                messages.put(new JSONObject().put("role", role).put("content", t.text()));
            }
            messages.put(new JSONObject().put("role", "user").put("content", userMsg));

            JSONObject body = new JSONObject()
                    .put("model", openAiModel)
                    .put("messages", messages)
                    .put("max_tokens", MAX_TOKENS)
                    .put("temperature", 0.5)
                    .put("top_p", 0.9);

            HttpResponse<String> res = HTTP.send(
                    HttpRequest.newBuilder()
                            .uri(URI.create(OPENAI_URL))
                            .timeout(Duration.ofSeconds(25))
                            .header("Authorization", "Bearer " + openAiKey)
                            .header("Content-Type", "application/json; charset=UTF-8")
                            .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                            .build(),
                    HttpResponse.BodyHandlers.ofString());

            JSONObject json = new JSONObject(res.body());
            if (json.has("error")) {
                LOGGER.warning("[OpenAI] " + json.getJSONObject("error").optString("message"));
                return null;
            }
            return json.getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content").trim();

        } catch (Exception e) {
            LOGGER.warning("[OpenAI] " + e.getMessage());
            return null;
        }
    }

    // ── Gemini ────────────────────────────────────────────────────────────────

    private String callGemini(String system, String userMsg, List<ChatTurn> history) {
        try {
            JSONObject payload = new JSONObject();
            payload.put("system_instruction", new JSONObject()
                    .put("parts", new JSONArray().put(new JSONObject().put("text", system))));
            payload.put("generationConfig", new JSONObject()
                    .put("temperature", 0.45)
                    .put("topP", 0.9)
                    .put("maxOutputTokens", MAX_TOKENS));

            JSONArray contents = new JSONArray();
            for (ChatTurn t : history) {
                contents.put(new JSONObject()
                        .put("role", "model".equalsIgnoreCase(t.role()) ? "model" : "user")
                        .put("parts", new JSONArray().put(new JSONObject().put("text", t.text()))));
            }
            contents.put(new JSONObject()
                    .put("role", "user")
                    .put("parts", new JSONArray().put(new JSONObject().put("text", userMsg))));
            payload.put("contents", contents);

            String url = GEMINI_URL_TPL.formatted(geminiModel, geminiKey);
            HttpResponse<String> res = HTTP.send(
                    HttpRequest.newBuilder()
                            .uri(URI.create(url))
                            .timeout(Duration.ofSeconds(25))
                            .header("Content-Type", "application/json")
                            .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                            .build(),
                    HttpResponse.BodyHandlers.ofString());

            JSONObject json = new JSONObject(res.body());
            if (json.has("error")) {
                LOGGER.warning("[Gemini] " + json.getJSONObject("error").optString("message"));
                return null;
            }
            return json.getJSONArray("candidates")
                    .getJSONObject(0)
                    .getJSONObject("content")
                    .getJSONArray("parts")
                    .getJSONObject(0)
                    .getString("text");

        } catch (Exception e) {
            LOGGER.warning("[Gemini] " + e.getMessage());
            return null;
        }
    }
}
