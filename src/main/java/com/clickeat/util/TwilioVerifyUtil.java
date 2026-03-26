package com.clickeat.util;

import com.clickeat.config.TwilioVerifyConfig;
import com.twilio.Twilio;
import com.twilio.rest.verify.v2.service.Verification;
import com.twilio.rest.verify.v2.service.VerificationCheck;

public class TwilioVerifyUtil {

    static {
        Twilio.init(TwilioVerifyConfig.ACCOUNT_SID, TwilioVerifyConfig.AUTH_TOKEN);
    }

    private TwilioVerifyUtil() {
    }

    public static boolean sendOtp(String phoneE164) {
        try {
            System.out.println("Twilio sendOtp phone = " + phoneE164);
            System.out.println("Twilio VERIFY_SERVICE_SID = " + TwilioVerifyConfig.VERIFY_SERVICE_SID);

            Verification verification = Verification.creator(
                    TwilioVerifyConfig.VERIFY_SERVICE_SID,
                    phoneE164,
                    "sms"
            ).create();

            System.out.println("Twilio sendOtp status = " + verification.getStatus());
            return "pending".equalsIgnoreCase(verification.getStatus());
        } catch (Exception e) {
            System.out.println("Twilio sendOtp error = " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public static boolean verifyOtp(String phoneE164, String code) {
        try {
            VerificationCheck check = VerificationCheck.creator(
                    TwilioVerifyConfig.VERIFY_SERVICE_SID
            ).setTo(phoneE164).setCode(code).create();

            return "approved".equalsIgnoreCase(check.getStatus());
        } catch (Exception e) {
            e.printStackTrace();
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
}
