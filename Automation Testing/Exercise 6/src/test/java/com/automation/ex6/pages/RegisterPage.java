package com.automation.ex6.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import com.automation.ex6.base.BasePage;

public class RegisterPage extends BasePage {

    private final By fullNameInput = By.name("fullName");
    private final By emailInput = By.name("email");
    private final By phoneInput = By.name("phone");
    private final By passwordInput = By.name("password");
    private final By confirmPasswordInput = By.name("confirmPassword");
    private final By submitButton = By.cssSelector("button[type='submit']");

    private final By passwordMismatchText = By.id("pw-mismatch");
    private final By serverErrorMessage = By.xpath("//*[contains(@class,'text-red-600') or contains(text(),'không đúng định dạng') or contains(text(),'đã được đăng ký')]");

    public RegisterPage(WebDriver driver) {
        super(driver);
    }

    public RegisterPage open(String baseUrl) {
        driver.get(baseUrl + "/register");
        return this;
    }

    public RegisterPage register(String fullName, String email, String phone, String password, String confirmPassword) {
        type(fullNameInput, fullName);
        type(emailInput, email);
        type(phoneInput, phone);
        type(passwordInput, password);
        type(confirmPasswordInput, confirmPassword);
        click(submitButton);
        return this;
    }

    public boolean hasPasswordMismatchText() {
        return isDisplayed(passwordMismatchText);
    }

    public boolean hasServerErrorMessage() {
        return isDisplayed(serverErrorMessage);
    }
}
