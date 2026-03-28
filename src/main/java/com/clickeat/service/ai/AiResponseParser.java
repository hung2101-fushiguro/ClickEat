package com.clickeat.service.ai;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

import com.clickeat.controller.ai.StructuredAiResponse;
import com.clickeat.controller.ai.StructuredAiResponse.MemoryWritebackEntry;
import com.clickeat.controller.ai.StructuredAiResponse.Recommendation;
import com.clickeat.model.FoodItem;

/**
 * Parses raw AI output into a {@link StructuredAiResponse}.
 * Also builds the final natural-language reply and recommendation cards.
 */
public final class AiResponseParser {

    // ── Main parse ────────────────────────────────────────────────────────────

    public StructuredAiResponse parse(String raw, List<FoodItem> fallback, String userMessage) {
        JSONObject json = tryExtractJson(raw);

        if (json == null) {
            return buildFallbackResponse(fallback, userMessage, "invalid_json");
        }

        List<Recommendation> recs = parseRecommendations(json);
        boolean usedFallback = false;
        if (recs.size() < 2) {
            recs = buildFallbackRecommendations(fallback, userMessage);
            usedFallback = true;
        }
        recs = ensureHealthyAlternative(recs);

        List<String> questions = new ArrayList<>();
        JSONArray qArr = json.optJSONArray("clarification_questions");
        if (qArr != null) {
            for (int i = 0; i < qArr.length() && i < 2; i++) {
                String q = qArr.optString(i, "").trim();
                if (!q.isEmpty()) questions.add(q);
            }
        }

        boolean needsClarification = json.optBoolean("needs_clarification", false);
        if (needsClarification && questions.isEmpty())
            questions.add("Bạn muốn ưu tiên ngon đậm vị hay lành mạnh hơn?");

        List<MemoryWritebackEntry> writebacks = parseWritebacks(json);

        String cta = json.optString("cta", "").trim();
        if (cta.isEmpty()) cta = "Bạn muốn mình chốt món nào luôn?";

        return StructuredAiResponse.builder()
                .parsedJson(true)
                .usedFallbackRecommendations(usedFallback)
                .intent(json.optString("intent", "fallback"))
                .needsClarification(needsClarification)
                .naturalResponse(json.optString("natural_response", "Mình gợi ý nhanh vài món để bạn chọn nhé.").trim())
                .nutritionNote(json.optString("nutrition_note", "").trim())
                .cta(cta)
                .clarificationQuestions(questions)
                .recommendations(recs)
                .memoryWritebacks(writebacks)
                .build();
    }

    // ── Compose natural chat reply ────────────────────────────────────────────

    public String composeReply(StructuredAiResponse r) {
        StringBuilder sb = new StringBuilder();
        sb.append(safe(r.naturalResponse(), "Mình gợi ý nhanh vài món để bạn chọn nhé."));

        List<Recommendation> recs = r.recommendations();
        if (recs != null && !recs.isEmpty()) {
            sb.append(" ");
            for (int i = 0; i < recs.size(); i++) {
                Recommendation rec = recs.get(i);
                if (rec == null) continue;
                if (i > 0) sb.append(" ");
                sb.append(i + 1).append(") ")
                  .append(safe(rec.dishName, "Món gợi ý"))
                  .append(" - ")
                  .append(safe(rec.reason, "phù hợp nhu cầu hiện tại"))
                  .append(".");
            }
        }

        if (!safe(r.nutritionNote(), "").isBlank())
            sb.append(" ").append(r.nutritionNote().trim());

        if (r.needsClarification()) {
            r.clarificationQuestions().forEach(q -> sb.append(" ").append(q.trim()));
        }

        if (!safe(r.cta(), "").isBlank())
            sb.append(" ").append(r.cta().trim());

        return normalizeReplyText(sb.toString());
    }

    // ── Build recommendation cards for JSP ────────────────────────────────────

    public List<Map<String, Object>> buildCards(StructuredAiResponse r, List<FoodItem> foods) {
        List<Map<String, Object>> cards = new ArrayList<>();
        if (r == null || r.recommendations() == null) return cards;

        for (Recommendation rec : r.recommendations()) {
            if (rec == null || safe(rec.dishName, "").isBlank()) continue;
            FoodItem matched = matchByName(rec.dishName, foods);

            Map<String, Object> card = new LinkedHashMap<>();
            card.put("dishName", safe(rec.dishName, "Món gợi ý"));
            card.put("reason", safe(rec.reason, "Phù hợp nhu cầu hiện tại của bạn."));
            card.put("healthScore", rec.healthScore);
            card.put("isHealthyAlternative", rec.isHealthyAlternative);
            card.put("estimatedCalories", rec.estimatedCalories);
            card.put("priceLevel", safe(rec.priceLevel, "unknown"));
            card.put("tags", rec.tags == null ? List.of() : rec.tags);

            if (matched != null) {
                card.put("foodId", matched.getId());
                card.put("imageUrl", safe(matched.getImageUrl(), ""));
                card.put("merchantName", safe(matched.getMerchantName(), ""));
                card.put("price", matched.getPrice());
            } else {
                card.put("foodId", null);
                card.put("imageUrl", "");
                card.put("merchantName", "");
                card.put("price", null);
            }
            cards.add(card);
        }
        return cards;
    }

