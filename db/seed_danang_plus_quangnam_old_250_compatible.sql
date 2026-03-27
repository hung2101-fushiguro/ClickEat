/*
  Seed compatible with SQL files in /db:
  - ClickEat2.sql
  - ClickEat_MERGED_SUPERSET.sql
  - SQLQuery_ClickEat.sql
  - add_missing_schema_merchant_patch.sql

  Scope:
  - 150 merchants in Da Nang core districts
  - 100 merchants in old Quang Nam areas (now represented under Da Nang context)

  Compatibility strategy:
  - Insert required common columns for Users and MerchantProfiles.
  - Optional MerchantProfiles columns are inserted dynamically if they exist.
  - MerchantWallets insert runs only when table exists.
  - Idempotent by Users.phone pattern.
*/

USE ClickEat;
GO

SET NOCOUNT ON;
GO

BEGIN TRY
    BEGIN TRAN;

    DECLARE @DnTarget INT = 150;
    DECLARE @QnOldTarget INT = 100;

    IF OBJECT_ID('tempdb..#Regions') IS NOT NULL DROP TABLE #Regions;
    CREATE TABLE #Regions (
        region_type NVARCHAR(20) NOT NULL,
        region_seq INT NOT NULL,
        district_code NVARCHAR(20) NOT NULL,
        district_name NVARCHAR(100) NOT NULL,
        district_short NVARCHAR(100) NOT NULL,
        PRIMARY KEY (region_type, region_seq)
    );

    INSERT INTO #Regions(region_type, region_seq, district_code, district_name, district_short)
    VALUES
    (N'DN', 1, N'490', N'Hải Châu', N'Hải Châu'),
    (N'DN', 2, N'491', N'Thanh Khê', N'Thanh Khê'),
    (N'DN', 3, N'492', N'Sơn Trà', N'Sơn Trà'),
    (N'DN', 4, N'493', N'Ngũ Hành Sơn', N'Ngũ Hành Sơn'),
    (N'DN', 5, N'494', N'Liên Chiểu', N'Liên Chiểu'),
    (N'DN', 6, N'495', N'Cẩm Lệ', N'Cẩm Lệ'),
    (N'DN', 7, N'497', N'Hòa Vang', N'Hòa Vang'),

    (N'QN_OLD', 1, N'QN01', N'Tam Kỳ (Quảng Nam cũ)', N'Tam Kỳ'),
    (N'QN_OLD', 2, N'QN02', N'Hội An (Quảng Nam cũ)', N'Hội An'),
    (N'QN_OLD', 3, N'QN03', N'Điện Bàn (Quảng Nam cũ)', N'Điện Bàn'),
    (N'QN_OLD', 4, N'QN04', N'Duy Xuyên (Quảng Nam cũ)', N'Duy Xuyên'),
    (N'QN_OLD', 5, N'QN05', N'Đại Lộc (Quảng Nam cũ)', N'Đại Lộc'),
    (N'QN_OLD', 6, N'QN06', N'Thăng Bình (Quảng Nam cũ)', N'Thăng Bình'),
    (N'QN_OLD', 7, N'QN07', N'Quế Sơn (Quảng Nam cũ)', N'Quế Sơn'),
    (N'QN_OLD', 8, N'QN08', N'Núi Thành (Quảng Nam cũ)', N'Núi Thành'),
    (N'QN_OLD', 9, N'QN09', N'Phú Ninh (Quảng Nam cũ)', N'Phú Ninh'),
    (N'QN_OLD',10, N'QN10', N'Tiên Phước (Quảng Nam cũ)', N'Tiên Phước');

    IF OBJECT_ID('tempdb..#Wards') IS NOT NULL DROP TABLE #Wards;
    CREATE TABLE #Wards (
        region_type NVARCHAR(20) NOT NULL,
        district_code NVARCHAR(20) NOT NULL,
        ward_code NVARCHAR(20) NOT NULL,
        ward_name NVARCHAR(100) NOT NULL
    );

    INSERT INTO #Wards(region_type, district_code, ward_code, ward_name)
    VALUES
    (N'DN', N'490', N'20194', N'Phước Ninh'),
    (N'DN', N'490', N'20195', N'Nam Dương'),
    (N'DN', N'490', N'20196', N'Bình Hiên'),
    (N'DN', N'490', N'20197', N'Hòa Thuận Tây'),

    (N'DN', N'491', N'20230', N'Thanh Khê Đông'),
    (N'DN', N'491', N'20231', N'Thanh Khê Tây'),
    (N'DN', N'491', N'20232', N'An Khê'),
    (N'DN', N'491', N'20233', N'Chính Gián'),

    (N'DN', N'492', N'20260', N'An Hải Bắc'),
    (N'DN', N'492', N'20261', N'An Hải Tây'),
    (N'DN', N'492', N'20262', N'Mân Thái'),
    (N'DN', N'492', N'20263', N'Phước Mỹ'),

    (N'DN', N'493', N'20290', N'Mỹ An'),
    (N'DN', N'493', N'20291', N'Khuê Mỹ'),
    (N'DN', N'493', N'20292', N'Hòa Hải'),
    (N'DN', N'493', N'20293', N'Hòa Quý'),

    (N'DN', N'494', N'20320', N'Hòa Minh'),
    (N'DN', N'494', N'20321', N'Hòa Khánh Bắc'),
    (N'DN', N'494', N'20322', N'Hòa Khánh Nam'),
    (N'DN', N'494', N'20323', N'Hòa Hiệp Nam'),

    (N'DN', N'495', N'20350', N'Hòa An'),
    (N'DN', N'495', N'20351', N'Hòa Phát'),
    (N'DN', N'495', N'20352', N'Hòa Thọ Tây'),
    (N'DN', N'495', N'20353', N'Hòa Xuân'),

    (N'DN', N'497', N'20380', N'Hòa Châu'),
    (N'DN', N'497', N'20381', N'Hòa Tiến'),
    (N'DN', N'497', N'20382', N'Hòa Phong'),
    (N'DN', N'497', N'20383', N'Hòa Sơn'),

    (N'QN_OLD', N'QN01', N'QN0101', N'Phường An Mỹ'),
    (N'QN_OLD', N'QN01', N'QN0102', N'Phường Hòa Hương'),
    (N'QN_OLD', N'QN01', N'QN0103', N'Phường Tân Thạnh'),

    (N'QN_OLD', N'QN02', N'QN0201', N'Phường Minh An'),
    (N'QN_OLD', N'QN02', N'QN0202', N'Phường Cẩm Phô'),
    (N'QN_OLD', N'QN02', N'QN0203', N'Phường Cẩm Châu'),

    (N'QN_OLD', N'QN03', N'QN0301', N'Phường Vĩnh Điện'),
    (N'QN_OLD', N'QN03', N'QN0302', N'Phường Điện An'),
    (N'QN_OLD', N'QN03', N'QN0303', N'Phường Điện Nam Bắc'),

    (N'QN_OLD', N'QN04', N'QN0401', N'Thị trấn Nam Phước'),
    (N'QN_OLD', N'QN04', N'QN0402', N'Xã Duy Trung'),
    (N'QN_OLD', N'QN04', N'QN0403', N'Xã Duy Phước'),

    (N'QN_OLD', N'QN05', N'QN0501', N'Thị trấn Ái Nghĩa'),
    (N'QN_OLD', N'QN05', N'QN0502', N'Xã Đại Hồng'),
    (N'QN_OLD', N'QN05', N'QN0503', N'Xã Đại Minh'),

    (N'QN_OLD', N'QN06', N'QN0601', N'Thị trấn Hà Lam'),
    (N'QN_OLD', N'QN06', N'QN0602', N'Xã Bình Minh'),
    (N'QN_OLD', N'QN06', N'QN0603', N'Xã Bình Phục'),

    (N'QN_OLD', N'QN07', N'QN0701', N'Thị trấn Đông Phú'),
    (N'QN_OLD', N'QN07', N'QN0702', N'Xã Quế Xuân 1'),
    (N'QN_OLD', N'QN07', N'QN0703', N'Xã Quế Phú'),

    (N'QN_OLD', N'QN08', N'QN0801', N'Thị trấn Núi Thành'),
    (N'QN_OLD', N'QN08', N'QN0802', N'Xã Tam Hiệp'),
    (N'QN_OLD', N'QN08', N'QN0803', N'Xã Tam Quang'),

    (N'QN_OLD', N'QN09', N'QN0901', N'Thị trấn Phú Thịnh'),
    (N'QN_OLD', N'QN09', N'QN0902', N'Xã Tam Dân'),
    (N'QN_OLD', N'QN09', N'QN0903', N'Xã Tam Vinh'),

    (N'QN_OLD', N'QN10', N'QN1001', N'Thị trấn Tiên Kỳ'),
    (N'QN_OLD', N'QN10', N'QN1002', N'Xã Tiên Cảnh'),
    (N'QN_OLD', N'QN10', N'QN1003', N'Xã Tiên Châu');

    IF OBJECT_ID('tempdb..#Streets') IS NOT NULL DROP TABLE #Streets;
    CREATE TABLE #Streets (
        region_type NVARCHAR(20) NOT NULL,
        district_code NVARCHAR(20) NOT NULL,
        street_name NVARCHAR(150) NOT NULL,
        base_lat DECIMAL(10,7) NOT NULL,
        base_lng DECIMAL(10,7) NOT NULL
    );

    INSERT INTO #Streets(region_type, district_code, street_name, base_lat, base_lng)
    VALUES
    (N'DN', N'490', N'Nguyễn Văn Linh', 16.0545000, 108.2022000),
    (N'DN', N'490', N'Lê Duẩn', 16.0678000, 108.2153000),
    (N'DN', N'490', N'Trưng Nữ Vương', 16.0504000, 108.2142000),

    (N'DN', N'491', N'Điện Biên Phủ', 16.0672000, 108.1916000),
    (N'DN', N'491', N'Hàm Nghi', 16.0607000, 108.1994000),
    (N'DN', N'491', N'Trần Cao Vân', 16.0732000, 108.2068000),

    (N'DN', N'492', N'Võ Nguyên Giáp', 16.0714000, 108.2453000),
    (N'DN', N'492', N'Ngô Quyền', 16.0711000, 108.2269000),
    (N'DN', N'492', N'Phạm Văn Đồng', 16.0746000, 108.2317000),

    (N'DN', N'493', N'Ngũ Hành Sơn', 16.0299000, 108.2461000),
    (N'DN', N'493', N'Lê Văn Hiến', 16.0243000, 108.2433000),
    (N'DN', N'493', N'An Thượng 29', 16.0518000, 108.2449000),

    (N'DN', N'494', N'Tôn Đức Thắng', 16.0979000, 108.1712000),
    (N'DN', N'494', N'Nguyễn Lương Bằng', 16.1117000, 108.1506000),
    (N'DN', N'494', N'Kinh Dương Vương', 16.1009000, 108.1643000),

    (N'DN', N'495', N'Cách Mạng Tháng Tám', 16.0325000, 108.2077000),
    (N'DN', N'495', N'Phạm Hùng', 16.0357000, 108.1937000),
    (N'DN', N'495', N'Nguyễn Hữu Thọ', 16.0342000, 108.2159000),

    (N'DN', N'497', N'Quốc lộ 14B', 15.9996000, 108.1215000),
    (N'DN', N'497', N'ĐT 602', 16.0642000, 108.0743000),
    (N'DN', N'497', N'ĐT 605', 16.0144000, 108.1188000),

    (N'QN_OLD', N'QN01', N'Hùng Vương', 15.5745000, 108.4726000),
    (N'QN_OLD', N'QN01', N'Phan Châu Trinh', 15.5719000, 108.4791000),

    (N'QN_OLD', N'QN02', N'Trần Phú', 15.8794000, 108.3381000),
    (N'QN_OLD', N'QN02', N'Nguyễn Thị Minh Khai', 15.8780000, 108.3346000),

    (N'QN_OLD', N'QN03', N'Trần Nhân Tông', 15.8892000, 108.2650000),
    (N'QN_OLD', N'QN03', N'Phạm Như Xương', 15.9015000, 108.2506000),

    (N'QN_OLD', N'QN04', N'Quốc lộ 1A', 15.7904000, 108.2455000),
    (N'QN_OLD', N'QN04', N'DT 610', 15.7813000, 108.2261000),

    (N'QN_OLD', N'QN05', N'Ái Nghĩa - Đại Hiệp', 15.8371000, 107.9870000),
    (N'QN_OLD', N'QN05', N'Quốc lộ 14B', 15.8414000, 108.0114000),

    (N'QN_OLD', N'QN06', N'Quốc lộ 1A', 15.7103000, 108.3302000),
    (N'QN_OLD', N'QN06', N'Đường Bình Đào', 15.7021000, 108.3159000),

    (N'QN_OLD', N'QN07', N'Hùng Vương', 15.6210000, 108.2708000),
    (N'QN_OLD', N'QN07', N'Quế Xuân', 15.6141000, 108.2611000),

    (N'QN_OLD', N'QN08', N'Quốc lộ 1A', 15.4247000, 108.6151000),
    (N'QN_OLD', N'QN08', N'Cảng Kỳ Hà', 15.5067000, 108.7066000),

    (N'QN_OLD', N'QN09', N'Trần Hưng Đạo', 15.5391000, 108.3579000),
    (N'QN_OLD', N'QN09', N'ĐT 616', 15.5299000, 108.3401000),

    (N'QN_OLD', N'QN10', N'Quốc lộ 40B', 15.4707000, 108.2679000),
    (N'QN_OLD', N'QN10', N'Tiên Kỳ - Tiên Cảnh', 15.4828000, 108.2577000);

    IF OBJECT_ID('tempdb..#Seed') IS NOT NULL DROP TABLE #Seed;
    CREATE TABLE #Seed (
        seed_no INT NOT NULL PRIMARY KEY,
        region_type NVARCHAR(20) NOT NULL,
        full_name NVARCHAR(100) NOT NULL,
        email NVARCHAR(150) NOT NULL,
        phone NVARCHAR(20) NOT NULL,
        password_hash NVARCHAR(255) NOT NULL,
        shop_name NVARCHAR(120) NOT NULL,
        shop_phone NVARCHAR(20) NOT NULL,
        shop_address_line NVARCHAR(255) NOT NULL,
        province_code NVARCHAR(20) NOT NULL,
        province_name NVARCHAR(100) NOT NULL,
        district_code NVARCHAR(20) NOT NULL,
        district_name NVARCHAR(100) NOT NULL,
        ward_code NVARCHAR(20) NOT NULL,
        ward_name NVARCHAR(100) NOT NULL,
        latitude DECIMAL(10,7) NULL,
        longitude DECIMAL(10,7) NULL,
        source_platform NVARCHAR(20) NULL,
        image_url NVARCHAR(500) NULL,
        business_hours NVARCHAR(MAX) NULL,
        shop_description NVARCHAR(MAX) NULL,
        status NVARCHAR(20) NOT NULL
    );

    ;WITH DNNumbers AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM DNNumbers WHERE n < @DnTarget
    )
    INSERT INTO #Seed (
        seed_no, region_type, full_name, email, phone, password_hash,
        shop_name, shop_phone, shop_address_line,
        province_code, province_name, district_code, district_name,
        ward_code, ward_name, latitude, longitude,
        source_platform, image_url, business_hours, shop_description, status
    )
    SELECT
        n.n,
        N'DN',
        CONCAT(N'Merchant Đà Nẵng ', FORMAT(n.n, '000')),
        CONCAT(N'merchant.dn.', FORMAT(n.n, '000'), N'@clickeat.vn'),
        CONCAT(N'0947', RIGHT('000000' + CAST(300000 + n.n AS VARCHAR(6)), 6)),
        CONCAT(N'hash_dn_', FORMAT(n.n, '000')),
        CONCAT(
            CASE ((n.n - 1) % 20)
                WHEN 0 THEN N'Mì Quảng Bà Mua'
                WHEN 1 THEN N'Bún Chả Cá Bà Lữ'
                WHEN 2 THEN N'Bánh Xèo Bà Dưỡng'
                WHEN 3 THEN N'Bánh Tráng Cuốn Thịt Heo Trần'
                WHEN 4 THEN N'Cơm Gà A Hải'
                WHEN 5 THEN N'Bánh Mì Bà Lan'
                WHEN 6 THEN N'Bún Mắm Vân'
                WHEN 7 THEN N'Hải Sản Bé Mặn'
                WHEN 8 THEN N'Cơm Niêu Nhà Đỏ'
                WHEN 9 THEN N'Bánh Canh Ruộng'
                WHEN 10 THEN N'Bún Bò Bà Thương'
                WHEN 11 THEN N'Bếp Cuốn Đà Nẵng'
                WHEN 12 THEN N'Bánh Bèo Bà Bé'
                WHEN 13 THEN N'Gỏi Cá Nam Ô'
                WHEN 14 THEN N'Bánh Tráng Kẹp Dì Hoa'
                WHEN 15 THEN N'Chè Sầu Liên'
                WHEN 16 THEN N'Ốc Điện Phương'
                WHEN 17 THEN N'Xương Má Hàm'
                WHEN 18 THEN N'Làng Nướng'
                ELSE N'Phở Bắc Hải'
            END,
            N' ',
            CASE (((n.n - 1) / 20) % 10)
                WHEN 0 THEN N'An Phú'
                WHEN 1 THEN N'Thanh Tâm'
                WHEN 2 THEN N'Quê Nhà'
                WHEN 3 THEN N'Góc Biển'
                WHEN 4 THEN N'Bếp Xưa'
                WHEN 5 THEN N'Phố Chợ'
                WHEN 6 THEN N'Rạng Đông'
                WHEN 7 THEN N'Sông Hàn'
                WHEN 8 THEN N'Mỹ Khê'
                ELSE N'Hoài Phố'
            END,
            N' ', r.district_short
        ),
        CONCAT(N'0236', RIGHT('000000' + CAST(200000 + n.n AS VARCHAR(6)), 6)),
        CONCAT(CAST(10 + ((n.n * 9) % 170) AS NVARCHAR(10)), N' ', st.street_name, N', ', w.ward_name, N', ', r.district_name, N', Đà Nẵng'),
        N'48',
        N'Đà Nẵng',
        r.district_code,
        r.district_name,
        w.ward_code,
        w.ward_name,
        CAST(st.base_lat + (((n.n % 5) - 2) * 0.0006) AS DECIMAL(10,7)),
        CAST(st.base_lng + ((((n.n + 1) % 5) - 2) * 0.0006) AS DECIMAL(10,7)),
        N'NONE',
        N'/assets/images/default-store-cover.jpg',
        N'06:30-22:30',
        N'Quán tại Đà Nẵng, dữ liệu seed phục vụ demo.',
        N'APPROVED'
    FROM DNNumbers n
    JOIN #Regions r
      ON r.region_type = N'DN' AND r.region_seq = ((n.n - 1) % 7) + 1
    CROSS APPLY (
        SELECT TOP 1 t.ward_code, t.ward_name
        FROM (
            SELECT
                w.ward_code,
                w.ward_name,
                ROW_NUMBER() OVER (ORDER BY w.ward_code) AS rn,
                COUNT(*) OVER () AS cnt
            FROM #Wards w
            WHERE w.region_type = N'DN' AND w.district_code = r.district_code
        ) t
        WHERE t.rn = ((n.n - 1) % t.cnt) + 1
    ) w
    CROSS APPLY (
        SELECT TOP 1 t.street_name, t.base_lat, t.base_lng
        FROM (
            SELECT
                st.street_name,
                st.base_lat,
                st.base_lng,
                ROW_NUMBER() OVER (ORDER BY st.street_name) AS rn,
                COUNT(*) OVER () AS cnt
            FROM #Streets st
            WHERE st.region_type = N'DN' AND st.district_code = r.district_code
        ) t
        WHERE t.rn = (((n.n - 1) / 2) % t.cnt) + 1
    ) st
    OPTION (MAXRECURSION 300);

    ;WITH QNNumbers AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM QNNumbers WHERE n < @QnOldTarget
    )
    INSERT INTO #Seed (
        seed_no, region_type, full_name, email, phone, password_hash,
        shop_name, shop_phone, shop_address_line,
        province_code, province_name, district_code, district_name,
        ward_code, ward_name, latitude, longitude,
        source_platform, image_url, business_hours, shop_description, status
    )
    SELECT
        @DnTarget + n.n,
        N'QN_OLD',
        CONCAT(N'Merchant Quảng Nam cũ ', FORMAT(n.n, '000')),
        CONCAT(N'merchant.qnold.', FORMAT(n.n, '000'), N'@clickeat.vn'),
        CONCAT(N'0948', RIGHT('000000' + CAST(500000 + n.n AS VARCHAR(6)), 6)),
        CONCAT(N'hash_qnold_', FORMAT(n.n, '000')),
        CONCAT(
            CASE ((n.n - 1) % 12)
                WHEN 0 THEN N'Cao Lầu Liên'
                WHEN 1 THEN N'Bánh Mì Phượng'
                WHEN 2 THEN N'Morning Glory Hội An'
                WHEN 3 THEN N'Cơm Gà Bà Buội'
                WHEN 4 THEN N'Mì Quảng Ông Hai'
                WHEN 5 THEN N'Bê Thui Cầu Mống'
                WHEN 6 THEN N'Bánh Đập Cẩm Nam'
                WHEN 7 THEN N'Hến Xào Cẩm Nam'
                WHEN 8 THEN N'Bún Mắm Nêm Hội An'
                WHEN 9 THEN N'Bánh Xèo Giếng Bá Lễ'
                WHEN 10 THEN N'Phở Liến'
                ELSE N'Hoian Roastery'
            END,
            N' ',
            CASE (((n.n - 1) / 12) % 10)
                WHEN 0 THEN N'Phố Hội'
                WHEN 1 THEN N'Cẩm Nam'
                WHEN 2 THEN N'Thanh Hà'
                WHEN 3 THEN N'An Bàng'
                WHEN 4 THEN N'Nam Phước'
                WHEN 5 THEN N'Điện Bàn'
                WHEN 6 THEN N'Tam Kỳ'
                WHEN 7 THEN N'Phú Ninh'
                WHEN 8 THEN N'Thăng Bình'
                ELSE N'Núi Thành'
            END,
            N' ', r.district_short
        ),
        CONCAT(N'0235', RIGHT('000000' + CAST(300000 + n.n AS VARCHAR(6)), 6)),
        CONCAT(CAST(5 + ((n.n * 11) % 145) AS NVARCHAR(10)), N' ', st.street_name, N', ', w.ward_name, N', ', r.district_name, N', Đà Nẵng'),
        N'48',
        N'Đà Nẵng',
        r.district_code,
        r.district_name,
        w.ward_code,
        w.ward_name,
        CAST(st.base_lat + (((n.n % 5) - 2) * 0.0011) AS DECIMAL(10,7)),
        CAST(st.base_lng + ((((n.n + 3) % 5) - 2) * 0.0011) AS DECIMAL(10,7)),
        N'NONE',
        N'/assets/images/default-store-cover.jpg',
        N'06:00-22:00',
        N'Quán khu Quảng Nam cũ, hiện quy hoạch theo vùng Đà Nẵng mở rộng.',
        N'APPROVED'
    FROM QNNumbers n
    JOIN #Regions r
      ON r.region_type = N'QN_OLD' AND r.region_seq = ((n.n - 1) % 10) + 1
    CROSS APPLY (
        SELECT TOP 1 t.ward_code, t.ward_name
        FROM (
            SELECT
                w.ward_code,
                w.ward_name,
                ROW_NUMBER() OVER (ORDER BY w.ward_code) AS rn,
                COUNT(*) OVER () AS cnt
            FROM #Wards w
            WHERE w.region_type = N'QN_OLD' AND w.district_code = r.district_code
        ) t
        WHERE t.rn = ((n.n - 1) % t.cnt) + 1
    ) w
    CROSS APPLY (
        SELECT TOP 1 t.street_name, t.base_lat, t.base_lng
        FROM (
            SELECT
                st.street_name,
                st.base_lat,
                st.base_lng,
                ROW_NUMBER() OVER (ORDER BY st.street_name) AS rn,
                COUNT(*) OVER () AS cnt
            FROM #Streets st
            WHERE st.region_type = N'QN_OLD' AND st.district_code = r.district_code
        ) t
        WHERE t.rn = (((n.n - 1) / 2) % t.cnt) + 1
    ) st
    OPTION (MAXRECURSION 300);

    INSERT INTO dbo.Users(full_name, email, phone, password_hash, role, status)
    SELECT
        s.full_name,
        s.email,
        s.phone,
        s.password_hash,
        N'MERCHANT',
        N'ACTIVE'
    FROM #Seed s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Users u WHERE u.phone = s.phone
    );

    DECLARE @mpCols NVARCHAR(MAX) = N'user_id, shop_name, shop_phone, shop_address_line, province_code, province_name, district_code, district_name, ward_code, ward_name, latitude, longitude, status';
    DECLARE @mpSelect NVARCHAR(MAX) = N'u.id, s.shop_name, s.shop_phone, s.shop_address_line, s.province_code, s.province_name, s.district_code, s.district_name, s.ward_code, s.ward_name, s.latitude, s.longitude, s.status';

    IF COL_LENGTH('dbo.MerchantProfiles', 'source_platform') IS NOT NULL
    BEGIN
        SET @mpCols = @mpCols + N', source_platform';
        SET @mpSelect = @mpSelect + N', s.source_platform';
    END;

    IF COL_LENGTH('dbo.MerchantProfiles', 'image_url') IS NOT NULL
    BEGIN
        SET @mpCols = @mpCols + N', image_url';
        SET @mpSelect = @mpSelect + N', s.image_url';
    END;

    IF COL_LENGTH('dbo.MerchantProfiles', 'business_hours') IS NOT NULL
    BEGIN
        SET @mpCols = @mpCols + N', business_hours';
        SET @mpSelect = @mpSelect + N', s.business_hours';
    END;

    IF COL_LENGTH('dbo.MerchantProfiles', 'shop_description') IS NOT NULL
    BEGIN
        SET @mpCols = @mpCols + N', shop_description';
        SET @mpSelect = @mpSelect + N', s.shop_description';
    END;

    DECLARE @sql NVARCHAR(MAX) = N'
        INSERT INTO dbo.MerchantProfiles (' + @mpCols + N')
        SELECT ' + @mpSelect + N'
        FROM #Seed s
        JOIN dbo.Users u ON u.phone = s.phone
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.MerchantProfiles mp
            WHERE mp.user_id = u.id
        );';

    EXEC sp_executesql @sql;

    IF OBJECT_ID('dbo.MerchantWallets', 'U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.MerchantWallets(merchant_user_id, balance)
        SELECT
            mp.user_id,
            0
        FROM dbo.MerchantProfiles mp
        JOIN dbo.Users u ON u.id = mp.user_id
        JOIN #Seed s ON s.phone = u.phone
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.MerchantWallets mw
            WHERE mw.merchant_user_id = mp.user_id
        );
    END;

    IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL
    BEGIN
        IF OBJECT_ID('tempdb..#SeedMerchants') IS NOT NULL DROP TABLE #SeedMerchants;
        SELECT
            u.id AS merchant_user_id,
            s.region_type,
            s.shop_name
        INTO #SeedMerchants
        FROM #Seed s
        JOIN dbo.Users u ON u.phone = s.phone;

        IF OBJECT_ID('tempdb..#CategoryTemplates') IS NOT NULL DROP TABLE #CategoryTemplates;
        CREATE TABLE #CategoryTemplates (
            category_name NVARCHAR(100) NOT NULL,
            sort_order INT NOT NULL
        );

        INSERT INTO #CategoryTemplates(category_name, sort_order)
        VALUES
        (N'Đặc sản miền Trung', 1),
        (N'Món nước', 2),
        (N'Món cơm', 3),
        (N'Hải sản', 4),
        (N'Ăn vặt', 5),
        (N'Đồ uống', 6),
        (N'Combo gia đình', 7);

        INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
        SELECT
            sm.merchant_user_id,
            ct.category_name,
            1,
            ct.sort_order
        FROM #SeedMerchants sm
        CROSS JOIN #CategoryTemplates ct
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.Categories c
            WHERE c.merchant_user_id = sm.merchant_user_id
              AND c.name = ct.category_name
        );

        IF OBJECT_ID('dbo.FoodItems', 'U') IS NOT NULL
        BEGIN
            IF OBJECT_ID('tempdb..#FoodTemplates') IS NOT NULL DROP TABLE #FoodTemplates;
            CREATE TABLE #FoodTemplates (
                food_name NVARCHAR(150) NOT NULL,
                category_name NVARCHAR(100) NOT NULL,
                base_price DECIMAL(18,2) NOT NULL,
                description NVARCHAR(500) NULL,
                is_fried BIT NOT NULL,
                calories INT NULL
            );

            INSERT INTO #FoodTemplates(food_name, category_name, base_price, description, is_fried, calories)
            VALUES
            (N'Mì Quảng gà ta', N'Đặc sản miền Trung', 49000, N'Mì Quảng sợi tươi, gà ta, rau sống Trà Quế.', 0, 560),
            (N'Cao lầu xá xíu Hội An', N'Đặc sản miền Trung', 54000, N'Cao lầu truyền thống, tóp mỡ giòn.', 0, 590),
            (N'Bê thui Cầu Mống cuốn bánh tráng', N'Đặc sản miền Trung', 89000, N'Bê thui mềm, mắm nêm đậm vị.', 0, 640),
            (N'Bún mắm nêm heo quay', N'Đặc sản miền Trung', 45000, N'Bún tươi, heo quay giòn bì.', 0, 520),
            (N'Bánh xèo tôm nhảy', N'Đặc sản miền Trung', 65000, N'Bánh xèo giòn, ăn kèm rau rừng.', 1, 670),

            (N'Bún chả cá Đà Nẵng', N'Món nước', 47000, N'Nước dùng thanh ngọt từ cá biển.', 0, 500),
            (N'Phở bò tái nạm', N'Món nước', 55000, N'Phở bò nước trong, bánh phở mềm.', 0, 610),
            (N'Bánh canh cá lóc', N'Món nước', 43000, N'Sợi bánh canh dai, cá lóc đồng.', 0, 530),
            (N'Hủ tiếu hải sản', N'Món nước', 62000, N'Hải sản tươi, nước dùng xương.', 0, 560),

            (N'Cơm gà Hội An xé', N'Món cơm', 52000, N'Cơm nghệ, gà xé, gỏi đu đủ.', 0, 650),
            (N'Cơm niêu cá bống kho tộ', N'Món cơm', 69000, N'Cơm niêu nóng, cá kho đậm đà.', 0, 710),
            (N'Cơm tấm sườn nướng', N'Món cơm', 58000, N'Sườn nướng than, mỡ hành thơm.', 0, 730),
            (N'Cơm chiên hải sản', N'Món cơm', 64000, N'Cơm chiên tơi, tôm mực tươi.', 1, 780),

            (N'Mực một nắng nướng sa tế', N'Hải sản', 129000, N'Mực một nắng nướng than, sốt sa tế.', 0, 580),
            (N'Tôm sú hấp sả', N'Hải sản', 149000, N'Tôm sú tươi hấp sả gừng.', 0, 540),
            (N'Gỏi cá trích Nam Ô', N'Hải sản', 99000, N'Đặc sản gỏi cá, rau rừng, bánh tráng.', 0, 460),
            (N'Nghêu hấp Thái', N'Hải sản', 89000, N'Nghêu tươi hấp chua cay kiểu Thái.', 0, 420),

            (N'Bánh tráng cuốn thịt heo', N'Ăn vặt', 59000, N'Thịt hai đầu da, rau sống, mắm nêm.', 0, 600),
            (N'Nem lụi nướng sả', N'Ăn vặt', 48000, N'Nem lụi thơm, cuốn bánh tráng.', 0, 520),
            (N'Ram cuốn cải', N'Ăn vặt', 45000, N'Ram giòn, cuốn cải xanh.', 1, 490),
            (N'Bánh đập hến xào', N'Ăn vặt', 39000, N'Bánh đập giòn ăn cùng hến xào cay.', 0, 430),
            (N'Ốc hút xào sả ớt', N'Ăn vặt', 69000, N'Món đặc trưng quán ốc Đà Nẵng, đậm vị cay thơm.', 0, 520),
            (N'Xương má hàm nướng muối ớt', N'Ăn vặt', 119000, N'Món nướng nổi tiếng, ăn kèm rau sống.', 1, 760),
            (N'Ba chỉ nướng tảng sốt Hàn', N'Ăn vặt', 129000, N'Phong cách làng nướng, thịt mềm mọng.', 1, 810),

            (N'Trà tắc xí muội', N'Đồ uống', 25000, N'Trà tắc mát lạnh, xí muội chua ngọt.', 0, 160),
            (N'Nước mát lá vối', N'Đồ uống', 22000, N'Nước lá vối thanh nhiệt.', 0, 90),
            (N'Cà phê muối', N'Đồ uống', 32000, N'Đặc sản cà phê muối miền Trung.', 0, 180),
            (N'Trà sen vàng', N'Đồ uống', 34000, N'Trà sen thơm, topping hạt sen.', 0, 210),

            (N'Combo gia đình miền Trung 3 người', N'Combo gia đình', 229000, N'2 món chính + 1 hải sản + 3 nước.', 0, 1800),
            (N'Combo đặc sản Đà Nẵng 2 người', N'Combo gia đình', 179000, N'Bún chả cá + bánh xèo + 2 nước.', 0, 1450),
            (N'Combo Hội An phố cổ', N'Combo gia đình', 199000, N'Cao lầu + cơm gà + ăn vặt + nước.', 0, 1600);

            INSERT INTO dbo.FoodItems(
                merchant_user_id,
                category_id,
                name,
                description,
                price,
                image_url,
                is_available,
                is_fried,
                calories
            )
            SELECT
                sm.merchant_user_id,
                c.id,
                CONCAT(ft.food_name, N' - ', LEFT(sm.shop_name, 42)),
                CONCAT(ft.description, N' Món nổi bật của quán ', LEFT(sm.shop_name, 42), N'.'),
                CASE
                    WHEN sm.region_type = N'QN_OLD' THEN ft.base_price - 3000
                    ELSE ft.base_price
                END,
                N'/assets/images/default-food-cover.jpg',
                1,
                ft.is_fried,
                ft.calories
            FROM #SeedMerchants sm
            JOIN #FoodTemplates ft ON 1 = 1
            JOIN dbo.Categories c
                ON c.merchant_user_id = sm.merchant_user_id
               AND c.name = ft.category_name
            WHERE NOT EXISTS (
                SELECT 1
                FROM dbo.FoodItems fi
                WHERE fi.merchant_user_id = sm.merchant_user_id
                AND fi.name = CONCAT(ft.food_name, N' - ', LEFT(sm.shop_name, 42))
            );
        END;

        IF OBJECT_ID('dbo.Vouchers', 'U') IS NOT NULL
        BEGIN
            IF OBJECT_ID('tempdb..#VoucherTemplates') IS NOT NULL DROP TABLE #VoucherTemplates;
            CREATE TABLE #VoucherTemplates (
                template_code NVARCHAR(20) NOT NULL,
                title NVARCHAR(200) NOT NULL,
                description NVARCHAR(1000) NOT NULL,
                discount_type NVARCHAR(10) NOT NULL,
                discount_value DECIMAL(18,2) NOT NULL,
                max_discount_amount DECIMAL(18,2) NULL,
                min_order_amount DECIMAL(18,2) NULL,
                max_uses_total INT NULL,
                max_uses_per_user INT NULL,
                starts_in_days INT NOT NULL,
                duration_days INT NOT NULL,
                is_published BIT NOT NULL
            );

            INSERT INTO #VoucherTemplates(
                template_code, title, description, discount_type, discount_value,
                max_discount_amount, min_order_amount, max_uses_total, max_uses_per_user,
                starts_in_days, duration_days, is_published
            )
            VALUES
            (N'WELCOME15', N'Ưu đãi khách mới 15%', N'Giảm 15% cho đơn đầu tiên tại quán.', N'PERCENT', 15, 45000, 90000, 500, 1, -1, 45, 1),
            (N'LUNCH20K', N'Ăn trưa tiết kiệm 20K', N'Giảm trực tiếp 20.000đ cho đơn trưa.', N'FIXED', 20000, NULL, 120000, 800, 2, -1, 30, 1),
            (N'FREESHIP15', N'Freeship tối đa 15K', N'Hỗ trợ phí ship tối đa 15.000đ.', N'FIXED', 15000, NULL, 70000, 1000, 3, -1, 35, 1),
            (N'NIGHT12', N'Ăn đêm giảm 12%', N'Giảm 12% cho khung giờ tối và khuya.', N'PERCENT', 12, 35000, 110000, 700, 2, -1, 40, 1),
            (N'COMBO25', N'Combo tiết kiệm 25K', N'Áp dụng cho đơn có combo hoặc nhóm món.', N'FIXED', 25000, NULL, 160000, 600, 2, -1, 35, 1),
            (N'DRINK10', N'Nước uống giảm 10%', N'Giảm 10% cho đơn có thức uống.', N'PERCENT', 10, 20000, 60000, 1200, 3, -1, 50, 1),
            (N'WEEKEND18', N'Cuối tuần bùng vị 18%', N'Ưu đãi cuối tuần cho đơn từ 150.000đ.', N'PERCENT', 18, 50000, 150000, 450, 1, 0, 60, 1),
            (N'FLASH30K', N'Flash sale giảm 30K', N'Voucher flash sale số lượng giới hạn.', N'FIXED', 30000, NULL, 180000, 250, 1, 1, 10, 1),
            (N'OLDQN22', N'Đặc sản Quảng Nam cũ 22K', N'Ưu đãi riêng cho khu vực Quảng Nam cũ.', N'FIXED', 22000, NULL, 130000, 500, 2, -1, 45, 1),
            (N'DANANGSEA', N'Vị biển Đà Nẵng 14%', N'Áp dụng cho các món hải sản và nhậu.', N'PERCENT', 14, 55000, 170000, 380, 1, -1, 55, 1);

            IF COL_LENGTH('dbo.Vouchers', 'voucher_type') IS NOT NULL
            BEGIN
                INSERT INTO dbo.Vouchers(
                    merchant_user_id,
                    code,
                    title,
                    description,
                    discount_type,
                    discount_value,
                    max_discount_amount,
                    min_order_amount,
                    start_at,
                    end_at,
                    max_uses_total,
                    max_uses_per_user,
                    is_published,
                    status,
                    voucher_type
                )
                SELECT
                    sm.merchant_user_id,
                    CONCAT(vt.template_code, N'_', RIGHT('000000' + CAST(sm.merchant_user_id AS VARCHAR(6)), 6)),
                    vt.title,
                    CASE
                        WHEN vt.template_code = N'OLDQN22' AND sm.region_type = N'QN_OLD'
                            THEN N'Ưu đãi khu Quảng Nam cũ thuộc vùng phục vụ mở rộng Đà Nẵng.'
                        WHEN vt.template_code = N'OLDQN22' AND sm.region_type = N'DN'
                            THEN N'Ưu đãi liên vùng cho khách đặt món từ khu vực mở rộng.'
                        ELSE vt.description
                    END,
                    vt.discount_type,
                    vt.discount_value,
                    vt.max_discount_amount,
                    vt.min_order_amount,
                    DATEADD(DAY, vt.starts_in_days, SYSUTCDATETIME()),
                    DATEADD(DAY, vt.starts_in_days + vt.duration_days, SYSUTCDATETIME()),
                    vt.max_uses_total,
                    vt.max_uses_per_user,
                    vt.is_published,
                    N'ACTIVE',
                    N'MERCHANT'
                FROM #SeedMerchants sm
                JOIN #VoucherTemplates vt ON 1 = 1
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM dbo.Vouchers v
                    WHERE v.merchant_user_id = sm.merchant_user_id
                      AND v.code = CONCAT(vt.template_code, N'_', RIGHT('000000' + CAST(sm.merchant_user_id AS VARCHAR(6)), 6))
                );
            END
            ELSE
            BEGIN
                INSERT INTO dbo.Vouchers(
                    merchant_user_id,
                    code,
                    title,
                    description,
                    discount_type,
                    discount_value,
                    max_discount_amount,
                    min_order_amount,
                    start_at,
                    end_at,
                    max_uses_total,
                    max_uses_per_user,
                    is_published,
                    status
                )
                SELECT
                    sm.merchant_user_id,
                    CONCAT(vt.template_code, N'_', RIGHT('000000' + CAST(sm.merchant_user_id AS VARCHAR(6)), 6)),
                    vt.title,
                    CASE
                        WHEN vt.template_code = N'OLDQN22' AND sm.region_type = N'QN_OLD'
                            THEN N'Ưu đãi khu Quảng Nam cũ thuộc vùng phục vụ mở rộng Đà Nẵng.'
                        WHEN vt.template_code = N'OLDQN22' AND sm.region_type = N'DN'
                            THEN N'Ưu đãi liên vùng cho khách đặt món từ khu vực mở rộng.'
                        ELSE vt.description
                    END,
                    vt.discount_type,
                    vt.discount_value,
                    vt.max_discount_amount,
                    vt.min_order_amount,
                    DATEADD(DAY, vt.starts_in_days, SYSUTCDATETIME()),
                    DATEADD(DAY, vt.starts_in_days + vt.duration_days, SYSUTCDATETIME()),
                    vt.max_uses_total,
                    vt.max_uses_per_user,
                    vt.is_published,
                    N'ACTIVE'
                FROM #SeedMerchants sm
                JOIN #VoucherTemplates vt ON 1 = 1
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM dbo.Vouchers v
                    WHERE v.merchant_user_id = sm.merchant_user_id
                      AND v.code = CONCAT(vt.template_code, N'_', RIGHT('000000' + CAST(sm.merchant_user_id AS VARCHAR(6)), 6))
                );
            END;
        END;
    END;

    COMMIT TRAN;

    PRINT N'Hoàn tất seed: 150 Đà Nẵng + 100 Quảng Nam cũ (tương thích đa schema).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(N'Seed thất bại: %s', 16, 1, @Err);
