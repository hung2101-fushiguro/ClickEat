from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def generate_sql(merchant_data):
    # Mocking users, merchants, categories, and food items
    user_id = 1000  # Starting fake user id for merchants
    
    sql_statements = ["-- ===========================================",
                      "-- SEED DATA CRAWLED FROM SHOPEEFOOD",
                      "-- ===========================================",
                      "USE ClickEat;",
                      "GO\n",
                      "BEGIN TRY",
                      "    BEGIN TRAN;\n"]
                      
    for data in merchant_data:
        shop_name = data['name'].replace("'", "''")
        shop_address = data['address'].replace("'", "''")
        shop_img = data['image'].replace("'", "''")
        
        # 1. Insert User
        phone = f"0900{user_id}"
        email = f"merchant{user_id}@shopeefood.vn"
        sql_statements.append(f"    -- Merchant {shop_name}")
        sql_statements.append(f"    INSERT INTO dbo.Users(full_name, email, phone, password_hash, role, status)")
        sql_statements.append(f"    VALUES(N'{shop_name}', N'{email}', N'{phone}', N'hash_pwd', N'MERCHANT', N'ACTIVE');\n")
        sql_statements.append(f"    DECLARE @m{user_id} BIGINT = SCOPE_IDENTITY();\n")
        
        # 2. Insert MerchantProfile
        # We dummy province and district for now based on address loosely
        province = "N'79', N'TP.HCM'" if "HCM" in shop_address or "Hồ Chí Minh" in shop_address else ("N'48', N'Đà Nẵng'" if "Nẵng" in shop_address else "N'49', N'Quảng Nam'")
        sql_statements.append(f"    INSERT INTO dbo.MerchantProfiles(user_id, shop_name, shop_phone, shop_address_line, province_code, province_name, district_code, district_name, ward_code, ward_name, status, image_url)")
        sql_statements.append(f"    VALUES(@m{user_id}, N'{shop_name}', N'{phone}', N'{shop_address}', {province}, N'000', N'Quận', N'000', N'Phường', N'APPROVED', N'{shop_img}');\n")
        
        cat_id = 1
        for category in data['menu']:
            cat_name = category['category_name'].replace("'", "''")
            
            # 3. Insert Category
            sql_statements.append(f"    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)")
            sql_statements.append(f"    VALUES(@m{user_id}, N'{cat_name}', 1, {cat_id});")
            sql_statements.append(f"    DECLARE @cat_m{user_id}_{cat_id} BIGINT = SCOPE_IDENTITY();\n")
            
            # 4. Insert FoodItems
            for item in category['items']:
                item_name = item['name'].replace("'", "''")
                item_desc = item['desc'].replace("'", "''") if item['desc'] else ""
                item_price = item['price'].replace(".", "").replace("đ", "").replace(",", "")
                item_img = item['img'].replace("'", "''") if item['img'] else "NULL"
                img_val = f"N'{item_img}'" if item_img != "NULL" else "NULL"
                
                sql_statements.append(f"    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)")
                sql_statements.append(f"    VALUES(@m{user_id}, @cat_m{user_id}_{cat_id}, N'{item_name}', N'{item_desc}', {item_price}, {img_val}, 1, 0, 500);")
            
            sql_statements.append("")
            cat_id += 1
            
        user_id += 1
        
    sql_statements.append("    COMMIT TRAN;")
    sql_statements.append("    PRINT N'ShopeeFood Crawled Data Seeded successfully.';")
    sql_statements.append("END TRY")
    sql_statements.append("BEGIN CATCH")
    sql_statements.append("    IF @@TRANCOUNT > 0 ROLLBACK TRAN;")
    sql_statements.append("    PRINT N'ERROR: ' + ERROR_MESSAGE();")
    sql_statements.append("    THROW;")
    sql_statements.append("END CATCH;")
    sql_statements.append("GO\n")
    
    with open('seed_crawled_data.sql', 'w', encoding='utf-8') as f:
        f.write("\n".join(sql_statements))
    print("Generated seed_crawled_data.sql successfully!")

