package com.automation.ex6.tests;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import com.automation.ex6.base.BaseTest;
import com.automation.ex6.pages.LoginPage;

public class LoginSystemTest extends BaseTest {

    @Test
    void loginWithInvalidPasswordShouldShowError() {
        assumeAppIsReachable("/login");

        LoginPage loginPage = new LoginPage(driver)
                .open(getBaseUrl());
        takeScreenshot("ex6_login_page");

        loginPage.login("0900000001", "wrong-password");
        takeScreenshot("ex6_login_invalid_result");

        String currentUrl = driver.getCurrentUrl();
        String pageSource = driver.getPageSource();
        Assertions.assertTrue(
                loginPage.hasErrorMessage()
                || currentUrl.contains("/login")
                || pageSource.contains("Sai tài khoản hoặc mật khẩu")
                || pageSource.contains("Vui lòng nhập đầy đủ tài khoản và mật khẩu"),
                "Expected login failure indicators (error message or remain on login page)."
        );
    }

    @Test
    void loginWithValidAccountShouldRedirectByRole() {
        assumeAppIsReachable("/login");

        String username = getConfig("valid.username");
        String password = getConfig("valid.password");

        new LoginPage(driver)
                .open(getBaseUrl())
                .login(username, password);

        takeScreenshot("ex6_login_valid_result");

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