END CATCH;
GO

/* Verification queries */
SELECT
    CASE
        WHEN u.email LIKE N'merchant.dn.%@clickeat.vn' THEN N'Đà Nẵng'
        WHEN u.email LIKE N'merchant.qnold.%@clickeat.vn' THEN N'Quảng Nam cũ'
        ELSE N'Khác'
    END AS seed_group,
    COUNT(*) AS merchant_count
FROM dbo.Users u
WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
   OR u.email LIKE N'merchant.qnold.%@clickeat.vn'
GROUP BY
    CASE
        WHEN u.email LIKE N'merchant.dn.%@clickeat.vn' THEN N'Đà Nẵng'
        WHEN u.email LIKE N'merchant.qnold.%@clickeat.vn' THEN N'Quảng Nam cũ'
        ELSE N'Khác'
    END;
GO

SELECT
    mp.district_name,
    COUNT(*) AS merchant_count
FROM dbo.MerchantProfiles mp
JOIN dbo.Users u ON u.id = mp.user_id
WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
   OR u.email LIKE N'merchant.qnold.%@clickeat.vn'
GROUP BY mp.district_name
ORDER BY mp.district_name;
GO

SELECT
    c.name AS category_name,
    COUNT(*) AS category_rows
FROM dbo.Categories c
JOIN dbo.Users u ON u.id = c.merchant_user_id
WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
   OR u.email LIKE N'merchant.qnold.%@clickeat.vn'
