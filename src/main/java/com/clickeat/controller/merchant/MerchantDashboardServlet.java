package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;

@WebServlet("/merchant/dashboard")
public class MerchantDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = (int) req.getSession().getAttribute("merchantId");
        OrderDAO orderDAO = new OrderDAO();

        // Stats via raw SQL for efficiency
        long todayRevenue = 0;
        int todayOrders = 0;
        int pendingOrders = 0;
        int monthOrders = 0;
        long[] weeklyRevenue = new long[7];

        String sqlToday = "SELECT COUNT(*) AS cnt, ISNULL(SUM(total_amount),0) AS rev "
                + "FROM Orders WHERE merchant_user_id = ? AND CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)";
        String sqlPending = "SELECT COUNT(*) AS cnt FROM Orders WHERE merchant_user_id = ? "
                + "AND order_status IN ('CREATED','PAID')";
        String sqlMonth = "SELECT COUNT(*) AS cnt FROM Orders WHERE merchant_user_id = ? "
                + "AND MONTH(created_at) = MONTH(GETDATE()) AND YEAR(created_at) = YEAR(GETDATE())";
        String sqlWeekly = "SELECT DATEPART(dw, created_at) AS dow, ISNULL(SUM(total_amount),0) AS rev "
                + "FROM Orders WHERE merchant_user_id = ? "
                + "AND created_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) "
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
        req.setAttribute("monthOrders", monthOrders);
        req.setAttribute("recentOrders", recentOrders);
        req.setAttribute("weeklyRevenueJson", sb.toString());
        req.setAttribute("isNewShop", todayOrders == 0 && recentOrders.isEmpty());

        req.getRequestDispatcher("/views/merchant/dashboard.jsp").forward(req, resp);
    }
}
