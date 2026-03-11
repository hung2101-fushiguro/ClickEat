package com.clickeat.controller.merchant;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.clickeat.config.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/merchant/settings")
public class MerchantSettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();
        loadProfile(req, merchantId);
        req.setAttribute("currentPage", "settings");
        req.getRequestDispatcher("/views/merchant/settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        int merchantId = ((Number) req.getSession().getAttribute("merchantId")).intValue();
        String tab = req.getParameter("tab");

        if ("store".equals(tab)) {
            String shopName = req.getParameter("shopName");
            String shopPhone = req.getParameter("shopPhone");
            String shopAddress = req.getParameter("shopAddress");
            String avatarData = req.getParameter("avatarData"); // base64 data URL (optional)

            String sql;
            if (avatarData != null && !avatarData.isBlank()) {
                sql = "UPDATE MerchantProfiles SET shop_name=?, shop_phone=?, shop_address_line=?, shop_avatar=?, updated_at=GETDATE() WHERE user_id=?";
            } else {
                sql = "UPDATE MerchantProfiles SET shop_name=?, shop_phone=?, shop_address_line=?, updated_at=GETDATE() WHERE user_id=?";
            }
            try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, shopName);
                ps.setString(2, shopPhone);
                ps.setString(3, shopAddress);
                if (avatarData != null && !avatarData.isBlank()) {
                    ps.setString(4, avatarData);
                    ps.setInt(5, merchantId);
                } else {
                    ps.setInt(4, merchantId);
                }
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }

            if (shopName != null && !shopName.isBlank()) {
                req.getSession().setAttribute("merchantShopName", shopName);
            }
        } else if ("hours".equals(tab)) {
            String businessHoursJson = req.getParameter("businessHours");
            if (businessHoursJson != null && !businessHoursJson.isBlank()) {
                String sql = "UPDATE MerchantProfiles SET business_hours=?, updated_at=GETDATE() WHERE user_id=?";
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, businessHoursJson);
                    ps.setInt(2, merchantId);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        loadProfile(req, merchantId);
        req.setAttribute("currentPage", "settings");
        req.setAttribute("successMsg", "Đã lưu cài đặt thành công.");
        req.setAttribute("activeTab", tab != null ? tab : "store");
        req.getRequestDispatcher("/views/merchant/settings.jsp").forward(req, resp);
    }

    private void loadProfile(HttpServletRequest req, int merchantId) {
        String shopName = "";
        String shopPhone = "";
        String shopAddress = "";
        String businessHours = "";
        String shopAvatar = "";
        try (Connection conn = DBContext.getConnection()) {
            String sql = "SELECT shop_name, shop_phone, shop_address_line, business_hours, shop_avatar FROM MerchantProfiles WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, merchantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    shopName = rs.getString("shop_name");
                    shopPhone = rs.getString("shop_phone");
                    shopAddress = rs.getString("shop_address_line");
                    businessHours = rs.getString("business_hours");
                    shopAvatar = rs.getString("shop_avatar");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        req.setAttribute("dbShopName", shopName != null ? shopName : "");
        req.setAttribute("dbShopPhone", shopPhone != null ? shopPhone : "");
        req.setAttribute("dbShopAddress", shopAddress != null ? shopAddress : "");
        req.setAttribute("dbBusinessHours", businessHours != null ? businessHours : "");
        req.setAttribute("dbShopAvatar", shopAvatar != null ? shopAvatar : "");
    }
}
