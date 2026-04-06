"""
Crawl nhà hàng khu FPT City / Điện Bàn / Ngũ Hành Sơn
Nguồn: foody.vn (tên, địa chỉ, SĐT, hình ảnh, menu)
Output: restaurants_danang.json + seed_crawled_data.sql
"""

import logging
import time
import sys
import io
import json
import re
from dataclasses import dataclass, field, asdict
from typing import Optional

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from webdriver_manager.chrome import ChromeDriverManager

# ── Encoding fix ──────────────────────────────────────────────────────────────
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

# ── Logging ───────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("crawl_log.txt", encoding="utf-8"),
    ],
)
log = logging.getLogger(__name__)

# ── Config ────────────────────────────────────────────────────────────────────
TARGET_COUNT = 50

AREA_URLS = [
    "https://www.foody.vn/da-nang/khu-vuc-fpt-city",
    "https://www.foody.vn/da-nang/khu-vuc-quan-ngu-hanh-son",
    "https://www.foody.vn/da-nang/khu-vuc-dien-ban",
]

# ── Data classes ──────────────────────────────────────────────────────────────
@dataclass
class FoodItem:
    name: str
    desc: str = ""
    price: int = 0
    img: str = ""

@dataclass
class MenuCategory:
    category_name: str
    items: list = field(default_factory=list)

@dataclass
class Restaurant:
    name: str
    address: str = ""
    phone: str = ""
    image: str = ""
    source_url: str = ""
    menu: list = field(default_factory=list)


# ══════════════════════════════════════════════════════════════════════════════
# Helpers
# ══════════════════════════════════════════════════════════════════════════════

def safe_text(parent, css: str) -> str:
    try:
        return parent.find_element(By.CSS_SELECTOR, css).text.strip()
    except Exception:
        return ""

def safe_attr(parent, css: str, attr: str) -> str:
    try:
        return (parent.find_element(By.CSS_SELECTOR, css).get_attribute(attr) or "").strip()
    except Exception:
        return ""

def parse_price(raw: str) -> int:
    cleaned = re.sub(r"[^\d]", "", raw)
    return int(cleaned) if cleaned else 0

def sql_escape(val: str) -> str:
    return (val or "").replace("'", "''")

def try_selectors_text(driver, selectors: list) -> str:
    for sel in selectors:
        try:
            el = driver.find_element(By.CSS_SELECTOR, sel)
            val = el.text.strip()
            if val:
                return val
        except Exception:
            continue
    return ""

def try_selectors_attr(driver, selectors: list, attr: str) -> str:
    for sel in selectors:
        try:
            el = driver.find_element(By.CSS_SELECTOR, sel)
            val = (el.get_attribute(attr) or "").strip()
            if val:
                return val
        except Exception:
            continue
    return ""

def slow_scroll(driver, times: int = 6, pause: float = 1.2):
    for _ in range(times):
        driver.execute_script("window.scrollBy(0, window.innerHeight * 0.8);")
        time.sleep(pause)


# ══════════════════════════════════════════════════════════════════════════════
# PHASE 1 — Thu thập link nhà hàng từ trang khu vực Foody
# ══════════════════════════════════════════════════════════════════════════════

def is_detail_link(href: str) -> bool:
    """Kiểm tra href có phải là link chi tiết nhà hàng không."""
    if not href or "foody.vn" not in href:
        return False
    skip = ["/khu-vuc", "/tim-kiem", "/loai-hinh", "/mon-an",
            "/dia-diem", "/giao-do-an", "/danh-sach"]
    if any(s in href for s in skip):
        return False
    parts = href.rstrip("/").split("/")
    # Phải có ít nhất: https: '' foody.vn da-nang ten-quan
    return len(parts) >= 5 and parts[-1] != "da-nang"

