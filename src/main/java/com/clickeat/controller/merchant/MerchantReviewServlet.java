package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.model.Rating;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

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
        String filter = request.getParameter("filter");
        if (filter == null) {
            filter = "all";
        }

        RatingDAO ratingDAO = new RatingDAO();
        List<Rating> reviews = ratingDAO.getReviewsForMerchant(merchantId, filter);

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

        String filter = request.getParameter("filter");
        String redirectUrl = request.getContextPath() + "/merchant/reviews";
        if (filter != null && !filter.isEmpty()) {
            redirectUrl += "?filter=" + filter;
        }

        response.sendRedirect(redirectUrl);
    }
}