def crawl_shopeefood(driver, url):
    print(f"Fetching {url} ...")
    
    try:
        driver.get(url)
        # Wait for the restaurant name to be visible
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "h1.name-restaurant"))
        )
        
        # Scroll a bit to load lazy elements
        driver.execute_script("window.scrollTo(0, 1000);")
        time.sleep(2)
        driver.execute_script("window.scrollTo(0, 2000);")
        time.sleep(2)
        
        name = driver.find_element(By.CSS_SELECTOR, "h1.name-restaurant").text.strip()
        address = driver.find_element(By.CSS_SELECTOR, "div.address-restaurant").text.strip()
        
        try:
            image = driver.find_element(By.CSS_SELECTOR, "div.detail-restaurant-img img").get_attribute("src")
        except:
            image = ""
            
        print(f"Found Restaurant: {name}")
        print(f"Address: {address}")
        
        # Wait for menu items
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "div.item-restaurant-row"))
        )
        
        # Find scroll container and extract items
        scroll_container = driver.find_element(By.CSS_SELECTOR, "div.ReactVirtualized__Grid__innerScrollContainer")
        children = scroll_container.find_elements(By.XPATH, "./*")
        
        menu_categories = []
        current_category = None
        
        for child in children:
            cls = child.get_attribute("class")
            if "menu-group" in cls:
                cat_name = child.find_element(By.CSS_SELECTOR, "div.title-menu").text.strip()
                current_category = {"category_name": cat_name, "items": []}
                menu_categories.append(current_category)
                print(f"  Category: {cat_name}")
            elif "item-restaurant-row" in cls:
                if not current_category:
                    current_category = {"category_name": "Món Chính", "items": []}
                    menu_categories.append(current_category)
                    
                item_name = child.find_element(By.CSS_SELECTOR, "h2.item-restaurant-name").text.strip()
                
                try:
                    item_desc = child.find_element(By.CSS_SELECTOR, "div.item-restaurant-desc").text.strip()
                except:
                    item_desc = ""
                    
                try:
                    item_price = child.find_element(By.CSS_SELECTOR, "div.current-price").text.strip()
                except:
                    item_price = "0"
                    
                try:
                    item_img = child.find_element(By.CSS_SELECTOR, "div.item-restaurant-img img").get_attribute("src")
                except:
                    item_img = ""
                    
                current_category["items"].append({
                    "name": item_name,
                    "desc": item_desc,
                    "price": item_price,
                    "img": item_img
                })
                print(f"    + {item_name} ({item_price})")
                
        restaurant_data = {
            "name": name,
            "address": address,
            "image": image,
            "menu": menu_categories
        }
        
        return restaurant_data
        
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def get_restaurant_links(driver, base_url, target_count):
    print(f"Discovering {target_count} restaurant links from {base_url} ...")
    driver.get(base_url)
    
    is_foody = "foody.vn" in base_url
    
    if not is_foody:
        # Handle ShopeeFood Location Popup if it appears
        try:
            print("Checking for location popup (ShopeeFood)...")
            location_input = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "input[placeholder*='Nhập địa chỉ'], #address"))
            )
            print("Handling location popup...")
            location_input.send_keys("Đà Nẵng")
            time.sleep(2)
            first_sug = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, ".suggest-local .location-items .location-item, .list-local .location-item"))
            )
            first_sug.click()
            print("Location set to Đà Nẵng.")
            time.sleep(3)
        except:
            print("No ShopeeFood location popup found or could not handle it, continuing...")

    collected_urls = set()
    
    while len(collected_urls) < target_count:
        if is_foody:
            # On Foody, look for ShopeeFood delivery links directly
            elements = driver.find_elements(By.CSS_SELECTOR, "a[href^='https://shopeefood.vn/']")
        else:
            # On ShopeeFood, use restaurant list selectors
            elements = driver.find_elements(By.CSS_SELECTOR, ".home-tab .item-restaurant a.item-content")
            if not elements:
                elements = driver.find_elements(By.CSS_SELECTOR, "a.item-content")
            
        added_new = False
        for el in elements:
            try:
                href = el.get_attribute("href")
                if href and ("/da-nang/" in href or "/quang-nam/" in href) and href not in collected_urls:
                    # Clear some tracking params if any
                    clean_href = href.split("?")[0]
                    collected_urls.add(clean_href)
                    added_new = True
                    if len(collected_urls) >= target_count:
                        break
            except:
                continue
                
        print(f"Found {len(collected_urls)}/{target_count} links...")
        
        if len(collected_urls) >= target_count:
            break
            
        # Try to click "Xem thêm" button
        try:
            if is_foody:
                # Foody "Xem tiếp" button
                load_more_btn = driver.find_element(By.CSS_SELECTOR, "a.load-more-result, .fd-btn-more")
            else:
                # ShopeeFood "Xem thêm" button
                load_more_btn = driver.find_element(By.XPATH, "//button[contains(., 'Xem thêm')]")
                
            driver.execute_script("arguments[0].scrollIntoView();", load_more_btn)
            time.sleep(1)
            load_more_btn.click()
            print("Clicked 'Load More' to discover more...")
            time.sleep(4)
        except:
            # If no button, just scroll down
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(3)
            
        if not added_new and len(collected_urls) > 0:
            driver.execute_script("window.scrollBy(0, -500);")
            time.sleep(1)
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(3)
        
    return list(collected_urls)

def main():
    print("Setting up Chrome (Headless Disabled) ...")
    chrome_options = Options()
    # chrome_options.add_argument("--headless")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
        
    all_merchants = []
    
    try:
        urls = []
        if len(sys.argv) > 1:
            urls = sys.argv[1:]
        else:
            # Default to the area the user requested
            discovery_url = "https://www.foody.vn/da-nang/khu-vuc-quan-ngu-hanh-son"
            urls = get_restaurant_links(driver, discovery_url, 50)
            
        print(f"\n--- Starting to crawl {len(urls)} restaurants ---")
        for i, url in enumerate(urls, 1):
            print(f"\n[{i}/{len(urls)}] ", end="")
            data = crawl_shopeefood(driver, url)
            if data:
                all_merchants.append(data)
                
            # Optional: save intermediate progress
            if len(all_merchants) % 10 == 0:
                print(f"--> Checkpoint: Generated SQL for {len(all_merchants)} restaurants so far...")
                generate_sql(all_merchants)
                
        if all_merchants:
            generate_sql(all_merchants)
            
    finally:
        driver.quit()

if __name__ == "__main__":
    main()