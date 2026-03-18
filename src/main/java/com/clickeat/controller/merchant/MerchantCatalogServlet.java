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
import java.nio.charset.StandardCharsets;

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

        try {
            // 1. Xử lý Toggle (Bật/Tắt) bằng AJAX
            if ("toggle".equals(action)) {
                response.setContentType("application/json");
                response.setCharacterEncoding(StandardCharsets.UTF_8.name());
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                String availableRaw = request.getParameter("isAvailable");
                String reason = request.getParameter("reason");
                FoodItem item = foodItemDAO.findById(itemId);
                boolean success = false;
                String message = "Không thể cập nhật món ăn.";

                // Chỉ cho phép update nếu món ăn thuộc về đúng chủ quán đó
                if (item != null && item.getMerchantUserId() == merchantId) {
                    boolean newStatus = availableRaw == null ? !item.isAvailable() : Boolean.parseBoolean(availableRaw);
                    String finalReason = (reason == null || reason.trim().isEmpty()) ? "Hết món hôm nay" : reason.trim();
                    success = foodItemDAO.toggleStatus(itemId, merchantId, newStatus, finalReason);
                    message = success
                            ? (newStatus ? "Đã bật lại món." : "Đã đánh dấu hết món hôm nay.")
                            : "Không thể cập nhật trạng thái món.";
                } else {
                    message = "Món ăn không thuộc quyền quản lý của bạn.";
                }

                response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
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

                    String finalReason = (reason == null || reason.trim().isEmpty()) ? "Hết món hôm nay" : reason.trim();
                    int affected = foodItemDAO.bulkToggleStatus(itemIds, merchantId, newStatus, finalReason);
                    int failed = itemIds.size() - affected;
                    if (affected > 0) {
                        String stateLabel = newStatus ? "đang bán" : "hết món hôm nay";
                        String msg = "Đã cập nhật " + affected + " món sang trạng thái " + stateLabel + ".";
                        if (failed > 0) {
                            msg += " " + failed + " món không cập nhật được (không thuộc quyền quản lý hoặc dữ liệu không hợp lệ).";
                        }
                        request.getSession().setAttribute("catalogSuccess", msg);
                    } else {
                        request.getSession().setAttribute("catalogError", "Không có món nào được cập nhật. Vui lòng kiểm tra lại danh sách đã chọn.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/merchant/catalog");
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

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
