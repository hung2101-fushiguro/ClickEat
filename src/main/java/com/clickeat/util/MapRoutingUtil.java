package com.clickeat.util;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import org.json.JSONArray;
import org.json.JSONObject;

public class MapRoutingUtil {

    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder().build();

    private static final String APP_USER_AGENT = "ClickEat/1.0 (delivery-distance-service)";
    private static final String NOMINATIM_BASE = "https://nominatim.openstreetmap.org/search";
    private static final String OSRM_BASE = "https://router.project-osrm.org/route/v1/driving/";

    private MapRoutingUtil() {
    }

    public static GeoPoint geocodeAddress(String fullAddress) {
        try {
            if (fullAddress == null || fullAddress.trim().isEmpty()) {
                return null;
            }

            String normalized = fullAddress.trim();
            if (!normalized.toLowerCase().contains("việt nam")
                    && !normalized.toLowerCase().contains("vietnam")) {
                normalized += ", Việt Nam";
            }

            String url = NOMINATIM_BASE
                    + "?format=jsonv2"
                    + "&limit=1"
                    + "&q=" + URLEncoder.encode(normalized, StandardCharsets.UTF_8);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("User-Agent", APP_USER_AGENT)
                    .header("Accept", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                return null;
            }

            JSONArray array = new JSONArray(response.body());
            if (array.isEmpty()) {
                return null;
            }

            JSONObject first = array.getJSONObject(0);
            double lat = Double.parseDouble(first.getString("lat"));
            double lon = Double.parseDouble(first.getString("lon"));

            GeoPoint point = new GeoPoint(lat, lon);
            return point.isValid() ? point : null;

        } catch (IOException | InterruptedException | RuntimeException e) {
            return null;
        }
    }

    public static ShippingQuote route(GeoPoint origin, GeoPoint destination) {
        ShippingQuote quote = new ShippingQuote();

        try {
            if (origin == null || destination == null || !origin.isValid() || !destination.isValid()) {
                quote.setAvailable(false);
                quote.setMessage("Thiếu tọa độ để tính tuyến đường.");
                return quote;
            }

            String coordinates = origin.getLongitude() + "," + origin.getLatitude()
                    + ";" + destination.getLongitude() + "," + destination.getLatitude();

            String url = OSRM_BASE + coordinates + "?overview=false&steps=false";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("User-Agent", APP_USER_AGENT)
                    .header("Accept", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                quote.setAvailable(false);
                quote.setMessage("OSRM trả về mã lỗi " + response.statusCode());
                return quote;
            }

            JSONObject root = new JSONObject(response.body());
            JSONArray routes = root.optJSONArray("routes");

            if (routes == null || routes.isEmpty()) {
                quote.setAvailable(false);
                quote.setMessage("Không tìm thấy tuyến đường phù hợp.");
                return quote;
            }

            JSONObject firstRoute = routes.getJSONObject(0);
            double distanceMeters = firstRoute.optDouble("distance", 0);
            double durationSeconds = firstRoute.optDouble("duration", 0);

            double distanceKm = distanceMeters / 1000.0;
            int durationMinutes = (int) Math.ceil(durationSeconds / 60.0);

            quote.setDistanceKm(round(distanceKm, 2));
            quote.setDurationMinutes(Math.max(durationMinutes, 1));
            quote.setAvailable(true);
            quote.setFromApi(true);
            quote.setMessage("Tính từ route API.");
            return quote;

        } catch (IOException | InterruptedException | RuntimeException e) {
            quote.setAvailable(false);
            quote.setMessage("Lỗi gọi route API: " + e.getMessage());
            return quote;
        }
    }

    public static double haversineKm(GeoPoint a, GeoPoint b) {
        if (a == null || b == null || !a.isValid() || !b.isValid()) {
            return 0;
        }

        double earthRadiusKm = 6371.0;

        double lat1 = Math.toRadians(a.getLatitude());
        double lon1 = Math.toRadians(a.getLongitude());
        double lat2 = Math.toRadians(b.getLatitude());
        double lon2 = Math.toRadians(b.getLongitude());

        double dLat = lat2 - lat1;
        double dLon = lon2 - lon1;

        double sinLat = Math.sin(dLat / 2);
        double sinLon = Math.sin(dLon / 2);

        double aa = sinLat * sinLat
                + Math.cos(lat1) * Math.cos(lat2) * sinLon * sinLon;

        double c = 2 * Math.atan2(Math.sqrt(aa), Math.sqrt(1 - aa));
        return earthRadiusKm * c;
    }

    private static double round(double value, int scale) {
        double factor = Math.pow(10, scale);
        return Math.round(value * factor) / factor;
    }

    public static String reverseGeocode(double latitude, double longitude) {
        try {
            String url = "https://nominatim.openstreetmap.org/reverse"
                    + "?format=jsonv2"
                    + "&lat=" + latitude
                    + "&lon=" + longitude;

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("User-Agent", APP_USER_AGENT)
                    .header("Accept", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                return null;
            }

            JSONObject root = new JSONObject(response.body());
            String displayName = root.optString("display_name", null);

            if (displayName == null || displayName.isBlank()) {
                return null;
            }

            return displayName;

        } catch (Exception e) {
            return null;
        }
    }
}
