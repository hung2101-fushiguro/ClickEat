package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.MessageDAO;
import com.clickeat.model.Message;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MerchantChatServlet", urlPatterns = {"/merchant/chat"})
public class MerchantChatServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || account.getRole() == null || !"MERCHANT".equalsIgnoreCase(account.getRole().trim())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        MessageDAO dao = new MessageDAO();
        long merchantId = account.getId();
        dao.purgeExpiredConversationsForMerchant(merchantId);

        Object chatInfo = request.getSession().getAttribute("chatInfo");
        if (chatInfo != null) {
            request.setAttribute("chatInfo", chatInfo);
            request.getSession().removeAttribute("chatInfo");
        }

        // 1. Lấy danh sách các cuộc hội thoại bên sidebar
        List<Message> convs = dao.getConversations(merchantId);
        request.setAttribute("conversations", convs);

        // 2. Nếu đang chọn một người cụ thể để chat
        String withIdStr = request.getParameter("with");
        if (withIdStr == null || withIdStr.isBlank()) {
            withIdStr = request.getParameter("userId");
        }
        if (withIdStr != null) {
            long withId;
            try {
                withId = Long.parseLong(withIdStr);
            } catch (NumberFormatException e) {
                withId = -1L;
            }

            if (withId > 0) {
                if (dao.hasActiveDeliveryWindow(merchantId, withId)) {
                    List<Message> history = dao.getChatHistory(merchantId, withId);
                    request.setAttribute("history", history);
                    request.setAttribute("activeWithId", withId);
                } else {
                    dao.deleteConversationBetween(merchantId, withId);
                    request.setAttribute("chatInfo", "Cuộc trò chuyện đã đóng vì đơn không còn trong giai đoạn giao hàng.");
                }
            }
        }

        request.getRequestDispatcher("/views/merchant/chat.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User account = (User) request.getSession().getAttribute("account");
        String toId = request.getParameter("receiverId");
        String text = request.getParameter("message");
        String redirectUrl = request.getContextPath() + "/merchant/chat";

        if (account == null || account.getRole() == null || !"MERCHANT".equalsIgnoreCase(account.getRole().trim())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (toId != null && text != null && !text.trim().isEmpty()) {
            long withId;
            try {
                withId = Long.parseLong(toId);
            } catch (NumberFormatException e) {
                response.sendRedirect(redirectUrl);
                return;
            }

            MessageDAO dao = new MessageDAO();
            if (dao.hasActiveDeliveryWindow(account.getId(), withId)) {
                dao.saveMessage(account.getId(), withId, text.trim());
            } else {
                dao.deleteConversationBetween(account.getId(), withId);
                request.getSession().setAttribute("chatInfo", "Cuộc trò chuyện đã đóng vì đơn không còn trong giai đoạn giao hàng.");
            }

            redirectUrl = redirectUrl + "?with=" + withId;
        }

        response.sendRedirect(redirectUrl);
    }
}
