package com.clickeat.controller.merchant;

import com.clickeat.config.DBContext;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.model.Category;
import com.clickeat.model.FoodItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/merchant/catalog")
public class MerchantCatalogServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int merchantId = (int) req.getSession().getAttribute("merchantId");
        String categoryFilter = req.getParameter("categoryId");

        FoodItemDAO foodDAO = new FoodItemDAO();
        List<FoodItem> allItems = foodDAO.findByMerchant(merchantId);

        // Apply category filter
        List<FoodItem> foodItems = new ArrayList<>();
        if (categoryFilter != null && !categoryFilter.isBlank()) {
            int catId = Integer.parseInt(categoryFilter);
            for (FoodItem fi : allItems) {
                if (fi.getCategoryId() == catId) {
                    foodItems.add(fi);
                }
            }
        } else {
            foodItems = allItems;
        }

        // Stats
        long available = foodItems.stream().filter(FoodItem::isAvailable).count();
        long unavailable = foodItems.size() - available;

        // Load categories
        List<Category> categories = loadCategories(merchantId);

        req.setAttribute("foodItems", foodItems);
        req.setAttribute("categories", categories);
        req.setAttribute("totalItems", foodItems.size());
        req.setAttribute("availableItems", available);
        req.setAttribute("unavailableItems", unavailable);
        req.getRequestDispatcher("/views/merchant/catalog.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        int merchantId = (int) req.getSession().getAttribute("merchantId");
        String action = req.getParameter("action");

        switch (action == null ? "" : action) {
            case "add" -> {
                String name = req.getParameter("name");
                String priceStr = req.getParameter("price");
                String desc = req.getParameter("description");
                String imgUrl = req.getParameter("imageUrl");
                String catStr = req.getParameter("categoryId");

                if (name == null || name.isBlank() || priceStr == null) {
                    break;
                }
                double price = Double.parseDouble(priceStr);
                int categoryId = (catStr != null && !catStr.isBlank()) ? Integer.parseInt(catStr) : 0;

                String sql = "INSERT INTO FoodItems (merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, created_at, updated_at) "
                        + "VALUES (?, ?, ?, ?, ?, ?, 1, 0, GETDATE(), GETDATE())";
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, merchantId);
                    ps.setInt(2, categoryId);
                    ps.setString(3, name);
                    ps.setString(4, desc);
                    ps.setDouble(5, price);
                    ps.setString(6, imgUrl);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            case "toggle" -> {
                String itemIdStr = req.getParameter("itemId");
                if (itemIdStr == null) {
                    break;
                }
                int itemId = Integer.parseInt(itemIdStr);
                String sql = "UPDATE FoodItems SET is_available = CASE WHEN is_available = 1 THEN 0 ELSE 1 END, updated_at = GETDATE() "
                        + "WHERE id = ? AND merchant_user_id = ?";
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, itemId);
                    ps.setInt(2, merchantId);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            case "delete" -> {
                String itemIdStr = req.getParameter("itemId");
                if (itemIdStr == null) {
                    break;
                }
                int itemId = Integer.parseInt(itemIdStr);
                String sql = "UPDATE FoodItems SET is_available = 0, updated_at = GETDATE() WHERE id = ? AND merchant_user_id = ?";
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, itemId);
                    ps.setInt(2, merchantId);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/catalog");
    }

    private List<Category> loadCategories(int merchantId) {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT DISTINCT c.id, c.name FROM Categories c "
                + "JOIN FoodItems fi ON fi.category_id = c.id WHERE fi.merchant_user_id = ? ORDER BY c.name";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Category cat = new Category();
                cat.setId(rs.getInt("id"));
                cat.setName(rs.getString("name"));
                list.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
