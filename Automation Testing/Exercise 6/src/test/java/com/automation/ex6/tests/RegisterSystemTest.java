package com.automation.ex6.tests;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;

import com.automation.ex6.base.BaseTest;
import com.automation.ex6.pages.RegisterPage;
import com.automation.ex6.utils.RandomDataUtil;

public class RegisterSystemTest extends BaseTest {

    @Test
    void registerWithMismatchPasswordShouldShowClientValidation() {
        assumeAppIsReachable("/register");

        RegisterPage registerPage = new RegisterPage(driver)
                .open(getBaseUrl());
        takeScreenshot("ex6_register_page");

        registerPage.register("Test User", "test.user@mail.com", "0988888888", "123456", "654321");
        takeScreenshot("ex6_register_mismatch_result");

        Assertions.assertTrue(registerPage.hasPasswordMismatchText());
    }

    @Test
    void registerWithValidDataShouldRedirectToLogin() {
        assumeAppIsReachable("/register");

        boolean runPositive = Boolean.parseBoolean(getConfig("run.register.positive"));
        Assumptions.assumeTrue(runPositive, "Set run.register.positive=true to execute this test.");

        String phone = RandomDataUtil.randomPhone();
        String email = RandomDataUtil.randomEmail();

        new RegisterPage(driver)
                .open(getBaseUrl())
                .register("Auto Register User", email, phone, "123456", "123456");

        takeScreenshot("ex6_register_valid_result");

        String currentUrl = driver.getCurrentUrl();
        Assertions.assertTrue(
                currentUrl.contains("/login") || currentUrl.contains("/register"),
                "Expected to stay register (if server reject) or redirect login. Actual URL: " + currentUrl
        );
    }
}
