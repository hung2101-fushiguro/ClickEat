package com.clickeat.controller.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.clickeat.config.DBContext;
import com.clickeat.config.VnpayConfig;
import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantDAO;
import com.clickeat.dal.impl.NotificationDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.OrderItemDAO;
import com.clickeat.dal.impl.PaymentTransactionDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Address;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.Order;
import com.clickeat.model.OrderItem;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import com.clickeat.util.VnpayUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private static final double DEFAULT_BASE_SHIPPING_FEE = 10000;
    private static final double DEFAULT_PER_KM_FEE = 5000;
    private static final double DEFAULT_PLATFORM_FEE = 3000;
    private static final double DEFAULT_MAX_DELIVERY_KM = 12;
    private static final double DEFAULT_INCLUDED_DISTANCE_KM = 1;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        Boolean guestVerified = (Boolean) session.getAttribute("guest_verified");
        String guestId = resolveGuestId(session);

        if (account == null && (guestVerified == null || !guestVerified)) {
            response.sendRedirect(request.getContextPath() + "/guest-checkout");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        FoodItemDAO foodDAO = new FoodItemDAO();
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

        Double requestLatitude = parseCoordinate(request.getParameter("shippingLat"));
        Double requestLongitude = parseCoordinate(request.getParameter("shippingLng"));
        Double sessionHomeLatitude = parseCoordinate(stringSession(session, "customer_home_latitude"));
        Double sessionHomeLongitude = parseCoordinate(stringSession(session, "customer_home_longitude"));
        Double cookieHomeLatitude = parseCoordinate(readCookie(request, "ce_home_lat"));
        Double cookieHomeLongitude = parseCoordinate(readCookie(request, "ce_home_lng"));

        Double customerLatitude = null;
        Double customerLongitude = null;

        if (requestLatitude != null && requestLongitude != null) {
            customerLatitude = requestLatitude;
            customerLongitude = requestLongitude;
        } else if (sessionHomeLatitude != null && sessionHomeLongitude != null) {
            customerLatitude = sessionHomeLatitude;
            customerLongitude = sessionHomeLongitude;
        } else if (cookieHomeLatitude != null && cookieHomeLongitude != null) {
            customerLatitude = cookieHomeLatitude;
            customerLongitude = cookieHomeLongitude;
        } else if (defaultAddress != null) {
            if (defaultAddress.getLatitude() != 0) {
                customerLatitude = defaultAddress.getLatitude();
            }
            if (defaultAddress.getLongitude() != 0) {
                customerLongitude = defaultAddress.getLongitude();
            }
        } else {
            customerLatitude = parseCoordinate(stringSession(session, "guest_latitude"));
            customerLongitude = parseCoordinate(stringSession(session, "guest_longitude"));
        }

        if (customerLatitude != null && customerLongitude != null) {
            session.setAttribute("customer_home_latitude", String.valueOf(customerLatitude));
            session.setAttribute("customer_home_longitude", String.valueOf(customerLongitude));
        }

        ShippingQuote shippingQuote = calculateShippingQuote(cart.getMerchantUserId(), customerLatitude, customerLongitude);
        double deliveryFee = shippingQuote.deliveryFee;

        String shippingAddress = request.getParameter("shippingAddress");
        if (shippingAddress == null || shippingAddress.isBlank()) {
            shippingAddress = request.getParameter("addressLine");
        }
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

        List<Voucher> availableVouchers = voucherDAO.getAvailableVouchersForCustomer(account != null ? customerId : 0);
        List<Voucher> validVouchersForThisOrder = new ArrayList<>();
        if (availableVouchers != null) {
            for (Voucher v : availableVouchers) {
                if (v.getMerchantUserId() == null || v.getMerchantUserId().equals(cart.getMerchantUserId())) {
                    if (v.getMinOrderAmount() == null || subTotal >= v.getMinOrderAmount()) {
                        validVouchersForThisOrder.add(v);
                    }
                }
            }
        }

        request.setAttribute("availableVouchers", validVouchersForThisOrder);

        double discountAmount = 0; // Calculated on client-side (JS) and verified on POST
        String voucherCode = "";
        Voucher appliedVoucher = null;
        String voucherMessage = null;
        String voucherError = null;

        double totalAmount = subTotal + deliveryFee - discountAmount;
        if (totalAmount < 0) {
            totalAmount = 0;
        }

        VoucherSuggestion suggestedVoucher = suggestBestVoucher(validVouchersForThisOrder, subTotal);

        request.setAttribute("checkoutItems", checkoutItems);
        request.setAttribute("subTotal", subTotal);
        request.setAttribute("deliveryFee", deliveryFee);
        request.setAttribute("baseShippingFee", shippingQuote.baseFee);
        request.setAttribute("distanceSurcharge", shippingQuote.distanceSurcharge);
        request.setAttribute("platformFee", shippingQuote.platformFee);
        request.setAttribute("distanceKm", shippingQuote.distanceKm);
        request.setAttribute("deliveryBlocked", shippingQuote.deliveryBlocked);
        request.setAttribute("deliveryError", shippingQuote.message);
        request.setAttribute("discountAmount", discountAmount);
        request.setAttribute("totalAmount", totalAmount);

        request.setAttribute("voucherCode", voucherCode == null ? "" : voucherCode);
        request.setAttribute("appliedVoucher", appliedVoucher);
        request.setAttribute("voucherMessage", voucherMessage);
        request.setAttribute("voucherError", voucherError);

        request.setAttribute("shippingAddress", shippingAddress);
        request.setAttribute("note", note);
        request.setAttribute("defaultAddress", defaultAddress);
        request.setAttribute("shippingLat", customerLatitude);
        request.setAttribute("shippingLng", customerLongitude);

        if (suggestedVoucher != null) {
            request.setAttribute("suggestedVoucher", suggestedVoucher.voucher);
            request.setAttribute("suggestedDiscount", suggestedVoucher.discountAmount);

            if (suggestedVoucher.voucher.getMinOrderAmount() != null
                    && subTotal < suggestedVoucher.voucher.getMinOrderAmount()
                    && cart.getMerchantUserId() != null
                    && cart.getMerchantUserId() > 0) {
                double amountToUnlock = suggestedVoucher.voucher.getMinOrderAmount() - subTotal;
                List<FoodItem> merchantFoods = foodDAO.findStoreFoodsPaged(
                        cart.getMerchantUserId(),
                        null,
                        null,
                        null,
                        "price_asc",
                        1,
                        30
                );

                Set<Integer> existingFoodIds = new HashSet<>();
                for (CartItem item : checkoutItems) {
                    existingFoodIds.add(item.getFoodItemId());
                }

                List<FoodItem> upsellFoods = new ArrayList<>();
                for (FoodItem f : merchantFoods) {
                    if (f == null || existingFoodIds.contains(f.getId())) {
                        continue;
                    }
                    upsellFoods.add(f);
                    if (upsellFoods.size() >= 3) {
                        break;
                    }
                }

                if (!upsellFoods.isEmpty()) {
                    request.setAttribute("upsellFoods", upsellFoods);
                    request.setAttribute("upsellTargetAmount", amountToUnlock);
                    request.setAttribute("upsellMerchantId", cart.getMerchantUserId());
                }
            }
        }

        if (account != null) {
            request.setAttribute("user", account);
        } else {
            request.setAttribute("guestFullName", session.getAttribute("guest_fullName"));
            request.setAttribute("guestEmail", session.getAttribute("guest_email"));
            request.setAttribute("guestPhone", session.getAttribute("guest_phone"));
            request.setAttribute("guestAddress", session.getAttribute("guest_address"));
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
        Boolean guestVerified = (Boolean) session.getAttribute("guest_verified");
        String guestId = resolveGuestId(session);

        if (account == null && (guestVerified == null || !guestVerified)) {
            response.sendRedirect(request.getContextPath() + "/guest-checkout");
            return;
        }

        String addressLineInput = request.getParameter("addressLine");
        String paymentMethod = request.getParameter("paymentMethod");
        String note = request.getParameter("note");
        Double requestLatitude = parseCoordinate(request.getParameter("shippingLat"));
        Double requestLongitude = parseCoordinate(request.getParameter("shippingLng"));
        Double sessionHomeLatitude = parseCoordinate(stringSession(session, "customer_home_latitude"));
        Double sessionHomeLongitude = parseCoordinate(stringSession(session, "customer_home_longitude"));
        Double cookieHomeLatitude = parseCoordinate(readCookie(request, "ce_home_lat"));
        Double cookieHomeLongitude = parseCoordinate(readCookie(request, "ce_home_lng"));

        if (paymentMethod == null || paymentMethod.isBlank()) {
            paymentMethod = account != null ? "COD" : "VNPAY";
        }

        // Guest chỉ được phép thanh toán VNPAY — không có tiền mặt
        if (account == null && !"VNPAY".equalsIgnoreCase(paymentMethod)) {
            paymentMethod = "VNPAY";
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
            receiverName = account.getFullName();
            receiverPhone = account.getPhone();

            if (defaultAddress != null) {
                if (defaultAddress.getReceiverName() != null && !defaultAddress.getReceiverName().isBlank()) {
                    receiverName = defaultAddress.getReceiverName();
                }
                if (defaultAddress.getReceiverPhone() != null && !defaultAddress.getReceiverPhone().isBlank()) {
                    receiverPhone = defaultAddress.getReceiverPhone();
                }

                if (defaultAddress.getAddressLine() != null && !defaultAddress.getAddressLine().isBlank()) {
                    deliveryAddressLine = defaultAddress.getAddressLine();
                }

                if (addressLineInput != null && !addressLineInput.isBlank()) {
                    String fullDefaultAddress = buildFullAddress(defaultAddress);
                    if (!addressLineInput.equals(fullDefaultAddress)) {
                        deliveryAddressLine = addressLineInput.trim();
                    }
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

                if (defaultAddress.getLatitude() != 0) {
                    latitude = defaultAddress.getLatitude();
                }
                if (defaultAddress.getLongitude() != 0) {
                    longitude = defaultAddress.getLongitude();
                }
            }

            if (requestLatitude != null && requestLongitude != null) {
                latitude = requestLatitude;
                longitude = requestLongitude;
            } else if (sessionHomeLatitude != null && sessionHomeLongitude != null) {
                latitude = sessionHomeLatitude;
                longitude = sessionHomeLongitude;
            } else if (cookieHomeLatitude != null && cookieHomeLongitude != null) {
                latitude = cookieHomeLatitude;
                longitude = cookieHomeLongitude;
            }
        } else {
            receiverName = stringSession(session, "guest_fullName");
            receiverPhone = stringSession(session, "guest_phone");

            Object guestAddress = session.getAttribute("guest_address");
            if ((deliveryAddressLine == null || deliveryAddressLine.isBlank()) && guestAddress != null) {
                deliveryAddressLine = guestAddress.toString();
            }

            if (requestLatitude != null && requestLongitude != null) {
                latitude = requestLatitude;
                longitude = requestLongitude;
            } else if (sessionHomeLatitude != null && sessionHomeLongitude != null) {
                latitude = sessionHomeLatitude;
                longitude = sessionHomeLongitude;
            } else if (cookieHomeLatitude != null && cookieHomeLongitude != null) {
                latitude = cookieHomeLatitude;
                longitude = cookieHomeLongitude;
            } else {
                latitude = parseCoordinate(stringSession(session, "guest_latitude"));
                longitude = parseCoordinate(stringSession(session, "guest_longitude"));
            }
        }

        if (latitude != null && longitude != null) {
            session.setAttribute("customer_home_latitude", String.valueOf(latitude));
            session.setAttribute("customer_home_longitude", String.valueOf(longitude));
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

        ShippingQuote shippingQuote = calculateShippingQuote(cart.getMerchantUserId(), latitude, longitude);
        if (shippingQuote.deliveryBlocked) {
            session.setAttribute("toastError", shippingQuote.message);
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        double deliveryFee = shippingQuote.deliveryFee;

        // Re-validate voucher server-side (never trust client-side discountAmount)
        String[] voucherCodesPost = request.getParameterValues("voucherCodes");
        double discountAmount = 0;
        List<Voucher> appliedVouchers = new ArrayList<>();

        if (voucherCodesPost != null && voucherCodesPost.length > 0 && cart.getMerchantUserId() != null && cart.getMerchantUserId() > 0) {
            List<String> codesList = java.util.Arrays.asList(voucherCodesPost);
            List<Voucher> vouchers = voucherDAO.findValidVouchersByCodes(cart.getMerchantUserId(), codesList);

            int merchantVoucherCount = 0;
            int systemVoucherCount = 0;

            for (Voucher voucher : vouchers) {
                if ("SYSTEM".equalsIgnoreCase(voucher.getVoucherType())) {
                    if (systemVoucherCount >= 1) {
                        continue;
                    }
                    systemVoucherCount++;
                } else {
                    if (merchantVoucherCount >= 1) {
                        continue;
                    }
                    merchantVoucherCount++;
                }

                if ((voucher.getMinOrderAmount() == null || subTotal >= voucher.getMinOrderAmount())
                        && (voucher.getMaxUsesTotal() == null || voucher.getUsedOrderCount() < voucher.getMaxUsesTotal())) {
                    boolean perUserOk = true;
                    if (account != null && voucher.getMaxUsesPerUser() != null) {
                        int usedByUser = voucherDAO.countUsageByVoucherAndCustomer(voucher.getId(), account.getId());
                        perUserOk = usedByUser < voucher.getMaxUsesPerUser();
                    }
                    if (perUserOk) {
                        appliedVouchers.add(voucher);
                        discountAmount += calculateDiscount(voucher, subTotal);
                    }
                }
            }
            if (discountAmount > subTotal) {
                discountAmount = subTotal;
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

        if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
            order.setPaymentStatus("PENDING");
            order.setOrderStatus("PENDING_PAYMENT");
        } else {
            order.setPaymentStatus("UNPAID");
            order.setOrderStatus("CREATED");
        }

        List<OrderItem> orderItems = new ArrayList<>();
        for (CartItem c : cartItems) {
            OrderItem oi = new OrderItem();
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
            oi.setSelectedSize(c.getSelectedSize());
            oi.setSelectedToppings(c.getSelectedToppings());
            oi.setOptionExtraPrice(c.getOptionExtraPrice());
            orderItems.add(oi);
        }

        int orderId;
        String paymentUrl = null;
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            orderId = orderDAO.insert(conn, order);
            if (orderId <= 0) {
                conn.rollback();
                session.setAttribute("toastError", "Không thể tạo đơn hàng.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            for (OrderItem item : orderItems) {
                item.setOrderId(orderId);
            }
            int[] batchResults = orderItemDAO.insertBatch(conn, orderItems);
            if (orderItemDAO.hasBatchFailure(batchResults)) {
                conn.rollback();
                session.setAttribute("toastError", "Không thể lưu chi tiết đơn hàng. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            if (!appliedVouchers.isEmpty()) {
                int customerId = account != null ? account.getId() : 0;
                for (Voucher voucher : appliedVouchers) {
                    boolean usageRecorded = voucherDAO.validateAndRecordUsage(
                            conn,
                            voucher.getId(),
                            cart.getMerchantUserId(),
                            orderId,
                            customerId,
                            guestId,
                            subTotal
                    );
                    if (!usageRecorded) {
                        conn.rollback();
                        session.setAttribute("toastError", "Voucher " + voucher.getCode() + " vừa hết lượt hoặc không còn hợp lệ. Vui lòng thử lại.");
                        response.sendRedirect(request.getContextPath() + "/checkout");
                        return;
                    }
                }
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

                paymentUrl = VnpayConfig.VNP_PAY_URL + "?" + VnpayUtil.buildQuery(vnpParams, true);
                int paymentInserted = paymentTransactionDAO.insertVnpay(
                        conn,
                        orderId,
                        totalAmount,
                        order.getOrderCode(),
                        vnpTxnRef,
                        paymentUrl
                );
                if (paymentInserted <= 0) {
                    conn.rollback();
                    session.setAttribute("toastError", "Không thể khởi tạo giao dịch VNPAY. Vui lòng thử lại.");
                    response.sendRedirect(request.getContextPath() + "/checkout");
                    return;
                }
            } else {
                boolean cartCleared;
                if (account != null) {
                    cartCleared = cartDAO.clearActiveCartByCustomerId(conn, account.getId());
                } else {
                    cartCleared = cartDAO.clearActiveCartByGuestId(conn, guestId);
                }

                if (!cartCleared) {
                    conn.rollback();
                    session.setAttribute("toastError", "Không thể cập nhật giỏ hàng sau khi tạo đơn. Vui lòng thử lại.");
                    response.sendRedirect(request.getContextPath() + "/checkout");
                    return;
                }
            }

            conn.commit();
        } catch (SQLException ex) {
            session.setAttribute("toastError", "Đặt hàng thất bại do lỗi hệ thống. Vui lòng thử lại.");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
            response.sendRedirect(paymentUrl);
            return;
        }

        NotificationDAO notificationDAO = new NotificationDAO();
        if (account != null) {
            notificationDAO.createForUser(account.getId(), "ORDER", "Đơn #" + order.getOrderCode() + " đã được tạo thành công.");
        }
        if (order.getMerchantId() > 0) {
            notificationDAO.createForUser(order.getMerchantId(), "ORDER", "Bạn có đơn mới #" + order.getOrderCode() + ".");
        }

        session.setAttribute("toastMsg", "Đặt hàng thành công.");
        response.sendRedirect(request.getContextPath() + "/payment-success?orderId=" + orderId);
    }

    private ShippingQuote calculateShippingQuote(Integer merchantUserId, Double customerLatitude, Double customerLongitude) {
        double baseFee = getConfigDouble("clickeat.shipping.baseFee", DEFAULT_BASE_SHIPPING_FEE);
        double perKmFee = getConfigDouble("clickeat.shipping.perKmFee", DEFAULT_PER_KM_FEE);
        double platformFee = getConfigDouble("clickeat.shipping.platformFee", DEFAULT_PLATFORM_FEE);
        double maxDistanceKm = getConfigDouble("clickeat.shipping.maxDistanceKm", DEFAULT_MAX_DELIVERY_KM);
        double includedDistanceKm = getConfigDouble("clickeat.shipping.includedDistanceKm", DEFAULT_INCLUDED_DISTANCE_KM);

        ShippingQuote quote = new ShippingQuote();
        quote.baseFee = Math.max(0, baseFee);
        quote.platformFee = Math.max(0, platformFee);
        quote.distanceSurcharge = 0;
        quote.distanceKm = null;
        quote.deliveryBlocked = false;

        if (merchantUserId == null || merchantUserId <= 0) {
            quote.deliveryFee = quote.baseFee + quote.platformFee;
            quote.message = "Không xác định được nhà hàng để tính phí giao hàng.";
            return quote;
        }

        MerchantProfile merchant = new MerchantDAO().getMerchantByUserId(merchantUserId);
        if (merchant == null || merchant.getLatitude() == null || merchant.getLongitude() == null
                || merchant.getLatitude() == 0 || merchant.getLongitude() == 0
                || customerLatitude == null || customerLongitude == null) {
            quote.deliveryFee = quote.baseFee + quote.platformFee;
            quote.message = "Chưa đủ tọa độ để tính khoảng cách chính xác, hệ thống tạm áp dụng phí mặc định.";
            return quote;
        }

        double distanceKm = haversineDistanceKm(
                merchant.getLatitude(),
                merchant.getLongitude(),
                customerLatitude,
                customerLongitude
        );

        quote.distanceKm = distanceKm;
        if (maxDistanceKm > 0 && distanceKm > maxDistanceKm) {
            quote.deliveryBlocked = true;
            quote.deliveryFee = 0;
            quote.message = String.format(
                    "Địa chỉ giao hàng cách quán %.1f km, vượt giới hạn giao tối đa %.1f km.",
                    distanceKm,
                    maxDistanceKm
            );
            return quote;
        }

        double extraDistance = Math.max(0, distanceKm - Math.max(0, includedDistanceKm));
        double chargedKm = Math.ceil(extraDistance);
        quote.distanceSurcharge = chargedKm * Math.max(0, perKmFee);
        quote.deliveryFee = quote.baseFee + quote.distanceSurcharge + quote.platformFee;
        quote.message = null;
        return quote;
    }

    private VoucherSuggestion suggestBestVoucher(List<Voucher> vouchers, double subTotal) {
        if (subTotal <= 0 || vouchers == null || vouchers.isEmpty()) {
            return null;
        }

        Voucher bestVoucher = null;
        double bestDiscount = 0;

        for (Voucher voucher : vouchers) {
            if (voucher == null) {
                continue;
            }

            double discount = calculateDiscount(voucher, subTotal);
            if (discount > bestDiscount) {
                bestDiscount = discount;
                bestVoucher = voucher;
            }
        }

        if (bestVoucher == null || bestDiscount <= 0) {
            return null;
        }

        VoucherSuggestion suggestion = new VoucherSuggestion();
        suggestion.voucher = bestVoucher;
        suggestion.discountAmount = bestDiscount;
        return suggestion;
    }

    private double getConfigDouble(String key, double defaultValue) {
        String value = System.getProperty(key);
        if (value == null || value.isBlank()) {
            String envKey = key.toUpperCase().replace('.', '_');
            value = System.getenv(envKey);
        }
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
        double earthRadiusKm = 6371.0;
        double latRad1 = Math.toRadians(lat1);
        double latRad2 = Math.toRadians(lat2);
        double deltaLat = Math.toRadians(lat2 - lat1);
        double deltaLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2)
                + Math.cos(latRad1) * Math.cos(latRad2)
                * Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadiusKm * c;
    }

    private static class ShippingQuote {

        private double baseFee;
        private double distanceSurcharge;
        private double platformFee;
        private double deliveryFee;
        private Double distanceKm;
        private boolean deliveryBlocked;
        private String message;
    }

    private static class VoucherSuggestion {

        private Voucher voucher;
        private double discountAmount;
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

    private String resolveGuestId(HttpSession session) {
        if (session == null) {
            return null;
        }

        String guestId = (String) session.getAttribute("guest_id");
        if (guestId == null || guestId.isBlank()) {
            guestId = (String) session.getAttribute("guestId");
        }

        if (guestId != null && !guestId.isBlank()) {
            session.setAttribute("guest_id", guestId);
            session.setAttribute("guestId", guestId);
            return guestId;
        }

        return null;
    }

    private Double parseCoordinate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String readCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null || name == null) {
            return null;
        }
        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
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