GROUP BY c.name
ORDER BY c.name;
GO

SELECT
    COUNT(*) AS total_food_items_seeded
FROM dbo.FoodItems fi
JOIN dbo.Users u ON u.id = fi.merchant_user_id
WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
   OR u.email LIKE N'merchant.qnold.%@clickeat.vn';
GO

SELECT
    COUNT(*) AS total_vouchers_seeded
FROM dbo.Vouchers v
JOIN dbo.Users u ON u.id = v.merchant_user_id
WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
   OR u.email LIKE N'merchant.qnold.%@clickeat.vn';
GO

IF COL_LENGTH('dbo.Vouchers', 'voucher_type') IS NOT NULL
BEGIN
    SELECT TOP 30
        v.merchant_user_id,
        v.code,
        v.voucher_type,
        v.discount_type,
        v.discount_value,
        v.min_order_amount,
        v.max_discount_amount,
        v.max_uses_total,
        v.max_uses_per_user,
        v.start_at,
        v.end_at,
        v.status
    FROM dbo.Vouchers v
    JOIN dbo.Users u ON u.id = v.merchant_user_id
    WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
       OR u.email LIKE N'merchant.qnold.%@clickeat.vn'
    ORDER BY v.merchant_user_id DESC, v.code;
END
ELSE
BEGIN
    SELECT TOP 30
        v.merchant_user_id,
        v.code,
        v.discount_type,
        v.discount_value,
        v.min_order_amount,
        v.max_discount_amount,
        v.max_uses_total,
        v.max_uses_per_user,
        v.start_at,
        v.end_at,
        v.status
    FROM dbo.Vouchers v
    JOIN dbo.Users u ON u.id = v.merchant_user_id
    WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
       OR u.email LIKE N'merchant.qnold.%@clickeat.vn'
    ORDER BY v.merchant_user_id DESC, v.code;
