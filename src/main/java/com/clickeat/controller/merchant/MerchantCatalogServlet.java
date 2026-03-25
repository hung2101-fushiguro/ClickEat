/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.merchant;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.CategoryDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.Category;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
        MerchantProfile profile = new MerchantProfileDAO().findById(merchantId);

        if (profile != null) {
            request.getSession().setAttribute("merchantShopName", profile.getShopName());
            request.getSession().setAttribute("merchantIsOpen", profile.getIsOpen() == null ? Boolean.TRUE : profile.getIsOpen());
        }

        // Lấy dữ liệu
        List<Category> categories = categoryDAO.getByMerchantId(merchantId);
        List<FoodItem> foodItems = foodItemDAO.getByMerchantId(merchantId);

        // Ném ra JSP
        request.setAttribute("categories", categories);
        request.setAttribute("foodItems", foodItems);
        request.setAttribute("currentPage", "catalog");
        request.setAttribute("successMsg", request.getSession().getAttribute("catalogSuccess"));
        request.setAttribute("errorMsg", request.getSession().getAttribute("catalogError"));
        request.getSession().removeAttribute("catalogSuccess");
        request.getSession().removeAttribute("catalogError");

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
        CategoryDAO categoryDAO = new CategoryDAO();

        try {
            // 1. Xử lý Toggle (Bật/Tắt) bằng AJAX
            if ("toggle".equals(action)) {
                int itemId;
                try {
                    itemId = Integer.parseInt(request.getParameter("itemId"));
                } catch (NumberFormatException ex) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                String availableRaw = request.getParameter("isAvailable");
                String reason = request.getParameter("reason");
                FoodItem item = foodItemDAO.findById(itemId);

                // Chỉ cho phép update nếu món ăn thuộc về đúng chủ quán đó
                if (item == null || item.getMerchantUserId() != merchantId) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                boolean newStatus = availableRaw == null ? !item.isAvailable() : Boolean.parseBoolean(availableRaw);
                boolean updated = foodItemDAO.toggleStatus(itemId, merchantId, newStatus, reason);
                if (!updated) {
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    return;
                }

                response.setStatus(HttpServletResponse.SC_OK);
                return;
            } else if ("bulk-toggle".equals(action)) {
                String[] rawIds = request.getParameterValues("itemIds");
                String availableRaw = request.getParameter("isAvailable");
                String reason = request.getParameter("reason");
                boolean newStatus = Boolean.parseBoolean(availableRaw);

                if (rawIds == null || rawIds.length == 0) {
                    request.getSession().setAttribute("catalogError", "Vui lòng chọn ít nhất 1 món để cập nhật.");
                } else {
                    List<Integer> itemIds = new java.util.ArrayList<>();
                    for (String rawId : rawIds) {
                        try {
                            itemIds.add(Integer.parseInt(rawId));
                        } catch (NumberFormatException ignored) {
                        }
                    }

                    int affected = foodItemDAO.bulkToggleStatus(itemIds, merchantId, newStatus, reason);
                    request.getSession().setAttribute("catalogSuccess", "Đã cập nhật trạng thái " + affected + " món.");
                }
                response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                return;
            } else if ("add-category".equals(action)) {
                String categoryName = request.getParameter("categoryName");
                String normalizedName = categoryName == null ? "" : categoryName.trim();

                if (normalizedName.isEmpty()) {
                    request.getSession().setAttribute("catalogError", "Tên danh mục không được để trống.");
                    response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                    return;
                }

                Category existing = categoryDAO.findByMerchantAndName(merchantId, normalizedName);
                if (existing != null) {
                    request.getSession().setAttribute("catalogError", "Danh mục đã tồn tại.");
                    response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                    return;
                }

                Category category = new Category();
                category.setMerchantUserId(merchantId);
                category.setName(normalizedName);
                category.setActive(true);
                category.setSortOrder(categoryDAO.getNextSortOrderByMerchant(merchantId));

                int created = categoryDAO.insert(category);
                request.getSession().setAttribute(created > 0 ? "catalogSuccess" : "catalogError",
                        created > 0 ? "Đã thêm danh mục mới." : "Không thể thêm danh mục mới.");
                response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                return;
            } // 2. Xử lý Thêm mới hoặc Cập nhật món
            else if ("add".equals(action) || "edit".equals(action)) {
                String name = request.getParameter("name");
                if (name != null) {
                    name = name.trim();
                }
                String desc = request.getParameter("description");
                double price;
                int categoryId;
                try {
                    price = Double.parseDouble(request.getParameter("price"));
                    categoryId = Integer.parseInt(request.getParameter("categoryId"));
                } catch (NumberFormatException ex) {
                    request.getSession().setAttribute("catalogError", "Dữ liệu giá hoặc danh mục không hợp lệ.");
                    response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                    return;
                }

                if (name == null || name.isEmpty()) {
                    request.getSession().setAttribute("catalogError", "Tên món ăn không được để trống.");
                    response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                    return;
                }
                if (price <= 0 || price > 999_999_999) {
                    request.getSession().setAttribute("catalogError", "Giá món phải lớn hơn 0 và trong giới hạn cho phép.");
                    response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                    return;
                }
                if (categoryId <= 0) {
                    request.getSession().setAttribute("catalogError", "Danh mục món không hợp lệ.");
                    response.sendRedirect(request.getContextPath() + "/merchant/catalog");
                    return;
                }

                String imageUrl = request.getParameter("imageUrl");

                FoodItem item = new FoodItem();
                item.setMerchantUserId(merchantId);
                item.setName(name);
                item.setDescription(desc);
                item.setPrice(price);
                item.setCategoryId(categoryId);
                item.setImageUrl(imageUrl);

                if ("add".equals(action)) {
                    item.setAvailable(true); // Mặc định vừa thêm là có bán
                    foodItemDAO.insert(item);
                } else {
                    int id = Integer.parseInt(request.getParameter("id"));
                    FoodItem existing = foodItemDAO.findById(id);
                    if (existing != null && existing.getMerchantUserId() == merchantId) {
                        item.setId(id);
                        item.setAvailable(existing.isAvailable());
                        item.setFried(existing.isFried());
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
            request.getSession().setAttribute("catalogError", "Có lỗi khi cập nhật danh mục món.");
            response.sendRedirect(request.getContextPath() + "/merchant/catalog?error=1");
        }
    }
}
