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
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "CustomerOrderTrackingApiServlet", urlPatterns = {"/api/customer-order-tracking"})
public class CustomerOrderTrackingApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

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

            String orderIdRaw = request.getParameter("orderId");
            if (orderIdRaw == null || orderIdRaw.isBlank()) {
                json.put("success", false);
                json.put("message", "Thiếu mã đơn hàng.");
                out.print(json.toString());
                return;
            }

            int orderId = Integer.parseInt(orderIdRaw);

            OrderDAO orderDAO = new OrderDAO();
            MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();
            UserDAO userDAO = new UserDAO();
            RatingDAO ratingDAO = new RatingDAO();

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

            if (merchant == null) {
                try {
                    merchant = merchantProfileDAO.findById(order.getMerchantId());
                } catch (Exception ignored) {
                }
            }

            User shipper = null;
            if (order.getShipperUserId() > 0) {
                try {
                    shipper = userDAO.findById(order.getShipperUserId());
                } catch (Exception ignored) {
                }
            }

            String orderStatus = order.getOrderStatus() == null
                    ? ""
                    : order.getOrderStatus().trim().toUpperCase();

            boolean merchantRated = ratingDAO.hasRatingForOrderAndTarget(order.getId(), "MERCHANT");
            boolean shipperRated = order.getShipperUserId() <= 0 || ratingDAO.hasRatingForOrderAndTarget(order.getId(), "SHIPPER");
            boolean fullyRated = merchantRated && shipperRated;
            boolean canConfirmReceived = "DELIVERED".equals(orderStatus) && !fullyRated;
            boolean showViewReviewButton = "DELIVERED".equals(orderStatus) && fullyRated;

            json.put("success", true);
            json.put("orderId", order.getId());
            json.put("orderCode", order.getOrderCode() == null ? "" : order.getOrderCode());
            json.put("orderStatus", orderStatus);
            json.put("statusStep", resolveStatusStep(orderStatus));
            json.put("statusLabel", resolveStatusLabel(orderStatus));
            json.put("routeMode", "STORE_TO_CUSTOMER");

            json.put("merchantRated", merchantRated);
            json.put("shipperRated", shipperRated);
            json.put("fullyRated", fullyRated);
            json.put("canConfirmReceived", canConfirmReceived);
            json.put("showReviewButton", canConfirmReceived);
            json.put("showViewReviewButton", showViewReviewButton);

            JSONObject customerJson = new JSONObject();
            customerJson.put("name", safe(order.getReceiverName()));
            customerJson.put("phone", safe(order.getReceiverPhone()));
            customerJson.put("address", safe(order.getDeliveryAddressLine()));
            customerJson.put("lat", order.getLatitude());
            customerJson.put("lng", order.getLongitude());
            json.put("customer", customerJson);

            JSONObject merchantJson = new JSONObject();
            if (merchant != null) {
                merchantJson.put("name", safe(merchant.getShopName()));
                merchantJson.put("phone", safe(merchant.getShopPhone()));
                merchantJson.put("address", safe(merchant.getShopAddressLine()));
                merchantJson.put("lat", merchant.getLatitude());
                merchantJson.put("lng", merchant.getLongitude());
                merchantJson.put("userId", merchant.getUserId());
            } else {
                merchantJson.put("name", "Chưa có thông tin cửa hàng");
                merchantJson.put("phone", "");
                merchantJson.put("address", "");
                merchantJson.put("lat", 0);
                merchantJson.put("lng", 0);
                merchantJson.put("userId", 0);
            }
            json.put("merchant", merchantJson);

            JSONObject shipperJson = new JSONObject();
            if (shipper != null) {
                shipperJson.put("id", shipper.getId());
                shipperJson.put("name", safe(shipper.getFullName()));
                shipperJson.put("phone", safe(shipper.getPhone()));
                shipperJson.put("meta", buildShipperMeta(orderStatus));
            } else {
                shipperJson.put("id", 0);
                shipperJson.put("name", "");
                shipperJson.put("phone", "");
                shipperJson.put("meta", "Hệ thống sẽ cập nhật khi có người nhận đơn.");
            }
            json.put("shipper", shipperJson);

            JSONObject routeInfo = new JSONObject();
            routeInfo.put("text", buildRouteText(orderStatus));
            json.put("routeInfo", routeInfo);

            JSONArray reviews = new JSONArray();
            if (fullyRated) {
                Rating merchantReview = ratingDAO.getRatingByOrderAndTarget(order.getId(), "MERCHANT");
                if (merchantReview != null) {
                    JSONObject item = new JSONObject();
                    item.put("targetType", "MERCHANT");
                    item.put("stars", merchantReview.getStars());
                    item.put("comment", safe(merchantReview.getComment()));
                    item.put("replyComment", safe(merchantReview.getReplyComment()));
                    item.put("targetName", merchant != null ? safe(merchant.getShopName()) : "Cửa hàng");
                    reviews.put(item);
                }

                if (order.getShipperUserId() > 0) {
                    Rating shipperReview = ratingDAO.getRatingByOrderAndTarget(order.getId(), "SHIPPER");
                    if (shipperReview != null) {
                        JSONObject item = new JSONObject();
                        item.put("targetType", "SHIPPER");
                        item.put("stars", shipperReview.getStars());
                        item.put("comment", safe(shipperReview.getComment()));
                        item.put("replyComment", safe(shipperReview.getReplyComment()));
                        item.put("targetName", shipper != null ? safe(shipper.getFullName()) : "Shipper");
                        reviews.put(item);
                    }
                }
            }
            json.put("reviews", reviews);

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Không thể tải dữ liệu tracking: " + e.getMessage());
            out.print(json.toString());
        }
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }

    private int resolveStatusStep(String status) {
        switch (status) {
            case "CREATED":
            case "PAID":
                return 1;
            case "MERCHANT_ACCEPTED":
            case "PREPARING":
                return 2;
            case "READY_FOR_PICKUP":
            case "DELIVERING":
                return 3;
            case "PICKED_UP":
                return 4;
            case "DELIVERED":
                return 5;
            default:
                return 1;
        }
    }

    private String resolveStatusLabel(String status) {
        switch (status) {
            case "CREATED":
            case "PAID":
                return "Đơn hàng đã được tạo";
            case "MERCHANT_ACCEPTED":
            case "PREPARING":
                return "Quán đang chuẩn bị món";
            case "READY_FOR_PICKUP":
                return "Quán đã chuẩn bị xong, chờ shipper nhận hàng";
            case "DELIVERING":
                return "Shipper đang đến quán nhận hàng";
            case "PICKED_UP":
                return "Shipper đã nhận món và đang giao đến bạn";
            case "DELIVERED":
                return "Đơn hàng đã giao thành công";
            default:
                return "Đơn hàng đang được xử lý";
        }
    }

    private String buildRouteText(String status) {
        switch (status) {
            case "READY_FOR_PICKUP":
            case "DELIVERING":
                return "Shipper đang đến quán nhận hàng";
            case "PICKED_UP":
                return "Shipper đang giao đơn từ quán đến bạn";
            case "DELIVERED":
                return "Đơn hàng đã giao hoàn tất";
            default:
                return "Tuyến giao hàng từ quán đến địa chỉ nhận";
        }
    }

    private String buildShipperMeta(String status) {
        switch (status) {
            case "DELIVERING":
                return "Shipper đang trên đường đến quán.";
            case "PICKED_UP":
                return "Shipper đã nhận hàng và đang giao cho bạn.";
            case "DELIVERED":
                return "Shipper đã hoàn tất giao hàng.";
            default:
                return "Shipper đã được gán cho đơn hàng.";
        }
    }
}
