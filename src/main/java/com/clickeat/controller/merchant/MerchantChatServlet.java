package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.MessageDAO;
import com.clickeat.model.Message;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "MerchantChatServlet", urlPatterns = {"/merchant/chat"})
public class MerchantChatServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        MessageDAO dao = new MessageDAO();
        long merchantId = account.getId();

        // 1. Lấy danh sách các cuộc hội thoại bên sidebar
        List<Message> convs = dao.getConversations(merchantId);
        request.setAttribute("conversations", convs);

        // 2. Nếu đang chọn một người cụ thể để chat
        String withIdStr = request.getParameter("with");
        if (withIdStr != null) {
            long withId = Long.parseLong(withIdStr);
            List<Message> history = dao.getChatHistory(merchantId, withId);
            request.setAttribute("history", history);
            request.setAttribute("activeWithId", withId);
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

        if (account != null && toId != null && text != null && !text.trim().isEmpty()) {
            new MessageDAO().saveMessage(account.getId(), Long.parseLong(toId), text.trim());
        }
        response.sendRedirect(request.getContextPath() + "/merchant/chat?with=" + toId);
    }
}
