package com.clickeat.controller.web;

import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.Address;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
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
import java.util.List;
import java.util.Locale;
import static org.apache.taglibs.standard.functions.Functions.trim;

@WebServlet(name = "StoreServlet", urlPatterns = {"/store"})
public class StoreServlet extends HttpServlet {

    private static final double MAX_DELIVERY_KM = 15.0;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        String keyword = trim(request.getParameter("keyword"));
        String district = trim(request.getParameter("district"));
        String sort = trim(request.getParameter("sort"));

        MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
        AddressDAO addressDAO = new AddressDAO();

        DeliveryLocation deliveryLocation = resolveCurrentDeliveryLocation(session, account, addressDAO);
        String effectiveProvince = deriveProvinceFromAddress(deliveryLocation.getAddress());

        // Không cho province từ request quyết định nữa
        // Luôn dùng province suy ra từ vị trí giao hàng hiện tại
        String province = effectiveProvince;

        List<String> provinces = new ArrayList<>();
        if (province != null && !province.isBlank()) {
            provinces.add(province);
        }

        List<String> districts = new ArrayList<>();
        if (province != null && !province.isBlank()) {
            try {
                districts = merchantDAO.getDistrictsByProvince(province);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        List<MerchantProfile> stores = new ArrayList<>();

        try {
            // Lấy theo province hiện tại để giảm tập dữ liệu trước
            List<MerchantProfile> rawStores = merchantDAO.searchApprovedStores(keyword, province, district, sort);
            stores = filterStoresByDeliveryLocation(rawStores, deliveryLocation);

            if (stores != null && !stores.isEmpty()) {
                applySort(stores, sort);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("storesError", e.getMessage());
        }

        if (stores == null) {
            stores = new ArrayList<>();
        }
        if (districts == null) {
            districts = new ArrayList<>();
        }
        if (provinces == null) {
            provinces = new ArrayList<>();
        }

        request.setAttribute("stores", stores);
        request.setAttribute("provinces", provinces);
        request.setAttribute("districts", districts);

        request.setAttribute("keyword", keyword);
        request.setAttribute("province", province);
        request.setAttribute("district", district);
        request.setAttribute("sort", sort);

        request.setAttribute("deliveryAddress", deliveryLocation.getAddress());
        request.setAttribute("deliverySource", deliveryLocation.getSource());
        request.setAttribute("deliveryLat", deliveryLocation.getLatitude());
        request.setAttribute("deliveryLng", deliveryLocation.getLongitude());
        request.setAttribute("maxDeliveryKm", MAX_DELIVERY_KM);

        // để JSP biết không cho đổi tỉnh/thành thủ công nữa
        request.setAttribute("provinceLocked", true);
        request.setAttribute("provinceLockedMessage",
                "Khu vực đang được xác định theo địa chỉ giao hàng hiện tại của bạn. Hãy dùng “Cập nhật vị trí” để đổi khu vực.");

        request.getRequestDispatcher("/views/web/store.jsp").forward(request, response);
    }

    private DeliveryLocation resolveCurrentDeliveryLocation(HttpSession session, User account, AddressDAO addressDAO) {
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

                // Nếu không có GPS override thì ưu tiên địa chỉ mặc định
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

    private List<MerchantProfile> filterStoresByDeliveryLocation(List<MerchantProfile> rawStores, DeliveryLocation location) {
        List<MerchantProfile> result = new ArrayList<>();

        if (rawStores == null || rawStores.isEmpty()) {
            return result;
        }

        GeoPoint customerPoint = null;
        if (location != null && location.hasCoordinates()) {
            customerPoint = new GeoPoint(location.getLatitude(), location.getLongitude());
        }

        for (MerchantProfile store : rawStores) {
            if (store == null) {
                continue;
            }

            if (store.getLatitude() == null || store.getLongitude() == null
                    || store.getLatitude() == 0 || store.getLongitude() == 0) {
                continue;
            }

            // Nếu chưa có vị trí giao hàng thì tạm không show store để tránh sai khu vực
            if (customerPoint == null || !customerPoint.isValid()) {
                continue;
            }

            GeoPoint merchantPoint = new GeoPoint(store.getLatitude(), store.getLongitude());

            // Lọc nhanh bằng khoảng cách thẳng
            double airDistanceKm = MapRoutingUtil.haversineKm(customerPoint, merchantPoint);
            if (airDistanceKm <= 0) {
                continue;
            }

            if (airDistanceKm > (MAX_DELIVERY_KM * 1.35)) {
                continue;
            }

            // Chỉ tính route thật cho nhóm đã qua bước lọc nhanh
            ShippingQuote quote = ShippingFeeUtil.buildQuote(customerPoint, merchantPoint);

            if (!quote.isAvailable() || quote.getDistanceKm() <= 0) {
                continue;
            }

            if (quote.getDistanceKm() > MAX_DELIVERY_KM) {
                continue;
            }

            store.setDistance(formatDistance(quote.getDistanceKm()));
            store.setDeliveryTime(formatDuration(quote.getDurationMinutes()));
            store.setMinPrice(quote.getFee());

            result.add(store);
        }

        // Mặc định gần nhất trước
        result.sort(Comparator.comparingDouble(this::extractDistanceValue));
        return result;
    }

    private void applySort(List<MerchantProfile> stores, String sort) {
        if (stores == null || stores.isEmpty() || sort == null || sort.isBlank()) {
            return;
        }

        String sortKey = sort.trim().toLowerCase();

        switch (sortKey) {
            case "nearest":
            case "distance":
                stores.sort(Comparator.comparingDouble(this::extractDistanceValue));
                break;

            case "rating":
                stores.sort((a, b) -> Double.compare(
                        b.getRating(),
                        a.getRating()
                ));
                break;

            case "name":
                stores.sort(Comparator.comparing(
                        s -> safeLower(s.getShopName())
                ));
                break;

            default:
                // giữ mặc định gần nhất trước
                break;
        }
    }

    private String deriveProvinceFromAddress(String address) {
        if (address == null || address.isBlank()) {
            return null;
        }

        String normalized = address.toLowerCase();

        if (normalized.contains("hồ chí minh") || normalized.contains("tp.hcm") || normalized.contains("tp hồ chí minh")) {
            return "TP.HCM";
        }
        if (normalized.contains("đà nẵng") || normalized.contains("da nang")) {
            return "Đà Nẵng";
        }
        if (normalized.contains("hà nội") || normalized.contains("ha noi")) {
            return "Hà Nội";
        }
        if (normalized.contains("cần thơ") || normalized.contains("can tho")) {
            return "Cần Thơ";
        }
        if (normalized.contains("hải phòng") || normalized.contains("hai phong")) {
            return "Hải Phòng";
        }

        // fallback: thử lấy phần cuối địa chỉ
        String[] parts = address.split(",");
        if (parts.length > 0) {
            return parts[parts.length - 1].trim();
        }

        return null;
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

    private String safeLower(String value) {
        return value == null ? "" : value.toLowerCase(Locale.ROOT);
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
        return String.format(Locale.US, "%.2f km", distanceKm).replace(".", ",");
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
}
