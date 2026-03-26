package com.clickeat.config;

import java.io.InputStream;
import java.util.Properties;

public class TwilioVerifyConfig {

    private static final Properties APP_PROPS = loadAppProperties();

    public static final String ACCOUNT_SID = readConfig("TWILIO_ACCOUNT_SID");
    public static final String AUTH_TOKEN = readConfig("TWILIO_AUTH_TOKEN");
    public static final String VERIFY_SERVICE_SID = readConfig("TWILIO_VERIFY_SERVICE_SID");

    private TwilioVerifyConfig() {
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

    private static Properties loadAppProperties() {
        Properties props = new Properties();
        try (InputStream in = TwilioVerifyConfig.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (Exception ignored) {
        }
        return props;
    }
}
