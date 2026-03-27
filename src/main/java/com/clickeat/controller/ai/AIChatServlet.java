package com.clickeat.controller.ai;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.json.JSONArray;
import org.json.JSONObject;

import com.clickeat.dal.impl.AITrainingEventDAO;
import com.clickeat.dal.impl.AIUserPreferenceSignalDAO;
import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.CustomerProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.AITrainingEvent;
import com.clickeat.model.Address;
import com.clickeat.model.CustomerProfile;
import com.clickeat.model.FoodItem;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AIChatServlet", urlPatterns = {"/ai"})
public class AIChatServlet extends HttpServlet {

    private static final String GEMINI_API_URL_PREFIX = "https://generativelanguage.googleapis.com/v1beta/models/";
    private static final String GEMINI_API_URL_SUFFIX = ":generateContent?key=";
    private static final String OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";
    private static final int MAX_HISTORY_TURNS = 8;
    private static final Logger LOGGER = Logger.getLogger(AIChatServlet.class.getName());
    private final AIUserPreferenceSignalDAO preferenceSignalDAO = new AIUserPreferenceSignalDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null) {
            String msg = URLEncoder.encode("Vui lòng đăng nhập để sử dụng AI", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login?msg=" + msg);
            return;
        }

        request.setAttribute("customerName", account.getFullName());

        // Lấy dữ liệu thật từ DB cho widget sidebar
        OrderDAO sidebarDAO = new OrderDAO();
        List<String> topFoods = sidebarDAO.getTopOrderedFoodNames(account.getId(), 30, 2);
        request.setAttribute("welcomeAiMessage", buildWelcomeMessage(account.getFullName(), topFoods));

        // Widget: "Đã ăn hôm qua"
        List<Map<String, Object>> yesterdayOrders = sidebarDAO.getYesterdayOrdersWithMerchant(account.getId());
        request.setAttribute("yesterdayOrders", yesterdayOrders);

        // Widget: "Cửa hàng yêu thích"
        Map<String, Object> favoriteMerchant = sidebarDAO.getFavoriteMerchant(account.getId());
        request.setAttribute("favoriteMerchant", favoriteMerchant);

        String feedbackStatus = request.getParameter("fb");
        if (feedbackStatus != null) {
            request.setAttribute("feedbackStatus", feedbackStatus);
        }

        request.setAttribute("chatHistoryView", buildChatHistoryView(getConversationHistory(request)));

        request.setAttribute("currentPage", "ai-chat");
        request.getRequestDispatcher("/views/ai/ai-chat.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User account = (User) request.getSession().getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userMessage = request.getParameter("message");
        if (userMessage == null || userMessage.trim().isEmpty()) {
            doGet(request, response);
            return;
        }
        String normalizedUserMessage = userMessage.trim();
        List<ChatTurn> historyTurns = getConversationHistory(request);

        // 2. Lấy lịch sử 14 ngày qua
        OrderDAO orderDAO = new OrderDAO();
        CustomerProfileDAO customerProfileDAO = new CustomerProfileDAO();
        CustomerProfile profile = customerProfileDAO.findByUserId(account.getId());
        UserLocation userLocation = resolveUserLocation(request, account.getId());
        List<FoodItem> suggestedFoods = orderDAO.getRecommendedFoodCards(
                profile,
                normalizedUserMessage,
                3,
                userLocation.latitude,
                userLocation.longitude);
        String foodHistory = orderDAO.getCustomerFoodHistory(account.getId(), 14);
        String menuContext = orderDAO.getPersonalizedMenuContext(profile, 20);
        String profileContext = buildProfileContext(profile);
        String safetyPolicyContext = buildSafetyPolicyContext(profile);
        String realtimeTimeContext = buildRealtimeTimeContext();

        // 2b. Lấy few-shot examples từ training data (thay cho fine-tuning)
        String healthGoal = (profile != null) ? profile.getHealthGoal() : null;
        String fewShotBlock = buildFewShotBlock(healthGoal, 5);
        String recentConversationContext = buildRecentConversationContext(historyTurns, 6);
        String suggestedFoodContext = buildSuggestedFoodsContext(suggestedFoods);
        String dataSourcingGuideline = buildDataSourcingGuideline(userLocation);
        String learnedPreferenceContext = buildLearnedPreferenceContext(request, account.getId());

        // 3. Xây dựng System Instruction dạng structured output để chạy production ổn định
        String systemInstruction
                = "Bạn là ClickEat Smart Nutrition & Ordering Assistant.\n"
                + "Mục tiêu ưu tiên: trải nghiệm tự nhiên, cá nhân hóa, tăng tỷ lệ chốt đơn, và an toàn sức khỏe.\n"
                + "Bạn chỉ cung cấp khuyến nghị dinh dưỡng tổng quát theo tinh thần WHO, không chẩn đoán y khoa.\n\n"
                + "=== HỒ SƠ CÁ NHÂN HÓA CỦA KHÁCH ===\n"
                + profileContext + "\n\n"
                + "=== DỮ LIỆU LỊCH SỬ ĂN UỐNG CỦA KHÁCH ===\n"
                + foodHistory + "\n\n"
                + "=== NGỮ CẢNH REALTIME ===\n"
                + realtimeTimeContext + "\n\n"
                + "=== CHÍNH SÁCH AN TOÀN BẮT BUỘC ===\n"
                + safetyPolicyContext + "\n\n"
                + "=== NGỮ CẢNH HỘI THOẠI GẦN NHẤT ===\n"
                + recentConversationContext + "\n\n"
                + "=== TRÍ NHỚ THÓI QUEN TỪ CÁC LẦN CHAT TRƯỚC ===\n"
                + learnedPreferenceContext + "\n\n"
                + "=== DANH SÁCH THỰC ĐƠN HIỆN CÓ TỪ HỆ THỐNG ===\n"
                + menuContext + "\n\n"
                + "=== ỨNG VIÊN MÓN ĐÃ LỌC SẴN (ƯU TIÊN CHỌN TỪ ĐÂY) ===\n"
                + suggestedFoodContext + "\n\n"
                + "=== CÁCH LẤY DỮ LIỆU (BẮT BUỘC) ===\n"
                + dataSourcingGuideline + "\n\n"
                + fewShotBlock
                + "=== QUY TẮC BẮT BUỘC ===\n"
                + "1. CHỈ chọn món trong danh sách thực đơn hệ thống.\n"
                + "2. Không bịa món, không bịa nhà hàng.\n"
                + "3. Mỗi lần đề xuất 2-3 món và bắt buộc có ít nhất 1 healthy alternative.\n"
                + "4. Nếu thiếu dữ liệu quan trọng thì needs_clarification=true, hỏi tối đa 2 câu ngắn.\n"
                + "5. Nếu người dùng mơ hồ, vẫn đưa 2 gợi ý tạm an toàn trước.\n"
                + "6. Nếu người dùng chọn món kém lành mạnh liên tục, phản hồi đồng hành, không phán xét.\n"
                + "7. Ưu tiên thứ tự: dị ứng/an toàn -> mục tiêu sức khỏe -> khẩu vị/lịch sử -> thời điểm realtime.\n"
                + "8. Giữ giọng điệu thân thiện, tự nhiên, không giáo điều.\n\n"
                + "=== OUTPUT CONTRACT (BẮT BUỘC JSON THUẦN, KHÔNG markdown, KHÔNG văn bản ngoài JSON) ===\n"
                + "{\n"
                + "  \"intent\": \"string\",\n"
                + "  \"needs_clarification\": true/false,\n"
                + "  \"clarification_questions\": [\"...\",\"...\"],\n"
                + "  \"natural_response\": \"string\",\n"
                + "  \"recommendations\": [\n"
                + "    {\n"
                + "      \"dish_name\": \"string\",\n"
                + "      \"reason\": \"string\",\n"
                + "      \"health_score\": 1-10,\n"
                + "      \"estimated_calories\": number|null,\n"
                + "      \"price_level\": \"low|medium|high|unknown\",\n"
                + "      \"tags\": [\"...\"],\n"
                + "      \"is_healthy_alternative\": true/false\n"
                + "    }\n"
                + "  ],\n"
                + "  \"nutrition_note\": \"string\",\n"
                + "  \"warnings\": [\"...\"],\n"
                + "  \"memory_writeback\": [\n"
                + "    {\"key\":\"food_preferences|allergies|health_goal|disliked_items|other\",\"value\":\"string\",\"confidence\":0.0}\n"
                + "  ],\n"
                + "  \"cta\": \"string\"\n"
                + "}\n"
                + "Ràng buộc: recommendations phải có 2 hoặc 3 món và luôn có >=1 món is_healthy_alternative=true.";

        // 4. Gọi AI API — ưu tiên OpenAI, fallback Gemini nếu chưa cấu hình
        String aiProvider = "openai";
        String rawAiOutput = callOpenAIAPI(systemInstruction, normalizedUserMessage, historyTurns);
        if (rawAiOutput == null) {
            aiProvider = "gemini";
            rawAiOutput = callGeminiAPI(systemInstruction, normalizedUserMessage, historyTurns);
        }
        if (rawAiOutput == null || rawAiOutput.isBlank()) {
            aiProvider = "none";
        }

        StructuredAiResponse structured = parseStructuredAiResponse(rawAiOutput, suggestedFoods, normalizedUserMessage);
        logStructuredInference(account.getId(), aiProvider, normalizedUserMessage, rawAiOutput, structured);
        String aiResponseText = composeNaturalChatReply(structured);

        updatePreferenceMemory(request, account.getId(), normalizedUserMessage);
        applyStructuredMemoryWriteback(customerProfileDAO, profile, account.getId(), structured);

        long interactionId = logTrainingEvent(account.getId(), normalizedUserMessage, profileContext, menuContext,
                historyToContext(historyTurns), profile, aiResponseText);

        appendConversationHistory(request, "user", normalizedUserMessage);
        appendConversationHistory(request, "model", aiResponseText);

        // Đẩy dữ liệu ra view
        request.setAttribute("userMessage", userMessage);
        request.setAttribute("aiReply", aiResponseText);
        request.setAttribute("suggestedFoods", suggestedFoods);
        request.setAttribute("aiStructuredRecommendations", buildRecommendationCards(structured, suggestedFoods));
        request.setAttribute("aiNutritionNote", safe(structured.nutritionNote, ""));
        request.setAttribute("aiNeedsClarification", structured.needsClarification);
        request.setAttribute("locationAwareEnabled", userLocation.latitude != null && userLocation.longitude != null);
        if (interactionId > 0) {
            request.setAttribute("aiInteractionId", interactionId);
        }

        doGet(request, response);
    }

    private String callGeminiAPI(String systemInstruction, String userMessage, List<ChatTurn> historyTurns) {
        try {
            String apiKey = resolveGeminiApiKey();
            if (apiKey.isBlank()) {
                return "AI chưa được cấu hình API key. Vui lòng cấu hình GEMINI_API_KEY hoặc context-param gemini.api.key trong web.xml.";
            }

            JSONObject payload = new JSONObject();

            // Setup System Instruction
            JSONObject sysInstObj = new JSONObject();
            sysInstObj.put("parts", new JSONArray().put(new JSONObject().put("text", systemInstruction)));
            payload.put("system_instruction", sysInstObj);
            payload.put("generationConfig", new JSONObject()
                    .put("temperature", 0.45)
                    .put("topP", 0.9)
                    .put("maxOutputTokens", 220));

            // Setup User Message
            JSONArray contents = new JSONArray();
            for (ChatTurn turn : historyTurns) {
                JSONObject turnContent = new JSONObject();
                turnContent.put("role", "model".equalsIgnoreCase(turn.role) ? "model" : "user");
                turnContent.put("parts", new JSONArray().put(new JSONObject().put("text", turn.text)));
                contents.put(turnContent);
            }

            JSONObject userContent = new JSONObject();
            userContent.put("role", "user");
            userContent.put("parts", new JSONArray().put(new JSONObject().put("text", userMessage)));
            contents.put(userContent);
            payload.put("contents", contents);

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(buildGeminiApiUrl(apiKey)))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            JSONObject jsonResponse = new JSONObject(response.body());

            // Xử lý lỗi nếu API key sai hoặc hết hạn
            if (jsonResponse.has("error")) {
                return "Hệ thống AI đang bảo trì. Vui lòng thử lại sau (" + jsonResponse.getJSONObject("error").getString("message") + ").";
            }

            return jsonResponse.getJSONArray("candidates")
                    .getJSONObject(0)
                    .getJSONObject("content")
                    .getJSONArray("parts")
                    .getJSONObject(0)
                    .getString("text");

        } catch (Exception e) {
            e.printStackTrace();
            return "Xin lỗi, tôi đang gặp sự cố kết nối. Vui lòng thử lại sau.";
        }
    }

    private String normalizeAiReplyText(String rawReply) {
        if (rawReply == null || rawReply.isBlank()) {
            return "Xin lỗi, mình chưa trả lời được lúc này. Bạn thử lại giúp mình nhé.";
        }

        String[] lines = rawReply.replace("\r", "\n").split("\n");
        StringBuilder sb = new StringBuilder();
        for (String line : lines) {
            if (line == null) {
                continue;
            }
            String trimmed = line.trim();
            if (trimmed.isEmpty()) {
                continue;
            }
            trimmed = trimmed.replaceFirst("^[-*•\\d+.)\\s]+", "").trim();
            if (trimmed.isEmpty()) {
                continue;
            }
            if (sb.length() > 0) {
                sb.append(' ');
            }
            sb.append(trimmed);
        }

        String normalized = sb.toString().replaceAll("\\s+", " ").trim();
        return normalized.isEmpty()
                ? "Xin lỗi, mình chưa trả lời được lúc này. Bạn thử lại giúp mình nhé."
                : normalized;
    }

    private String buildWelcomeMessage(String customerName, List<String> topFoods) {
        String safeName = safe(customerName, "bạn");
        if (topFoods == null || topFoods.isEmpty()) {
            return "Chào " + safeName + "! Hôm nay bạn muốn dùng bữa kiểu gì nhỉ? Mình sẽ gợi ý món phù hợp theo mục tiêu sức khỏe và vị trí hiện tại của bạn.";
        }

        if (topFoods.size() == 1) {
            return "Chào " + safeName + "! Mình thấy bạn hay chọn " + topFoods.get(0)
                    + ". Hôm nay bạn muốn ăn tương tự hay thử món mới gần khu vực của bạn?";
        }

        return "Chào " + safeName + "! Mình thấy gần đây bạn hay mua " + topFoods.get(0)
                + " và " + topFoods.get(1)
                + ". Hôm nay mình gợi ý vài món gần gu và giao được tới chỗ bạn nhé?";
    }

    private String buildRecentConversationContext(List<ChatTurn> historyTurns, int maxTurns) {
        if (historyTurns == null || historyTurns.isEmpty()) {
            return "- Chưa có lịch sử trước đó trong phiên hiện tại.";
        }

        int safeMaxTurns = Math.max(1, Math.min(maxTurns, 10));
        int start = Math.max(0, historyTurns.size() - (safeMaxTurns * 2));
        StringBuilder sb = new StringBuilder();
        for (int i = start; i < historyTurns.size(); i++) {
            ChatTurn turn = historyTurns.get(i);
            String roleLabel = "model".equalsIgnoreCase(turn.role) ? "AI" : "Khách";
            String text = safe(turn.text, "").replaceAll("\\s+", " ").trim();
            if (text.length() > 140) {
                text = text.substring(0, 140) + "...";
            }
            if (text.isEmpty()) {
                continue;
            }
            sb.append("- ").append(roleLabel).append(": ").append(text).append("\n");
        }

        String result = sb.toString().trim();
        return result.isEmpty() ? "- Chưa có lịch sử trước đó trong phiên hiện tại." : result;
    }

    private String buildSuggestedFoodsContext(List<FoodItem> foods) {
        if (foods == null || foods.isEmpty()) {
            return "- Chưa có ứng viên món đã lọc. Hãy chọn từ danh sách menu hệ thống và giữ đúng rule an toàn/phạm vi giao.";
        }

        StringBuilder sb = new StringBuilder();
        for (FoodItem food : foods) {
            if (food == null) {
                continue;
            }
            sb.append("- ")
                    .append(safe(food.getName(), "Món ăn"))
                    .append(" | ")
                    .append(safe(food.getMerchantName(), "Nhà hàng"))
                    .append(" | ")
                    .append(Math.round(food.getPrice()))
                    .append("đ\n");
        }
        String result = sb.toString().trim();
        return result.isEmpty()
                ? "- Chưa có ứng viên món đã lọc. Hãy chọn từ danh sách menu hệ thống và giữ đúng rule an toàn/phạm vi giao."
                : result;
    }

    private String buildDataSourcingGuideline(UserLocation userLocation) {
        boolean hasLocation = userLocation != null
                && userLocation.latitude != null
                && userLocation.longitude != null;
        return "1) Món và giá: ưu tiên từ block ứng viên món đã lọc; nếu thiếu mới dò danh sách menu hệ thống.\n"
                + "2) Sức khỏe và dị ứng: bắt buộc theo hồ sơ cá nhân hóa và chính sách an toàn.\n"
                + "3) Sở thích và cách nói chuyện: dùng lịch sử ăn uống + ngữ cảnh hội thoại gần nhất + trí nhớ thói quen chat.\n"
                + "4) Vị trí hiện tại: "
                + (hasLocation
                        ? "đã có tọa độ, chỉ chọn món trong phạm vi có thể giao."
                        : "chưa có tọa độ realtime, ưu tiên món an toàn và có thể hỏi khách bật vị trí khi cần.");
    }

    private String buildLearnedPreferenceContext(HttpServletRequest request, int userId) {
        Map<String, Integer> merged = new LinkedHashMap<>();

        Map<String, Integer> sessionMemory = getPreferenceMemory(request);
        for (Map.Entry<String, Integer> entry : sessionMemory.entrySet()) {
            merged.put(entry.getKey(), entry.getValue());
        }

        Map<String, Integer> persistentMemory = preferenceSignalDAO.getTopSignals(userId, 12);
        for (Map.Entry<String, Integer> entry : persistentMemory.entrySet()) {
            Integer current = merged.get(entry.getKey());
            merged.put(entry.getKey(), (current == null ? 0 : current) + entry.getValue());
        }

        if (merged.isEmpty()) {
            return "- Chưa có dữ liệu học thói quen từ chat trước trong phiên này.";
        }

        List<Map.Entry<String, Integer>> entries = new ArrayList<>(merged.entrySet());
        entries.sort((a, b) -> Integer.compare(b.getValue(), a.getValue()));

        StringBuilder sb = new StringBuilder();
        int count = 0;
        for (Map.Entry<String, Integer> entry : entries) {
            sb.append("- ").append(entry.getKey()).append(" (ưu tiên ").append(entry.getValue()).append(")\n");
            count++;
            if (count >= 6) {
                break;
            }
        }
        return sb.toString().trim();
    }

    private void updatePreferenceMemory(HttpServletRequest request, int userId, String userMessage) {
        if (userMessage == null || userMessage.isBlank()) {
            return;
        }

        Map<String, Integer> memory = getPreferenceMemory(request);
        String normalized = normalize(userMessage);

        if (normalized.contains("ga ran") || normalized.contains("ga chien")) {
            rememberPreference(memory, userId, "fried-chicken", "Ưa món gà rán/chiên");
        }
        if (normalized.contains("banh trang") || normalized.contains("cuon")) {
            rememberPreference(memory, userId, "roll-snack", "Thích món cuốn và ăn vặt");
        }
        if (normalized.contains("com")) {
            rememberPreference(memory, userId, "rice-meal", "Quan tâm nhóm món cơm");
        }
        if (normalized.contains("bun") || normalized.contains("pho") || normalized.contains("mi")) {
            rememberPreference(memory, userId, "noodle-soup", "Hay chọn món nước/noodle");
        }
        if (normalized.contains("tra sua") || normalized.contains("do uong") || normalized.contains("nuoc")) {
            rememberPreference(memory, userId, "drink-choice", "Quan tâm đồ uống");
        }
        if (normalized.contains("healthy") || normalized.contains("eat clean") || normalized.contains("giam can")) {
            rememberPreference(memory, userId, "healthy-focus", "Ưu tiên món healthy/kiểm soát calo");
        }
        if (normalized.contains("an dem") || normalized.contains("khuya")) {
            rememberPreference(memory, userId, "late-night", "Nhu cầu ăn khuya");
        }
        if (normalized.contains("khong hanh") || normalized.contains("di ung") || normalized.contains("khong") && normalized.contains("an")) {
            rememberPreference(memory, userId, "ingredient-constraint", "Có ràng buộc nguyên liệu khi chọn món");
        }

        request.getSession().setAttribute("aiPreferenceMemory", memory);
    }

    private Map<String, Integer> getPreferenceMemory(HttpServletRequest request) {
        @SuppressWarnings("unchecked")
        Map<String, Integer> memory = (Map<String, Integer>) request.getSession().getAttribute("aiPreferenceMemory");
        if (memory == null) {
            memory = new LinkedHashMap<>();
            request.getSession().setAttribute("aiPreferenceMemory", memory);
        }
        return memory;
    }

    private void incrementMemory(Map<String, Integer> memory, String key) {
        Integer current = memory.get(key);
        memory.put(key, current == null ? 1 : current + 1);
    }

    private void rememberPreference(Map<String, Integer> memory, int userId, String signalKey, String signalLabel) {
        incrementMemory(memory, signalLabel);
        preferenceSignalDAO.incrementSignal(userId, signalKey, signalLabel);
    }

    /**
     * Gọi OpenAI Chat Completions API. API key và model được đọc từ web.xml
     * (context-param: openai.api.key, openai.model). Trả về null nếu chưa cấu
     * hình OpenAI để caller fallback sang Gemini.
     */
    private String callOpenAIAPI(String systemInstruction, String userMessage, List<ChatTurn> historyTurns) {
        try {
            // Đọc config từ web.xml
            String apiKey = getServletContext().getInitParameter("openai.api.key");
            String model = getServletContext().getInitParameter("openai.model");

            // Fallback: đọc từ biến môi trường nếu web.xml chưa set
            if (apiKey == null || apiKey.isBlank() || apiKey.startsWith("sk-YOUR")) {
                apiKey = System.getenv("OPENAI_API_KEY");
            }
            if (model == null || model.isBlank()) {
                model = "gpt-4o-mini";
            }
            if (apiKey == null || apiKey.isBlank()) {
                return null; // Chưa cấu hình — fallback Gemini
            }

            // Build messages array (system + history + user)
            JSONArray messages = new JSONArray();
            messages.put(new JSONObject()
                    .put("role", "system")
                    .put("content", systemInstruction));

            for (ChatTurn turn : historyTurns) {
                String role = "model".equalsIgnoreCase(turn.role) ? "assistant" : "user";
                messages.put(new JSONObject().put("role", role).put("content", turn.text));
            }
            messages.put(new JSONObject().put("role", "user").put("content", userMessage));

            JSONObject payload = new JSONObject()
                    .put("model", model)
                    .put("messages", messages)
                    .put("max_tokens", 220)
                    .put("temperature", 0.5)
                    .put("top_p", 0.9);

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(OPENAI_API_URL))
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                    .build();

            HttpResponse<String> res = HttpClient.newHttpClient()
                    .send(req, HttpResponse.BodyHandlers.ofString());

            JSONObject json = new JSONObject(res.body());
            if (json.has("error")) {
                String errorMessage = json.getJSONObject("error").optString("message");
                System.err.println("[OpenAI Error] " + errorMessage);
                return null; // Fallback sang Gemini khi OpenAI lỗi/quota
            }

            return json.getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content").trim();

        } catch (Exception e) {
            System.err.println("[OpenAI] Exception: " + e.getMessage());
            return null; // Fallback sang Gemini khi OpenAI lỗi kết nối
        }
    }

    private String resolveGeminiApiKey() {
        String fromWebXml = getServletContext().getInitParameter("gemini.api.key");
        if (fromWebXml != null && !fromWebXml.isBlank() && !fromWebXml.startsWith("AIza_YOUR")) {
            return fromWebXml.trim();
        }
        String fromWebXmlLegacy = getServletContext().getInitParameter("GEMINI_API_KEY");
        if (fromWebXmlLegacy != null && !fromWebXmlLegacy.isBlank()) {
            return fromWebXmlLegacy.trim();
        }
        String fromEnv = System.getenv("GEMINI_API_KEY");
        if (fromEnv != null && !fromEnv.isBlank()) {
            return fromEnv.trim();
        }
        String fromProperty = System.getProperty("GEMINI_API_KEY");
        if (fromProperty != null && !fromProperty.isBlank()) {
            return fromProperty.trim();
        }
        return "";
    }

    private UserLocation resolveUserLocation(HttpServletRequest request, int userId) {
        Double latFromRequest = parseCoordinate(request.getParameter("latitude"));
        Double lngFromRequest = parseCoordinate(request.getParameter("longitude"));
        if (isValidCoordinate(latFromRequest, lngFromRequest)) {
            request.getSession().setAttribute("aiUserLatitude", latFromRequest);
            request.getSession().setAttribute("aiUserLongitude", lngFromRequest);
            return new UserLocation(latFromRequest, lngFromRequest);
        }

        Object latSession = request.getSession().getAttribute("aiUserLatitude");
        Object lngSession = request.getSession().getAttribute("aiUserLongitude");
        Double latFromSession = parseCoordinate(latSession == null ? null : String.valueOf(latSession));
        Double lngFromSession = parseCoordinate(lngSession == null ? null : String.valueOf(lngSession));
        if (isValidCoordinate(latFromSession, lngFromSession)) {
            return new UserLocation(latFromSession, lngFromSession);
        }

        AddressDAO addressDAO = new AddressDAO();
        Address defaultAddress = addressDAO.findDefaultByUserId(userId);
        if (defaultAddress != null) {
            double lat = defaultAddress.getLatitude();
            double lng = defaultAddress.getLongitude();
            if (isValidCoordinate(lat, lng)) {
                return new UserLocation(lat, lng);
            }
        }
        return new UserLocation(null, null);
    }

    private Double parseCoordinate(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(raw.trim());
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private boolean isValidCoordinate(Double lat, Double lng) {
        return lat != null && lng != null
                && lat >= -90 && lat <= 90
                && lng >= -180 && lng <= 180;
    }

    private boolean isValidCoordinate(double lat, double lng) {
        return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    }

    private String resolveGeminiModel() {
        String fromWebXml = getServletContext().getInitParameter("gemini.model");
        if (fromWebXml != null && !fromWebXml.isBlank()) {
            return fromWebXml.trim();
        }
        String fromEnv = System.getenv("GEMINI_MODEL");
        if (fromEnv != null && !fromEnv.isBlank()) {
            return fromEnv.trim();
        }
        return "gemini-2.5-flash";
    }

    private String buildGeminiApiUrl(String apiKey) {
        String model = resolveGeminiModel();
        return GEMINI_API_URL_PREFIX + model + GEMINI_API_URL_SUFFIX + apiKey;
    }

    private String buildProfileContext(CustomerProfile profile) {
        if (profile == null) {
            return "Chưa có hồ sơ cá nhân hóa (sở thích, dị ứng, mục tiêu sức khỏe).";
        }

        String preferences = safe(profile.getFoodPreferences(), "Chưa khai báo");
        String allergies = safe(profile.getAllergies(), "Chưa khai báo");
        String healthGoal = safe(profile.getHealthGoal(), "Chưa khai báo");
        String dailyCalories = profile.getDailyCalorieTarget() == null ? "Chưa khai báo" : String.valueOf(profile.getDailyCalorieTarget());

        return "- Sở thích món: " + preferences + "\n"
                + "- Dị ứng/không dung nạp: " + allergies + "\n"
                + "- Mục tiêu sức khỏe: " + healthGoal + "\n"
                + "- Mục tiêu calo/ngày: " + dailyCalories;
    }

    private String buildSafetyPolicyContext(CustomerProfile profile) {
        List<String> rules = new ArrayList<>();
        rules.add("- Luôn ưu tiên an toàn thực phẩm và không gợi ý món mâu thuẫn với dị ứng.");

        if (profile == null) {
            rules.add("- Hồ sơ sức khỏe chưa đủ dữ liệu, AI phải khuyến nghị bảo thủ và nhắc người dùng cập nhật profile.");
            return String.join("\n", rules);
        }

        String allergies = normalize(profile.getAllergies());
        if (!allergies.isEmpty()) {
            rules.add("- CẤM đề xuất món có từ khóa liên quan dị ứng: " + profile.getAllergies() + ".");
        }

        String goal = normalize(profile.getHealthGoal());
        if (goal.contains("giam can") || goal.contains("eat clean") || goal.contains("healthy")) {
            rules.add("- Ưu tiên món không chiên, calo vừa phải, nhiều rau và đạm nạc.");
        }
        if (goal.contains("tang co") || goal.contains("muscle") || goal.contains("protein")) {
            rules.add("- Ưu tiên món giàu protein và cân bằng năng lượng.");
        }
        if (goal.contains("tieu duong") || goal.contains("it duong") || goal.contains("giam duong")) {
            rules.add("- Hạn chế món nhiều đường và món chiên nhiều dầu.");
        }

        if (profile.getDailyCalorieTarget() != null && profile.getDailyCalorieTarget() > 0) {
            int perMeal = Math.max(250, profile.getDailyCalorieTarget() / 3);
            rules.add("- Calo mục tiêu tham chiếu mỗi bữa khoảng " + perMeal + " kcal.");
        }

        return String.join("\n", rules);
    }

    private String safe(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        String lowered = value.toLowerCase(Locale.ROOT).trim();
        String normalized = java.text.Normalizer.normalize(lowered, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        return normalized;
    }

    /**
     * Lấy các ví dụ tốt nhất từ AITrainingEvents (feedback_score=1) và format
     * thành khối few-shot để inject vào system prompt Gemini. Đây là cách dùng
     * training data mà không cần fine-tuning.
     */
    private String buildFewShotBlock(String healthGoal, int maxExamples) {
        try {
            AITrainingEventDAO trainingDAO = new AITrainingEventDAO();
            List<com.clickeat.model.AITrainingEvent> examples
                    = trainingDAO.findTopRatedExamples(maxExamples, healthGoal);

            if (examples == null || examples.isEmpty()) {
                return ""; // Chưa có data training — bỏ qua, không ảnh hưởng prompt
            }

            StringBuilder sb = new StringBuilder("=== VÍ DỤ TRẢ LỜI TỐT (Học từ phản hồi thực tế của người dùng) ===\n");
            sb.append("Dưới đây là các cặp câu hỏi - trả lời được người dùng đánh giá HỮU ÍCH.\n");
            sb.append("Hãy học phong cách trả lời từ các ví dụ này.\n\n");

            int count = 0;
            for (com.clickeat.model.AITrainingEvent ex : examples) {
                String q = safe(ex.getUserMessage(), "").trim();
                String a = safe(ex.getAiReply(), "").trim();
                if (q.isEmpty() || a.isEmpty()) {
                    continue;
                }

                // Giới hạn độ dài mỗi ví dụ để tránh blow up context window
                if (q.length() > 200) {
                    q = q.substring(0, 200) + "...";
                }
                if (a.length() > 400) {
                    a = a.substring(0, 400) + "...";
                }

                sb.append("Ví dụ ").append(++count).append(":\n");
                sb.append("  Khách hỏi: ").append(q).append("\n");
                sb.append("  AI trả lời: ").append(a).append("\n\n");
            }

            if (count == 0) {
                return "";
            }

            sb.append("\n");
            return sb.toString();

        } catch (Exception e) {
            // Không làm crash main flow nếu query training data lỗi
            return "";
        }
    }

    private String buildRealtimeTimeContext() {
        LocalTime now = LocalTime.now();
        int hour = now.getHour();
        String slot;
        if (hour >= 5 && hour < 11) {
            slot = "sáng";
        } else if (hour >= 11 && hour < 14) {
            slot = "trưa";
        } else if (hour >= 14 && hour < 18) {
            slot = "chiều";
        } else if (hour >= 18 && hour < 23) {
            slot = "tối";
        } else {
            slot = "khuya";
        }
        return "- Thời điểm hiện tại: " + slot + " (" + now.withSecond(0).withNano(0) + ")";
    }

    private long logTrainingEvent(int userId,
            String userMessage,
            String profileContext,
            String menuContext,
            String conversationContext,
            CustomerProfile profile,
            String aiReply) {
        try {
            AITrainingEvent event = new AITrainingEvent();
            event.setUserId(userId);
            event.setUserMessage(userMessage);
            event.setSystemContext(buildCompactContext(profileContext, menuContext));
            event.setConversationContext(conversationContext);
            event.setAiReply(aiReply);
            event.setHasProfile(profile != null);
            event.setHealthGoal(profile == null ? null : profile.getHealthGoal());

            AITrainingEventDAO dao = new AITrainingEventDAO();
            return dao.insertEvent(event);
        } catch (Exception ignored) {
            return 0;
        }
    }

    private String buildCompactContext(String profileContext, String menuContext) {
        String compactProfile = safe(profileContext, "");
        String compactMenu = safe(menuContext, "");
        if (compactMenu.length() > 8000) {
            compactMenu = compactMenu.substring(0, 8000);
        }
        return "PROFILE:\n" + compactProfile + "\n\nMENU_SNIPPET:\n" + compactMenu;
    }

    private List<ChatTurn> getConversationHistory(HttpServletRequest request) {
        @SuppressWarnings("unchecked")
        List<ChatTurn> history = (List<ChatTurn>) request.getSession().getAttribute("aiConversationHistory");
        if (history == null) {
            history = new ArrayList<>();
            request.getSession().setAttribute("aiConversationHistory", history);
        }
        return new ArrayList<>(history);
    }

    private void appendConversationHistory(HttpServletRequest request, String role, String text) {
        @SuppressWarnings("unchecked")
        List<ChatTurn> history = (List<ChatTurn>) request.getSession().getAttribute("aiConversationHistory");
        if (history == null) {
            history = new ArrayList<>();
            request.getSession().setAttribute("aiConversationHistory", history);
        }

        history.add(new ChatTurn(role, safe(text, "")));
        int maxMessages = MAX_HISTORY_TURNS * 2;
        while (history.size() > maxMessages) {
            history.remove(0);
        }
    }

    private String historyToContext(List<ChatTurn> historyTurns) {
        if (historyTurns == null || historyTurns.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        int start = Math.max(0, historyTurns.size() - (MAX_HISTORY_TURNS * 2));
        for (int i = start; i < historyTurns.size(); i++) {
            ChatTurn t = historyTurns.get(i);
            sb.append("[").append(t.role).append("] ").append(safe(t.text, "")).append("\n");
        }
        return sb.toString();
    }

    private List<Map<String, Object>> buildChatHistoryView(List<ChatTurn> historyTurns) {
        List<Map<String, Object>> view = new ArrayList<>();
        if (historyTurns == null || historyTurns.isEmpty()) {
            return view;
        }

        for (ChatTurn turn : historyTurns) {
            Map<String, Object> row = new LinkedHashMap<>();
            boolean isModel = "model".equalsIgnoreCase(turn.getRole());
            row.put("role", turn.getRole());
            row.put("isModel", isModel);
            row.put("text", safe(turn.getText(), ""));
            view.add(row);
        }
        return view;
    }

    private StructuredAiResponse parseStructuredAiResponse(String raw,
            List<FoodItem> fallbackFoods,
            String userMessage) {
        StructuredAiResponse response = new StructuredAiResponse();
        response.intent = "fallback";
        response.naturalResponse = "Mình gợi ý nhanh vài món phù hợp để bạn chọn nhé.";

        JSONObject json = tryParseJsonObject(raw);
        if (json == null) {
            response.parsedJson = false;
            response.parseFailureReason = "invalid_json";
            response.usedFallbackRecommendations = true;
            response.recommendations = buildFallbackRecommendations(fallbackFoods);
            ensureHealthyAlternative(response.recommendations);
            response.nutritionNote = "Nếu bạn muốn mình cá nhân hóa kỹ hơn, cho mình biết mục tiêu sức khỏe và ngân sách nhé.";
            response.cta = "Bạn thích món đậm vị hay nhẹ bụng hơn?";
            return response;
        }

        response.parsedJson = true;

        response.intent = safe(json.optString("intent"), "fallback");
        response.needsClarification = json.optBoolean("needs_clarification", false);
        response.naturalResponse = safe(json.optString("natural_response"), response.naturalResponse);
        response.nutritionNote = safe(json.optString("nutrition_note"), "");
        response.cta = safe(json.optString("cta"), "Bạn muốn mình chốt món nào luôn?");

        JSONArray questions = json.optJSONArray("clarification_questions");
        if (questions != null) {
            for (int i = 0; i < questions.length() && i < 2; i++) {
                String q = questions.optString(i);
                if (q != null && !q.isBlank()) {
                    response.clarificationQuestions.add(q.trim());
                }
            }
        }

        JSONArray recs = json.optJSONArray("recommendations");
        if (recs != null) {
            for (int i = 0; i < recs.length() && i < 3; i++) {
                JSONObject item = recs.optJSONObject(i);
                if (item == null) {
                    continue;
                }
                Recommendation rec = new Recommendation();
                rec.dishName = safe(item.optString("dish_name"), "Món gợi ý");
                rec.reason = safe(item.optString("reason"), "Phù hợp nhu cầu hiện tại của bạn.");
                rec.healthScore = Math.max(1, Math.min(10, item.optInt("health_score", 7)));
                rec.estimatedCalories = item.has("estimated_calories") && !item.isNull("estimated_calories")
                        ? item.optInt("estimated_calories") : null;
                rec.priceLevel = safe(item.optString("price_level"), "unknown").toLowerCase(Locale.ROOT);
                JSONArray tags = item.optJSONArray("tags");
                if (tags != null) {
                    for (int t = 0; t < tags.length(); t++) {
                        String tag = safe(tags.optString(t), "");
                        if (!tag.isBlank()) {
                            rec.tags.add(tag);
                        }
                    }
                }
                rec.isHealthyAlternative = item.optBoolean("is_healthy_alternative", false);
                response.recommendations.add(rec);
            }
        }

        if (response.recommendations.size() < 2) {
            response.usedFallbackRecommendations = true;
            response.recommendations = buildFallbackRecommendations(fallbackFoods);
        }
        ensureHealthyAlternative(response.recommendations);

        JSONArray writeback = json.optJSONArray("memory_writeback");
        if (writeback != null) {
            for (int i = 0; i < writeback.length(); i++) {
                JSONObject wb = writeback.optJSONObject(i);
                if (wb == null) {
                    continue;
                }
                MemoryWritebackEntry entry = new MemoryWritebackEntry();
                entry.key = safe(wb.optString("key"), "").toLowerCase(Locale.ROOT);
                entry.value = safe(wb.optString("value"), "");
                entry.confidence = wb.optDouble("confidence", 0.0);
                if (!entry.key.isBlank() && !entry.value.isBlank()) {
                    response.memoryWritebacks.add(entry);
                }
            }
        }

        if (response.needsClarification && response.clarificationQuestions.isEmpty()) {
            response.clarificationQuestions.add("Bạn muốn ưu tiên ngon đậm vị hay lành mạnh hơn?");
        }

        if (response.cta.isBlank()) {
            response.cta = "Bạn muốn mình chốt món nào cho đơn này?";
        }

        if (response.naturalResponse.isBlank()) {
            response.naturalResponse = "Mình đã lọc nhanh các lựa chọn phù hợp cho bạn.";
        }

        if (response.intent.isBlank()) {
            response.intent = "fallback";
        }

        if (response.needsClarification && response.clarificationQuestions.isEmpty()) {
            response.clarificationQuestions.add("Bạn muốn ăn theo mục tiêu sức khỏe nào hôm nay?");
        }

        return response;
    }

    private JSONObject tryParseJsonObject(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        String text = raw.trim();

        if (text.startsWith("```") && text.contains("{")) {
            int firstBrace = text.indexOf('{');
            int lastBrace = text.lastIndexOf('}');
            if (firstBrace >= 0 && lastBrace > firstBrace) {
                text = text.substring(firstBrace, lastBrace + 1).trim();
            }
        }

        try {
            return new JSONObject(text);
        } catch (Exception ignored) {
            int firstBrace = text.indexOf('{');
            int lastBrace = text.lastIndexOf('}');
            if (firstBrace >= 0 && lastBrace > firstBrace) {
                try {
                    return new JSONObject(text.substring(firstBrace, lastBrace + 1));
                } catch (Exception ignoredAgain) {
                    return null;
                }
            }
            return null;
        }
    }

    private List<Recommendation> buildFallbackRecommendations(List<FoodItem> foods) {
        List<Recommendation> recs = new ArrayList<>();
        if (foods != null) {
            for (FoodItem food : foods) {
                if (food == null) {
                    continue;
                }
                Recommendation rec = new Recommendation();
                rec.dishName = safe(food.getName(), "Món gợi ý");
                rec.reason = "Món đang sẵn và phù hợp ngữ cảnh hiện tại của bạn.";
                rec.healthScore = food.isFried() ? 6 : 8;
                rec.isHealthyAlternative = !food.isFried();
                recs.add(rec);
                if (recs.size() >= 3) {
                    break;
                }
            }
        }

        while (recs.size() < 2) {
            Recommendation rec = new Recommendation();
            rec.dishName = recs.isEmpty() ? "Cơm gà nướng rau" : "Bún cá rau nhiều";
            rec.reason = "Lựa chọn cân bằng, dễ ăn và phù hợp nhiều nhu cầu.";
            rec.healthScore = 8;
            rec.isHealthyAlternative = true;
            recs.add(rec);
        }
        return recs;
    }

    private List<Map<String, Object>> buildRecommendationCards(StructuredAiResponse response, List<FoodItem> suggestedFoods) {
        List<Map<String, Object>> cards = new ArrayList<>();
        if (response == null || response.recommendations == null || response.recommendations.isEmpty()) {
            return cards;
        }

        for (Recommendation rec : response.recommendations) {
            if (rec == null || safe(rec.dishName, "").isBlank()) {
                continue;
            }

            Map<String, Object> card = new LinkedHashMap<>();
            FoodItem matchedFood = matchFoodByName(rec.dishName, suggestedFoods);

            card.put("dishName", safe(rec.dishName, "Món gợi ý"));
            card.put("reason", safe(rec.reason, "Phù hợp nhu cầu hiện tại của bạn."));
            card.put("healthScore", rec.healthScore);
            card.put("isHealthyAlternative", rec.isHealthyAlternative);
            card.put("estimatedCalories", rec.estimatedCalories);
            card.put("priceLevel", safe(rec.priceLevel, "unknown"));
            card.put("tags", rec.tags == null ? new ArrayList<>() : rec.tags);

            if (matchedFood != null) {
                card.put("foodId", matchedFood.getId());
                card.put("imageUrl", safe(matchedFood.getImageUrl(), ""));
                card.put("merchantName", safe(matchedFood.getMerchantName(), ""));
                card.put("price", matchedFood.getPrice());
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

    private FoodItem matchFoodByName(String dishName, List<FoodItem> foods) {
        if (foods == null || foods.isEmpty() || dishName == null || dishName.isBlank()) {
            return null;
        }
        String target = normalize(dishName);
        for (FoodItem food : foods) {
            if (food == null || food.getName() == null) {
                continue;
            }
            String foodName = normalize(food.getName());
            if (foodName.equals(target) || foodName.contains(target) || target.contains(foodName)) {
                return food;
            }
        }
        return null;
    }

    private void logStructuredInference(int userId,
            String provider,
            String userMessage,
            String rawOutput,
            StructuredAiResponse response) {
        try {
            int recommendationCount = response == null || response.recommendations == null ? 0 : response.recommendations.size();
            int writebackCount = response == null || response.memoryWritebacks == null ? 0 : response.memoryWritebacks.size();
            boolean parseOk = response != null && response.parsedJson;
            boolean fallbackRecs = response != null && response.usedFallbackRecommendations;

            LOGGER.info(() -> String.format(
                    "[AIChat] userId=%d provider=%s parseOk=%s fallbackRecs=%s intent=%s needsClarification=%s recs=%d writebacks=%d userMsgLen=%d rawLen=%d",
                    userId,
                    safe(provider, "unknown"),
                    parseOk,
                    fallbackRecs,
                    response == null ? "" : safe(response.intent, ""),
                    response != null && response.needsClarification,
                    recommendationCount,
                    writebackCount,
                    safe(userMessage, "").length(),
                    safe(rawOutput, "").length()));

            if (!parseOk || fallbackRecs) {
                String rawSnippet = safe(rawOutput, "").replaceAll("\\s+", " ").trim();
                if (rawSnippet.length() > 260) {
                    rawSnippet = rawSnippet.substring(0, 260) + "...";
                }
                String warning = "[AIChat] structured parse degraded"
                        + " parseOk=" + parseOk
                        + " fallbackRecs=" + fallbackRecs
                        + " reason=" + (response == null ? "unknown" : safe(response.parseFailureReason, "unknown"))
                        + " rawSnippet=" + rawSnippet;
                LOGGER.warning(warning);
            }
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "[AIChat] Failed to emit structured telemetry", ex);
        }
    }

    private void ensureHealthyAlternative(List<Recommendation> recs) {
        if (recs == null || recs.isEmpty()) {
            return;
        }
        for (Recommendation rec : recs) {
            if (rec != null && rec.isHealthyAlternative) {
                return;
            }
        }
        recs.get(0).isHealthyAlternative = true;
        if (recs.get(0).healthScore < 8) {
            recs.get(0).healthScore = 8;
        }
    }

    private String composeNaturalChatReply(StructuredAiResponse response) {
        StringBuilder sb = new StringBuilder();
        sb.append(safe(response.naturalResponse, "Mình gợi ý nhanh vài món để bạn chọn nhé."));

        if (response.recommendations != null && !response.recommendations.isEmpty()) {
            sb.append(" ");
            for (int i = 0; i < response.recommendations.size(); i++) {
                Recommendation rec = response.recommendations.get(i);
                if (rec == null) {
                    continue;
                }
                if (i > 0) {
                    sb.append(" ");
                }
                sb.append(i + 1).append(") ")
                        .append(safe(rec.dishName, "Món gợi ý"))
                        .append(" - ")
                        .append(safe(rec.reason, "phù hợp nhu cầu hiện tại"))
                        .append(".");
            }
        }

        if (!safe(response.nutritionNote, "").isBlank()) {
            sb.append(" ").append(response.nutritionNote.trim());
        }

        if (response.needsClarification && response.clarificationQuestions != null && !response.clarificationQuestions.isEmpty()) {
            sb.append(" ");
            for (int i = 0; i < response.clarificationQuestions.size(); i++) {
                if (i > 0) {
                    sb.append(" ");
                }
                sb.append(response.clarificationQuestions.get(i).trim());
            }
        }

        if (!safe(response.cta, "").isBlank()) {
            sb.append(" ").append(response.cta.trim());
        }

        return normalizeAiReplyText(sb.toString());
    }

    private void applyStructuredMemoryWriteback(CustomerProfileDAO customerProfileDAO,
            CustomerProfile profile,
            int userId,
            StructuredAiResponse response) {
        if (response == null || response.memoryWritebacks == null || response.memoryWritebacks.isEmpty()) {
            return;
        }

        CustomerProfile target = profile;
        if (target == null) {
            customerProfileDAO.ensureExists(userId);
            target = customerProfileDAO.findByUserId(userId);
            if (target == null) {
                target = new CustomerProfile();
                target.setUserId(userId);
            }
        }

        boolean profileDirty = false;
        for (MemoryWritebackEntry entry : response.memoryWritebacks) {
            if (entry == null || entry.confidence < 0.75) {
                continue;
            }

            String key = safe(entry.key, "").toLowerCase(Locale.ROOT);
            String value = safe(entry.value, "");
            if (key.isBlank() || value.isBlank()) {
                continue;
            }

            switch (key) {
                case "food_preferences":
                    target.setFoodPreferences(mergeProfileField(target.getFoodPreferences(), value));
                    profileDirty = true;
                    break;
                case "allergies":
                    target.setAllergies(mergeProfileField(target.getAllergies(), value));
                    profileDirty = true;
                    break;
                case "health_goal":
                    target.setHealthGoal(value);
                    profileDirty = true;
                    break;
                default:
                    rememberPreference(new LinkedHashMap<>(), userId, "wb-" + key, "Tín hiệu AI: " + key + "=" + value);
                    break;
            }
        }

        if (profileDirty) {
            customerProfileDAO.updateProfile(target);
        }
    }

    private String mergeProfileField(String oldValue, String newValue) {
        String oldText = safe(oldValue, "");
        String newText = safe(newValue, "");
        if (newText.isBlank()) {
            return oldText;
        }
        if (oldText.isBlank()) {
            return newText;
        }

        String normalizedOld = normalize(oldText);
        String normalizedNew = normalize(newText);
        if (normalizedOld.contains(normalizedNew)) {
            return oldText;
        }
        return oldText + "; " + newText;
    }

    private static final class StructuredAiResponse {

        private String intent;
        private boolean needsClarification;
        private String naturalResponse;
        private String nutritionNote;
        private String cta;
        private boolean parsedJson;
        private boolean usedFallbackRecommendations;
        private String parseFailureReason;
        private List<String> clarificationQuestions = new ArrayList<>();
        private List<Recommendation> recommendations = new ArrayList<>();
        private List<MemoryWritebackEntry> memoryWritebacks = new ArrayList<>();
    }

    private static final class Recommendation {

        private String dishName;
        private String reason;
        private int healthScore;
        private boolean isHealthyAlternative;
        private Integer estimatedCalories;
        private String priceLevel;
        private List<String> tags = new ArrayList<>();
    }

    private static final class MemoryWritebackEntry {

        private String key;
        private String value;
        private double confidence;
    }

    private static final class ChatTurn {

        private final String role;
        private final String text;

        private ChatTurn(String role, String text) {
            this.role = role == null ? "user" : role;
            this.text = text == null ? "" : text;
        }

        private String getRole() {
            return role;
        }

        private String getText() {
            return text;
        }
    }

    private static final class UserLocation {

        private final Double latitude;
        private final Double longitude;

        private UserLocation(Double latitude, Double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }
}
