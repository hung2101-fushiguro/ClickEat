package com.clickeat.util;

import com.clickeat.config.VonageVerifyConfig;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class VonageVerifyUtil {

    private static final HttpClient HTTP = HttpClient.newHttpClient();
    private static final Gson GSON = new Gson();
    private static String lastError;

    private VonageVerifyUtil() {
    }

    public static String getLastError() {
        return lastError;
    }

    public static SendOtpResult sendOtp(String phoneE164) {
        lastError = null;

        try {
            String body = "number=" + enc(phoneE164)
                    + "&brand=" + enc(VonageVerifyConfig.BRAND)
                    + "&code_length=6";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.nexmo.com/verify/json"))
                    .header("Authorization", basicAuth())
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString());
            JsonObject json = GSON.fromJson(response.body(), JsonObject.class);

            String status = getString(json, "status");
            if ("0".equals(status)) {
                String requestId = getString(json, "request_id");
                return new SendOtpResult(true, requestId, null);
            }

            String errorText = getString(json, "error_text");
            lastError = "Vonage sendOtp error | status=" + status + " | message=" + errorText;
            return new SendOtpResult(false, null, lastError);

        } catch (IOException | InterruptedException e) {
            lastError = "Vonage sendOtp system error | " + e.getClass().getSimpleName() + " | " + e.getMessage();
            return new SendOtpResult(false, null, lastError);
        }
    }

    public static boolean verifyOtp(String requestId, String code) {
        lastError = null;

        try {
            String body = "request_id=" + enc(requestId)
                    + "&code=" + enc(code);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.nexmo.com/verify/check/json"))
                    .header("Authorization", basicAuth())
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString());
            JsonObject json = GSON.fromJson(response.body(), JsonObject.class);

            String status = getString(json, "status");
            if ("0".equals(status)) {
                return true;
            }

            String errorText = getString(json, "error_text");
            lastError = "Vonage verifyOtp error | status=" + status + " | message=" + errorText;
            return false;

        } catch (IOException | InterruptedException e) {
            lastError = "Vonage verifyOtp system error | " + e.getClass().getSimpleName() + " | " + e.getMessage();
            return false;
        }
    }

    public static String normalizePhoneToE164VN(String phone) {
        if (phone == null) {
            return null;
        }

        phone = phone.trim().replaceAll("\\s+", "");
        if (phone.startsWith("+")) {
            return phone;
        }
        if (phone.startsWith("0")) {
            return "+84" + phone.substring(1);
        }
        if (phone.startsWith("84")) {
            return "+" + phone;
        }
        return phone;
    }

    private static String basicAuth() {
        String raw = VonageVerifyConfig.API_KEY + ":" + VonageVerifyConfig.API_SECRET;
        return "Basic " + Base64.getEncoder().encodeToString(raw.getBytes(StandardCharsets.UTF_8));
    }

    private static String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static String getString(JsonObject json, String key) {
        return json != null && json.has(key) && !json.get(key).isJsonNull()
                ? json.get(key).getAsString()
                : null;
    }

    public static class SendOtpResult {
        private final boolean success;
        private final String requestId;
        private final String errorMessage;

        public SendOtpResult(boolean success, String requestId, String errorMessage) {
            this.success = success;
            this.requestId = requestId;
            this.errorMessage = errorMessage;
        }

        public boolean isSuccess() {
            return success;
        }

        public String getRequestId() {
            return requestId;
        }

        public String getErrorMessage() {
            return errorMessage;
        }
    }
}