    // ── Fallback response ─────────────────────────────────────────────────────

    private StructuredAiResponse buildFallbackResponse(List<FoodItem> foods,
                                                        String userMessage,
                                                        String reason) {
        List<Recommendation> recs = ensureHealthyAlternative(
                buildFallbackRecommendations(foods, userMessage));

        String naturalResponse;
        String nutritionNote;
        String cta;

        if (isWeightLossIntent(userMessage)) {
            naturalResponse = "Mình hiểu bạn đang ưu tiên giảm cân, mình lọc nhanh món nhẹ và ít dầu mỡ hơn.";
            nutritionNote   = "Mẹo nhanh: ưu tiên món luộc/hấp và kiểm soát tinh bột vào buổi tối.";
            cta             = "Bạn muốn mình lọc thêm theo ngân sách không?";
        } else if (isRiceIntent(userMessage)) {
            naturalResponse = "Có nhé, mình ưu tiên gợi ý nhóm món cơm cho bạn.";
            nutritionNote   = "Nếu muốn nhẹ hơn, mình có thể ưu tiên cơm + rau + đạm nạc.";
            cta             = "Bạn muốn cơm gà, cơm sườn hay cơm phần healthy?";
        } else if (isNoodleQuangIntent(userMessage)) {
            naturalResponse = "Mình thấy bạn muốn ăn Mỳ Quảng, mình ưu tiên món gần nhu cầu này trước.";
            nutritionNote   = "Nếu muốn nhẹ bụng hơn, mình có thể ưu tiên phiên bản ít dầu và thêm rau.";
            cta             = "Bạn muốn bản đậm vị hay thanh nhẹ?";
        } else {
            naturalResponse = "Mình gợi ý nhanh vài món đang có trong hệ thống để bạn tham khảo.";
            nutritionNote   = "Nếu bạn muốn mình cá nhân hóa kỹ hơn, cho mình biết mục tiêu sức khỏe và ngân sách nhé.";
            cta             = "Bạn thích món đậm vị hay nhẹ bụng hơn?";
        }

        return StructuredAiResponse.builder()
                .parsedJson(false)
                .usedFallbackRecommendations(true)
                .parseFailureReason(reason)
                .intent("fallback")
                .naturalResponse(naturalResponse)
                .nutritionNote(nutritionNote)
                .cta(cta)
                .recommendations(recs)
                .build();
    }

    // ── Parse helpers ─────────────────────────────────────────────────────────

    private List<Recommendation> parseRecommendations(JSONObject json) {
        List<Recommendation> recs = new ArrayList<>();
        JSONArray arr = json.optJSONArray("recommendations");
        if (arr == null) return recs;

        for (int i = 0; i < arr.length() && i < 3; i++) {
            JSONObject item = arr.optJSONObject(i);
            if (item == null) continue;

            List<String> tags = new ArrayList<>();
            JSONArray tagsArr = item.optJSONArray("tags");
            if (tagsArr != null)
                for (int t = 0; t < tagsArr.length(); t++) {
                    String tag = tagsArr.optString(t, "").trim();
                    if (!tag.isEmpty()) tags.add(tag);
                }

            Integer calories = item.has("estimated_calories") && !item.isNull("estimated_calories")
                    ? item.optInt("estimated_calories") : null;

            recs.add(new Recommendation(
                    item.optString("dish_name", "Món gợi ý").trim(),
                    item.optString("reason", "Phù hợp nhu cầu hiện tại của bạn.").trim(),
                    item.optInt("health_score", 7),
                    item.optBoolean("is_healthy_alternative", false),
                    calories,
                    item.optString("price_level", "unknown").toLowerCase(Locale.ROOT),
                    tags
            ));
        }
        return recs;
    }

    private List<MemoryWritebackEntry> parseWritebacks(JSONObject json) {
        List<MemoryWritebackEntry> list = new ArrayList<>();
        JSONArray arr = json.optJSONArray("memory_writeback");
        if (arr == null) return list;
        for (int i = 0; i < arr.length(); i++) {
            JSONObject wb = arr.optJSONObject(i);
            if (wb == null) continue;
            String key   = wb.optString("key", "").toLowerCase(Locale.ROOT).trim();
            String value = wb.optString("value", "").trim();
            double conf  = wb.optDouble("confidence", 0.0);
            if (!key.isBlank() && !value.isBlank())
                list.add(new MemoryWritebackEntry(key, value, conf));
        }
        return list;
    }

    // ── Fallback recommendations ──────────────────────────────────────────────

