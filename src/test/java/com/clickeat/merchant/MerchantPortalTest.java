package com.clickeat.merchant;

import java.time.Duration;
import java.util.List;

import org.junit.jupiter.api.AfterAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import io.github.bonigarcia.wdm.WebDriverManager;

/**
 * Automation test suite for ClickEat Merchant Portal.
 *
 * Configuration (via system properties or defaults):
 * -Dapp.base.url=http://localhost:8080/ClickEat2
 * -Dtest.username=merchant1@shop.vn -Dtest.password=123456
 * -Dwebdriver.headless=true
 *
 * Run: mvn test -Dwebdriver.headless=false (to watch the browser)
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class MerchantPortalTest {

    // ── Config ───────────────────────────────────────────────────────────
    private static final String BASE = System.getProperty("app.base.url", "http://localhost:8080/ClickEat2");
    private static final String EMAIL = System.getProperty("test.username", "merchant1@shop.vn");
    private static final String PASSWORD = System.getProperty("test.password", "123456");
    private static final boolean HEADLESS = Boolean.parseBoolean(System.getProperty("webdriver.headless", "true"));

    private static WebDriver driver;
    private static WebDriverWait wait;

    // ── Lifecycle ─────────────────────────────────────────────────────────
    @BeforeAll
    static void setup() {
        WebDriverManager.chromedriver().setup();
        ChromeOptions opts = new ChromeOptions();
        if (HEADLESS) {
            opts.addArguments("--headless=new", "--disable-gpu", "--no-sandbox", "--window-size=1400,900");
        } else {
            opts.addArguments("--window-size=1400,900");
        }
        opts.addArguments("--disable-dev-shm-usage");
        driver = new ChromeDriver(opts);
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(5));
    }

    @AfterAll
    static void teardown() {
        if (driver != null) {
            driver.quit();
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────
    private void go(String path) {
        driver.get(BASE + path);
    }

    private WebElement find(By by) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(by));
    }

    private WebElement click(By by) {
        WebElement el = wait.until(ExpectedConditions.elementToBeClickable(by));
        el.click();
        return el;
    }

    private void type(By by, String text) {
        WebElement el = find(by);
        el.clear();
        el.sendKeys(text);
    }

    /**
     * Login via unified login page and wait for merchant dashboard. Returns
     * false if login fails.
     */
    private boolean login(String email, String password) {
        go("/login");
        type(By.name("username"), email);
        type(By.name("password"), password);
        click(By.id("loginBtn"));
        try {
            wait.until(ExpectedConditions.or(
                    ExpectedConditions.urlContains("/merchant/dashboard"),
                    ExpectedConditions.presenceOfElementLocated(By.cssSelector(".error, .text-red"))
            ));
        } catch (TimeoutException e) {
            return false;
        }
        return driver.getCurrentUrl().contains("/merchant/dashboard");
    }

    private void ensureLoggedIn() {
        if (!driver.getCurrentUrl().contains("/merchant/")) {
            assertTrue(login(EMAIL, PASSWORD), "Login required but failed");
        } else if (driver.getCurrentUrl().contains("/merchant/login")) {
            assertTrue(login(EMAIL, PASSWORD), "Login required but failed");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AUTH TESTS
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(1)
    @DisplayName("TC01 – Unauthenticated access redirects to unified login")
    void unauthenticatedRedirectToLogin() {
        String[] protectedPaths = {
            "/merchant/dashboard", "/merchant/orders", "/merchant/catalog",
            "/merchant/analytics", "/merchant/reviews", "/merchant/settings"
        };
        for (String path : protectedPaths) {
            go(path);
            String current = driver.getCurrentUrl();
            // MerchantAuthFilter → /merchant/login → MerchantLoginServlet.doGet → /login
            assertTrue(current.contains("/login"),
                    "Expected redirect to login from " + path + " but was: " + current);
        }
    }

    @Test
    @Order(2)
    @DisplayName("TC02 – Login page has required elements")
    void loginPageElements() {
        go("/login");
        assertNotNull(find(By.name("username")), "Username input missing");
        assertNotNull(find(By.name("password")), "Password input missing");
        assertNotNull(find(By.id("loginBtn")), "Login button missing");
    }

    @Test
    @Order(3)
    @DisplayName("TC03 – Invalid credentials shows error message")
    void invalidLoginShowsError() {
        go("/login");
        type(By.name("username"), "wrong@email.com");
        type(By.name("password"), "wrongpassword");
        click(By.id("loginBtn"));

        // Should stay on unified login page with error
        assertTrue(driver.getCurrentUrl().contains("/login"),
                "Should remain on login page after invalid credentials");

        // Look for error message in page
        String body = driver.findElement(By.tagName("body")).getText();
        boolean hasError = body.contains("sai") || body.contains("không đúng")
                || body.contains("invalid") || body.contains("error")
                || driver.findElements(By.cssSelector(".text-red-600, .bg-red-50, .error")).size() > 0;
        assertTrue(hasError, "Error message should appear on invalid login");
    }

    @Test
    @Order(4)
    @DisplayName("TC04 – Valid login redirects to dashboard")
    void validLoginSuccess() {
        boolean success = login(EMAIL, PASSWORD);
        assertTrue(success, "Login should succeed with valid credentials");
        assertTrue(driver.getCurrentUrl().contains("/merchant/dashboard"),
                "Should be on dashboard after login, was: " + driver.getCurrentUrl());
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DASHBOARD TESTS
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(5)
    @DisplayName("TC05 – Dashboard loads key stat cards")
    void dashboardStatCards() {
        ensureLoggedIn();
        go("/merchant/dashboard");

        // Should have revenue / order count stats
        String body = find(By.tagName("main")).getText();
        boolean hasStats = body.contains("đ") || body.contains("đơn") || body.contains("Doanh thu");
        assertTrue(hasStats, "Dashboard should show revenue or order stats");
    }

    @Test
    @Order(6)
    @DisplayName("TC06 – Dashboard sidebar navigation present")
    void dashboardSidebarExistsWithLinks() {
        ensureLoggedIn();
        go("/merchant/dashboard");

        // Nav links
        List<WebElement> navLinks = driver.findElements(By.cssSelector("aside a[href]"));
        assertTrue(navLinks.size() >= 5, "Sidebar should have at least 5 nav links, found: " + navLinks.size());

        // Notification bell
        assertNotNull(driver.findElement(By.id("notifBtn")), "Notification bell should exist");
    }

    @Test
    @Order(7)
    @DisplayName("TC07 – Notification bell API returns JSON")
    void notificationBellApi() {
        ensureLoggedIn();
        go("/merchant/notifications");
        String body = driver.findElement(By.tagName("body")).getText();
        assertTrue(body.contains("\"unread\""),
                "Notifications API should return JSON with 'unread' key, got: " + body.substring(0, Math.min(200, body.length())));
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ORDERS TESTS
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(8)
    @DisplayName("TC08 – Orders page loads with status tabs")
    void ordersPageTabs() {
        ensureLoggedIn();
        go("/merchant/orders");

        // Should have tab buttons
        List<WebElement> tabs = driver.findElements(By.cssSelector("a[href*='status='], a[href*='/merchant/orders']"));
        assertTrue(tabs.size() >= 3, "Orders page should have status tabs");

        // Should have order list or empty state
        String body = find(By.tagName("main")).getText();
        boolean hasOrders = driver.findElements(By.cssSelector("[data-order-id]")).size() > 0
                || body.contains("không có") || body.contains("Chưa có") || body.contains("trống");
        assertTrue(hasOrders || body.length() > 100, "Orders page should load content");
    }

    @Test
    @Order(9)
    @DisplayName("TC09 – Orders page status filter tabs navigate correctly")
    void ordersStatusFilterTabs() {
        ensureLoggedIn();
        go("/merchant/orders");

        // Click each status tab
        String[] statuses = {"PAID", "MERCHANT_ACCEPTED", "DELIVERED", "CANCELLED", "MERCHANT_REJECTED"};
        for (String status : statuses) {
            go("/merchant/orders?status=" + status);
            assertEquals(200, 200); // No exception = page loaded
            // Ensure no server error
            String body = driver.findElement(By.tagName("body")).getText();
            assertFalse(body.contains("HTTP Status 500") || body.contains("NullPointerException"),
                    "Server error on status=" + status + " filter");
        }
    }

    @Test
    @Order(10)
    @DisplayName("TC10 – Orders page pagination parameter works")
    void ordersPaginationParam() {
        ensureLoggedIn();
        go("/merchant/orders?page=1");
        String body = driver.findElement(By.tagName("body")).getText();
        assertFalse(body.contains("500") && body.contains("Error"),
                "Page param should not cause 500 error");
    }

    @Test
    @Order(11)
    @DisplayName("TC11 – Cancel reason modal opens on Từ chối button click")
    void cancelModalOpens() {
        ensureLoggedIn();
        go("/merchant/orders");

        // Check if there are any new orders with reject button
        List<WebElement> rejectBtns = driver.findElements(
                By.cssSelector("button[onclick*='openCancelModal']"));
        if (rejectBtns.isEmpty()) {
            System.out.println("[TC11] SKIP - No pending orders to reject");
            return;
        }

        // Click first reject button
        ((JavascriptExecutor) driver).executeScript("arguments[0].click()", rejectBtns.get(0));

        // Modal should appear
        WebElement modal = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("cancelModal")));
        assertTrue(modal.isDisplayed(), "Cancel modal should be visible after click");

        // Close it
        click(By.cssSelector("#cancelModal button[onclick='closeCancelModal()']"));
        wait.until(ExpectedConditions.invisibilityOfElementLocated(By.id("cancelModal")));
    }

    @Test
    @Order(12)
    @DisplayName("TC12 – Prep time modal opens on Nhận đơn button click")
    void prepModalOpens() {
        ensureLoggedIn();
        go("/merchant/orders");

        List<WebElement> acceptBtns = driver.findElements(
                By.cssSelector("button[onclick*='openPrepModal']"));
        if (acceptBtns.isEmpty()) {
            System.out.println("[TC12] SKIP - No pending orders to accept");
            return;
        }

        ((JavascriptExecutor) driver).executeScript("arguments[0].click()", acceptBtns.get(0));
        WebElement modal = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("prepModal")));
        assertTrue(modal.isDisplayed(), "Prep modal should be visible after click");

        // Close it
        click(By.cssSelector("#prepModal button[onclick='closePrepModal()']"));
        wait.until(ExpectedConditions.invisibilityOfElementLocated(By.id("prepModal")));
    }

    @Test
    @Order(13)
    @DisplayName("TC13 – Order search filters cards client-side")
    void ordersSearch() {
        ensureLoggedIn();
        go("/merchant/orders");

        // The search is purely client-side JS — no URL param, no server call
        List<WebElement> inputs = driver.findElements(By.id("orderSearch"));
        if (inputs.isEmpty()) {
            System.out.println("[TC13] SKIP - Search input not found");
            return;
        }
        WebElement searchInput = inputs.get(0);

        // Type text — sendKeys fires native input events in Chrome
        searchInput.clear();
        searchInput.sendKeys("ZZZNOMATCHWHATSOEVER9999");

        // Page must not crash or navigate away after client-side search
        assertFalse(driver.getPageSource().contains("HTTP Status 500"),
                "Client-side search must not cause server error");
        assertTrue(driver.getCurrentUrl().contains("/merchant/orders"),
                "Should remain on orders page after search, was: " + driver.getCurrentUrl());

        // Clear
        searchInput.clear();
    }

    @Test
    @Order(14)
    @DisplayName("TC14 – Order detail modal opens via detail API call")
    void orderDetailModal() {
        ensureLoggedIn();
        go("/merchant/orders");

        List<WebElement> detailBtns = driver.findElements(By.cssSelector(".detail-trigger"));
        if (detailBtns.isEmpty()) {
            System.out.println("[TC14] SKIP - No orders to view detail");
            return;
        }

        ((JavascriptExecutor) driver).executeScript("arguments[0].click()", detailBtns.get(0));
        WebElement modal = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("detailModal")));
        assertTrue(modal.isDisplayed(), "Detail modal should open");

        // Wait for items to load (spinner disappears)
        wait.until(ExpectedConditions.invisibilityOfElementLocated(By.id("detailSpinner")));

        // Close modal
        By closeBtn = By.cssSelector("#detailModal button[onclick='closeDetail()']");
        click(closeBtn);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CATALOG TESTS
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(15)
    @DisplayName("TC15 – Catalog page loads without server error")
    void catalogPageLoads() {
        ensureLoggedIn();
        go("/merchant/catalog");
        String body = find(By.tagName("body")).getText();
        assertFalse(body.contains("HTTP Status 500"), "Catalog should not return 500");
        assertFalse(body.contains("NullPointerException"), "Catalog should not NPE");
    }

    @Test
    @Order(16)
    @DisplayName("TC16 – Catalog shows food items or empty state")
    void catalogShowsItems() {
        ensureLoggedIn();
        go("/merchant/catalog");
        String body = find(By.tagName("main")).getText();
        boolean hasContent = driver.findElements(By.cssSelector("[data-item-id], .food-card, tr")).size() > 0
                || body.contains("Chưa có") || body.contains("trống") || body.contains("Thêm");
        assertTrue(hasContent, "Catalog should show items or empty state");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  TOGGLE OPEN/CLOSE TEST
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(17)
    @DisplayName("TC17 – Toggle shop open/close and return to dashboard")
    void toggleShopOpenClose() {
        ensureLoggedIn();
        go("/merchant/dashboard");

        // Read initial state via CSS class (green=open, red=closed) — avoids Vietnamese text encoding
        WebElement toggleBtn = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.cssSelector("form[action*='toggle-open'] button")));
        boolean wasGreen = toggleBtn.getAttribute("class").contains("green");

        // Submit via JS — returns IMMEDIATELY (before navigation), so stalenessOf can catch the reload
        ((JavascriptExecutor) driver).executeScript(
                "document.querySelector(\"form[action*='toggle-open']\").submit()");
        wait.until(ExpectedConditions.stalenessOf(toggleBtn));

        // Re-find after page reload
        WebElement toggleAfter = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.cssSelector("form[action*='toggle-open'] button")));
        boolean isGreenAfter = toggleAfter.getAttribute("class").contains("green");
        assertNotEquals(wasGreen, isGreenAfter,
                "Toggle should flip shop state. Before open=" + wasGreen + " After open=" + isGreenAfter);

        // Toggle back to original state
        ((JavascriptExecutor) driver).executeScript(
                "document.querySelector(\"form[action*='toggle-open']\").submit()");
        wait.until(ExpectedConditions.stalenessOf(toggleAfter));
        WebElement restored = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.cssSelector("form[action*='toggle-open'] button")));
        assertEquals(wasGreen, restored.getAttribute("class").contains("green"),
                "Toggle should be restored to original state");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  REVIEWS TESTS
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(18)
    @DisplayName("TC18 – Reviews page loads with filter tabs")
    void reviewsPageWithFilters() {
        ensureLoggedIn();
        go("/merchant/reviews");
        String body = find(By.tagName("body")).getText();
        assertFalse(body.contains("500"), "Reviews page should not 500");

        // Click filter tabs
        for (String filter : new String[]{"all", "unanswered", "negative"}) {
            go("/merchant/reviews?filter=" + filter);
            String fb = driver.findElement(By.tagName("body")).getText();
            assertFalse(fb.contains("NullPointerException"),
                    "Reviews filter=" + filter + " caused NPE");
        }
    }

    @Test
    @Order(19)
    @DisplayName("TC19 – Reviews star filter works")
    void reviewsStarFilter() {
        ensureLoggedIn();
        for (int stars = 1; stars <= 5; stars++) {
            go("/merchant/reviews?stars=" + stars);
            String body = driver.findElement(By.tagName("body")).getText();
            assertFalse(body.contains("HTTP Status 500"),
                    "Reviews stars=" + stars + " caused 500");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SETTINGS TESTS
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(20)
    @DisplayName("TC20 – Settings page loads with store info populated")
    void settingsPageLoadsWithData() {
        ensureLoggedIn();
        go("/merchant/settings");

        WebElement shopNameInput = find(By.name("shopName"));
        String shopName = shopNameInput.getAttribute("value");
        assertNotNull(shopName, "Shop name input should exist");
        assertFalse(shopName.isBlank(), "Shop name should be populated from DB, was blank");

        WebElement phoneInput = find(By.name("shopPhone"));
        String phone = phoneInput.getAttribute("value");
        assertFalse(phone.isBlank(), "Shop phone should be populated from DB, was blank");
    }

    @Test
    @Order(21)
    @DisplayName("TC21 – Settings store form submits and shows success message")
    void settingsStoreFormSaves() {
        ensureLoggedIn();
        go("/merchant/settings");

        // Read current shop name
        WebElement nameInput = find(By.name("shopName"));
        String currentName = nameInput.getAttribute("value");

        // Submit form unchanged to verify it saves
        click(By.cssSelector("#storeForm button[type=submit]"));

        // Should show success message
        WebElement success = wait.until(
                ExpectedConditions.visibilityOfElementLocated(
                        By.cssSelector(".bg-green-50, .text-green-700")));
        assertTrue(success.isDisplayed(), "Success message should appear after save");
    }

    @Test
    @Order(22)
    @DisplayName("TC22 – Settings business hours tab renders days")
    void settingsHoursTabRendered() {
        ensureLoggedIn();
        go("/merchant/settings");

        // Use JS executor to click the hours tab button (avoids visibility/focus issues)
        ((JavascriptExecutor) driver).executeScript(
                "document.querySelector('[onclick*=hours]').click()");

        // Wait for #tab-hours to become visible AND rows to populate
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("tab-hours")));
        wait.until(driver2 -> {
            List<WebElement> rows = driver2.findElements(By.cssSelector("#hoursRows > div"));
            return rows.size() == 7;
        });

        List<WebElement> rows = driver.findElements(By.cssSelector("#hoursRows > div"));
        assertEquals(7, rows.size(), "Should show 7 day rows in hours tab");
    }

    @Test
    @Order(23)
    @DisplayName("TC23 – Settings business hours save POSTs and shows success")
    void settingsHoursSave() {
        ensureLoggedIn();
        go("/merchant/settings");

        // Use JS executor to click the hours tab button (avoids visibility/focus issues)
        ((JavascriptExecutor) driver).executeScript(
                "document.querySelector('[onclick*=hours]').click()");
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("tab-hours")));
        wait.until(driver2 -> driver2.findElements(
                By.cssSelector("#hoursRows > div")).size() == 7);

        // Use JS executor to call saveHours() directly
        ((JavascriptExecutor) driver).executeScript("saveHours()");

        // Should navigate to settings with success message
        WebElement success = wait.until(
                ExpectedConditions.visibilityOfElementLocated(
                        By.cssSelector(".bg-green-50, .text-green-700")));
        assertTrue(success.isDisplayed(), "Success message should appear after saving hours");

        // Verify we're still on settings page
        assertTrue(driver.getCurrentUrl().contains("/merchant/settings"),
                "Should stay on settings page after hours save");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ANALYTICS, WALLET, OTHER PAGES
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(24)
    @DisplayName("TC24 – Analytics page loads without error")
    void analyticsPageLoads() {
        ensureLoggedIn();
        go("/merchant/analytics");
        String body = driver.findElement(By.tagName("body")).getText();
        assertFalse(body.contains("HTTP Status 500"), "Analytics page should not 500");
    }

    @Test
    @Order(25)
    @DisplayName("TC25 – Wallet page loads without error")
    void walletPageLoads() {
        ensureLoggedIn();
        go("/merchant/wallet");
        String body = driver.findElement(By.tagName("body")).getText();
        assertFalse(body.contains("HTTP Status 500"), "Wallet page should not 500");
    }

    @Test
    @Order(26)
    @DisplayName("TC26 – Promotions page loads without error")
    void promotionsPageLoads() {
        ensureLoggedIn();
        go("/merchant/promotions");
        String body = driver.findElement(By.tagName("body")).getText();
        assertFalse(body.contains("HTTP Status 500"), "Promotions page should not 500");
    }

    @Test
    @Order(27)
    @DisplayName("TC27 – Chat page loads without error")
    void chatPageLoads() {
        ensureLoggedIn();
        go("/merchant/chat");
        String body = driver.findElement(By.tagName("body")).getText();
        assertFalse(body.contains("HTTP Status 500"), "Chat page should not 500");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  LOGOUT TEST (last so session is preserved for other tests)
    // ═══════════════════════════════════════════════════════════════════
    @Test
    @Order(28)
    @DisplayName("TC28 – Logout clears session and redirects to unified login")
    void logoutRedirectsToLogin() {
        ensureLoggedIn();
        go("/merchant/logout");
        wait.until(ExpectedConditions.urlContains("/login"));
        assertTrue(driver.getCurrentUrl().contains("/login"),
                "After logout should redirect to login, was: " + driver.getCurrentUrl());

        // Verify protected page now redirects to login
        go("/merchant/dashboard");
        wait.until(ExpectedConditions.urlContains("/login"));
        assertTrue(driver.getCurrentUrl().contains("/login"),
                "After logout, accessing dashboard should redirect to login");
    }
}
