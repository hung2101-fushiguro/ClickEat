package com.automation.ex6.base;

import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.util.Properties;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

import io.github.bonigarcia.wdm.WebDriverManager;

public abstract class BaseTest {

    protected WebDriver driver;
    protected Properties config;

    @BeforeEach
    void setUp() {
        config = loadConfig();
        WebDriverManager.chromedriver().setup();

        ChromeOptions options = new ChromeOptions();
        boolean headless = Boolean.parseBoolean(
                System.getProperty("headless", config.getProperty("headless", "true"))
        );
        if (headless) {
            options.addArguments("--headless=new", "--window-size=1920,1080");
        }
        options.addArguments("--disable-gpu", "--no-sandbox");

        driver = new ChromeDriver(options);
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(3));
        driver.manage().window().maximize();
    }

    @AfterEach
    void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }

    protected String getBaseUrl() {
        return System.getProperty("base.url", config.getProperty("base.url"));
    }

    protected String getConfig(String key) {
        return System.getProperty(key, config.getProperty(key));
    }

    private Properties loadConfig() {
        Properties properties = new Properties();
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("config.properties")) {
            if (is != null) {
                properties.load(is);
            }
        } catch (IOException exception) {
            throw new RuntimeException("Cannot load config.properties", exception);
        }
        return properties;
    }
}
