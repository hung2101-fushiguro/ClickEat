package com.clickeat.service.ai;

import java.time.LocalTime;
import java.util.List;
import java.util.Locale;

import com.clickeat.controller.ai.ChatTurn;
import com.clickeat.controller.ai.UserLocation;
import com.clickeat.dal.impl.AITrainingEventDAO;
import com.clickeat.model.CustomerProfile;
import com.clickeat.model.FoodItem;

/**
 * Builds the system prompt for AI calls.
 * Extracted from AIChatServlet for testability.
 */
public final class AiPromptBuilder {

    // ── Context record ────────────────────────────────────────────────────────

    public record PromptContext(
            CustomerProfile profile,
            String foodHistory,
            String menuContext,
            List<FoodItem> candidates,
            List<ChatTurn> history,
            UserLocation location,
            String learnedPreferences
    ) {}

    // ── Public entry point ────────────────────────────────────────────────────

    public String build(PromptContext ctx) {
        String healthGoal = ctx.profile() != null ? ctx.profile().getHealthGoal() : null;

        return """
                Bạn là ClickEat Smart Nutrition & Ordering Assistant.
                Mục tiêu ưu tiên: trải nghiệm tự nhiên, cá nhân hóa, tăng tỉ lệ chốt đơn, và an toàn sức khỏe.
                Bạn chỉ cung cấp khuyến nghị dinh dưỡng tổng quát theo tinh thần WHO, không chẩn đoán y khoa.

                === HỒ SƠ CÁ NHÂN HÓA CỦA KHÁCH ===
                %s

                === DỮ LIỆU LỊCH SỬ ĂN UỐNG CỦA KHÁCH ===
                %s

                === NGỮ CẢNH REALTIME ===
                %s

                === CHÍNH SÁCH AN TOÀN BẮT BUỘC ===
                %s

                === NGỮ CẢNH HỘI THOẠI GẦN NHẤT ===
                %s

                === TRÍ NHỚ THÓI QUEN TỪ CÁC LẦN CHAT TRƯỚC ===
                %s

                === DANH SÁCH THỰC ĐƠN HIỆN CÓ TỪ HỆ THỐNG ===
                %s

                === ỨNG VIÊN MÓN ĐÃ LỌC SẴN (ƯU TIÊN CHỌN TỪ ĐÂY) ===
                %s

                === CÁCH LẤY DỮ LIỆU (BẮT BUỘC) ===
                %s

                === SQL SCHEMA TRUST MAP ===
                %s

                === DISH SCORING RUBRIC ===
                %s

                %s
                === QUY TẮC BẮT BUỘC ===
                1. CHỈ chọn món trong danh sách thực đơn hệ thống.
                2. Không bịa món, không bịa nhà hàng.
                3. Mỗi lần đề xuất 2-3 món và bắt buộc có ít nhất 1 healthy alternative.
                4. Nếu thiếu dữ liệu quan trọng thì needs_clarification=true, hỏi tối đa 2 câu ngắn.
                5. Nếu người dùng mơ hồ, vẫn đưa 2 gợi ý tạm an toàn trước.
                6. Nếu người dùng chọn món kém lành mạnh liên tục, phản hồi đồng hành, không phán xét.
                7. Ưu tiên thứ tự: dị ứng/an toàn -> mục tiêu sức khỏe -> khẩu vị/lịch sử -> thời điểm realtime.
                8. Giữ giọng điệu thân thiện, tự nhiên, không giáo điều.

                === OUTPUT CONTRACT (BẮT BUỘC JSON THUẦN, KHÔNG markdown, KHÔNG văn bản ngoài JSON) ===
                {
                  "intent": "string",
                  "response_tone": "friendly|consultative|concise",
                  "needs_clarification": true/false,
                  "clarification_questions": ["...","..."],
                  "natural_response": "string",
                  "recommendations": [
                    {
                      "dish_name": "string",
                      "reason": "string",
                      "reason_evidence": ["profile"|"history"|"menu"|"realtime"],
                      "health_score": 1-10,
                      "confidence": 0.0-1.0,
                      "estimated_calories": number|null,
                      "price_level": "low|medium|high|unknown",
                      "tags": ["..."],
                      "is_healthy_alternative": true/false
                    }
                  ],
                  "nutrition_note": "string",
                  "warnings": ["..."],
                  "memory_writeback": [
                    {"key":"food_preferences|allergies|health_goal|disliked_items|other","value":"string","confidence":0.0}
                  ],
                  "cta": "string"
                }
                Ràng buộc: recommendations phải có 2 hoặc 3 món và luôn có >=1 món is_healthy_alternative=true.
                """.formatted(
                buildProfileContext(ctx.profile()),
                safe(ctx.foodHistory(), "Chưa có lịch sử."),
                buildRealtimeContext(),
                buildSafetyPolicy(ctx.profile()),
                buildRecentConversation(ctx.history()),
                safe(ctx.learnedPreferences(), "- Chưa có dữ liệu học thói quen."),
                safe(ctx.menuContext(), "- Menu chưa tải được."),
                buildCandidatesContext(ctx.candidates()),
                buildDataSourcingGuideline(ctx.location()),
                SCHEMA_TRUST,
                RUBRIC,
                buildFewShotBlock(healthGoal, 5)
        );
    }

