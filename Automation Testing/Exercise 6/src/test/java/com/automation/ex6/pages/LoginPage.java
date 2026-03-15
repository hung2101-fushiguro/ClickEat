package com.automation.ex6.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import com.automation.ex6.base.BasePage;

public class LoginPage extends BasePage {

    private final By usernameInput = By.name("username");
    private final By passwordInput = By.name("password");
    private final By submitButton = By.cssSelector("button[type='submit']");
    private final By errorMessage = By.xpath("//*[contains(text(),'Sai tài khoản hoặc mật khẩu') or contains(text(),'Vui lòng nhập đầy đủ tài khoản và mật khẩu')]");

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    public LoginPage open(String baseUrl) {
        driver.get(baseUrl + "/login");
        return this;
    }

    public LoginPage login(String username, String password) {
        type(usernameInput, username);
        type(passwordInput, password);
        click(submitButton);
        return this;
    }

    public boolean hasErrorMessage() {
        return isDisplayed(errorMessage);
    }
}
