package com.clickeat.util;

import jakarta.servlet.http.HttpServletRequest;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class VnpayUtil {

    private VnpayUtil() {
    }

    public static String hmacSHA512(String key, String data) {
        try {
            Mac hmac512 = Mac.getInstance("");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "");
            hmac512.init(secretKey);
            byte[] bytes = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));

            StringBuilder hash = new StringBuilder();
            for (byte b : bytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hash.append('0');
                }
                hash.append(hex);
            }
            return hash.toString();
        } catch (Exception e) {
            throw new RuntimeException("Không thể tạo HMAC SHA512", e);
        }
    }

    public static String buildQuery(Map<String, String> params, boolean encodeValue) {
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < fieldNames.size(); i++) {
            String key = fieldNames.get(i);
            String value = params.get(key);
            if (value == null || value.isBlank()) {
                continue;
            }

            if (sb.length() > 0) {
                sb.append("&");
            }

            sb.append(URLEncoder.encode(key, StandardCharsets.US_ASCII));
            sb.append("=");

            if (encodeValue) {
                sb.append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
            } else {
                sb.append(value);
            }
        }
        return sb.toString();
    }

    public static String getIpAddress(HttpServletRequest request) {
        String[] headers = {
            "X-Forwarded-For",
            "Proxy-Client-IP",
            "WL-Proxy-Client-IP",
            "HTTP_X_FORWARDED_FOR",
            "HTTP_X_FORWARDED",
            "HTTP_X_CLUSTER_CLIENT_IP",
            "HTTP_CLIENT_IP",
            "HTTP_FORWARDED_FOR",
            "HTTP_FORWARDED"
        };

        for (String header : headers) {
            String ip = request.getHeader(header);
            if (ip != null && !ip.isBlank() && !"unknown".equalsIgnoreCase(ip)) {
                return ip.split(",")[0].trim();
            }
        }
        return request.getRemoteAddr();
    }

    public static String formatDate(Date date) {
        return new SimpleDateFormat("yyyyMMddHHmmss").format(date);
    }

    public static Date addMinutes(Date date, int minutes) {
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT-7"));
        cal.setTime(date);
        cal.add(Calendar.MINUTE, minutes);
        return cal.getTime();
    }

    public static boolean validateReturn(Map<String, String> fields, String secret) {
        String secureHash = fields.remove("vnp_SecureHash");
        fields.remove("vnp_SecureHashType");

        String signData = buildQuery(fields, true);
        String computed = hmacSHA512(secret, signData);
        return computed.equalsIgnoreCase(secureHash);
    }
}