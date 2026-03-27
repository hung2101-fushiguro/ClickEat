package com.clickeat.util;

public class ShippingFeeUtil {

    private static final double MIN_FEE = 15000;
    private static final double FIRST_BLOCK_KM = 2.0;
    private static final double SECOND_BLOCK_KM = 5.0;
    private static final double RATE_2_TO_5_KM = 3000;
    private static final double RATE_OVER_5_KM = 4000;

    private ShippingFeeUtil() {
    }

    public static double calculateFee(double distanceKm) {
        if (distanceKm <= 0) {
            return MIN_FEE;
        }

        if (distanceKm <= FIRST_BLOCK_KM) {
            return MIN_FEE;
        }

        double fee = MIN_FEE;

        if (distanceKm > FIRST_BLOCK_KM) {
            double secondBlock = Math.min(distanceKm, SECOND_BLOCK_KM) - FIRST_BLOCK_KM;
            if (secondBlock > 0) {
                fee += Math.ceil(secondBlock) * RATE_2_TO_5_KM;
            }
        }

        if (distanceKm > SECOND_BLOCK_KM) {
            double overBlock = distanceKm - SECOND_BLOCK_KM;
            fee += Math.ceil(overBlock) * RATE_OVER_5_KM;
        }

        return fee;
    }

    public static ShippingQuote buildQuote(GeoPoint customerPoint, GeoPoint merchantPoint) {
        ShippingQuote quote = MapRoutingUtil.route(merchantPoint, customerPoint);

        if (quote.isAvailable()) {
            quote.setFee(calculateFee(quote.getDistanceKm()));
            return quote;
        }

        double fallbackDistance = MapRoutingUtil.haversineKm(merchantPoint, customerPoint);
        if (fallbackDistance <= 0) {
            ShippingQuote unavailable = new ShippingQuote();
            unavailable.setAvailable(false);
            unavailable.setFee(MIN_FEE);
            unavailable.setDistanceKm(0);
            unavailable.setDurationMinutes(0);
            unavailable.setFromApi(false);
            unavailable.setMessage("Không thể tính khoảng cách. Tạm dùng phí mặc định.");
            return unavailable;
        }

        double estimatedRoadDistance = fallbackDistance * 1.2;
        int estimatedMinutes = (int) Math.ceil((estimatedRoadDistance / 25.0) * 60.0);

        ShippingQuote fallback = new ShippingQuote();
        fallback.setAvailable(true);
        fallback.setFromApi(false);
        fallback.setDistanceKm(round(estimatedRoadDistance, 2));
        fallback.setDurationMinutes(Math.max(estimatedMinutes, 1));
        fallback.setFee(calculateFee(estimatedRoadDistance));
        fallback.setMessage("Đang dùng ước lượng khoảng cách theo tọa độ.");
        return fallback;
    }

    private static double round(double value, int scale) {
        double factor = Math.pow(10, scale);
        return Math.round(value * factor) / factor;
    }
}