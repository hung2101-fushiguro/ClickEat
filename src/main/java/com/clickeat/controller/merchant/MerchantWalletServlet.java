package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.clickeat.config.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/merchant/wallet")
public class MerchantWalletServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();

        long totalIncome = 0;
        long monthlyIncome = 0;
        long pendingAmount = 0;
        long availableBalance = 0;

        // recentOrders: [orderCode, formattedAmount, dateStr]
        List<String[]> recentOrders = new ArrayList<>();

        try (Connection conn = DBContext.getConnection()) {

            // ── Aggregate: income & pending ──────────────────────────
            String sqlStats
                    = "SELECT "
                    + "  ISNULL(SUM(CASE WHEN order_status='DELIVERED' THEN total_amount ELSE 0 END), 0) AS totalIncome,"
                    + "  ISNULL(SUM(CASE WHEN order_status='DELIVERED' AND MONTH(created_at)=MONTH(GETDATE()) AND YEAR(created_at)=YEAR(GETDATE()) THEN total_amount ELSE 0 END), 0) AS monthlyIncome,"
                    + "  ISNULL(SUM(CASE WHEN order_status IN ('PAID','MERCHANT_ACCEPTED','PREPARING','READY_FOR_PICKUP','DELIVERING') THEN total_amount ELSE 0 END), 0) AS pendingAmount "
                    + "FROM Orders WHERE merchant_user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlStats)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    totalIncome = rs.getLong("totalIncome");
                    monthlyIncome = rs.getLong("monthlyIncome");
                    pendingAmount = rs.getLong("pendingAmount");
                }
            }
            availableBalance = totalIncome;

            // ── Recent 10 delivered orders ────────────────────────────
            String sqlRecent
                    = "SELECT TOP 10 order_code, total_amount, created_at "
                    + "FROM Orders WHERE merchant_user_id = ? AND order_status = 'DELIVERED' "
                    + "ORDER BY created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(sqlRecent)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                NumberFormat nf = NumberFormat.getNumberInstance(Locale.of("vi", "VN"));
                while (rs.next()) {
                    String code = rs.getString("order_code");
                    long amount = rs.getLong("total_amount");
                    Timestamp ts = rs.getTimestamp("created_at");
                    String date = ts != null ? ts.toLocalDateTime().toLocalDate().toString() : "";
                    recentOrders.add(new String[]{code, nf.format(amount) + "₫", date});
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Format for display
        NumberFormat nf = NumberFormat.getNumberInstance(Locale.of("vi", "VN"));

        req.setAttribute("currentPage", "wallet");
        req.setAttribute("availableBalance", nf.format(availableBalance) + "₫");
        req.setAttribute("totalIncome", nf.format(totalIncome) + "₫");
        req.setAttribute("monthlyIncome", nf.format(monthlyIncome) + "₫");
        req.setAttribute("pendingAmount", nf.format(pendingAmount) + "₫");
        req.setAttribute("recentOrders", recentOrders);

        req.getRequestDispatcher("/views/merchant/wallet.jsp").forward(req, resp);
    }
}