    // ── Welcome message (used in doGet) ───────────────────────────────────────

    public String buildWelcomeMessage(String name, List<String> topFoods) {
        String n = safe(name, "bạn");
        if (topFoods == null || topFoods.isEmpty()) {
            return "Chào " + n + "! Hôm nay bạn muốn dùng bữa kiểu gì nhỉ? "
                 + "Mình sẽ gợi ý món phù hợp theo mục tiêu sức khỏe và vị trí hiện tại của bạn.";
        }
        if (topFoods.size() == 1) {
            return "Chào " + n + "! Mình thấy bạn hay chọn " + topFoods.get(0)
                 + ". Hôm nay bạn muốn ăn tương tự hay thử món mới gần khu vực của bạn?";
        }
        return "Chào " + n + "! Mình thấy gần đây bạn hay mua " + topFoods.get(0)
             + " và " + topFoods.get(1)
             + ". Hôm nay mình gợi ý vài món gần gũi và giao được tới chỗ bạn nhé?";
    }

    // ── Private builders ──────────────────────────────────────────────────────

    private String buildProfileContext(CustomerProfile p) {
        if (p == null) return "Chưa có hồ sơ cá nhân hóa (sở thích, dị ứng, mục tiêu sức khỏe).";
        return "- Sở thích món: " + safe(p.getFoodPreferences(), "Chưa khai báo") + "\n"
             + "- Dị ứng/không dung nạp: " + safe(p.getAllergies(), "Chưa khai báo") + "\n"
             + "- Mục tiêu sức khỏe: " + safe(p.getHealthGoal(), "Chưa khai báo") + "\n"
             + "- Mục tiêu calo/ngày: " + (p.getDailyCalorieTarget() == null
                     ? "Chưa khai báo" : p.getDailyCalorieTarget());
    }

    private String buildSafetyPolicy(CustomerProfile p) {
        StringBuilder sb = new StringBuilder("- Luôn ưu tiên an toàn thực phẩm và không gợi ý món mâu thuẫn với dị ứng.\n");
        if (p == null) {
            sb.append("- Hồ sơ sức khỏe chưa đủ dữ liệu, AI phải khuyến nghị bảo thủ và nhắc người dùng cập nhật profile.");
            return sb.toString();
        }
        String allergies = normalize(p.getAllergies());
        if (!allergies.isEmpty())
            sb.append("- CẤM đề xuất món có từ khóa liên quan dị ứng: ").append(p.getAllergies()).append(".\n");

        String goal = normalize(p.getHealthGoal());
        if (goal.contains("giam can") || goal.contains("eat clean") || goal.contains("healthy"))
            sb.append("- Ưu tiên món không chiên, calo vừa phải, nhiều rau và đạm nạc.\n");
        if (goal.contains("tang co") || goal.contains("muscle") || goal.contains("protein"))
            sb.append("- Ưu tiên món giàu protein và cân bằng năng lượng.\n");
        if (goal.contains("tieu duong") || goal.contains("it duong") || goal.contains("giam duong"))
            sb.append("- Hạn chế món nhiều đường và món chiên nhiều dầu.\n");

        if (p.getDailyCalorieTarget() != null && p.getDailyCalorieTarget() > 0) {
            int perMeal = Math.max(250, p.getDailyCalorieTarget() / 3);
            sb.append("- Calo mục tiêu tham chiếu mỗi bữa khoảng ").append(perMeal).append(" kcal.\n");
        }
        return sb.toString().trim();
    }

    private String buildRealtimeContext() {
        LocalTime now = LocalTime.now();
        int h = now.getHour();
        String slot = h >= 5 && h < 11 ? "sáng"
                : h >= 11 && h < 14 ? "trưa"
                : h >= 14 && h < 18 ? "chiều"
                : h >= 18 && h < 23 ? "tối"
                : "khuya";
        return "- Thời điểm hiện tại: " + slot + " (" + now.withSecond(0).withNano(0) + ")";
    }

    private String buildRecentConversation(List<ChatTurn> history) {
        if (history == null || history.isEmpty())
            return "- Chưa có lịch sử trước đó trong phiên hiện tại.";

        int start = Math.max(0, history.size() - 12); // last 6 turns
        StringBuilder sb = new StringBuilder();
        for (int i = start; i < history.size(); i++) {
            ChatTurn t = history.get(i);
            String label = "model".equalsIgnoreCase(t.role()) ? "AI" : "Khách";
            String text = t.text().replaceAll("\\s+", " ").trim();
            if (text.length() > 140) text = text.substring(0, 140) + "...";
            if (!text.isEmpty()) sb.append("- ").append(label).append(": ").append(text).append("\n");
        }
        String r = sb.toString().trim();
        return r.isEmpty() ? "- Chưa có lịch sử trước đó trong phiên hiện tại." : r;
    }