def get_restaurant_links(driver, target_count: int) -> list:
    collected = set()

    for area_url in AREA_URLS:
        if len(collected) >= target_count:
            break

        log.info(f"Quét khu vực: {area_url}")
        try:
            driver.get(area_url)
            time.sleep(5)
        except Exception as e:
            log.warning(f"Load thất bại {area_url}: {e}")
            continue

        stale = 0
        while len(collected) < target_count and stale < 7:
            before = len(collected)

            # Lấy tất cả thẻ <a> trên trang, lọc link chi tiết nhà hàng
            all_links = driver.find_elements(By.TAG_NAME, "a")
            for a in all_links:
                try:
                    href = (a.get_attribute("href") or "").split("?")[0]
                    if is_detail_link(href):
                        collected.add(href)
                except Exception:
                    continue

            log.info(f"  → {len(collected)}/{target_count} links")

            if len(collected) == before:
                stale += 1
            else:
                stale = 0

            if len(collected) >= target_count:
                break

            # Thử click "Xem thêm"
            clicked = False
            for xpath in [
                "//a[contains(@class,'view-more')]",
                "//button[contains(.,'Xem thêm')]",
                "//a[contains(.,'Xem thêm')]",
                "//a[contains(.,'Xem tiếp')]",
                "//*[@class='btn-load-more']",
            ]:
                try:
                    btn = driver.find_element(By.XPATH, xpath)
                    driver.execute_script("arguments[0].scrollIntoView(true);", btn)
                    time.sleep(0.5)
                    btn.click()
                    log.info("  → Clicked 'Xem thêm'")
                    time.sleep(4)
                    clicked = True
                    break
                except Exception:
                    continue

            if not clicked:
                slow_scroll(driver, times=3, pause=1.5)

    result = list(collected)[:target_count]
    log.info(f"Tổng: {len(result)} links nhà hàng")
    return result


# ══════════════════════════════════════════════════════════════════════════════
# PHASE 2 — Crawl chi tiết nhà hàng trên Foody.vn
# ══════════════════════════════════════════════════════════════════════════════

NAME_SELS = [
    "h1.res-page-name", "h1.restaurant-name", "h1.name",
    ".fn-name h1", "h1.place-name", "h1",
]
ADDR_SELS = [
    "span.address-value", ".res-info-address span",
    "div.address-restaurant span", "a.address",
    ".fn-address", "span.fn-address",
    "div.info-contact span",
]
PHONE_SELS = [
    "a.phone-value", "span.phone-value",
    "a[href^='tel:']", ".fn-phone",
    "span.tel", ".res-info-phone span",
]
IMG_SELS = [
    "div.restaurant-img img", "div.res-banner img",
    ".fn-avatar img", "img.restaurant-avatar",
    ".restaurant-cover img", "div.cover-img img",
]

def extract_phone_from_body(driver) -> str:
    try:
        body = driver.find_element(By.TAG_NAME, "body").text
        m = re.search(r"(0[0-9]{9,10})", body)
        return m.group(1) if m else ""
    except Exception:
        return ""

def crawl_menu_foody(driver) -> list:
    """Parse menu từ trang Foody chi tiết."""
    categories = []
    slow_scroll(driver, times=8, pause=1.0)

    # Foody dùng cấu trúc: section group → item list
    GROUP_SELS = [
        "div.food-list-group", "div.menu-section",
        "div.menu-group", "section.food-section",
        "div.category-group",
    ]
    ITEM_SELS = [
        "div.food-item", "div.item-food",
        "li.food-item", ".food-card",
        "div.res-item",
    ]

    for grp_sel in GROUP_SELS:
        groups = driver.find_elements(By.CSS_SELECTOR, grp_sel)
        if not groups:
            continue

        log.info(f"  Menu: {len(groups)} groups [{grp_sel}]")
        for grp in groups:
            cat_name = (
                safe_text(grp, "h2.group-name") or safe_text(grp, "div.group-title")
                or safe_text(grp, "h3") or safe_text(grp, "h2") or "Menu"
            )
            cat = MenuCategory(category_name=cat_name)
            for item_sel in ITEM_SELS:
                items = grp.find_elements(By.CSS_SELECTOR, item_sel)
                if items:
                    for it in items:
                        fi = parse_food_item(it)
                        if fi:
                            cat.items.append(fi)
                    break
            if cat.items:
                categories.append(cat)
                log.info(f"    [{cat_name}]: {len(cat.items)} món")
        if categories:
            return categories

    # Fallback: flat list
    for item_sel in ITEM_SELS:
        items = driver.find_elements(By.CSS_SELECTOR, item_sel)
        if items:
            log.info(f"  Menu flat: {len(items)} món [{item_sel}]")
            cat = MenuCategory(category_name="Thực Đơn")
            for it in items:
                fi = parse_food_item(it)
                if fi:
                    cat.items.append(fi)
            if cat.items:
                categories.append(cat)
            return categories

    log.warning("  Không tìm thấy menu")
    return []

