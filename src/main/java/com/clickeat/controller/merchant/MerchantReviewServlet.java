package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.model.Rating;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MerchantReviewServlet", urlPatterns = {"/merchant/reviews"})
public class MerchantReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int merchantId = (int) account.getId();
        String filter = normalizeFilter(request.getParameter("filter"));

        int page = 1;
        try {
            String pageRaw = request.getParameter("page");
            if (pageRaw != null) {
                page = Integer.parseInt(pageRaw);
            }
        } catch (NumberFormatException ignored) {
            page = 1;
        }
        int pageSize = 10;

        RatingDAO ratingDAO = new RatingDAO();
        int filteredTotal = ratingDAO.countReviewsForMerchant(merchantId, filter);
        int totalPages = Math.max(1, (int) Math.ceil(filteredTotal / (double) pageSize));
        if (page > totalPages) {
            page = totalPages;
        }

        List<Rating> reviews = ratingDAO.getReviewsForMerchant(merchantId, filter, page, pageSize);

        double avgRating = ratingDAO.getAverageRating(merchantId);
        int totalCount = ratingDAO.getTotalCount(merchantId);
        int positiveCount = ratingDAO.getPositiveCount(merchantId);

        int positivePercent = 0;
        if (totalCount > 0) {
            positivePercent = (int) Math.round(((double) positiveCount / totalCount) * 100);
        }

        // Bắt buộc dùng Locale.US để xuất ra dấu chấm (VD: 4.5) thay vì dấu phẩy
        String avgStarsStr = String.format(java.util.Locale.US, "%.1f", avgRating);
        if ("0.0".equals(avgStarsStr)) {
            avgStarsStr = "0";
        }

        request.setAttribute("reviews", reviews);
        request.setAttribute("avgStars", avgStarsStr);   // Biến dạng chuỗi để in ra số (VD: "4.5")
        request.setAttribute("avgRating", avgRating);    // Biến dạng số thực (Double) để so sánh vẽ sao
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("positivePercent", positivePercent);
        request.setAttribute("filter", filter);
        request.setAttribute("currentPageNum", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("filteredTotal", filteredTotal);
        request.setAttribute("currentPage", "reviews");

        request.getRequestDispatcher("/views/merchant/reviews.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("reply".equals(action)) {
            try {
                long ratingId = Long.parseLong(request.getParameter("ratingId"));
                String replyText = request.getParameter("replyText");
                int merchantId = (int) account.getId();

                if (replyText != null && !replyText.trim().isEmpty()) {
                    RatingDAO ratingDAO = new RatingDAO();
                    ratingDAO.updateReply(ratingId, merchantId, replyText.trim());
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        String filter = normalizeFilter(request.getParameter("filter"));
        String pageRaw = request.getParameter("page");
        String redirectUrl = request.getContextPath() + "/merchant/reviews";
        StringBuilder query = new StringBuilder();
        if (filter != null && !filter.isEmpty()) {
            query.append("filter=").append(java.net.URLEncoder.encode(filter, java.nio.charset.StandardCharsets.UTF_8));
        }
        if (pageRaw != null && !pageRaw.isBlank()) {
            if (query.length() > 0) {
                query.append("&");
            }
            query.append("page=").append(java.net.URLEncoder.encode(pageRaw, java.nio.charset.StandardCharsets.UTF_8));
        }
        if (query.length() > 0) {
            redirectUrl += "?" + query;
        }

        response.sendRedirect(redirectUrl);
    }

    private String normalizeFilter(String filter) {
        if (filter == null) {
            return "all";
        }
        String normalized = filter.trim().toLowerCase();
        if ("unanswered".equals(normalized) || "negative".equals(normalized)) {
            return normalized;
        }
        return "all";
    }
}