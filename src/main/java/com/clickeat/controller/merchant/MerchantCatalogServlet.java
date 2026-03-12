/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import com.clickeat.dal.impl.CategoryDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.model.Category;
import com.clickeat.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import java.util.List;

import com.clickeat.model.FoodItem;

@WebServlet(name = "MerchantCatalogServlet", urlPatterns = {"/merchant/catalog"})
public class MerchantCatalogServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int merchantId = account.getId();
        CategoryDAO categoryDAO = new CategoryDAO();
        FoodItemDAO foodItemDAO = new FoodItemDAO();

        // Lấy dữ liệu
        List<Category> categories = categoryDAO.getByMerchantId(merchantId);
        List<FoodItem> foodItems = foodItemDAO.getByMerchantId(merchantId);

        // Ném ra JSP
        request.setAttribute("categories", categories);
        request.setAttribute("foodItems", foodItems);
        request.setAttribute("currentPage", "catalog");

        request.getRequestDispatcher("/views/merchant/catalog.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"MERCHANT".equals(account.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int merchantId = account.getId();
        String action = request.getParameter("action");
        FoodItemDAO foodItemDAO = new FoodItemDAO();

        try {
            // 1. Xử lý Toggle (Bật/Tắt) bằng AJAX
            if ("toggle".equals(action)) {
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                FoodItem item = foodItemDAO.findById(itemId);

                // Chỉ cho phép update nếu món ăn thuộc về đúng chủ quán đó
                if (item != null && item.getMerchantUserId() == merchantId) {
                    boolean newStatus = !item.isIsAvailable();
                    foodItemDAO.toggleStatus(itemId, merchantId, newStatus);
                }
                return; 
            } // 2. Xử lý Thêm mới hoặc Cập nhật món
            else if ("add".equals(action) || "edit".equals(action)) {
                String name = request.getParameter("name");
                String desc = request.getParameter("description");
                double price = Double.parseDouble(request.getParameter("price"));
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                String imageUrl = request.getParameter("imageUrl");

                FoodItem item = new FoodItem();
                item.setMerchantUserId(merchantId);
                item.setName(name);
                item.setDescription(desc);
                item.setPrice(price);
                item.setCategoryId(categoryId);
                item.setImageUrl(imageUrl);

                if ("add".equals(action)) {
                    item.setIsAvailable(true); // Mặc định vừa thêm là có bán
                    foodItemDAO.insert(item);
                } else {
                    int id = Integer.parseInt(request.getParameter("id"));
                    FoodItem existing = foodItemDAO.findById(id);
                    if (existing != null && existing.getMerchantUserId() == merchantId) {
                        item.setId(id);
                        item.setIsAvailable(existing.isIsAvailable());
                        item.setIsFried(existing.isIsFried());
                        item.setCalories(existing.getCalories());
                        item.setProteinG(existing.getProteinG());
                        item.setCarbsG(existing.getCarbsG());
                        item.setFatG(existing.getFatG());
                        foodItemDAO.update(item);
                    }
                }
                // Thêm/Sửa xong thì F5 lại trang Catalog
                response.sendRedirect(request.getContextPath() + "/merchant/catalog");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/merchant/catalog?error=1");
        }
    }
}