def parse_food_item(el) -> Optional[FoodItem]:
    try:
        name = (
            safe_text(el, "h3.food-title") or safe_text(el, "span.food-name")
            or safe_text(el, "h3") or safe_text(el, "h2")
            or safe_text(el, ".item-name") or safe_text(el, "p.name")
        )
        if not name:
            return None
        desc = (
            safe_text(el, "p.food-desc") or safe_text(el, "span.food-desc")
            or safe_text(el, ".item-desc") or ""
        )
        price_raw = (
            safe_text(el, "span.price") or safe_text(el, "span.food-price")
            or safe_text(el, ".item-price") or "0"
        )
        img = safe_attr(el, "img", "src") or safe_attr(el, "img", "data-src") or ""
        return FoodItem(name=name, desc=desc, price=parse_price(price_raw), img=img)
    except Exception:
        return None

def crawl_restaurant(driver, url: str) -> Optional[Restaurant]:
    log.info(f"Crawl: {url}")
    try:
        driver.get(url)

        loaded = False
        for sel in NAME_SELS:
            try:
                WebDriverWait(driver, 12).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, sel))
                )
                loaded = True
                break
            except TimeoutException:
                continue

        if not loaded:
            log.warning(f"  Timeout: {url}")
            return None

        time.sleep(2)

        name  = try_selectors_text(driver, NAME_SELS)
        addr  = try_selectors_text(driver, ADDR_SELS)
        phone = try_selectors_text(driver, PHONE_SELS)
        image = try_selectors_attr(driver, IMG_SELS, "src")

        if phone.startswith("tel:"):
            phone = phone[4:].strip()
        if not phone:
            phone = extract_phone_from_body(driver)

        if not name:
            log.warning(f"  Không lấy được tên: {url}")
            return None

        log.info(f"  ✓ {name}")
        log.info(f"    Địa chỉ : {addr or '(không có)'}")
        log.info(f"    SĐT     : {phone or '(không có)'}")

        menu = crawl_menu_foody(driver)

        return Restaurant(
            name=name, address=addr, phone=phone,
            image=image, source_url=url, menu=menu,
        )

    except Exception as e:
        log.error(f"Lỗi: {url} — {e}")
        return None


# ══════════════════════════════════════════════════════════════════════════════
# Outputs
# ══════════════════════════════════════════════════════════════════════════════

def save_json(data: list, path="restaurants_danang.json"):
    with open(path, "w", encoding="utf-8") as f:
        json.dump([asdict(r) for r in data], f, ensure_ascii=False, indent=2)
    log.info(f"JSON: {path} ({len(data)} nhà hàng)")

def generate_sql(data: list, path="seed_crawled_data.sql"):
    L = [
        "-- SEED: Foody.vn — FPT City / Điện Bàn / Ngũ Hành Sơn",
        "USE ClickEat;", "GO\n",
        "BEGIN TRY", "    BEGIN TRAN;\n",
    ]
    uid = 1000
    for r in data:
        sn = sql_escape(r.name)
        sa = sql_escape(r.address)
        si = sql_escape(r.image)
        sp = sql_escape(r.phone) if r.phone else f"0900{uid}"
        em = f"merchant{uid}@foody.vn"
        pv = "N'49', N'Quảng Nam'" if "Quảng Nam" in r.address or "Điện Bàn" in r.address else "N'48', N'Đà Nẵng'"

        L += [
            f"    -- {sn}",
            f"    INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)",
            f"    VALUES(N'{sn}',N'{em}',N'{sp}',N'hash_pwd',N'MERCHANT',N'ACTIVE');",
            f"    DECLARE @m{uid} BIGINT = SCOPE_IDENTITY();\n",
            f"    INSERT INTO dbo.MerchantProfiles(user_id,shop_name,shop_phone,shop_address_line,province_code,province_name,district_code,district_name,ward_code,ward_name,status,image_url)",
            f"    VALUES(@m{uid},N'{sn}',N'{sp}',N'{sa}',{pv},N'000',N'Quận',N'000',N'Phường',N'APPROVED',N'{si}');\n",
        ]
        cid = 1
        for cat in r.menu:
            sc = sql_escape(cat.category_name)
            L += [
                f"    INSERT INTO dbo.Categories(merchant_user_id,name,is_active,sort_order)",
                f"    VALUES(@m{uid},N'{sc}',1,{cid});",
                f"    DECLARE @cat_m{uid}_{cid} BIGINT = SCOPE_IDENTITY();\n",
            ]
            for it in cat.items:
                sn2 = sql_escape(it.name)
                sd  = sql_escape(it.desc)
                iv  = f"N'{sql_escape(it.img)}'" if it.img else "NULL"
                L += [
                    f"    INSERT INTO dbo.FoodItems(merchant_user_id,category_id,name,description,price,image_url,is_available,is_fried,calories)",
                    f"    VALUES(@m{uid},@cat_m{uid}_{cid},N'{sn2}',N'{sd}',{it.price},{iv},1,0,500);",
                ]
            L.append("")
            cid += 1
        uid += 1

    L += [
        "    COMMIT TRAN;",
        "    PRINT N'Seeded successfully.';",
        "END TRY",
        "BEGIN CATCH",
        "    IF @@TRANCOUNT > 0 ROLLBACK TRAN;",
        "    PRINT N'ERROR: ' + ERROR_MESSAGE();",
        "    THROW;",
        "END CATCH;",
        "GO\n",
    ]
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    log.info(f"SQL: {path}")


