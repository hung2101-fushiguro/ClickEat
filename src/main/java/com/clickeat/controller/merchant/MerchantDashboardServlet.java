package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/merchant/dashboard")
public class MerchantDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();
        OrderDAO orderDAO = new OrderDAO();

        // Stats via raw SQL for efficiency
        long todayRevenue = 0;
        int todayOrders = 0;
        int pendingOrders = 0;
        int monthOrders = 0;
        long[] weeklyRevenue = new long[7];

        String sqlToday = "SELECT COUNT(*) AS cnt, ISNULL(SUM(total_amount),0) AS rev "
                + "FROM Orders WHERE merchant_user_id = ? AND CAST(created_at AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND order_status NOT IN ('CANCELLED','FAILED')";
        String sqlPending = "SELECT COUNT(*) AS cnt FROM Orders WHERE merchant_user_id = ? "
                + "AND order_status IN ('CREATED','PAID')";
        String sqlMonth = "SELECT COUNT(*) AS cnt FROM Orders WHERE merchant_user_id = ? "
                + "AND MONTH(created_at) = MONTH(GETDATE()) AND YEAR(created_at) = YEAR(GETDATE()) "
                + "AND order_status NOT IN ('CANCELLED','FAILED')";
        String sqlWeekly = "SELECT DATEPART(dw, created_at) AS dow, ISNULL(SUM(total_amount),0) AS rev "
                + "FROM Orders WHERE merchant_user_id = ? "
                + "AND created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) "
                + "AND order_status NOT IN ('CANCELLED','FAILED') "
                + "GROUP BY DATEPART(dw, created_at)";

        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlToday)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    todayOrders = rs.getInt("cnt");
                    todayRevenue = rs.getLong("rev");
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlPending)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    pendingOrders = rs.getInt("cnt");
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlMonth)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    monthOrders = rs.getInt("cnt");
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlWeekly)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    int dow = rs.getInt("dow"); // 1=Sun,2=Mon,...,7=Sat (SQL Server)
                    // Map to Mon-Sun index (0-6)
                    int idx = (dow == 1) ? 6 : dow - 2;
                    if (idx >= 0 && idx < 7) {
                        weeklyRevenue[idx] = rs.getLong("rev");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Recent orders (last 8)
        List<Order> recentOrders = new ArrayList<>();
        String sqlRecent = "SELECT TOP 8 * FROM Orders WHERE merchant_user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sqlRecent)) {
            ps.setInt(1, merchantId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setOrderCode(rs.getString("order_code"));
                o.setReceiverName(rs.getString("receiver_name"));
                o.setOrderStatus(rs.getString("order_status"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                recentOrders.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Top selling items (last 30 days)
        List<Object[]> topItems = new ArrayList<>();
        String sqlTopItems = "SELECT TOP 5 fi.name, SUM(oi.quantity) AS total_qty "
                + "FROM OrderItems oi "
                + "JOIN FoodItems fi ON fi.id = oi.food_item_id "
                + "JOIN Orders o ON o.id = oi.order_id "
                + "WHERE o.merchant_user_id = ? AND o.created_at >= DATEADD(day, -30, GETDATE()) "
                + "AND o.order_status NOT IN ('CANCELLED','FAILED') "
                + "GROUP BY fi.name ORDER BY total_qty DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sqlTopItems)) {
            ps.setInt(1, merchantId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                topItems.add(new Object[]{rs.getString("name"), rs.getInt("total_qty")});
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Average rating
        double avgRating = 0.0;
        String sqlRating = "SELECT AVG(CAST(stars AS FLOAT)) AS avgRating FROM Ratings "
                + "WHERE target_type = 'MERCHANT' AND target_user_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sqlRating)) {
            ps.setInt(1, merchantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getObject("avgRating") != null) {
                avgRating = Math.round(rs.getDouble("avgRating") * 10.0) / 10.0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Build weekly revenue JSON array
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 7; i++) {
            if (i > 0) {
                sb.append(',');
            }
            sb.append(weeklyRevenue[i]);
        }

        req.setAttribute("todayRevenue", todayRevenue);
        req.setAttribute("todayOrders", todayOrders);
        req.setAttribute("pendingOrders", pendingOrders);
        req.setAttribute("recentOrders", recentOrders);
        req.setAttribute("topItems", topItems);
        req.setAttribute("avgRating", avgRating);
        req.setAttribute("weeklyRevenueJson", sb.toString());
        req.setAttribute("isNewShop", todayOrders == 0 && recentOrders.isEmpty());

        req.getRequestDispatcher("/views/merchant/dashboard.jsp").forward(req, resp);
    }
}