END;
GO

SELECT TOP 30
    u.id,
    u.full_name,
    u.phone,
    u.email,
    mp.shop_name,
    mp.shop_address_line,
    mp.district_name,
    mp.ward_name,
    mp.latitude,
    mp.longitude
FROM dbo.Users u
JOIN dbo.MerchantProfiles mp ON mp.user_id = u.id
WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
   OR u.email LIKE N'merchant.qnold.%@clickeat.vn'
ORDER BY u.id DESC;
GO

SELECT
     mp.shop_name,
     COUNT(*) AS duplicate_count
FROM dbo.Users u
JOIN dbo.MerchantProfiles mp ON mp.user_id = u.id
WHERE u.email LIKE N'merchant.dn.%@clickeat.vn'
    OR u.email LIKE N'merchant.qnold.%@clickeat.vn'
GROUP BY mp.shop_name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, mp.shop_name;
GO

/* =========================================================
   5) CẬP NHẬT ẢNH CHÍNH XÁC (EXACT MAPPING) CHO MERCHANTS VÀ FOOD ITEMS
   ========================================================= */

PRINT N'Bắt đầu cập nhật hình ảnh chính xác (exact mapping) cho Merchant và Food...';
GO

-- 1. Cập nhật FoodItems (31 món template chính xác)
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id22-Mi-Quang-ga.jpg' WHERE name LIKE N'Mì Quảng gà ta%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_cao_lau.jpg' WHERE name LIKE N'Cao lầu xá xíu Hội An%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id23-Banh-trang-cuon-thit.jpg' WHERE name LIKE N'Bê thui Cầu Mống cuốn bánh tráng%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_bun_mam.jpg' WHERE name LIKE N'Bún mắm nêm heo quay%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id25-Banh-xeo-tom-thit.jpg' WHERE name LIKE N'Bánh xèo tôm nhảy%';