# ══════════════════════════════════════════════════════════════════════════════
# Driver
# ══════════════════════════════════════════════════════════════════════════════

def build_driver():
    opts = Options()
    # opts.add_argument("--headless=new")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--window-size=1920,1080")
    opts.add_argument("--disable-blink-features=AutomationControlled")
    opts.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    )
    opts.add_experimental_option("excludeSwitches", ["enable-automation"])
    opts.add_experimental_option("useAutomationExtension", False)
    return webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=opts)


# ══════════════════════════════════════════════════════════════════════════════
# DEBUG MODE — lưu HTML để tìm selector đúng
# ══════════════════════════════════════════════════════════════════════════════

def debug_mode(driver):
    """
    Chạy: python crawl_foody_danang.py --debug
    Lưu HTML của trang khu vực và trang chi tiết để bạn inspect selector.
    """
    area_url = "https://www.foody.vn/da-nang/khu-vuc-fpt-city"
    log.info(f"DEBUG: load {area_url}")
    driver.get(area_url)
    time.sleep(6)

    with open("debug_area.html", "w", encoding="utf-8") as f:
        f.write(driver.page_source)
    log.info("Saved: debug_area.html")

    # Tìm link chi tiết đầu tiên
    all_a = driver.find_elements(By.TAG_NAME, "a")
    detail = None
    for a in all_a:
        href = (a.get_attribute("href") or "").split("?")[0]
        if is_detail_link(href):
            detail = href
            break

    if detail:
        log.info(f"DEBUG: load detail {detail}")
        driver.get(detail)
        time.sleep(6)
        with open("debug_detail.html", "w", encoding="utf-8") as f:
            f.write(driver.page_source)
        log.info("Saved: debug_detail.html")
        log.info(f"Detail URL: {detail}")

    log.info("\nMở debug_area.html và debug_detail.html bằng trình duyệt")
    log.info("F12 → inspect để tìm đúng CSS selector cho name/address/phone/menu")
    log.info("Sau đó cập nhật NAME_SELS, ADDR_SELS, PHONE_SELS, GROUP_SELS trong script")


# ══════════════════════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════════════════════

def main():
    log.info("=== Foody Crawler — FPT City / Điện Bàn / Ngũ Hành Sơn ===")
    driver = build_driver()
    results: list[Restaurant] = []

    try:
        if "--debug" in sys.argv:
            debug_mode(driver)
            return

        if len(sys.argv) > 1:
            urls = sys.argv[1:]
        else:
            urls = get_restaurant_links(driver, TARGET_COUNT)

        if not urls:
            log.error("Không tìm được link nào!")
            log.error("Gợi ý: chạy với --debug để xem HTML thực tế và tìm đúng selector")
            return

        log.info(f"\nBắt đầu crawl {len(urls)} nhà hàng\n{'='*50}")

        for i, url in enumerate(urls, 1):
            log.info(f"[{i}/{len(urls)}]")
            r = crawl_restaurant(driver, url)
            if r:
                results.append(r)

            if results and len(results) % 10 == 0:
                save_json(results)
                generate_sql(results)
            time.sleep(1.5)

        if results:
            save_json(results)
            generate_sql(results)
            log.info(f"\n✅ Xong! {len(results)} nhà hàng → restaurants_danang.json + seed_crawled_data.sql")
        else:
            log.warning("Không lấy được dữ liệu. Chạy --debug để kiểm tra selector.")

    finally:
        driver.quit()

if __name__ == "__main__":
    main()