    private String buildCandidatesContext(List<FoodItem> foods) {
        if (foods == null || foods.isEmpty())
            return "- Chưa có ứng viên món đã lọc. Hãy chọn từ danh sách menu hệ thống và giữ đúng rule an toàn/phạm vi giao.";
        StringBuilder sb = new StringBuilder();
        for (FoodItem f : foods) {
            if (f == null) continue;
            sb.append("- ").append(safe(f.getName(), "Món ăn"))
              .append(" | ").append(safe(f.getMerchantName(), "Nhà hàng"))
              .append(" | ").append(Math.round(f.getPrice())).append("đ\n");
        }
        String r = sb.toString().trim();
        return r.isEmpty()
                ? "- Chưa có ứng viên món đã lọc. Hãy chọn từ danh sách menu hệ thống."
                : r;
    }

    private String buildDataSourcingGuideline(UserLocation loc) {
        boolean hasLoc = loc != null && loc.isValid();
        return "1) Món và giá: ưu tiên từ block ứng viên món đã lọc; nếu thiếu mới từ danh sách menu hệ thống.\n"
             + "2) Sức khỏe và dị ứng: bắt buộc theo hồ sơ cá nhân hóa và chính sách an toàn.\n"
             + "3) Sở thích và cách nói chuyện: dùng lịch sử ăn uống + ngữ cảnh hội thoại gần nhất + trí nhớ thói quen chat.\n"
             + "4) Vị trí hiện tại: "
             + (hasLoc ? "đã có tọa độ, chỉ chọn món trong phạm vi có thể giao."
                       : "chưa có tọa độ realtime, ưu tiên món an toàn và có thể hỏi khách bật vị trí khi cần.");
    }

    /**
     * Builds few-shot examples from high-rated training events.
     * Total size is capped to protect context window budget.
     */
    private String buildFewShotBlock(String healthGoal, int maxExamples) {
        try {
            List<com.clickeat.model.AITrainingEvent> examples =
                    new AITrainingEventDAO().findTopRatedExamples(maxExamples, healthGoal);
            if (examples == null || examples.isEmpty()) return "";

            StringBuilder sb = new StringBuilder(
                    "=== VÍ DỤ TRẢ LỜI TỐT (Học từ phản hồi thực tế của người dùng) ===\n"
                    + "Dưới đây là các cặp câu hỏi - trả lời được người dùng đánh giá HỮU ÍCH.\n"
                    + "Hãy học phong cách trả lời từ các ví dụ này.\n\n");

            int count = 0;
            int totalChars = 0;
            final int MAX_TOTAL_CHARS = 2000; // hard cap to protect context window

            for (com.clickeat.model.AITrainingEvent ex : examples) {
                String q = safe(ex.getUserMessage(), "").trim();
                String a = safe(ex.getAiReply(), "").trim();
                if (q.isEmpty() || a.isEmpty()) continue;
                if (q.length() > 180) q = q.substring(0, 180) + "...";
                if (a.length() > 320) a = a.substring(0, 320) + "...";

                int chunkSize = q.length() + a.length() + 30;
                if (totalChars + chunkSize > MAX_TOTAL_CHARS) break;

                sb.append("Ví dụ ").append(++count).append(":\n")
                  .append("  Khách hỏi: ").append(q).append("\n")
                  .append("  AI trả lời: ").append(a).append("\n\n");
                totalChars += chunkSize;
            }
            return count == 0 ? "" : sb.append("\n").toString();

        } catch (Exception e) {
            return ""; // Never crash main flow
        }
    }

    // ── Static context strings ────────────────────────────────────────────────

    private static final String SCHEMA_TRUST =
            "- merchants.is_open + merchant_addresses: only use open merchants that can deliver.\n"
          + "- food_items.price + food_items.name + categories.name: source of truth for dish name/price/category.\n"
          + "- vouchers: only mention currently valid vouchers.\n"
          + "- customer_profile: source of truth for personalization and safety.\n"
          + "- orders + order_items: use for preference inference only, never invent off-system items.";

    private static final String RUBRIC =
            "- Score each dish: health_fit(40%) + preference_fit(25%) + context_fit(20%) + conversion_potential(15%).\n"
          + "- health_fit: align with health goal, avoid allergens, keep calories reasonable.\n"
          + "- preference_fit: align with taste profile and recent purchase history.\n"
          + "- context_fit: fit current time, delivery feasibility, and budget.\n"
          + "- conversion_potential: maximize order likelihood (familiar option + healthy alternative).\n"
          + "- Sort recommendations by total score descending before returning.";

    // ── Utilities ─────────────────────────────────────────────────────────────

    private static String safe(String v, String fallback) {
        return v == null || v.isBlank() ? fallback : v.trim();
    }

    private static String normalize(String v) {
        if (v == null) return "";
        String low = v.toLowerCase(Locale.ROOT).trim();
        return java.text.Normalizer.normalize(low, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
    }
}