UPDATE dbo.FoodItems SET image_url = N'/assets/images/id19-Bun-cha-suat-day-du.jpg' WHERE name LIKE N'Bún chả cá Đà Nẵng%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id18-Pho-bo-tai.jpg' WHERE name LIKE N'Phở bò tái nạm%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id21-Hu-tieu-Nam-Vang.jpg' WHERE name LIKE N'Bánh canh cá lóc%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id21-Hu-tieu-Nam-Vang.jpg' WHERE name LIKE N'Hủ tiếu hải sản%';

UPDATE dbo.FoodItems SET image_url = N'/assets/images/id2-Ga-ran-gion.jpg' WHERE name LIKE N'Cơm gà Hội An xé%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id20-Com-tam-suon-bi-cha.jpg' WHERE name LIKE N'Cơm niêu cá bống kho tộ%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id20-Com-tam-suon-bi-cha.jpg' WHERE name LIKE N'Cơm tấm sườn nướng%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id20-Com-tam-suon-bi-cha.jpg' WHERE name LIKE N'Cơm chiên hải sản%';

UPDATE dbo.FoodItems SET image_url = N'/assets/images/id27-Nem-cua-be.jpg' WHERE name LIKE N'Mực một nắng nướng sa tế%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_tom_su.jpg' WHERE name LIKE N'Tôm sú hấp sả%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_goi_ca.jpg' WHERE name LIKE N'Gỏi cá trích Nam Ô%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_tom_su.jpg' WHERE name LIKE N'Nghêu hấp Thái%';

