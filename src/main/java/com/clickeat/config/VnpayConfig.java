package com.clickeat.config;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

public class VnpayConfig {

    private static final Properties APP_PROPS = loadMergedProperties();

    public static final String VNP_TMN_CODE = readConfig("VNP_TMN_CODE", "VNP_TMN_CODE_PLACEHOLDER");
    public static final String VNP_HASH_SECRET = readConfig("VNP_HASH_SECRET", "VNP_HASH_SECRET_PLACEHOLDER");

    // Sandbox URL chính thức
    public static final String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    public static final String VNP_RETURN_URL = readConfig("VNP_RETURN_URL",
            "https://localhost:8443/ClickEat2/vnpay-return");
    public static final String VNP_IPN_URL = readConfig("VNP_IPN_URL",
            "https://localhost:8443/ClickEat2/vnpay-ipn");

    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";
    public static final String VNP_CURR_CODE = "VND";
    public static final String VNP_LOCALE = "vn";
    public static final String VNP_ORDER_TYPE = "other";

    private VnpayConfig() {
    }

    private static String readConfig(String key, String defaultValue) {
        String fromProperty = System.getProperty(key);
        if (fromProperty != null && !fromProperty.isBlank()) {
            return fromProperty.trim();
        }

        String fromApp = APP_PROPS.getProperty(key);
        if (fromApp != null && !fromApp.isBlank()) {
            return fromApp.trim();
        }

        String fromEnv = System.getenv(key);
        if (fromEnv != null && !fromEnv.isBlank()) {
            return fromEnv.trim();
        }

        return defaultValue;
    }

    private static Properties loadMergedProperties() {
        Properties props = new Properties();

        try (InputStream in = VnpayConfig.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (Exception ignored) {
        }

        try (InputStream local = new FileInputStream("api-keys.local.properties")) {
            props.load(local);
        } catch (Exception ignored) {
        }

        return props;
    }
}
