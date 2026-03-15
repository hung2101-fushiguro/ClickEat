package com.automation.ex6.utils;

import java.util.concurrent.ThreadLocalRandom;

public final class RandomDataUtil {

    private RandomDataUtil() {
    }

    public static String randomPhone() {
        long value = ThreadLocalRandom.current().nextLong(100000000L, 999999999L);
        return "0" + value;
    }

    public static String randomEmail() {
        int suffix = ThreadLocalRandom.current().nextInt(10000, 99999);
        return "auto_user_" + suffix + "@mail.com";
    }
}
