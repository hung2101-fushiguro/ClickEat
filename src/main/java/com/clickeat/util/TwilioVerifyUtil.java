package com.clickeat.util;

import com.clickeat.config.TwilioVerifyConfig;
import com.twilio.Twilio;
import com.twilio.exception.ApiException;
import com.twilio.rest.verify.v2.service.Verification;
import com.twilio.rest.verify.v2.service.VerificationCheck;

public class TwilioVerifyUtil {

    private static volatile boolean initialized = false;
    private static final ThreadLocal<String> LAST_ERROR = new ThreadLocal<>();

    private TwilioVerifyUtil() {
    }

    public static boolean sendOtp(String phoneE164) {
        clearLastError();

        if (phoneE164 == null || phoneE164.isBlank() || !phoneE164.matches("^\\+[1-9]\\d{8,14}$")) {
            setLastError("Số điện thoại chưa đúng chuẩn quốc tế E.164 (ví dụ: +84900000000).");
            return false;
        }

        if (!ensureInitialized()) {
            return false;
        }
        try {
            Verification verification = Verification.creator(
                    TwilioVerifyConfig.VERIFY_SERVICE_SID,
                    phoneE164,
                    "sms"
            ).create();

            return "pending".equalsIgnoreCase(verification.getStatus());
        } catch (Exception e) {
            setLastError(buildReadableError(e));
            return false;
        }
    }

    public static boolean verifyOtp(String phoneE164, String code) {
        clearLastError();

        if (!ensureInitialized()) {
            return false;
        }
        try {
            VerificationCheck check = VerificationCheck.creator(
                    TwilioVerifyConfig.VERIFY_SERVICE_SID,
                    code
            ).setTo(phoneE164).create();

            return "approved".equalsIgnoreCase(check.getStatus());
        } catch (Exception e) {
            setLastError(buildReadableError(e));
            return false;
        }
    }

    public static String getLastError() {
        return LAST_ERROR.get();
    }

    private static boolean ensureInitialized() {
        if (!isConfigured()) {
            setLastError("Thiếu cấu hình Twilio Verify (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_VERIFY_SERVICE_SID).");
            return false;
        }
        if (initialized) {
            return true;
        }
        synchronized (TwilioVerifyUtil.class) {
            if (!initialized) {
                try {
                    Twilio.init(TwilioVerifyConfig.ACCOUNT_SID, TwilioVerifyConfig.AUTH_TOKEN);
                    initialized = true;
                } catch (Exception e) {
                    setLastError("Không khởi tạo được kết nối Twilio: " + safeMessage(e));
                    return false;
                }
            }
        }
        return true;
    }

    private static boolean isConfigured() {
        return notBlank(TwilioVerifyConfig.ACCOUNT_SID)
                && notBlank(TwilioVerifyConfig.AUTH_TOKEN)
                && notBlank(TwilioVerifyConfig.VERIFY_SERVICE_SID);
    }

    private static boolean notBlank(String value) {
        return value != null && !value.isBlank();
    }

    private static void clearLastError() {
        LAST_ERROR.remove();
    }

    private static void setLastError(String message) {
        if (message == null || message.isBlank()) {
            LAST_ERROR.remove();
            return;
        }
        LAST_ERROR.set(message.trim());
    }

    private static String buildReadableError(Exception e) {
        if (e instanceof ApiException apiEx) {
            Integer code = apiEx.getCode();
            String message = safeMessage(apiEx);

            if (message != null) {
                String lower = message.toLowerCase();
                if (lower.contains("unverified") || lower.contains("verify") && lower.contains("trial")) {
                    return "Số điện thoại chưa được verify trong Twilio Trial. Hãy thêm số này vào Verified Caller IDs của tài khoản Twilio.";
                }
                if (lower.contains("invalid") && lower.contains("to")) {
                    return "Số điện thoại nhận OTP không hợp lệ hoặc không đúng chuẩn +84...";
                }
                if (lower.contains("service") && lower.contains("sid")) {
                    return "TWILIO_VERIFY_SERVICE_SID không đúng hoặc service đã bị xóa.";
                }
            }

            if (code != null) {
                return "Twilio trả về lỗi (code " + code + "): " + message;
            }
            return "Twilio trả về lỗi: " + message;
        }

        return "Không thể gửi OTP do lỗi kết nối Twilio: " + safeMessage(e);
    }

    private static String safeMessage(Exception e) {
        String message = e == null ? null : e.getMessage();
        if (message == null || message.isBlank()) {
            return "Không có chi tiết lỗi.";
        }
        return message;
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
}
