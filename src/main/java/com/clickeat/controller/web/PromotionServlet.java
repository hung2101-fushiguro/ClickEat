package com.clickeat.controller.web;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "PromotionServlet", urlPatterns = {"/promotion", "/promotions"})
public class PromotionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort");
        int page = parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 10;

        VoucherDAO voucherDAO = new VoucherDAO();
        int totalItems = voucherDAO.countPublicPromotions(keyword);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) pageSize));
        if (page > totalPages) {
            page = totalPages;
        }

        List<Voucher> vouchers = voucherDAO.searchPublicPromotions(keyword, sort, page, pageSize);

        request.setAttribute("vouchers", vouchers);
        request.setAttribute("keyword", keyword);
        request.setAttribute("sort", sort);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/views/web/promotion.jsp").forward(request, response);
    }

    private int parsePositiveInt(String raw, int defaultValue) {
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            int value = Integer.parseInt(raw);
            return value > 0 ? value : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }
}
