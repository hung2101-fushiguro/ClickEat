package com.clickeat.controller.web;

import com.clickeat.config.VnpayConfig;
import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.CustomerVoucherDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.PaymentTransactionDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Address;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.CustomerVoucher;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import com.clickeat.util.DeliveryLocation;
import com.clickeat.util.GeoPoint;
import com.clickeat.util.MapRoutingUtil;
import com.clickeat.util.ShippingFeeUtil;
import com.clickeat.util.ShippingQuote;
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
        Boolean guestVerified = (Boolean) session.getAttribute("guestVerified");
        String guestId = (String) session.getAttribute("guestId");

        if (account == null && (guestVerified == null || !guestVerified)) {
            response.sendRedirect(request.getContextPath() + "/guest-checkout");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        FoodItemDAO foodDAO = new FoodItemDAO();
        AddressDAO addressDAO = new AddressDAO();
        VoucherDAO voucherDAO = new VoucherDAO();
        MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();

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

        MerchantProfile merchant = null;
        if (cart.getMerchantUserId() != null) {
            merchant = merchantProfileDAO.findById(cart.getMerchantUserId());
        }

        DeliveryLocation deliveryLocation = resolveCheckoutDeliveryLocation(session, account, defaultAddress);

        String shippingAddress = request.getParameter("shippingAddress");
        if (shippingAddress == null || shippingAddress.isBlank()) {
            shippingAddress = deliveryLocation.getAddress();
        }

        String note = request.getParameter("note");
        if (note == null) {
            note = "";
        }

        ShippingQuote shippingQuote = buildShippingQuoteForView(deliveryLocation, shippingAddress, merchant);
        double deliveryFee = shippingQuote.getFee() > 0 ? shippingQuote.getFee() : 15000;

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

            if (account == null) {
                voucherError = "Bạn cần đăng nhập và lưu voucher vào kho trước khi áp dụng.";
            } else if (merchantId == null || merchantId <= 0) {
                voucherError = "Không xác định được nhà hàng của giỏ hàng.";
            } else {
                CustomerVoucherDAO customerVoucherDAO = new CustomerVoucherDAO();
                CustomerVoucher savedVoucher = customerVoucherDAO.findSavedVoucherForCheckout(account.getId(), merchantId, voucherCode);

                if (savedVoucher == null) {
                    voucherError = "Mã voucher không nằm trong kho voucher của bạn, đã hết hạn hoặc không thuộc cửa hàng này.";
                } else {
                    Voucher voucher = voucherDAO.findPublicActiveById(savedVoucher.getVoucherId());

                    if (voucher == null) {
                        voucherError = "Voucher không còn tồn tại trên hệ thống.";
                    } else if (voucher.getMinOrderAmount() != null && subTotal < voucher.getMinOrderAmount()) {
                        voucherError = "Đơn hàng chưa đạt giá trị tối thiểu để áp dụng voucher.";
                    } else if (voucher.getMaxUsesTotal() != null
                            && voucher.getUsedOrderCount() >= voucher.getMaxUsesTotal()) {
                        voucherError = "Voucher đã hết lượt sử dụng.";
                    } else if (voucher.getMaxUsesPerUser() != null) {
                        int usedByUser = voucherDAO.countUsageByVoucherAndCustomer(voucher.getId(), account.getId());
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
                            voucherMessage = "Áp dụng voucher thành công từ kho voucher của bạn: " + voucherCode;
                        } else {
                            voucherError = "Voucher hợp lệ nhưng không áp dụng được cho đơn hàng này.";
                        }
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
        request.setAttribute("merchantProfile", merchant);
        request.setAttribute("deliverySource", deliveryLocation.getSource());

        request.setAttribute("shippingDistanceKm", shippingQuote.getDistanceKm());
        request.setAttribute("shippingDurationMinutes", shippingQuote.getDurationMinutes());
        request.setAttribute("shippingQuoteMessage", shippingQuote.getMessage());
        request.setAttribute("shippingQuoteFromApi", shippingQuote.isFromApi());

        if (account != null) {
            request.setAttribute("user", account);

            String displayFullName = account.getFullName();
            String displayPhone = account.getPhone();

            if (defaultAddress != null) {
                if (defaultAddress.getReceiverName() != null && !defaultAddress.getReceiverName().isBlank()) {
                    displayFullName = defaultAddress.getReceiverName();
                }
                if (defaultAddress.getReceiverPhone() != null && !defaultAddress.getReceiverPhone().isBlank()) {
                    displayPhone = defaultAddress.getReceiverPhone();
                }
            }

            request.setAttribute("displayFullName", displayFullName);
            request.setAttribute("displayEmail", account.getEmail());
            request.setAttribute("displayPhone", displayPhone);
            request.setAttribute("displayAddress", shippingAddress);
        } else {
            String guestFullName = stringSession(session, "guestFullName");
            String guestEmail = stringSession(session, "guestEmail");
            String guestPhone = stringSession(session, "guestPhone");
            String guestAddress = stringSession(session, "guestAddress");

            request.setAttribute("guestFullName", guestFullName);
            request.setAttribute("guestEmail", guestEmail);
            request.setAttribute("guestPhone", guestPhone);
            request.setAttribute("guestAddress", guestAddress);

            request.setAttribute("displayFullName", guestFullName);
            request.setAttribute("displayEmail", guestEmail);
            request.setAttribute("displayPhone", guestPhone);
            request.setAttribute("displayAddress", shippingAddress);
        }

        request.setAttribute("foodDAO", foodDAO);
        request.getRequestDispatcher("/views/web/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        Boolean guestVerified = (Boolean) session.getAttribute("guestVerified");
        String guestId = (String) session.getAttribute("guestId");

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

        if (note == null) {
            note = "";
        }

        AddressDAO addressDAO = new AddressDAO();
        Address defaultAddress = null;

        String receiverName;
        String receiverPhone;
        String deliveryAddressLine = addressLineInput;

        String provinceCode = "NA";
        String provinceName = "NA";
        String districtCode = "NA";
        String districtName = "NA";
        String wardCode = "NA";
        String wardName = "NA";

        Double latitude = null;
        Double longitude = null;

        if (account != null) {
            defaultAddress = addressDAO.findDefaultByUserId(account.getId());
            DeliveryLocation deliveryLocation = resolveCheckoutDeliveryLocation(session, account, defaultAddress);

            receiverName = account.getFullName();
            receiverPhone = account.getPhone();

            if (defaultAddress != null) {
                if (defaultAddress.getReceiverName() != null && !defaultAddress.getReceiverName().isBlank()) {
                    receiverName = defaultAddress.getReceiverName();
                }
                if (defaultAddress.getReceiverPhone() != null && !defaultAddress.getReceiverPhone().isBlank()) {
                    receiverPhone = defaultAddress.getReceiverPhone();
                }

                if (defaultAddress.getProvinceCode() != null && !defaultAddress.getProvinceCode().isBlank()) {
                    provinceCode = defaultAddress.getProvinceCode();
                }
                if (defaultAddress.getProvinceName() != null && !defaultAddress.getProvinceName().isBlank()) {
                    provinceName = defaultAddress.getProvinceName();
                }
                if (defaultAddress.getDistrictCode() != null && !defaultAddress.getDistrictCode().isBlank()) {
                    districtCode = defaultAddress.getDistrictCode();
                }
                if (defaultAddress.getDistrictName() != null && !defaultAddress.getDistrictName().isBlank()) {
                    districtName = defaultAddress.getDistrictName();
                }
                if (defaultAddress.getWardCode() != null && !defaultAddress.getWardCode().isBlank()) {
                    wardCode = defaultAddress.getWardCode();
                }
                if (defaultAddress.getWardName() != null && !defaultAddress.getWardName().isBlank()) {
                    wardName = defaultAddress.getWardName();
                }
            }

            if (deliveryLocation != null && deliveryLocation.getAddress() != null && !deliveryLocation.getAddress().isBlank()) {
                deliveryAddressLine = deliveryLocation.getAddress();
            }

            if (addressLineInput != null && !addressLineInput.isBlank()) {
                deliveryAddressLine = addressLineInput.trim();
            }

            if (deliveryLocation != null && deliveryLocation.getLatitude() != null && deliveryLocation.getLatitude() != 0) {
                latitude = deliveryLocation.getLatitude();
            }
            if (deliveryLocation != null && deliveryLocation.getLongitude() != null && deliveryLocation.getLongitude() != 0) {
                longitude = deliveryLocation.getLongitude();
            }

        } else {
            receiverName = stringSession(session, "guestFullName");
            receiverPhone = stringSession(session, "guestPhone");

            DeliveryLocation deliveryLocation = resolveCheckoutDeliveryLocation(session, null, null);

            if (deliveryLocation != null && deliveryLocation.getAddress() != null && !deliveryLocation.getAddress().isBlank()) {
                deliveryAddressLine = deliveryLocation.getAddress();
            }

            if (addressLineInput != null && !addressLineInput.isBlank()) {
                deliveryAddressLine = addressLineInput.trim();
            }

            if (deliveryLocation != null && deliveryLocation.getLatitude() != null && deliveryLocation.getLatitude() != 0) {
                latitude = deliveryLocation.getLatitude();
            }
            if (deliveryLocation != null && deliveryLocation.getLongitude() != null && deliveryLocation.getLongitude() != 0) {
                longitude = deliveryLocation.getLongitude();
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
        VoucherDAO voucherDAO = new VoucherDAO();
        CustomerVoucherDAO customerVoucherDAO = new CustomerVoucherDAO();
        MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();

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

        MerchantProfile merchant = null;
        if (cart.getMerchantUserId() != null) {
            merchant = merchantProfileDAO.findById(cart.getMerchantUserId());
        }

        GeoPoint customerPoint = null;
        if (latitude != null && longitude != null && latitude != 0 && longitude != 0) {
            customerPoint = new GeoPoint(latitude, longitude);
        } else if (deliveryAddressLine != null && !deliveryAddressLine.isBlank()) {
            GeoPoint geocoded = MapRoutingUtil.geocodeAddress(deliveryAddressLine);
            if (geocoded != null && geocoded.isValid()) {
                customerPoint = geocoded;
                latitude = geocoded.getLatitude();
                longitude = geocoded.getLongitude();
            }
        }

        ShippingQuote shippingQuote = buildShippingQuote(customerPoint, merchant);
        double deliveryFee = shippingQuote.getFee() > 0 ? shippingQuote.getFee() : 15000;
        double discountAmount = 0;

        String voucherCode = request.getParameter("voucherCode");
        if (voucherCode != null) {
            voucherCode = voucherCode.trim();
        }

        Voucher appliedVoucher = null;

        if (voucherCode != null && !voucherCode.isEmpty()) {
            if (account == null) {
                session.setAttribute("toastError", "Khách chưa đăng nhập không thể dùng voucher đã lưu.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            Integer merchantId = cart.getMerchantUserId();
            if (merchantId == null || merchantId <= 0) {
                session.setAttribute("toastError", "Không xác định được cửa hàng của giỏ hàng.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            CustomerVoucher savedVoucher = customerVoucherDAO.findSavedVoucherForCheckout(
                    account.getId(), merchantId, voucherCode
            );

            if (savedVoucher == null) {
                session.setAttribute("toastError", "Voucher không nằm trong kho của bạn hoặc không còn hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            Voucher voucher = voucherDAO.findById(savedVoucher.getVoucherId());
            if (voucher == null) {
                session.setAttribute("toastError", "Voucher không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            if (voucher.getMinOrderAmount() != null && subTotal < voucher.getMinOrderAmount()) {
                session.setAttribute("toastError", "Đơn hàng chưa đạt mức tối thiểu để dùng voucher.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            if (voucher.getMaxUsesTotal() != null
                    && voucher.getUsedOrderCount() >= voucher.getMaxUsesTotal()) {
                session.setAttribute("toastError", "Voucher đã hết lượt sử dụng.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            if (voucher.getMaxUsesPerUser() != null) {
                int usedByUser = voucherDAO.countUsageByVoucherAndCustomer(voucher.getId(), account.getId());
                if (usedByUser >= voucher.getMaxUsesPerUser()) {
                    session.setAttribute("toastError", "Bạn đã dùng hết số lượt của voucher này.");
                    response.sendRedirect(request.getContextPath() + "/checkout");
                    return;
                }
            }

            appliedVoucher = voucher;
            discountAmount = calculateDiscount(appliedVoucher, subTotal);

            if (discountAmount <= 0) {
                session.setAttribute("toastError", "Voucher không áp dụng được cho đơn hàng này.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }
        }

        double totalAmount = subTotal + deliveryFee - discountAmount;
        if (totalAmount < 0) {
            totalAmount = 0;
        }

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

        if (appliedVoucher != null) {
            order.setVoucherId(appliedVoucher.getId());
        }

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

        if (appliedVoucher != null && account != null) {
            voucherDAO.insertUsage(appliedVoucher.getId(), orderId, account.getId(), null);
            customerVoucherDAO.markUsed(account.getId(), appliedVoucher.getId());
        }

        if (account != null) {
            cartDAO.clearActiveCartByCustomerId(account.getId());
        } else {
            cartDAO.clearActiveCartByGuestId(guestId);

            // Ghi nhớ đơn gần nhất của guest để header luôn hiện nút theo dõi
            session.setAttribute("guestLastOrderId", orderId);
            session.setAttribute("guestLastOrderCode", order.getOrderCode());
            session.setAttribute("guestHasTrackableOrder", true);
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

    private String stringValue(Object value) {
        return value == null ? null : value.toString();
    }

    private Double toDouble(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Double) {
            return (Double) value;
        }
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        try {
            return Double.parseDouble(value.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private DeliveryLocation resolveCheckoutDeliveryLocation(HttpSession session, User account, Address defaultAddress) {
        Double sessionLat = toDouble(session.getAttribute("currentDeliveryLat"));
        Double sessionLng = toDouble(session.getAttribute("currentDeliveryLng"));
        String sessionAddress = stringValue(session.getAttribute("currentDeliveryAddress"));
        String sessionSource = stringValue(session.getAttribute("currentDeliverySource"));

        if (account != null && "CUSTOMER".equalsIgnoreCase(account.getRole())) {
            if (sessionLat != null && sessionLng != null && sessionLat != 0 && sessionLng != 0) {
                return new DeliveryLocation(
                        sessionLat,
                        sessionLng,
                        (sessionAddress == null || sessionAddress.isBlank()) ? "Vị trí hiện tại" : sessionAddress,
                        (sessionSource == null || sessionSource.isBlank()) ? "GPS" : sessionSource
                );
            }

            if (defaultAddress != null
                    && defaultAddress.getLatitude() != 0
                    && defaultAddress.getLongitude() != 0) {
                return new DeliveryLocation(
                        defaultAddress.getLatitude(),
                        defaultAddress.getLongitude(),
                        buildFullAddress(defaultAddress),
                        "DEFAULT_ADDRESS"
                );
            }
        }

        if (sessionLat != null && sessionLng != null && sessionLat != 0 && sessionLng != 0) {
            return new DeliveryLocation(
                    sessionLat,
                    sessionLng,
                    (sessionAddress == null || sessionAddress.isBlank()) ? "Vị trí hiện tại" : sessionAddress,
                    (sessionSource == null || sessionSource.isBlank()) ? "GPS" : sessionSource
            );
        }

        String guestAddress = stringSession(session, "guestAddress");
        if (guestAddress != null && !guestAddress.isBlank()) {
            return new DeliveryLocation(null, null, guestAddress, "GUEST_ADDRESS");
        }

        return new DeliveryLocation(null, null, "", "NONE");
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

    private ShippingQuote buildShippingQuoteForView(DeliveryLocation deliveryLocation,
            String shippingAddress, MerchantProfile merchant) {

        GeoPoint customerPoint = null;

        if (deliveryLocation != null
                && deliveryLocation.getLatitude() != null
                && deliveryLocation.getLongitude() != null
                && deliveryLocation.getLatitude() != 0
                && deliveryLocation.getLongitude() != 0) {
            customerPoint = new GeoPoint(deliveryLocation.getLatitude(), deliveryLocation.getLongitude());
        }

        if (customerPoint == null && shippingAddress != null && !shippingAddress.isBlank()) {
            GeoPoint geocoded = MapRoutingUtil.geocodeAddress(shippingAddress);
            if (geocoded != null && geocoded.isValid()) {
                customerPoint = geocoded;
            }
        }

        return buildShippingQuote(customerPoint, merchant);
    }

    private ShippingQuote buildShippingQuote(GeoPoint customerPoint, MerchantProfile merchant) {
        if (merchant == null || merchant.getLatitude() == null || merchant.getLongitude() == null
                || merchant.getLatitude() == 0 || merchant.getLongitude() == 0) {
            ShippingQuote quote = new ShippingQuote();
            quote.setAvailable(false);
            quote.setFromApi(false);
            quote.setFee(15000);
            quote.setMessage("Quán chưa có tọa độ, đang dùng phí giao mặc định.");
            return quote;
        }

        if (customerPoint == null || !customerPoint.isValid()) {
            ShippingQuote quote = new ShippingQuote();
            quote.setAvailable(false);
            quote.setFromApi(false);
            quote.setFee(15000);
            quote.setMessage("Chưa xác định được vị trí giao hàng, đang dùng phí giao mặc định.");
            return quote;
        }

        GeoPoint merchantPoint = new GeoPoint(merchant.getLatitude(), merchant.getLongitude());
        return ShippingFeeUtil.buildQuote(customerPoint, merchantPoint);
    }
}
