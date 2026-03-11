package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/merchant/analytics")
public class MerchantAnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();

        String period = req.getParameter("period");
        if (period == null || period.isEmpty()) {
            period = "30";
        }
        int days;
        try {
            days = Integer.parseInt(period);
        } catch (NumberFormatException e) {
            days = 30;
            period = "30";
        }

        long totalRevenue = 0;
        int totalOrders = 0;
        long avgOrderValue = 0;
        int cancelledOrders = 0;

        StringBuilder dailyLabels = new StringBuilder("[");
        StringBuilder dailyData = new StringBuilder("[");

        // top items: [name, qtySold, revenue]
        List<String[]> topItems = new ArrayList<>();

        try (Connection conn = DBContext.getConnection()) {

            // ── Aggregate stats ──────────────────────────────────────
            String sqlAgg
                    = "SELECT "
                    + "  ISNULL(SUM(CASE WHEN order_status='DELIVERED' THEN total_amount ELSE 0 END), 0) AS totalRevenue,"
                    + "  COUNT(*) AS totalOrders,"
                    + "  SUM(CASE WHEN order_status='CANCELLED' THEN 1 ELSE 0 END) AS cancelledOrders "
                    + "FROM Orders "
                    + "WHERE merchant_user_id = ? "
                    + "  AND created_at >= DATEADD(day, ?, CAST(GETDATE() AS DATE))";
            try (PreparedStatement ps = conn.prepareStatement(sqlAgg)) {
                ps.setInt(1, merchantId);
                ps.setInt(2, -days);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    totalRevenue = rs.getLong("totalRevenue");
                    totalOrders = rs.getInt("totalOrders");
                    cancelledOrders = rs.getInt("cancelledOrders");
                }
            }
            avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

            // ── Daily revenue chart ──────────────────────────────────
            String sqlDaily
                    = "SELECT CAST(created_at AS DATE) AS day, ISNULL(SUM(total_amount), 0) AS rev "
                    + "FROM Orders "
                    + "WHERE merchant_user_id = ? AND order_status = 'DELIVERED' "
                    + "  AND created_at >= DATEADD(day, ?, CAST(GETDATE() AS DATE)) "
                    + "GROUP BY CAST(created_at AS DATE) "
                    + "ORDER BY day";
            try (PreparedStatement ps = conn.prepareStatement(sqlDaily)) {
                ps.setInt(1, merchantId);
                ps.setInt(2, -days);
                ResultSet rs = ps.executeQuery();
                boolean first = true;
                while (rs.next()) {
                    if (!first) {
                        dailyLabels.append(",");
                        dailyData.append(",");
                    }
                    dailyLabels.append("\"").append(rs.getString("day")).append("\"");
                    dailyData.append(rs.getLong("rev"));
                    first = false;
                }
            }

            // ── Top 5 items by quantity sold ─────────────────────────
            String sqlTop
                    = "SELECT TOP 5 oi.item_name_snapshot AS itemName, "
                    + "  SUM(oi.quantity) AS totalSold, "
                    + "  ISNULL(SUM(oi.unit_price_snapshot * oi.quantity), 0) AS revenue "
                    + "FROM OrderItems oi "
                    + "JOIN Orders o ON o.id = oi.order_id "
                    + "WHERE o.merchant_user_id = ? "
                    + "  AND o.created_at >= DATEADD(day, ?, CAST(GETDATE() AS DATE)) "
                    + "GROUP BY oi.item_name_snapshot "
                    + "ORDER BY totalSold DESC";
            try (PreparedStatement ps = conn.prepareStatement(sqlTop)) {
                ps.setInt(1, merchantId);
                ps.setInt(2, -days);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    topItems.add(new String[]{
                        rs.getString("itemName"),
                        String.valueOf(rs.getInt("totalSold")),
                        String.valueOf(rs.getLong("revenue"))
                    });
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        dailyLabels.append("]");
        dailyData.append("]");

        req.setAttribute("currentPage", "analytics");
        req.setAttribute("period", period);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("avgOrderValue", avgOrderValue);
        req.setAttribute("cancelledOrders", cancelledOrders);
        req.setAttribute("dailyLabels", dailyLabels.toString());
        req.setAttribute("dailyData", dailyData.toString());
        req.setAttribute("topItems", topItems);

        req.getRequestDispatcher("/views/merchant/analytics.jsp").forward(req, resp);
    }
}
