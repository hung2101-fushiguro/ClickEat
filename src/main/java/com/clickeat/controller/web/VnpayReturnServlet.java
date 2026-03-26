package com.clickeat.controller.web;

import com.clickeat.config.VnpayConfig;
import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.PaymentTransactionDAO;
import com.clickeat.model.Order;
import com.clickeat.util.VnpayUtil;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "VnpayReturnServlet", urlPatterns = {"/vnpay-return"})
public class VnpayReturnServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Map<String, String> fields = new HashMap<>();
        request.getParameterMap().forEach((k, v) -> {
            if (k.startsWith("vnp_") && v != null && v.length > 0) {
                fields.put(k, v[0]);
            }
        });

        boolean valid = VnpayUtil.validateReturn(new HashMap<>(fields), VnpayConfig.VNP_HASH_SECRET);

        String vnpTxnRef = request.getParameter("vnp_TxnRef");
        String responseCode = request.getParameter("vnp_ResponseCode");
        String transactionStatus = request.getParameter("vnp_TransactionStatus");
        String vnpTransactionNo = request.getParameter("vnp_TransactionNo");
        String vnpPayDate = request.getParameter("vnp_PayDate");

        PaymentTransactionDAO paymentDAO = new PaymentTransactionDAO();
        OrderDAO orderDAO = new OrderDAO();
        CartDAO cartDAO = new CartDAO();

        int orderId = 0;
        if (vnpTxnRef != null && vnpTxnRef.startsWith("VNP_")) {
            try {
                String[] parts = vnpTxnRef.split("_");
                if (parts.length >= 3) {
                    orderId = Integer.parseInt(parts[1]);
                }
            } catch (Exception ignored) {
            }
        }

        if (!valid || orderId <= 0) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String callbackPayload = request.getQueryString();

        if ("00".equals(responseCode) && "00".equals(transactionStatus)) {
            paymentDAO.markSuccess(orderId, vnpTransactionNo, responseCode, vnpPayDate, callbackPayload);
            orderDAO.markPaidByVnpay(orderId);

            Order order = orderDAO.findById(orderId);
            if (order != null) {
                if (order.getCustomerUserId() > 0) {
                    cartDAO.clearActiveCartByCustomerId(order.getCustomerUserId());
                } else if (order.getGuestId() != null && !order.getGuestId().isBlank()) {
                    cartDAO.clearActiveCartByGuestId(order.getGuestId());
                }
            }

            response.sendRedirect(request.getContextPath() + "/payment-success?orderId=" + orderId);
            return;
        }

        paymentDAO.markFailed(orderId, responseCode, callbackPayload);
        orderDAO.markPaymentFailed(orderId);

        request.getSession().setAttribute("toastError", "Thanh toán thất bại. Vui lòng thử lại.");
        response.sendRedirect(request.getContextPath() + "/checkout");
    }
}
