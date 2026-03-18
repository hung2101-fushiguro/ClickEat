package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    // HIỂN THỊ TRANG THANH TOÁN
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        // 1. Bắt buộc đăng nhập
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int customerId = account.getId();

        CartDAO cartDAO = new CartDAO();

        // 2. Lấy Giỏ hàng hiện tại
        Cart cart = cartDAO.getActiveCartByCustomerId(customerId);

        // Nếu không có giỏ hàng hoặc giỏ hàng trống thì đuổi về trang chủ
        if (cart == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<com.clickeat.model.CartItemView> cartItems = new com.clickeat.dal.impl.CartItemViewDAO().getByCartId(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 3. Tính tiền
        double subTotal = 0;
        for (com.clickeat.model.CartItemView item : cartItems) {
            subTotal += item.getLineTotal();
        }

        double deliveryFee = 15000; // Phí ship mặc định tạm thời
        double totalAmount = subTotal + deliveryFee;

        // 4. Đẩy dữ liệu sang JSP
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subTotal", subTotal);
        request.setAttribute("deliveryFee", deliveryFee);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("user", account); // Truyền user sang để điền sẵn Tên, SĐT

        FoodItemDAO foodDAO = new FoodItemDAO();
        request.setAttribute("foodDAO", foodDAO);

        // 5. Chuyển hướng
        request.getRequestDispatcher("/views/web/checkout.jsp").forward(request, response);
    }

    // XỬ LÝ KHI BẤM NÚT "ĐẶT HÀNG"
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1. Thu thập thông tin từ Form
        String receiverName = request.getParameter("receiverName");
        String receiverPhone = request.getParameter("receiverPhone");
        String addressLine = request.getParameter("addressLine");
        String note = request.getParameter("note");
        String paymentMethod = request.getParameter("paymentMethod");
        String voucherCode = request.getParameter("voucherCode");

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        OrderDAO orderDAO = new OrderDAO();
        OrderItemDAO orderItemDAO = new OrderItemDAO();
        FoodItemDAO foodDAO = new FoodItemDAO();
        VoucherDAO voucherDAO = new VoucherDAO();

        // 2. Lấy Giỏ hàng hiện tại
        Cart cart = cartDAO.getActiveCartByCustomerId(account.getId());
        if (cart == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<CartItem> cartItems = cartItemDAO.getItemsByCartId(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        double subtotal = 0;
        for (CartItem ci : cartItems) {
            subtotal += ci.getUnitPriceSnapshot() * ci.getQuantity();
        }
        double deliveryFee = 15000;

        Integer merchantIdFromCart = cart.getMerchantUserId();
        int merchantId = merchantIdFromCart != null ? merchantIdFromCart : 0;
        MerchantProfile merchant = new MerchantProfileDAO().findById(merchantId);
        if (merchant != null) {
            boolean isOpen = merchant.getIsOpen() == null || merchant.getIsOpen();
            if (!isOpen) {
                request.setAttribute("toastError", "Cửa hàng hiện đang tạm đóng, vui lòng quay lại sau.");
                doGet(request, response);
                return;
            }
            Double minOrderAmount = merchant.getMinOrderAmount();
            if (minOrderAmount != null && subtotal < minOrderAmount) {
                request.setAttribute("toastError", "Đơn chưa đạt mức tối thiểu " + String.format("%,.0f", minOrderAmount) + "đ.");
                doGet(request, response);
                return;
            }
        }

        double discountAmount = 0;
        Integer appliedVoucherId = null;
        String normalizedVoucherCode = voucherCode == null ? "" : voucherCode.trim().toUpperCase();
        if (!normalizedVoucherCode.isEmpty()) {
            Voucher voucher = voucherDAO.findByMerchantAndCode(merchantId, normalizedVoucherCode);
            if (voucher == null) {
                renderCheckoutWithError(request, response, "Mã voucher không tồn tại cho cửa hàng này.", normalizedVoucherCode);
                return;
            }

            if (!voucherDAO.isVoucherCurrentlyActive(voucher)) {
                renderCheckoutWithError(request, response, "Voucher chưa hiệu lực, đã hết hạn hoặc đang tạm dừng publish.", normalizedVoucherCode);
                return;
            }

            Double voucherMinOrder = voucher.getMinOrderAmount();
            if (voucherMinOrder != null && subtotal < voucherMinOrder) {
                renderCheckoutWithError(request, response, "Đơn chưa đạt mức tối thiểu để áp dụng voucher " + voucher.getCode() + ".", normalizedVoucherCode);
                return;
            }

            Integer maxUsesTotal = voucher.getMaxUsesTotal();
            if (maxUsesTotal != null) {
                int usedTotal = voucher.getUsedOrderCount() == null ? 0 : voucher.getUsedOrderCount();
                if (usedTotal >= maxUsesTotal) {
                    renderCheckoutWithError(request, response, "Voucher đã hết lượt sử dụng.", normalizedVoucherCode);
                    return;
                }
            }

            Integer maxUsesPerUser = voucher.getMaxUsesPerUser();
            if (maxUsesPerUser != null) {
                int usedByCustomer = voucherDAO.countUsageByCustomer(voucher.getId(), account.getId());
                if (usedByCustomer >= maxUsesPerUser) {
                    renderCheckoutWithError(request, response, "Bạn đã đạt giới hạn sử dụng voucher này.", normalizedVoucherCode);
                    return;
                }
            }

            if ("PERCENT".equalsIgnoreCase(voucher.getDiscountType())) {
                discountAmount = subtotal * voucher.getDiscountValue() / 100.0;
                Double maxDiscountAmount = voucher.getMaxDiscountAmount();
                if (maxDiscountAmount != null && discountAmount > maxDiscountAmount) {
                    discountAmount = maxDiscountAmount;
                }
            } else {
                discountAmount = voucher.getDiscountValue();
            }
            if (discountAmount > subtotal) {
                discountAmount = subtotal;
            }
            appliedVoucherId = voucher.getId();
        }

        double totalAmount = subtotal + deliveryFee - discountAmount;
        if (totalAmount < 0) {
            totalAmount = 0;
        }

        com.clickeat.model.Order order = new com.clickeat.model.Order();
        String orderCode = "ORD-" + System.currentTimeMillis();
        order.setOrderCode(orderCode);
        order.setCustomerUserId(account.getId());

        order.setMerchantId(merchantId);
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setDeliveryAddressLine(addressLine);
        order.setDeliveryNote(note);
        order.setPaymentMethod(paymentMethod);
        order.setPaymentStatus("UNPAID");
        order.setOrderStatus("CREATED");
        order.setSubtotalAmount(subtotal);
        order.setDeliveryFee(deliveryFee);
        order.setDiscountAmount(discountAmount);
        order.setTotalAmount(totalAmount);

        // 4. Lưu Order vào DB
        int orderId = orderDAO.insert(order);
        if (orderId > 0) {
            // 5. Lưu OrderItems
            for (CartItem ci : cartItems) {
                com.clickeat.model.OrderItem oi = new com.clickeat.model.OrderItem();
                oi.setOrderId(orderId);
                oi.setFoodItemId(ci.getFoodItemId());

                // Lấy tên món từ FoodItem (Do snapshot có thể thay đổi hoặc để DB an toàn hơn)
                com.clickeat.model.FoodItem food = foodDAO.findById(ci.getFoodItemId());
                oi.setItemNameSnapshot(food != null ? food.getName() : "Món ăn");

                oi.setUnitPriceSnapshot(ci.getUnitPriceSnapshot());
                oi.setQuantity(ci.getQuantity());
                oi.setNote(ci.getNote());
                orderItemDAO.insert(oi);
            }

            if (appliedVoucherId != null) {
                voucherDAO.createVoucherUsage(appliedVoucherId, orderId, account.getId());
            }

            // 6. Chuyển trạng thái Cart thành CHECKED_OUT
            cart.setStatus("CHECKED_OUT");
            cartDAO.update(cart);

            // 7. Thông báo và điều hướng
            session.setAttribute("toastMsg", "Đặt hàng thành công! Mã đơn hàng: " + orderCode);
            response.sendRedirect(request.getContextPath() + "/order-success?code=" + orderCode);
        } else {
            request.setAttribute("toastError", "Có lỗi xảy ra khi đặt hàng. Vui lòng thử lại!");
            doGet(request, response);
        }
    }

    private void renderCheckoutWithError(HttpServletRequest request, HttpServletResponse response, String message, String voucherCode)
            throws ServletException, IOException {
        request.setAttribute("toastError", message);
        request.setAttribute("voucherCode", voucherCode);
        doGet(request, response);
    }
}