UPDATE dbo.FoodItems SET image_url = N'/assets/images/id23-Banh-trang-cuon-thit.jpg' WHERE name LIKE N'Bánh tráng cuốn thịt heo%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id2-Ga-cay.jpg' WHERE name LIKE N'Nem lụi nướng sả%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id27-Nem-cua-be.jpg' WHERE name LIKE N'Ram cuốn cải%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id26-Banh-da-cua.jpg' WHERE name LIKE N'Bánh đập hến xào%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_tom_su.jpg' WHERE name LIKE N'Ốc hút xào sả ớt%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id4-Burger-ga.jpg' WHERE name LIKE N'Xương má hàm nướng muối ớt%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id4-Burger-ca.jpg' WHERE name LIKE N'Ba chỉ nướng tảng sốt Hàn%';

UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_tra_dao.jpg' WHERE name LIKE N'Trà tắc xí muội%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id5-Tra-dao.jpg' WHERE name LIKE N'Nước mát lá vối%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/food_ca_phe_muoi.jpg' WHERE name LIKE N'Cà phê muối%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id5-Tra-dao.jpg' WHERE name LIKE N'Trà sen vàng%';

UPDATE dbo.FoodItems SET image_url = N'/assets/images/id3-Combo-1.jpg' WHERE name LIKE N'Combo gia đình miền Trung 3 người%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id3-Combo-2.jpg' WHERE name LIKE N'Combo đặc sản Đà Nẵng 2 người%';
UPDATE dbo.FoodItems SET image_url = N'/assets/images/id3-Combo-1.jpg' WHERE name LIKE N'Combo Hội An phố cổ%';


