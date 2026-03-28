package com.clickeat.controller.web;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.RatingDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.Order;
import com.clickeat.model.Rating;
import com.clickeat.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "CustomerViewReviewServlet", urlPatterns = {"/api/customer-review"})
public class CustomerViewReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        JSONObject json = new JSONObject();
        PrintWriter out = response.getWriter();

        try {
            User account = (User) request.getSession().getAttribute("account");
            if (account == null || !"CUSTOMER".equalsIgnoreCase(account.getRole())) {
                json.put("success", false);
                json.put("message", "Bạn cần đăng nhập.");
                out.print(json.toString());
                return;
            }

            int orderId = Integer.parseInt(request.getParameter("orderId"));

            OrderDAO orderDAO = new OrderDAO();
            RatingDAO ratingDAO = new RatingDAO();
            MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();
            UserDAO userDAO = new UserDAO();

            Order order = orderDAO.findById(orderId);
            if (order == null || order.getCustomerUserId() != account.getId()) {
                json.put("success", false);
                json.put("message", "Không tìm thấy đơn hàng.");
                out.print(json.toString());
                return;
            }

            MerchantProfile merchant = null;
            try {
                merchant = merchantProfileDAO.findByMerchantUserId(order.getMerchantId());
            } catch (Exception ignored) {
            }

            User shipper = null;
            if (order.getShipperUserId() > 0) {
                shipper = userDAO.findById(order.getShipperUserId());
            }

            JSONArray reviews = new JSONArray();

            Rating merchantReview = ratingDAO.getRatingByOrderAndTarget(orderId, "MERCHANT");
            if (merchantReview != null) {
                JSONObject item = new JSONObject();
                item.put("targetType", "MERCHANT");
                item.put("targetName", merchant != null ? safe(merchant.getShopName()) : "Cửa hàng");
                item.put("stars", merchantReview.getStars());
                item.put("comment", safe(merchantReview.getComment()));
                item.put("replyComment", safe(merchantReview.getReplyComment()));
                reviews.put(item);
            }

            Rating shipperReview = ratingDAO.getRatingByOrderAndTarget(orderId, "SHIPPER");
            if (shipperReview != null) {
                JSONObject item = new JSONObject();
                item.put("targetType", "SHIPPER");
                item.put("targetName", shipper != null ? safe(shipper.getFullName()) : "Shipper");
                item.put("stars", shipperReview.getStars());
                item.put("comment", safe(shipperReview.getComment()));
                item.put("replyComment", safe(shipperReview.getReplyComment()));
                reviews.put(item);
            }

            json.put("success", true);
            json.put("reviews", reviews);
            out.print(json.toString());

        } catch (Exception e) {
            json.put("success", false);
            json.put("message", "Không thể tải đánh giá.");
            out.print(json.toString());
        }
    }

    private String safe(String s) {
        return s == null ? "" : s;
    }
}