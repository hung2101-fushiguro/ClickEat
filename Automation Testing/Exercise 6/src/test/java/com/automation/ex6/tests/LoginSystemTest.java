package com.automation.ex6.tests;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import com.automation.ex6.base.BaseTest;
import com.automation.ex6.pages.LoginPage;

public class LoginSystemTest extends BaseTest {

    @Test
    void loginWithInvalidPasswordShouldShowError() {
        LoginPage loginPage = new LoginPage(driver)
                .open(getBaseUrl())
                .login("0900000001", "wrong-password");

        Assertions.assertTrue(loginPage.hasErrorMessage());
    }

    @Test
    void loginWithValidAccountShouldRedirectByRole() {
        String username = getConfig("valid.username");
        String password = getConfig("valid.password");

        new LoginPage(driver)
                .open(getBaseUrl())
                .login(username, password);

        String currentUrl = driver.getCurrentUrl();
        Assertions.assertTrue(
                currentUrl.contains("/home")
                || currentUrl.contains("/admin/dashboard")
                || currentUrl.contains("/merchant/dashboard")
                || currentUrl.contains("/shipper/dashboard"),
                "Expected redirect to role dashboard or home, actual URL: " + currentUrl
        );
    }
}