-- 2. Cập nhật MerchantProfiles (32 cửa hàng cơ sở)

-- Đà Nẵng
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id22-Mi-Quang-Da-Nang.jpg' WHERE shop_name LIKE N'Mì Quảng Bà Mua%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id19-Bun-Cha-Pho-Co.jpg' WHERE shop_name LIKE N'Bún Chả Cá Bà Lữ%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id25-Banh-Xeo-Mien-Tay.jpg' WHERE shop_name LIKE N'Bánh Xèo Bà Dưỡng%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id23-Banh-Trang-Cuon-DN.jpg' WHERE shop_name LIKE N'Bánh Tráng Cuốn Thịt Heo Trần%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id20-Com-Tam-Sai-Gon.jpg' WHERE shop_name LIKE N'Cơm Gà A Hải%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_noodle.jpg' WHERE shop_name LIKE N'Bánh Mì Bà Lan%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_noodle.jpg' WHERE shop_name LIKE N'Bún Mắm Vân%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_seafood.jpg' WHERE shop_name LIKE N'Hải Sản Bé Mặn%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id20-Com-Tam-Sai-Gon.jpg' WHERE shop_name LIKE N'Cơm Niêu Nhà Đỏ%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id26-Banh-Da-Cua-Hai-Phong.jpg' WHERE shop_name LIKE N'Bánh Canh Ruộng%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id18-Pho-Ha-Thanh.jpg' WHERE shop_name LIKE N'Bún Bò Bà Thương%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id23-Banh-Trang-Cuon-DN.jpg' WHERE shop_name LIKE N'Bếp Cuốn Đà Nẵng%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_noodle.jpg' WHERE shop_name LIKE N'Bánh Bèo Bà Bé%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_seafood.jpg' WHERE shop_name LIKE N'Gỏi Cá Nam Ô%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id23-Banh-Trang-Cuon-DN.jpg' WHERE shop_name LIKE N'Bánh Tráng Kẹp Dì Hoa%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_coffee.jpg' WHERE shop_name LIKE N'Chè Sầu Liên%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_seafood.jpg' WHERE shop_name LIKE N'Ốc Điện Phương%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id2-Lollibee-Q1.jpg' WHERE shop_name LIKE N'Xương Má Hàm%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id3-Lollibee-Q3.jpg' WHERE shop_name LIKE N'Làng Nướng%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id18-Pho-Ha-Thanh.jpg' WHERE shop_name LIKE N'Phở Bắc Hải%';

-- Quảng Nam Cũ
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_noodle.jpg' WHERE shop_name LIKE N'Cao Lầu Liên%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_hoi_an.jpg' WHERE shop_name LIKE N'Bánh Mì Phượng%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_hoi_an.jpg' WHERE shop_name LIKE N'Morning Glory Hội An%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id20-Com-Tam-Sai-Gon.jpg' WHERE shop_name LIKE N'Cơm Gà Bà Buội%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id22-Mi-Quang-Da-Nang.jpg' WHERE shop_name LIKE N'Mì Quảng Ông Hai%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id4-Lollibee-BT.jpg' WHERE shop_name LIKE N'Bê Thui Cầu Mống%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id25-Banh-Xeo-Mien-Tay.jpg' WHERE shop_name LIKE N'Bánh Đập Cẩm Nam%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id26-Banh-Da-Cua-Hai-Phong.jpg' WHERE shop_name LIKE N'Hến Xào Cẩm Nam%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_noodle.jpg' WHERE shop_name LIKE N'Bún Mắm Nêm Hội An%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id25-Banh-Xeo-Mien-Tay.jpg' WHERE shop_name LIKE N'Bánh Xèo Giếng Bá Lễ%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/id18-Pho-Ha-Thanh.jpg' WHERE shop_name LIKE N'Phở Liến%';
UPDATE dbo.MerchantProfiles SET image_url = N'/assets/images/shop_coffee.jpg' WHERE shop_name LIKE N'Hoian Roastery%';


