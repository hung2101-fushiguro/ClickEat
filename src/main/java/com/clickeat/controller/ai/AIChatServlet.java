package com.clickeat.controller.ai;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "AIChatServlet", urlPatterns = {"/ai"})
public class AIChatServlet extends HttpServlet {

    // Thay bằng API Key thật của bạn lấy từ Google AI Studio
    private static final String GEMINI_API_KEY = "";
    private static final String GEMINI_API_URL
            = ""
            + GEMINI_API_KEY;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login?msg=Vui lòng đăng nhập để sử dụng AI");
            return;
        }

        // Truyền tên để hiển thị lời chào
        request.setAttribute("customerName", account.getFullName());

        // Lấy lịch sử 14 ngày cho AI (như đã làm)
        // OrderDAO orderDAO = new OrderDAO();
        // String foodHistory = orderDAO.getCustomerFoodHistory(account.getId(), 14);
        // --- MOCK DỮ LIỆU CHO WIDGET BÊN PHẢI (Cửa hàng yêu thích, Đã ăn hôm qua) ---
        // Thực tế bạn sẽ gọi: orderDAO.getYesterdayOrders(account.getId());
        request.setAttribute("favoriteStoreName", "Trịnh Hưng Quán - Cơm Gà");
        request.setAttribute("favoriteStoreRating", "4.8");
        request.setAttribute("favoriteStoreDistance", "1.2km");
        request.setAttribute("favoriteStoreTime", "15-20p");
        request.setAttribute("favoriteStoreImg", "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=500&q=80");

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

        // 2. Lấy lịch sử 14 ngày qua
        OrderDAO orderDAO = new OrderDAO();
        String foodHistory = orderDAO.getCustomerFoodHistory(account.getId(), 14);
        String menuContext = orderDAO.getAvailableMenuContext();

        // 3. Xây dựng System Instruction (Nhồi ngữ cảnh và luật của Bộ Y Tế)
        String systemInstruction
                = "Bạn là AI chuyên gia dinh dưỡng của ứng dụng giao đồ ăn ClickEat.\n"
                + "Khách hàng đang trò chuyện với bạn tên là: " + account.getFullName() + ".\n\n"
                + "=== DỮ LIỆU LỊCH SỬ ĂN UỐNG CỦA KHÁCH ===\n"
                + foodHistory + "\n\n"
                + "=== NGUYÊN TẮC TƯ VẤN DINH DƯỠNG (Theo Bộ Y Tế Việt Nam) ===\n"
                + "1. Ăn đủ, cân đối và đa dạng thực phẩm hằng ngày; kết hợp thực phẩm động vật và thực vật.\n"
                + "2. Ăn nhiều thực phẩm giàu vi chất như rau, củ, quả nhiều màu sắc; đọc thông tin dinh dưỡng trên nhãn thực phẩm.\n"
                + "3. Sử dụng hợp lý thực phẩm giàu đạm; ưu tiên cá, thịt gia cầm và các loại hạt; hạn chế thịt đỏ.\n"
                + "4. Uống đủ nước mỗi ngày.\n"
                + "5. Phụ nữ mang thai và cho con bú cần chế độ dinh dưỡng hợp lý và bổ sung vi chất theo hướng dẫn.\n"
                + "6. Khuyến khích nuôi con bằng sữa mẹ theo khuyến nghị của Bộ Y tế.\n"
                + "7. Hạn chế thức ăn chiên rán, thức ăn nhanh nhiều dầu mỡ, nhiều muối, nhiều đường và đồ uống có cồn.\n"
                + "8. Đảm bảo an toàn thực phẩm trong lựa chọn, chế biến và bảo quản.\n"
                + "9. Ăn đủ 3 bữa mỗi ngày (sáng, trưa, tối), không bỏ bữa, không ăn quá no.\n"
                + "10. Duy trì cân nặng hợp lý và tăng cường vận động thể chất.\n\n"
                + "=== QUY TẮC PHÂN TÍCH VÀ TƯ VẤN ===\n"
                + "1. Nếu khách ăn đồ chiên rán (is_fried = Có) quá 3 lần mỗi tuần, cảnh báo nguy cơ mỡ máu cao hoặc béo phì và khuyên chuyển sang món luộc, hấp hoặc salad.\n"
                + "2. Nếu một bữa ăn có lượng calo quá cao (>1000 kcal), hãy nhắc khách kiểm soát khẩu phần.\n"
                + "3. Phân tích các món khách thường ăn để suy ra sở thích, sau đó gợi ý các món tương tự nhưng lành mạnh hơn có trên ClickEat.\n\n"
                + "=== CÁCH TRẢ LỜI ===\n"
                + "- Trả lời bằng tiếng Việt.\n"
                + "- Xưng là 'AI'.\n"
                + "- Gọi khách bằng tên: " + account.getFullName() + ".\n"
                + "- Trả lời ngắn gọn, thân thiện, dễ đọc trên giao diện chat.\n"
                + "- Không sử dụng định dạng Markdown phức tạp.\n"
                + "=== TRƯỜNG HỢP KHÁCH KHÔNG QUAN TÂM ===\n"
                + "- Trả lời với thái độ hơi hờn dỗi như dỗi người yêu.\n"
                + "- Ý kiến của khách là số 1.\n "
                + "=== LƯU Ý ===\n"
                + "- Trả lời khách thật ngắn gọn và làm theo yêu cầu của khách\n"
                + "- Khi nào mà khách hỏi về món ăn mà khách đã ăn nhiều trong tuần thì mới đưa ra cảnh báo.\n"
                + "- Nếu khách mà hỏi về món ăn mà hợp lý tốt đối với cơ thể không phải món gây hại mà khách ăn nhiều thì đưa ra gợi ý chứ không đưa ra cảnh báo.\n\n"
                /* ---------- PHẦN THÊM VÀO THEO YÊU CẦU CỦA BẠN ---------- */
                + "=== DANH SÁCH THỰC ĐƠN HIỆN CÓ TỪ HỆ THỐNG ===\n"
                + menuContext + "\n\n"
                + "=== QUY TẮC GỢI Ý MÓN ĂN TỪ HỆ THỐNG (BẮT BUỘC) ===\n"
                + "1. CHỈ GỢI Ý các món ăn có trong danh sách thực đơn vừa cung cấp ở trên.\n"
                + "2. Tuyệt đối không tự bịa ra món ăn hoặc bịa tên nhà hàng không tồn tại trong danh sách.\n"
                + "3. Khi gợi ý, phải luôn kèm theo giá tiền và tên nhà hàng để khách dễ lựa chọn (Ví dụ: 'Bạn có thể thử Gà rán giòn (45.000đ) của nhà hàng Lollibee Q1').\n"
                + "4. Dựa vào yêu cầu của khách (ví dụ: 'cơm', 'gà', 'tráng miệng', 'nước') để tìm trong danh sách xem có món hoặc thể loại nào khớp để giới thiệu.";
        // 4. Gọi Gemini API
        String aiResponseText = callGeminiAPI(systemInstruction, userMessage);

        // Đẩy dữ liệu ra view
        request.setAttribute("userMessage", userMessage);
        request.setAttribute("aiReply", aiResponseText);

        doGet(request, response);
    }

    private String callGeminiAPI(String systemInstruction, String userMessage) {
        try {
            JSONObject payload = new JSONObject();

            // Setup System Instruction
            JSONObject sysInstObj = new JSONObject();
            sysInstObj.put("parts", new JSONArray().put(new JSONObject().put("text", systemInstruction)));
            payload.put("system_instruction", sysInstObj);

            // Setup User Message
            JSONArray contents = new JSONArray();
            JSONObject userContent = new JSONObject();
            userContent.put("role", "user");
            userContent.put("parts", new JSONArray().put(new JSONObject().put("text", userMessage)));
            contents.put(userContent);
            payload.put("contents", contents);

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(GEMINI_API_URL))
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
}
