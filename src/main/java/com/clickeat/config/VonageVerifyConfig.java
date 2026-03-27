package com.clickeat.config;

import java.io.InputStream;
import java.util.Properties;

public class VonageVerifyConfig {

    private static final Properties APP_PROPS = loadAppProperties();

    public static final String API_KEY = readConfig("VONAGE_API_KEY");
    public static final String API_SECRET = readConfig("VONAGE_API_SECRET");
    public static final String BRAND = readConfigWithDefault("VONAGE_BRAND", "ClickEat");
    public static final String OTP_MODE = readConfig("OTP_MODE");
    public static final String OTP_MOCK_CODE = readConfig("OTP_MOCK_CODE");

    private VonageVerifyConfig() {
    }

    private static String readConfig(String key) {
        String fromProperty = System.getProperty(key);
        if (fromProperty != null && !fromProperty.isBlank()) {
            return fromProperty.trim();
        }

        String fromAppProps = APP_PROPS.getProperty(key);
        if (fromAppProps != null && !fromAppProps.isBlank()) {
            return fromAppProps.trim();
        }

        String fromEnv = System.getenv(key);
        return fromEnv == null ? "" : fromEnv.trim();
    }

    private static String readConfigWithDefault(String key, String defaultValue) {
        String value = readConfig(key);
        return value == null || value.isBlank() ? defaultValue : value;
    }

    private static Properties loadAppProperties() {
        Properties props = new Properties();
        try (InputStream in = VonageVerifyConfig.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (Exception ignored) {
        }
        return props;
    }
}
