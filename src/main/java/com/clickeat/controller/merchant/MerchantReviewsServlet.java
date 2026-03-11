package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/merchant/reviews")
public class MerchantReviewsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();

        String filter = req.getParameter("filter");
        if (filter == null || filter.isEmpty()) {
            filter = "all";
        }

        // reviews: [customerName, stars, comment, dateLabel, ratingId, reply]
        List<Object[]> reviews = new ArrayList<>();
        double totalStars = 0;
        int totalCount = 0;
        int positiveCount = 0;

        String filterCondition = "";
        if ("unanswered".equals(filter)) {
            filterCondition = "AND (r.reply IS NULL OR r.reply = '') ";
        } else if ("negative".equals(filter)) {
            filterCondition = "AND r.stars <= 3 ";
        }

        try (Connection conn = DBContext.getConnection()) {
            String sql
                    = "SELECT r.id, r.stars, r.comment, r.created_at, r.order_id, r.reply, "
                    + "  ISNULL(u.full_name, N'Khách') AS customerName "
                    + "FROM Ratings r "
                    + "LEFT JOIN Users u ON u.id = r.rater_customer_id "
                    + "WHERE r.target_type = 'MERCHANT' AND r.target_user_id = ? "
                    + filterCondition
                    + "ORDER BY r.created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                LocalDate today = LocalDate.now();
                while (rs.next()) {
                    int ratingId = rs.getInt("id");
                    int stars = rs.getInt("stars");
                    String comment = rs.getString("comment");
                    Timestamp ts = rs.getTimestamp("created_at");
                    String name = rs.getString("customerName");
                    String reply = rs.getString("reply");

                    // relative date label
                    String dateLabel;
                    if (ts != null) {
                        LocalDate day = ts.toLocalDateTime().toLocalDate();
                        long diff = ChronoUnit.DAYS.between(day, today);
                        if (diff == 0) {
                            dateLabel = "Hôm nay";
                        } else if (diff == 1) {
                            dateLabel = "Hôm qua";
                        } else if (diff < 7) {
                            dateLabel = diff + " ngày trước";
                        } else {
                            dateLabel = day.toString();
                        }
                    } else {
                        dateLabel = "";
                    }

                    reviews.add(new Object[]{name, stars, comment != null ? comment : "", dateLabel, ratingId, reply != null ? reply : ""});
                    totalStars += stars;
                    totalCount++;
                    if (stars >= 4) {
                        positiveCount++;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        double avgStars = totalCount > 0 ? Math.round((totalStars / totalCount) * 10.0) / 10.0 : 0.0;
        int positivePercent = totalCount > 0 ? (int) Math.round((positiveCount * 100.0) / totalCount) : 0;

        req.setAttribute("currentPage", "reviews");
        req.setAttribute("filter", filter);
        req.setAttribute("reviews", reviews);
        req.setAttribute("avgStars", avgStars);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("positivePercent", positivePercent);

        req.getRequestDispatcher("/views/merchant/reviews.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();
        String action = req.getParameter("action");

        if ("reply".equals(action)) {
            String ratingIdStr = req.getParameter("ratingId");
            String replyText = req.getParameter("replyText");
            if (ratingIdStr != null && replyText != null && !replyText.isBlank()) {
                String sql = "UPDATE Ratings SET reply=?, replied_at=GETDATE() " + "WHERE id=? AND target_user_id=? AND target_type='MERCHANT'";
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, replyText.trim());
                    ps.setInt(2, Integer.parseInt(ratingIdStr));
                    ps.setInt(3, merchantId);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        resp.sendRedirect(req.getContextPath() + "/merchant/reviews");
    }
}
