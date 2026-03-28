package com.clickeat.controller.ai;

/** Immutable GPS coordinate pair. */
public final class UserLocation {
    public static final UserLocation UNKNOWN = new UserLocation(null, null);

    public final Double lat;
    public final Double lng;

    public UserLocation(Double lat, Double lng) {
        this.lat = lat;
        this.lng = lng;
    }

    public boolean isValid() {
        return valid(lat, lng);
    }

    public static boolean valid(Double lat, Double lng) {
        return lat != null && lng != null
                && lat >= -90 && lat <= 90
                && lng >= -180 && lng <= 180;
    }

    public static boolean valid(double lat, double lng) {
        return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    }
}