    private List<Recommendation> buildFallbackRecommendations(List<FoodItem> foods, String userMessage) {
        boolean weightLoss     = isWeightLossIntent(userMessage);
        boolean noodleQuang    = isNoodleQuangIntent(userMessage);
        List<Recommendation> recs = new ArrayList<>();

        if (foods != null) {
            for (FoodItem f : foods) {
                if (f == null) continue;
                String reason;
                if (weightLoss)
                    reason = f.isFried()
                            ? "Đang có sẵn, nhưng nên dùng khẩu phần nhỏ để hỗ trợ giảm cân."
                            : "Ít dầu mỡ hơn và phù hợp định hướng giảm cân.";
                else if (noodleQuang && normalize(safe(f.getName(), "")).contains("mi quang"))
                    reason = "Đang có sẵn và sát đúng món bạn đang muốn ăn.";
                else
                    reason = "Món đang có sẵn trong hệ thống.";

                int score = weightLoss ? (f.isFried() ? 6 : 9) : (f.isFried() ? 6 : 8);
                recs.add(new Recommendation(
                        safe(f.getName(), "Món gợi ý"), reason, score,
                        !f.isFried() || weightLoss, null, "unknown", List.of()));
                if (recs.size() >= 3) break;
            }
        }

        return recs;
    }

    private static List<Recommendation> ensureHealthyAlternative(List<Recommendation> recs) {
        if (recs == null || recs.isEmpty()) return recs;
        for (Recommendation r : recs) if (r != null && r.isHealthyAlternative) return recs;

        // Mutate a copy since Recommendation is immutable — replace first item
        List<Recommendation> copy = new ArrayList<>(recs);
        Recommendation first = copy.get(0);
        copy.set(0, new Recommendation(
                first.dishName, first.reason,
                Math.max(first.healthScore, 8),
                true,
                first.estimatedCalories, first.priceLevel, first.tags));
        return copy;
    }

    // ── JSON extraction ───────────────────────────────────────────────────────

    private static JSONObject tryExtractJson(String raw) {
        if (raw == null || raw.isBlank()) return null;
        String text = raw.trim();

        // Strip markdown fences if present
        if (text.startsWith("```")) {
            int first = text.indexOf('{');
            int last  = text.lastIndexOf('}');
            if (first >= 0 && last > first) text = text.substring(first, last + 1).trim();
        }

        try { return new JSONObject(text); } catch (Exception ignored) {}

        int first = text.indexOf('{');
        int last  = text.lastIndexOf('}');
        if (first >= 0 && last > first) {
            try { return new JSONObject(text.substring(first, last + 1)); } catch (Exception ignored) {}
        }
        return null;
    }

    // ── Intent detection ──────────────────────────────────────────────────────

    private boolean isWeightLossIntent(String msg) {
        String n = normalize(msg);
        return n.contains("giam can") || n.contains("eat clean")
                || n.contains("healthy") || n.contains("it dau") || n.contains("an kieng");
    }

    private boolean isNoodleQuangIntent(String msg) {
        String n = normalize(msg);
        return n.contains("mi quang") || n.contains("my quang");
    }

    private boolean isRiceIntent(String msg) {
        String n = normalize(msg);
        // Explicit rice-meal keywords only — avoids false positives on "comment" etc.
        return n.matches(".*\\bcom\\b.*") || n.contains("mon com") || n.contains("co com");
    }

    // ── Utilities ─────────────────────────────────────────────────────────────

    private FoodItem matchByName(String dishName, List<FoodItem> foods) {
        if (foods == null || foods.isEmpty() || dishName == null) return null;
        String target = normalize(dishName);
        for (FoodItem f : foods) {
            if (f == null || f.getName() == null) continue;
            String name = normalize(f.getName());
            if (name.equals(target) || name.contains(target) || target.contains(name)) return f;
        }
        return null;
    }

    /** Strip bullet/list prefixes and collapse whitespace for natural prose output. */
    private String normalizeReplyText(String raw) {
        if (raw == null || raw.isBlank())
            return "Xin lỗi, mình chưa trả lời được lúc này. Bạn thử lại giúp mình nhé.";
        String[] lines = raw.replace("\r", "\n").split("\n");
        StringBuilder sb = new StringBuilder();
        for (String line : lines) {
            String t = line == null ? "" : line.trim().replaceFirst("^[-*•\\d+.)\\s]+", "").trim();
            if (!t.isEmpty()) { if (sb.length() > 0) sb.append(' '); sb.append(t); }
        }
        String result = sb.toString().replaceAll("\\s+", " ").trim();
        return result.isEmpty()
                ? "Xin lỗi, mình chưa trả lời được lúc này. Bạn thử lại giúp mình nhé."
                : result;
    }

    private static String safe(String v, String fallback) {
        return v == null || v.isBlank() ? fallback : v.trim();
    }

    private static String normalize(String v, boolean diacritics) {
        if (v == null) return "";
        String low = v.toLowerCase(Locale.ROOT).trim();
        return java.text.Normalizer.normalize(low, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
    }

    // Single-arg version for internal use
    private static String normalize(String v) { return normalize(v, true); }
}
