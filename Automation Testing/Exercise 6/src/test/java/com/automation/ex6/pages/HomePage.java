package com.automation.ex6.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import com.automation.ex6.base.BasePage;

public class HomePage extends BasePage {

    private final By homeUniqueMarker = By.xpath("//*[contains(text(),'ClickEat')]");

    public HomePage(WebDriver driver) {
        super(driver);
    }

    public boolean isLoaded() {
        return isDisplayed(homeUniqueMarker);
    }
}
