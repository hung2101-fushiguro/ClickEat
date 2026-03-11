package com.clickeat.controller.merchant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/merchant/chat")
public class MerchantChatServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("currentPage", "chat");

        String chatId = req.getParameter("id");
        if (chatId != null && !chatId.isEmpty()) {
            req.setAttribute("initialChatId", chatId);
        }

        req.getRequestDispatcher("/views/merchant/chat.jsp").forward(req, resp);
    }
}
