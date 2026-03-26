package com.clickeat.controller.web;

import com.clickeat.config.VnpayConfig;
import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.PaymentTransactionDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Address;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.FoodItem;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import com.clickeat.util.VnpayUtil;
import java.io.IOException;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        Boolean guestVerified = (Boolean) session.getAttribute("guest_verified");
        String guestId = (String) session.getAttribute("guest_id");

        if (account == null && (guestVerified == null || !guestVerified)) {
            response.sendRedirect(request.getContextPath() + "/guest-checkout");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        AddressDAO addressDAO = new AddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();

        Cart cart;
        int customerId = 0;
        Address defaultAddress = null;

        if (account != null) {
            customerId = account.getId();
            cart = cartDAO.getActiveCartByCustomerId(customerId);
            defaultAddress = addressDAO.findDefaultByUserId(customerId);
        } else {
            if (guestId == null || guestId.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/guest-checkout");
                return;
            }
            cart = cartDAO.getActiveCartByGuestId(guestId);
        }

        if (cart == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<CartItem> checkoutItems = cartItemDAO.getItemsByCartId(cart.getId());
        if (checkoutItems == null || checkoutItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        double subTotal = 0;
        for (CartItem item : checkoutItems) {
            subTotal += item.getQuantity() * item.getUnitPriceSnapshot();
        }

        double deliveryFee = 15000;

        String shippingAddress = request.getParameter("shippingAddress");
        if (shippingAddress == null || shippingAddress.isBlank()) {
            if (account != null) {
                shippingAddress = buildFullAddress(defaultAddress);
            } else {
                Object guestAddress = session.getAttribute("guest_address");
                shippingAddress = guestAddress == null ? "" : guestAddress.toString();
            }
        }

        String note = request.getParameter("note");
        if (note == null) {
            note = "";
        }

        String voucherCode = request.getParameter("voucherCode");
        Voucher appliedVoucher = null;
        double discountAmount = 0;
        String voucherMessage = null;
        String voucherError = null;

        if (voucherCode != null) {
            voucherCode = voucherCode.trim();
        }

        if (voucherCode != null && !voucherCode.isEmpty()) {
            Integer merchantId = cart.getMerchantUserId();

            if (merchantId == null || merchantId <= 0) {
                voucherError = "Không xác định được nhà hàng của giỏ hàng.";
            } else {
                Voucher voucher = voucherDAO.findValidVoucherByCode(merchantId, voucherCode);

                if (voucher == null) {
                    voucherError = "Mã voucher không tồn tại, đã hết hạn hoặc không thuộc cửa hàng này.";
                } else if (voucher.getMinOrderAmount() != null && subTotal < voucher.getMinOrderAmount()) {
                    voucherError = "Đơn hàng chưa đạt giá trị tối thiểu để áp dụng voucher.";
                } else if (voucher.getMaxUsesTotal() != null
                        && voucher.getUsedOrderCount() >= voucher.getMaxUsesTotal()) {
                    voucherError = "Voucher đã hết lượt sử dụng.";
                } else if (account != null && voucher.getMaxUsesPerUser() != null) {
                    int usedByUser = voucherDAO.countUsageByVoucherAndCustomer(voucher.getId(), customerId);
                    if (usedByUser >= voucher.getMaxUsesPerUser()) {
                        voucherError = "Bạn đã sử dụng hết số lượt cho voucher này.";
                    } else {
                        appliedVoucher = voucher;
                    }
                } else {
                    appliedVoucher = voucher;
                }

                if (appliedVoucher != null) {
                    discountAmount = calculateDiscount(appliedVoucher, subTotal);

                    if (discountAmount > 0) {
                        voucherMessage = "Áp dụng voucher thành công: " + appliedVoucher.getCode();
                    } else {
                        voucherError = "Voucher hợp lệ nhưng không áp dụng được cho đơn hàng này.";
                    }
                }
            }
        }

        double totalAmount = subTotal + deliveryFee - discountAmount;
        if (totalAmount < 0) {
            totalAmount = 0;
        }

        request.setAttribute("checkoutItems", checkoutItems);
        request.setAttribute("subTotal", subTotal);
        request.setAttribute("deliveryFee", deliveryFee);
        request.setAttribute("discountAmount", discountAmount);
        request.setAttribute("totalAmount", totalAmount);

        request.setAttribute("voucherCode", voucherCode == null ? "" : voucherCode);
        request.setAttribute("appliedVoucher", appliedVoucher);
        request.setAttribute("voucherMessage", voucherMessage);
        request.setAttribute("voucherError", voucherError);

        request.setAttribute("shippingAddress", shippingAddress);
        request.setAttribute("note", note);
        request.setAttribute("defaultAddress", defaultAddress);

        if (account != null) {
            request.setAttribute("user", account);
        } else {
            request.setAttribute("guestFullName", session.getAttribute("guest_fullName"));
            request.setAttribute("guestEmail", session.getAttribute("guest_email"));
            request.setAttribute("guestPhone", session.getAttribute("guest_phone"));
            request.setAttribute("guestAddress", session.getAttribute("guest_address"));
        }

        request.getRequestDispatcher("/views/web/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        Boolean guestVerified = (Boolean) session.getAttribute("guest_verified");
        String guestId = (String) session.getAttribute("guest_id");

        if (account == null && (guestVerified == null || !guestVerified)) {
            response.sendRedirect(request.getContextPath() + "/guest-checkout");
            return;
        }

        String addressLineInput = request.getParameter("addressLine");
        String paymentMethod = request.getParameter("paymentMethod");
        String note = request.getParameter("note");

        if (paymentMethod == null || paymentMethod.isBlank()) {
            paymentMethod = "COD";
        }

        AddressDAO addressDAO = new AddressDAO();
        Address defaultAddress = null;

        String receiverName;
        String receiverPhone;
        String deliveryAddressLine = addressLineInput;

        String provinceCode = request.getParameter("provinceCode");
        String provinceName = request.getParameter("provinceName");
        String districtCode = request.getParameter("districtCode");
        String districtName = request.getParameter("districtName");
        String wardCode = request.getParameter("wardCode");
        String wardName = request.getParameter("wardName");

        if (provinceCode == null || provinceCode.isBlank()) provinceCode = "NA";
        if (provinceName == null || provinceName.isBlank()) provinceName = "NA";
        if (districtCode == null || districtCode.isBlank()) districtCode = "NA";
        if (districtName == null || districtName.isBlank()) districtName = "NA";
        if (wardCode == null || wardCode.isBlank()) wardCode = "NA";
        if (wardName == null || wardName.isBlank()) wardName = "NA";

        Double latitude = null;
        Double longitude = null;

        if (account != null) {
            defaultAddress = addressDAO.findDefaultByUserId(account.getId());
            receiverName = account.getFullName();
            receiverPhone = account.getPhone();

            if (defaultAddress != null) {
                if (defaultAddress.getReceiverName() != null && !defaultAddress.getReceiverName().isBlank()) {
                    receiverName = defaultAddress.getReceiverName();
                }
                if (defaultAddress.getReceiverPhone() != null && !defaultAddress.getReceiverPhone().isBlank()) {
                    receiverPhone = defaultAddress.getReceiverPhone();
                }

                if (provinceCode.equals("NA") && defaultAddress.getProvinceCode() != null && !defaultAddress.getProvinceCode().isBlank()) {
                    provinceCode = defaultAddress.getProvinceCode();
                    provinceName = defaultAddress.getProvinceName();
                    districtCode = defaultAddress.getDistrictCode();
                    districtName = defaultAddress.getDistrictName();
                    wardCode = defaultAddress.getWardCode();
                    wardName = defaultAddress.getWardName();
                    
                    if (addressLineInput == null || addressLineInput.isBlank() || addressLineInput.equals(buildFullAddress(defaultAddress))) {
                        deliveryAddressLine = defaultAddress.getAddressLine();
                    } else {
                        deliveryAddressLine = addressLineInput.trim() + ", " + wardName + ", " + districtName + ", " + provinceName;
                    }
                } else {
                    deliveryAddressLine = addressLineInput.trim() + ", " + wardName + ", " + districtName + ", " + provinceName;
                }

                if (defaultAddress.getLatitude() != 0) {
                    latitude = defaultAddress.getLatitude();
                }
                if (defaultAddress.getLongitude() != 0) {
                    longitude = defaultAddress.getLongitude();
                }
            } else {
                 if (!provinceCode.equals("NA")) {
                     deliveryAddressLine = addressLineInput.trim() + ", " + wardName + ", " + districtName + ", " + provinceName;
                 }
            }
        } else {
            receiverName = stringSession(session, "guest_fullName");
            receiverPhone = stringSession(session, "guest_phone");

            if (!provinceCode.equals("NA")) {
                 deliveryAddressLine = addressLineInput.trim() + ", " + wardName + ", " + districtName + ", " + provinceName;
            } else {
                Object guestAddress = session.getAttribute("guest_address");
                if ((deliveryAddressLine == null || deliveryAddressLine.isBlank()) && guestAddress != null) {
                    deliveryAddressLine = guestAddress.toString();
                }
            }
        }

        if (deliveryAddressLine == null || deliveryAddressLine.isBlank()) {
            session.setAttribute("toastError", "Vui lòng nhập địa chỉ giao hàng.");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        OrderDAO orderDAO = new OrderDAO();
        OrderItemDAO orderItemDAO = new OrderItemDAO();
        PaymentTransactionDAO paymentTransactionDAO = new PaymentTransactionDAO();
        FoodItemDAO foodDAO = new FoodItemDAO();

        Cart cart;
        if (account != null) {
            cart = cartDAO.getActiveCartByCustomerId(account.getId());
        } else {
            if (guestId == null || guestId.isBlank()) {
                session.setAttribute("toastError", "Không tìm thấy phiên đặt hàng khách.");
                response.sendRedirect(request.getContextPath() + "/guest-checkout");
                return;
            }
            cart = cartDAO.getActiveCartByGuestId(guestId);
        }

        if (cart == null) {
            session.setAttribute("toastError", "Không tìm thấy giỏ hàng.");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<CartItem> cartItems = cartItemDAO.getItemsByCartId(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            session.setAttribute("toastError", "Giỏ hàng đang trống.");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        double subTotal = 0;
        for (CartItem item : cartItems) {
            subTotal += item.getQuantity() * item.getUnitPriceSnapshot();
        }

        double deliveryFee = 15000;
        double discountAmount = 0;
        double totalAmount = subTotal + deliveryFee - discountAmount;

        Order order = new Order();
        order.setOrderCode(orderDAO.generateOrderCode());

        if (account != null) {
            order.setCustomerUserId(account.getId());
        } else {
            order.setGuestId(guestId);
        }

        order.setMerchantId(cart.getMerchantUserId());
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setDeliveryAddressLine(deliveryAddressLine);

        order.setProvinceCode(provinceCode);
        order.setProvinceName(provinceName);
        order.setDistrictCode(districtCode);
        order.setDistrictName(districtName);
        order.setWardCode(wardCode);
        order.setWardName(wardName);

        if (latitude != null) {
            order.setLatitude(latitude);
        }
        if (longitude != null) {
            order.setLongitude(longitude);
        }

        order.setDeliveryNote(note);
        order.setPaymentMethod(paymentMethod);
        order.setSubtotalAmount(subTotal);
        order.setDeliveryFee(deliveryFee);
        order.setDiscountAmount(discountAmount);
        order.setTotalAmount(totalAmount);

        if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
            order.setPaymentStatus("PENDING");
            order.setOrderStatus("PENDING_PAYMENT");
        } else {
            order.setPaymentStatus("UNPAID");
            order.setOrderStatus("CREATED");
        }

        int orderId = orderDAO.insert(order);
        if (orderId <= 0) {
            session.setAttribute("toastError", "Không thể tạo đơn hàng.");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        for (CartItem c : cartItems) {
            OrderItem oi = new OrderItem();
            oi.setOrderId(orderId);
            oi.setFoodItemId(c.getFoodItemId());

            String itemName = "";
            try {
                FoodItem food = foodDAO.findById(c.getFoodItemId());
                if (food != null) {
                    itemName = food.getName();
                }
            } catch (Exception ignored) {
            }

            oi.setItemNameSnapshot(itemName);
            oi.setUnitPriceSnapshot(c.getUnitPriceSnapshot());
            oi.setQuantity(c.getQuantity());
            oi.setNote(c.getNote());
            orderItemDAO.insert(oi);
        }

        if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
            String vnpTxnRef = "VNP_" + orderId + "_" + System.currentTimeMillis();

            Map<String, String> vnpParams = new LinkedHashMap<>();
            Date now = new Date();
            Date expire = VnpayUtil.addMinutes(now, 15);

            vnpParams.put("vnp_Version", VnpayConfig.VNP_VERSION);
            vnpParams.put("vnp_Command", VnpayConfig.VNP_COMMAND);
            vnpParams.put("vnp_TmnCode", VnpayConfig.VNP_TMN_CODE);
            vnpParams.put("vnp_Amount", String.valueOf((long) (totalAmount * 100)));
            vnpParams.put("vnp_CurrCode", VnpayConfig.VNP_CURR_CODE);
            vnpParams.put("vnp_TxnRef", vnpTxnRef);
            vnpParams.put("vnp_OrderInfo", "Thanh toan don hang " + order.getOrderCode());
            vnpParams.put("vnp_OrderType", VnpayConfig.VNP_ORDER_TYPE);
            vnpParams.put("vnp_Locale", VnpayConfig.VNP_LOCALE);
            vnpParams.put("vnp_ReturnUrl", VnpayConfig.VNP_RETURN_URL);
            vnpParams.put("vnp_IpAddr", VnpayUtil.getIpAddress(request));
            vnpParams.put("vnp_CreateDate", VnpayUtil.formatDate(now));
            vnpParams.put("vnp_ExpireDate", VnpayUtil.formatDate(expire));

            String signData = VnpayUtil.buildQuery(vnpParams, true);
            String secureHash = VnpayUtil.hmacSHA512(VnpayConfig.VNP_HASH_SECRET, signData);
            vnpParams.put("vnp_SecureHash", secureHash);

            String paymentUrl = VnpayConfig.VNP_PAY_URL + "?" + VnpayUtil.buildQuery(vnpParams, true);

            paymentTransactionDAO.insertVnpay(
                    orderId,
                    totalAmount,
                    order.getOrderCode(),
                    vnpTxnRef,
                    paymentUrl
            );

            response.sendRedirect(paymentUrl);
            return;
        }

        if (account != null) {
            cartDAO.clearActiveCartByCustomerId(account.getId());
        } else {
            cartDAO.clearActiveCartByGuestId(guestId);
        }

        session.setAttribute("toastMsg", "Đặt hàng thành công.");
        response.sendRedirect(request.getContextPath() + "/payment-success?orderId=" + orderId);
    }

    private String buildFullAddress(Address address) {
        if (address == null) {
            return "";
        }

        StringBuilder sb = new StringBuilder();

        if (address.getAddressLine() != null && !address.getAddressLine().isBlank()) {
            sb.append(address.getAddressLine());
        }
        if (address.getWardName() != null && !address.getWardName().isBlank()) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            sb.append(address.getWardName());
        }
        if (address.getDistrictName() != null && !address.getDistrictName().isBlank()) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            sb.append(address.getDistrictName());
        }
        if (address.getProvinceName() != null && !address.getProvinceName().isBlank()) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            sb.append(address.getProvinceName());
        }

        return sb.toString();
    }

    private String stringSession(HttpSession session, String key) {
        Object value = session.getAttribute(key);
        return value == null ? "" : value.toString();
    }

    private double calculateDiscount(Voucher voucher, double subTotal) {
        if (voucher == null) {
            return 0;
        }

        if (voucher.getMinOrderAmount() != null && subTotal < voucher.getMinOrderAmount()) {
            return 0;
        }

        double discount = 0;

        if ("PERCENT".equalsIgnoreCase(voucher.getDiscountType())) {
            discount = subTotal * voucher.getDiscountValue() / 100.0;

            if (voucher.getMaxDiscountAmount() != null && discount > voucher.getMaxDiscountAmount()) {
                discount = voucher.getMaxDiscountAmount();
            }
        } else {
            discount = voucher.getDiscountValue();
        }

        if (discount < 0) {
            discount = 0;
        }

        if (discount > subTotal) {
            discount = subTotal;
        }

        return discount;
    }
}
