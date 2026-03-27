package com.clickeat.controller.web;

import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.CartDAO;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.CustomerVoucherDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.dal.impl.VoucherDAO;
import com.clickeat.model.Address;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.CustomerVoucher;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import com.clickeat.model.Voucher;
import com.clickeat.util.DeliveryLocation;
import com.clickeat.util.GeoPoint;
import com.clickeat.util.MapRoutingUtil;
import com.clickeat.util.ShippingFeeUtil;
import com.clickeat.util.ShippingQuote;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    private static final double MAX_DELIVERY_KM = 15.0;
    private static final double LOCATION_MISMATCH_ALERT_KM = 1.5;

    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();
    private final CustomerVoucherDAO customerVoucherDAO = new CustomerVoucherDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final CartItemDAO cartItemDAO = new CartItemDAO();
    private final AddressDAO addressDAO = new AddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        String guestId = (String) session.getAttribute("guestId");

        int cartCount = 0;
        List<FoodItem> foods = new ArrayList<>();
        List<Voucher> vouchers = new ArrayList<>();
        List<MerchantProfile> merchants = new ArrayList<>();

        DeliveryLocation deliveryLocation = resolveCurrentDeliveryLocation(session, account);
        List<MerchantProfile> allMerchants = new ArrayList<>();

        try {
            allMerchants = merchantProfileDAO.findAll();
            if (allMerchants == null) {
                allMerchants = new ArrayList<>();
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("merchantsError", e.getMessage());
        }
        try {
            Cart cart = null;

            if (account != null) {
                cart = cartDAO.getActiveCartByCustomerId(account.getId());
            } else if (guestId != null && !guestId.trim().isEmpty()) {
                cart = cartDAO.getActiveCartByGuestId(guestId);
            }

            if (cart != null) {
                List<CartItem> items = cartItemDAO.getItemsByCartId(cart.getId());
                if (items != null) {
                    for (CartItem item : items) {
                        cartCount += item.getQuantity();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("cartError", e.getMessage());
        }

        try {
            foods = foodItemDAO.getTopFoods(8);
            foods = filterHotDealsByCurrentProvince(foods, allMerchants, deliveryLocation, 8);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("foodsError", e.getMessage());
        }

        try {
            List<Voucher> candidateVouchers = voucherDAO.getActiveVouchers(20);

            if (candidateVouchers == null) {
                candidateVouchers = new ArrayList<>();
            }

            if (account != null && "CUSTOMER".equalsIgnoreCase(account.getRole())) {
                List<CustomerVoucher> savedVouchers = customerVoucherDAO.getSavedVouchersByCustomer(account.getId());
                Set<Integer> savedVoucherIds = new HashSet<>();

                if (savedVouchers != null) {
                    for (CustomerVoucher cv : savedVouchers) {
                        savedVoucherIds.add(cv.getVoucherId());
                    }
                }

                for (Voucher v : candidateVouchers) {
                    if (!savedVoucherIds.contains(v.getId())) {
                        vouchers.add(v);
                    }
                    if (vouchers.size() == 4) {
                        break;
                    }
                }

                if (vouchers.size() < 4) {
                    for (Voucher v : candidateVouchers) {
                        if (!containsVoucher(vouchers, v.getId())) {
                            vouchers.add(v);
                        }
                        if (vouchers.size() == 4) {
                            break;
                        }
                    }
                }
            } else {
                for (Voucher v : candidateVouchers) {
                    vouchers.add(v);
                    if (vouchers.size() == 4) {
                        break;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("vouchersError", e.getMessage());
        }

        try {
            merchants = getNearbyFeaturedMerchants(allMerchants, deliveryLocation, 6);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("merchantsError", e.getMessage());
        }

        if (foods == null) {
            foods = new ArrayList<>();
        }
        if (vouchers == null) {
            vouchers = new ArrayList<>();
        }
        if (merchants == null) {
            merchants = new ArrayList<>();
        }

        Double defaultLat = null;
        Double defaultLng = null;
        String defaultAddressText = null;

        if (account != null && "CUSTOMER".equalsIgnoreCase(account.getRole())) {
            try {
                Address defaultAddress = addressDAO.findDefaultByUserId(account.getId());
                if (defaultAddress != null
                        && defaultAddress.getLatitude() != 0
                        && defaultAddress.getLongitude() != 0) {
                    defaultLat = defaultAddress.getLatitude();
                    defaultLng = defaultAddress.getLongitude();
                    defaultAddressText = buildFullAddress(defaultAddress);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("cartCount", cartCount);
        request.setAttribute("foods", foods);
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("merchants", merchants);

        request.setAttribute("deliveryAddress", deliveryLocation.getAddress());
        request.setAttribute("deliverySource", deliveryLocation.getSource());
        request.setAttribute("deliveryLat", deliveryLocation.getLatitude());
        request.setAttribute("deliveryLng", deliveryLocation.getLongitude());
        request.setAttribute("maxDeliveryKm", MAX_DELIVERY_KM);

        request.setAttribute("defaultAddressLat", defaultLat);
        request.setAttribute("defaultAddressLng", defaultLng);
        request.setAttribute("defaultAddressText", defaultAddressText);
        request.setAttribute("locationMismatchAlertKm", LOCATION_MISMATCH_ALERT_KM);

        request.getRequestDispatcher("/views/web/home.jsp").forward(request, response);
    }

    private DeliveryLocation resolveCurrentDeliveryLocation(HttpSession session, User account) {
        Double sessionLat = toDouble(session.getAttribute("currentDeliveryLat"));
        Double sessionLng = toDouble(session.getAttribute("currentDeliveryLng"));
        String sessionAddress = stringValue(session.getAttribute("currentDeliveryAddress"));
        String sessionSource = stringValue(session.getAttribute("currentDeliverySource"));

        if (account != null && "CUSTOMER".equalsIgnoreCase(account.getRole())) {
            try {
                Address defaultAddress = addressDAO.findDefaultByUserId(account.getId());

                // Nếu user đã chủ động cập nhật GPS trong session thì dùng GPS override cho phiên hiện tại
                if (sessionLat != null && sessionLng != null && sessionLat != 0 && sessionLng != 0) {
                    return new DeliveryLocation(
                            sessionLat,
                            sessionLng,
                            (sessionAddress == null || sessionAddress.isBlank()) ? "Vị trí hiện tại" : sessionAddress,
                            (sessionSource == null || sessionSource.isBlank()) ? "GPS" : sessionSource
                    );
                }

                // Nếu không có GPS override thì ưu tiên địa chỉ mặc định trong DB
                if (defaultAddress != null
                        && defaultAddress.getLatitude() != 0
                        && defaultAddress.getLongitude() != 0) {

                    String fullAddress = buildFullAddress(defaultAddress);

                    return new DeliveryLocation(
                            defaultAddress.getLatitude(),
                            defaultAddress.getLongitude(),
                            (fullAddress == null || fullAddress.isBlank()) ? "Địa chỉ mặc định" : fullAddress,
                            "DEFAULT_ADDRESS"
                    );
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Guest hoặc user chưa có địa chỉ mặc định: dùng session GPS nếu có
        if (sessionLat != null && sessionLng != null && sessionLat != 0 && sessionLng != 0) {
            return new DeliveryLocation(
                    sessionLat,
                    sessionLng,
                    (sessionAddress == null || sessionAddress.isBlank()) ? "Vị trí hiện tại" : sessionAddress,
                    (sessionSource == null || sessionSource.isBlank()) ? "GPS" : sessionSource
            );
        }

        return new DeliveryLocation(null, null, "Chưa xác định vị trí giao hàng", "NONE");
    }

    private List<MerchantProfile> getNearbyFeaturedMerchants(List<MerchantProfile> allMerchants, DeliveryLocation location, int limit) {
        List<MerchantProfile> candidates = new ArrayList<>();
        List<MerchantProfile> result = new ArrayList<>();

        if (allMerchants == null || allMerchants.isEmpty()) {
            return result;
        }

        GeoPoint customerPoint = null;
        if (location != null && location.hasCoordinates()) {
            customerPoint = new GeoPoint(location.getLatitude(), location.getLongitude());
        }

        for (MerchantProfile merchant : allMerchants) {
            if (merchant == null) {
                continue;
            }

            if (!"APPROVED".equalsIgnoreCase(merchant.getStatus())) {
                continue;
            }

            if (merchant.getLatitude() == null || merchant.getLongitude() == null
                    || merchant.getLatitude() == 0 || merchant.getLongitude() == 0) {
                continue;
            }

            if (customerPoint == null || !customerPoint.isValid()) {
                merchant.setDistance("Chưa xác định");
                merchant.setDeliveryTime("--");
                candidates.add(merchant);
                continue;
            }

            GeoPoint merchantPoint = new GeoPoint(merchant.getLatitude(), merchant.getLongitude());
            double airDistanceKm = MapRoutingUtil.haversineKm(customerPoint, merchantPoint);

            if (airDistanceKm <= 0) {
                continue;
            }

            if (airDistanceKm > (MAX_DELIVERY_KM * 1.35)) {
                continue;
            }

            merchant.setDistance(formatDistance(airDistanceKm));
            merchant.setDeliveryTime("Đang tính...");
            candidates.add(merchant);
        }

        if (customerPoint == null || !customerPoint.isValid()) {
            if (candidates.size() > limit) {
                return new ArrayList<>(candidates.subList(0, limit));
            }
            return candidates;
        }

        candidates.sort(Comparator.comparingDouble(this::extractDistanceValue));

        int routeCheckCount = Math.min(candidates.size(), 12);

        for (int i = 0; i < routeCheckCount; i++) {
            MerchantProfile merchant = candidates.get(i);

            GeoPoint merchantPoint = new GeoPoint(merchant.getLatitude(), merchant.getLongitude());
            ShippingQuote quote = ShippingFeeUtil.buildQuote(customerPoint, merchantPoint);

            if (!quote.isAvailable() || quote.getDistanceKm() <= 0) {
                continue;
            }

            if (quote.getDistanceKm() > MAX_DELIVERY_KM) {
                continue;
            }

            merchant.setDistance(formatDistance(quote.getDistanceKm()));
            merchant.setDeliveryTime(formatDuration(quote.getDurationMinutes()));
            merchant.setMinPrice(quote.getFee());
            result.add(merchant);

            if (result.size() == limit) {
                break;
            }
        }

        return result;
    }

    private List<FoodItem> filterHotDealsByCurrentProvince(List<FoodItem> foods,
            List<MerchantProfile> allMerchants,
            DeliveryLocation location,
            int limit) {

        if (foods == null || foods.isEmpty() || allMerchants == null || allMerchants.isEmpty() || location == null) {
            return foods;
        }

        Set<String> provinceSignals = extractProvinceSignals(location.getAddress());
        if (provinceSignals.isEmpty()) {
            return foods;
        }

        Map<Long, MerchantProfile> merchantByUserId = new HashMap<>();
        for (MerchantProfile merchant : allMerchants) {
            if (merchant == null) {
                continue;
            }
            merchantByUserId.put(merchant.getUserId(), merchant);
        }

        List<FoodItem> sameProvinceFoods = new ArrayList<>();
        for (FoodItem food : foods) {
            MerchantProfile merchant = merchantByUserId.get((long) food.getMerchantUserId());
            if (matchesProvince(merchant, provinceSignals)) {
                sameProvinceFoods.add(food);
                if (sameProvinceFoods.size() >= limit) {
                    break;
                }
            }
        }

        // Keep old behavior if location parsing fails to match anything.
        if (sameProvinceFoods.isEmpty()) {
            return foods;
        }
        return sameProvinceFoods;
    }

    private boolean matchesProvince(MerchantProfile merchant, Set<String> provinceSignals) {
        if (merchant == null || provinceSignals == null || provinceSignals.isEmpty()) {
            return false;
        }

        String provinceName = normalizePlaceToken(merchant.getProvinceName());
        String provinceCode = normalizePlaceToken(merchant.getProvinceCode());

        for (String signal : provinceSignals) {
            if (signal == null || signal.isBlank()) {
                continue;
            }
            if (!provinceName.isBlank() && (provinceName.contains(signal) || signal.contains(provinceName))) {
                return true;
            }
            if (!provinceCode.isBlank() && signal.equalsIgnoreCase(provinceCode)) {
                return true;
            }
        }

        return false;
    }

    private Set<String> extractProvinceSignals(String address) {
        Set<String> result = new HashSet<>();
        if (address == null || address.isBlank()) {
            return result;
        }

        String[] parts = address.split(",");
        for (String raw : parts) {
            String token = normalizePlaceToken(raw);
            if (token.isBlank()) {
                continue;
            }

            if (token.contains("tinh")
                    || token.contains("thanh pho")
                    || token.startsWith("tp ")
                    || token.startsWith("tp.")) {
                result.add(token);
                result.add(stripProvincePrefix(token));
            }
        }

        if (result.isEmpty() && parts.length > 0) {
            // Fallback: last meaningful segment before country often maps to province/city.
            String fallback = normalizePlaceToken(parts[parts.length - 1]);
            if (fallback.equals("viet nam") && parts.length >= 2) {
                fallback = normalizePlaceToken(parts[parts.length - 2]);
            }
            if (!fallback.isBlank()) {
                result.add(fallback);
                result.add(stripProvincePrefix(fallback));
            }
        }

        result.removeIf(String::isBlank);
        return result;
    }

    private String stripProvincePrefix(String token) {
        if (token == null) {
            return "";
        }
        String value = token;
        value = value.replace("thanh pho", "").trim();
        value = value.replace("tinh", "").trim();
        value = value.replace("tp.", "").trim();
        value = value.replace("tp", "").trim();
        return value;
    }

    private String normalizePlaceToken(String value) {
        if (value == null) {
            return "";
        }

        String normalized = java.text.Normalizer.normalize(value, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .toLowerCase(Locale.ROOT)
                .replace('đ', 'd')
                .replaceAll("[^a-z0-9\\s]", " ")
                .replaceAll("\\s+", " ")
                .trim();

        return normalized;
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

    private String stringValue(Object value) {
        return value == null ? null : value.toString();
    }

    private double extractDistanceValue(MerchantProfile merchant) {
        try {
            String raw = merchant.getDistance();
            if (raw == null) {
                return Double.MAX_VALUE;
            }
            raw = raw.toLowerCase().replace("km", "").replace(",", ".").trim();
            return Double.parseDouble(raw);
        } catch (Exception e) {
            return Double.MAX_VALUE;
        }
    }

    private String formatDistance(double distanceKm) {
        return String.format(java.util.Locale.US, "%.2f km", distanceKm).replace(".", ",");
    }

    private String formatDuration(int minutes) {
        if (minutes <= 0) {
            return "--";
        }
        if (minutes < 60) {
            return minutes + " phút";
        }

        int hour = minutes / 60;
        int remain = minutes % 60;

        if (remain == 0) {
            return hour + " giờ";
        }
        return hour + " giờ " + remain + " phút";
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

    private boolean containsVoucher(List<Voucher> list, int voucherId) {
        if (list == null || list.isEmpty()) {
            return false;
        }

        for (Voucher v : list) {
            if (v.getId() == voucherId) {
                return true;
            }
        }
        return false;
    }
}