PRINT N'Hoàn tất cập nhật hình ảnh chính xác từng item!';
GO
 
  
 / *   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  
       6 )   B �N   C �P   N H �T   �N H   C H � N H   X � C   D D G   ( E X A C T   M A P P I N G   2 . 0 )  
       = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =   * /  
  
 P R I N T   N ' B �t   �u   c �p   n h �t   h � n h   �n h   D D G   c h � n h   x � c   1 0 0 %   t �n g   i t e m . . . ' ;  
 G O  
  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ m _ q u _ n g _ g _ t a . j p g '   W H E R E   n a m e   L I K E   N ' M �   Q u �n g   g �   t a % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c a o _ l _ u _ x _ x _ u _ h _ i _ a n . j p g '   W H E R E   n a m e   L I K E   N ' C a o   l �u   x �   x � u   H �i   A n % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b _ t h u i _ c _ u _ m _ n g _ c u _ n _ b _ n h _ t r _ n . j p g '   W H E R E   n a m e   L I K E   N ' B �   t h u i   C �u   M �n g   c u �n   b � n h   t r � n g % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b _ n _ m _ m _ n _ m _ h e o _ q u a y . j p g '   W H E R E   n a m e   L I K E   N ' B � n   m �m   n � m   h e o   q u a y % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b _ n h _ x _ o _ t _ m _ n h _ y . j p g '   W H E R E   n a m e   L I K E   N ' B � n h   x � o   t � m   n h �y % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b _ n _ c h _ c _ n _ n g . j p g '   W H E R E   n a m e   L I K E   N ' B � n   c h �  c �   �   N �n g % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ p h _ b _ t _ i _ n _ m . j p g '   W H E R E   n a m e   L I K E   N ' P h �  b �   t � i   n �m % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b _ n h _ c a n h _ c _ l _ c . j p g '   W H E R E   n a m e   L I K E   N ' B � n h   c a n h   c �   l � c % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ h _ t i _ u _ h _ i _ s _ n . j p g '   W H E R E   n a m e   L I K E   N ' H �  t i �u   h �i   s �n % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c _ m _ g _ h _ i _ a n _ x . j p g '   W H E R E   n a m e   L I K E   N ' C �m   g �   H �i   A n   x � % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c _ m _ n i _ u _ c _ b _ n g _ k h o _ t . j p g '   W H E R E   n a m e   L I K E   N ' C �m   n i � u   c �   b �n g   k h o   t �% ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c _ m _ t _ m _ s _ n _ n _ n g . j p g '   W H E R E   n a m e   L I K E   N ' C �m   t �m   s ��n   n ��n g % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c _ m _ c h i _ n _ h _ i _ s _ n . j p g '   W H E R E   n a m e   L I K E   N ' C �m   c h i � n   h �i   s �n % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ m _ c _ m _ t _ n _ n g _ n _ n g _ s a _ t . j p g '   W H E R E   n a m e   L I K E   N ' M �c   m �t   n �n g   n ��n g   s a   t �% ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ t _ m _ s _ h _ p _ s . j p g '   W H E R E   n a m e   L I K E   N ' T � m   s �   h �p   s �% ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ g _ i _ c _ t r _ c h _ n a m . j p g '   W H E R E   n a m e   L I K E   N ' G �i   c �   t r � c h   N a m   � % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ n g h _ u _ h _ p _ t h _ i . j p g '   W H E R E   n a m e   L I K E   N ' N g h � u   h �p   T h � i % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b _ n h _ t r _ n g _ c u _ n _ t h _ t _ h e o . j p g '   W H E R E   n a m e   L I K E   N ' B � n h   t r � n g   c u �n   t h �t   h e o % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ n e m _ l _ i _ n _ n g _ s . j p g '   W H E R E   n a m e   L I K E   N ' N e m   l �i   n ��n g   s �% ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ r a m _ c u _ n _ c _ i . j p g '   W H E R E   n a m e   L I K E   N ' R a m   c u �n   c �i % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b _ n h _ p _ h _ n _ x _ o . j p g '   W H E R E   n a m e   L I K E   N ' B � n h   �p   h �n   x � o % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c _ h _ t _ x _ o _ s _ t . j p g '   W H E R E   n a m e   L I K E   N ' �c   h � t   x � o   s �  �t % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ x _ n g _ m _ h _ m _ n _ n g _ m u _ i _ t . j p g '   W H E R E   n a m e   L I K E   N ' X ��n g   m �   h � m   n ��n g   m u �i   �t % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ b a _ c h _ n _ n g _ t _ n g _ s _ t _ h _ n . j p g '   W H E R E   n a m e   L I K E   N ' B a   c h �  n ��n g   t �n g   s �t   H � n % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ t r _ t _ c _ x _ m u _ i . j p g '   W H E R E   n a m e   L I K E   N ' T r �   t �c   x �   m u �i % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ n _ c _ m _ t _ l _ v _ i . j p g '   W H E R E   n a m e   L I K E   N ' N ��c   m � t   l �   v �i % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c _ p h _ m u _ i . j p g '   W H E R E   n a m e   L I K E   N ' C �   p h �   m u �i % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ t r _ s e n _ v _ n g . j p g '   W H E R E   n a m e   L I K E   N ' T r �   s e n   v � n g % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c o m b o _ g i a _ n h _ m i _ n _ t r u n g _ 3 _ n g _ i . j p g '   W H E R E   n a m e   L I K E   N ' C o m b o   g i a   � n h   m i �n   T r u n g   3   n g ��i % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c o m b o _ c _ s _ n _ n _ n g _ 2 _ n g _ i . j p g '   W H E R E   n a m e   L I K E   N ' C o m b o   �c   s �n   �   N �n g   2   n g ��i % ' ;  
 U P D A T E   d b o . F o o d I t e m s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ f o o d _ c o m b o _ h _ i _ a n _ p h _ c . j p g '   W H E R E   n a m e   L I K E   N ' C o m b o   H �i   A n   p h �  c �% ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ m _ q u _ n g _ b _ m u a . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' M �   Q u �n g   B �   M u a % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n _ c h _ c _ b _ l . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n   C h �  C �   B �   L �% ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ x _ o _ b _ d _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   X � o   B �   D ��n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ t r _ n g _ c u _ n _ t h _ t _ h e o _ t r _ n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   T r � n g   C u �n   T h �t   H e o   T r �n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ c _ m _ g _ a _ h _ i . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' C �m   G �   A   H �i % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ m _ b _ l a n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   M �   B �   L a n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n _ m _ m _ v _ n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n   M �m   V � n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ h _ i _ s _ n _ b _ m _ n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' H �i   S �n   B �   M �n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ c _ m _ n i _ u _ n h . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' C �m   N i � u   N h �   �% ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ c a n h _ r u _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   C a n h   R u �n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n _ b _ b _ t h _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n   B �   B �   T h ��n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ p _ c u _ n _ n _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B �p   C u �n   �   N �n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ b _ o _ b _ b . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   B � o   B �   B � % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ g _ i _ c _ n a m . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' G �i   C �   N a m   � % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ t r _ n g _ k _ p _ d _ h o a . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   T r � n g   K �p   D �   H o a % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ c h _ s _ u _ l i _ n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' C h �   S �u   L i � n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ c _ i _ n _ p h _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' �c   i �n   P h ��n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ x _ n g _ m _ h _ m . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' X ��n g   M �   H � m % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ l _ n g _ n _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' L � n g   N ��n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ p h _ b _ c _ h _ i . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' P h �  B �c   H �i % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ c a o _ l _ u _ l i _ n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' C a o   L �u   L i � n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ m _ p h _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   M �   P h ��n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ m o r n i n g _ g l o r y _ h _ i _ a n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' M o r n i n g   G l o r y   H �i   A n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ c _ m _ g _ b _ b u _ i . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' C �m   G �   B �   B u �i % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ m _ q u _ n g _ n g _ h a i . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' M �   Q u �n g   � n g   H a i % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ t h u i _ c _ u _ m _ n g . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B �   T h u i   C �u   M �n g % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ p _ c _ m _ n a m . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   �p   C �m   N a m % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ h _ n _ x _ o _ c _ m _ n a m . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' H �n   X � o   C �m   N a m % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n _ m _ m _ n _ m _ h _ i _ a n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n   M �m   N � m   H �i   A n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ b _ n h _ x _ o _ g i _ n g _ b _ l . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' B � n h   X � o   G i �n g   B �   L �% ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ p h _ l i _ n . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' P h �  L i �n % ' ;  
 U P D A T E   d b o . M e r c h a n t P r o f i l e s   S E T   i m a g e _ u r l   =   N ' / a s s e t s / i m a g e s / r e a l _ s h o p _ h o i a n _ r o a s t e r y . j p g '   W H E R E   s h o p _ n a m e   L I K E   N ' H o i a n   R o a s t e r y % ' ;  
  
 P R I N T   N ' H o � n   t �t   c �p   n h �t   1 0 0 %   h � n h   �n h   �c   q u y �n   D D G ! ' ;  
 G O  
 