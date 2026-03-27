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

        // 3. Xây dựng System Instruction theo rule gợi ý món ngắn gọn và bám dữ liệu hệ thống
        String systemInstruction
                = "Bạn là AI gợi ý món ăn cho ứng dụng ClickEat.\n"
                + "=== HỒ SƠ CÁ NHÂN HÓA CỦA KHÁCH ===\n"
                + profileContext + "\n\n"
                + "=== DỮ LIỆU LỊCH SỬ ĂN UỐNG CỦA KHÁCH ===\n"
                + foodHistory + "\n\n"
                + "=== NGỮ CẢNH REALTIME ===\n"
                + realtimeTimeContext + "\n\n"
                + "=== CHÍNH SÁCH AN TOÀN BẮT BUỘC THEO HỒ SƠ KHÁCH ===\n"
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
                + "=== MỤC TIÊU ===\n"
                + "- Gợi ý món ăn phù hợp nhu cầu người dùng.\n"
                + "- Trả lời tự nhiên, ngắn gọn, giống người thật.\n"
                + "- Giúp người dùng chọn món nhanh.\n\n"
                + "=== QUY TẮC BẮT BUỘC ===\n"
                + "1. CHỈ được chọn món từ danh sách thực đơn hệ thống ở trên.\n"
                + "2. KHÔNG được tự tạo món mới hoặc bịa nhà hàng.\n"
                + "3. KHÔNG giải thích dài dòng.\n"
                + "4. Mỗi lần chỉ gợi ý 2-3 món.\n"
                + "5. Ưu tiên theo thứ tự: mục tiêu sức khỏe -> sở thích và lịch sử ăn uống -> thời điểm realtime.\n"
                + "6. Nếu không có món phù hợp hoàn toàn, chọn món gần nhất nhưng vẫn trong danh sách.\n"
                + "7. Chỉ gợi ý món từ quán nằm trong phạm vi có thể giao tới vị trí hiện tại của khách.\n"
                + "8. Nếu yêu cầu xung đột dị ứng hoặc an toàn sức khỏe, cảnh báo rất ngắn và đưa món thay thế an toàn từ danh sách.\n"
                + "9. Nếu khách nói mơ hồ, chọn 2 món an toàn trước rồi hỏi thêm 1 câu ngắn để làm rõ cho lượt sau.\n"
                + "10. Giữ tính liên tục hội thoại: bám ngữ cảnh gần nhất, không lặp lại nguyên văn câu vừa nói ở lượt trước.\n\n"
                + "=== PHONG CÁCH TRẢ LỜI ===\n"
                + "- Trả lời bằng tiếng Việt, thân thiện, tự nhiên.\n"
                + "- Chỉ 1-2 câu.\n"
                + "- Không dùng markdown, không bullet list.\n"
                + "- Không prefix 'AI:'.\n"
                + "- Không giải thích logic lựa chọn.\n"
                + "- Nêu tên món + giá + nhà hàng để khách chốt nhanh.\n"
                + "- Câu đầu bám đúng nhu cầu hiện tại; câu sau chốt lựa chọn hoặc hỏi rõ 1 ý nếu cần.";
        // 4. Gọi AI API — ưu tiên OpenAI, fallback Gemini nếu chưa cấu hình
        String aiResponseText = callOpenAIAPI(systemInstruction, normalizedUserMessage, historyTurns);
        if (aiResponseText == null) {
            aiResponseText = callGeminiAPI(systemInstruction, normalizedUserMessage, historyTurns);
        }
        aiResponseText = normalizeAiReplyText(aiResponseText);
        updatePreferenceMemory(request, account.getId(), normalizedUserMessage);

        long interactionId = logTrainingEvent(account.getId(), normalizedUserMessage, profileContext, menuContext,
                historyToContext(historyTurns), profile, aiResponseText);

        appendConversationHistory(request, "user", normalizedUserMessage);
        appendConversationHistory(request, "model", aiResponseText);

        // Đẩy dữ liệu ra view
        request.setAttribute("userMessage", userMessage);
        request.setAttribute("aiReply", aiResponseText);
        request.setAttribute("suggestedFoods", suggestedFoods);
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
