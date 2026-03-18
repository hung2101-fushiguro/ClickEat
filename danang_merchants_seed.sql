/*
  ClickEat - Seed thực tế hơn cho Đà Nẵng (~100 quán)
  - Tạo Users + MerchantProfiles + Categories + FoodItems
  - Tên quán theo nhóm ẩm thực, địa chỉ theo quận/huyện trung tâm Đà Nẵng
  - Mỗi quán có nhiều món ăn + đồ uống (template theo phong cách quán)
  - Idempotent: chạy lại không tạo trùng theo phone/category/item
*/

USE ClickEat;
GO
SET NOCOUNT ON;
GO

DECLARE @MerchantCount INT = 100;

DECLARE @District TABLE (
    district_seq INT PRIMARY KEY,
    district_code NVARCHAR(20),
    district_name NVARCHAR(100),
    ward_name NVARCHAR(100),
    base_lat DECIMAL(10,7),
    base_lng DECIMAL(10,7)
);

INSERT INTO @District VALUES
(1, N'DN-HC',  N'Hải Châu',     N'Phường Hải Châu',     16.0595000, 108.2215000),
(2, N'DN-ST',  N'Sơn Trà',      N'Phường An Hải',       16.0672000, 108.2408000),
(3, N'DN-NHS', N'Ngũ Hành Sơn', N'Phường Mỹ An',        16.0468000, 108.2462000),
(4, N'DN-TK',  N'Thanh Khê',    N'Phường Thanh Khê',    16.0726000, 108.2097000),
(5, N'DN-CL',  N'Cẩm Lệ',       N'Phường Hòa Cường',    16.0348000, 108.2199000);

DECLARE @Street TABLE (
    district_seq INT,
    street_seq INT,
    street_name NVARCHAR(120),
    PRIMARY KEY (district_seq, street_seq)
);

INSERT INTO @Street VALUES
(1,1,N'Đường Bạch Đằng'), (1,2,N'Đường Nguyễn Văn Linh'), (1,3,N'Đường Hoàng Diệu'), (1,4,N'Đường Trần Phú'),
(2,1,N'Đường Võ Văn Kiệt'), (2,2,N'Đường Phạm Văn Đồng'), (2,3,N'Đường Hồ Nghinh'), (2,4,N'Đường Dương Đình Nghệ'),
(3,1,N'Đường Võ Nguyên Giáp'), (3,2,N'Đường Châu Thị Vĩnh Tế'), (3,3,N'Đường An Thượng 2'), (3,4,N'Đường An Thượng 29'),
(4,1,N'Đường Điện Biên Phủ'), (4,2,N'Đường Hà Huy Tập'), (4,3,N'Đường Nguyễn Tất Thành'), (4,4,N'Đường Lê Duẩn'),
(5,1,N'Đường 2 Tháng 9'), (5,2,N'Đường Cách Mạng Tháng 8'), (5,3,N'Đường Lê Thanh Nghị'), (5,4,N'Đường Tiểu La');

DECLARE @Cuisine TABLE (
    cuisine_seq INT PRIMARY KEY,
    shop_prefix NVARCHAR(120),
    cuisine_name NVARCHAR(100)
);

INSERT INTO @Cuisine VALUES
(1, N'Quán Hải Sản Biển Xanh', N'Hải sản'),
(2, N'Bếp Cơm Nhà Đà Nẵng',    N'Cơm Việt'),
(3, N'Bún Phở Gánh Chiều',     N'Bún/Phở'),
(4, N'Pizza & Pasta Riverside',N'Âu - Pizza'),
(5, N'Trà Sữa Mây',            N'Trà sữa/Đồ uống'),
(6, N'Nhà Hàng Chay An Lạc',   N'Chay');

DECLARE @MerchantSeed TABLE (
    n INT PRIMARY KEY,
    shop_name NVARCHAR(120),
    shop_phone NVARCHAR(20),
    shop_address_line NVARCHAR(255),
    district_code NVARCHAR(20),
    district_name NVARCHAR(100),
    ward_code NVARCHAR(20),
    ward_name NVARCHAR(100),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    cuisine_seq INT
);

;WITH N AS (
    SELECT TOP (@MerchantCount) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
), S AS (
    SELECT
        n.n,
        ((n.n - 1) % 5) + 1 AS district_seq,
        ((n.n - 1) % 6) + 1 AS cuisine_seq,
        ((n.n * 3) % 4) + 1 AS street_seq
    FROM N n
)
INSERT INTO @MerchantSeed (
    n, shop_name, shop_phone, shop_address_line,
    district_code, district_name, ward_code, ward_name,
    latitude, longitude, cuisine_seq
)
SELECT
    s.n,
    c.shop_prefix + N' - CN ' + RIGHT('000' + CAST(s.n AS NVARCHAR(3)), 3),
    N'0938' + RIGHT('000000' + CAST(s.n AS NVARCHAR(6)), 6),
    N'Số ' + CAST(10 + ((s.n * 7) % 180) AS NVARCHAR(10)) + N' ' + st.street_name + N', ' + d.district_name + N', Đà Nẵng',
    d.district_code,
    d.district_name,
    N'W-' + d.district_code + N'-' + RIGHT('000' + CAST(s.n AS NVARCHAR(3)), 3),
    d.ward_name,
    CAST(d.base_lat + (((s.n * 13) % 90) / 10000.0) AS DECIMAL(10,7)),
    CAST(d.base_lng + (((s.n * 17) % 90) / 10000.0) AS DECIMAL(10,7)),
    s.cuisine_seq
FROM S s
JOIN @District d ON d.district_seq = s.district_seq
JOIN @Cuisine c ON c.cuisine_seq = s.cuisine_seq
JOIN @Street st ON st.district_seq = s.district_seq AND st.street_seq = s.street_seq;

/* 1) Users */
INSERT INTO dbo.Users (full_name, email, phone, password_hash, role, status)
SELECT
    ms.shop_name,
    NULL,
    ms.shop_phone,
    N'$2a$10$placeholder.hash.seed.only',
    N'MERCHANT',
    N'ACTIVE'
FROM @MerchantSeed ms
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Users u
    WHERE u.phone = ms.shop_phone
);

/* 2) MerchantProfiles */
INSERT INTO dbo.MerchantProfiles (
    user_id, shop_name, shop_phone, shop_address_line,
    province_code, province_name,
    district_code, district_name,
    ward_code, ward_name,
    latitude, longitude, status
)
SELECT
    u.id,
    ms.shop_name,
    ms.shop_phone,
    ms.shop_address_line,
    N'48', N'Đà Nẵng',
    ms.district_code, ms.district_name,
    ms.ward_code, ms.ward_name,
    ms.latitude, ms.longitude,
    N'APPROVED'
FROM @MerchantSeed ms
JOIN dbo.Users u ON u.phone = ms.shop_phone
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.MerchantProfiles mp
    WHERE mp.user_id = u.id
);

DECLARE @CategorySeed TABLE (category_name NVARCHAR(100), sort_order INT);
INSERT INTO @CategorySeed VALUES
(N'Món chính',1),
(N'Đồ uống',2),
(N'Ăn kèm',3),
(N'Tráng miệng',4),
(N'Combo',5);

/* 3) Categories */
INSERT INTO dbo.Categories (merchant_user_id, name, is_active, sort_order)
SELECT
    mp.user_id,
    cs.category_name,
    1,
    cs.sort_order
FROM dbo.MerchantProfiles mp
JOIN dbo.Users u ON u.id = mp.user_id
CROSS JOIN @CategorySeed cs
WHERE u.phone BETWEEN N'0938000001' AND N'0938000100'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Categories c
      WHERE c.merchant_user_id = mp.user_id
        AND c.name = cs.category_name
  );

DECLARE @MerchantCuisine TABLE (
    merchant_user_id BIGINT PRIMARY KEY,
    cuisine_seq INT
);

INSERT INTO @MerchantCuisine (merchant_user_id, cuisine_seq)
SELECT u.id, ms.cuisine_seq
FROM @MerchantSeed ms
JOIN dbo.Users u ON u.phone = ms.shop_phone;

DECLARE @FoodTemplate TABLE (
    cuisine_seq INT, /* 0 = áp dụng mọi quán */
    category_name NVARCHAR(100),
    item_name NVARCHAR(150),
    item_description NVARCHAR(500),
    base_price DECIMAL(18,2),
    is_fried BIT,
    calories INT,
    protein_g DECIMAL(10,2),
    carbs_g DECIMAL(10,2),
    fat_g DECIMAL(10,2)
);

/* Hải sản */
INSERT INTO @FoodTemplate VALUES
(1,N'Món chính',N'Lẩu hải sản chua cay',N'Tôm, mực, nghêu, rau nấm tươi',169000,0,860,52,78,28),
(1,N'Món chính',N'Cơm chiên hải sản',N'Cơm rang cùng tôm mực và rau củ',79000,0,720,26,94,20),
(1,N'Món chính',N'Mì xào hải sản',N'Mì xào đậm vị sốt đặc trưng',85000,0,690,28,88,18),
(1,N'Ăn kèm',N'Hàu nướng mỡ hành',N'Hàu tươi nướng thơm',99000,0,430,24,14,26),
(1,N'Ăn kèm',N'Tôm sú nướng muối ớt',N'Tôm sú nướng vị cay nhẹ',129000,0,510,36,8,28),
(1,N'Combo',N'Combo hải sản 2 người',N'Gồm lẩu + món nướng + nước',329000,0,1450,74,130,56),
(1,N'Đồ uống',N'Nước sâm mát lạnh',N'Thức uống giải nhiệt',25000,0,120,1,29,0),
(1,N'Tráng miệng',N'Rau câu dừa',N'Rau câu dừa thanh mát',28000,0,190,2,36,2);

/* Cơm Việt */
INSERT INTO @FoodTemplate VALUES
(2,N'Món chính',N'Cơm tấm sườn bì chả',N'Món cơm tấm truyền thống',65000,0,760,35,84,22),
(2,N'Món chính',N'Cơm gà xối mỡ',N'Cơm gà giòn da, sốt đặc biệt',69000,1,820,34,82,30),
(2,N'Món chính',N'Cơm bò lúc lắc',N'Bò mềm xào tiêu đen',79000,0,790,32,86,26),
(2,N'Ăn kèm',N'Canh rong biển thịt bằm',N'Canh nóng ăn kèm cơm',29000,0,180,10,14,7),
(2,N'Ăn kèm',N'Trứng ốp la',N'Một phần trứng ốp la',15000,0,110,7,1,8),
(2,N'Combo',N'Combo cơm văn phòng',N'Cơm + canh + nước',89000,0,980,42,112,24),
(2,N'Đồ uống',N'Trà đá',N'Trà đá phục vụ tại bàn',5000,0,0,0,0,0),
(2,N'Tráng miệng',N'Sữa chua nha đam',N'Sữa chua thanh mát',22000,0,140,4,22,4);

/* Bún/Phở */
INSERT INTO @FoodTemplate VALUES
(3,N'Món chính',N'Bún bò đặc biệt',N'Nước dùng ninh xương đậm đà',59000,0,640,30,82,16),
(3,N'Món chính',N'Phở tái nạm',N'Phở bò truyền thống',62000,0,610,31,78,14),
(3,N'Món chính',N'Mì Quảng gà',N'Mì Quảng chuẩn vị miền Trung',55000,0,590,24,80,14),
(3,N'Ăn kèm',N'Quẩy giòn',N'Phần quẩy ăn kèm',12000,1,180,3,20,9),
(3,N'Ăn kèm',N'Gân bò hầm',N'Phần topping thêm',25000,0,160,12,2,10),
(3,N'Combo',N'Combo bún bò + nước',N'Một tô + nước giải khát',79000,0,760,33,98,18),
(3,N'Đồ uống',N'Nước mơ đá',N'Nước mơ chua ngọt',22000,0,120,0,30,0),
(3,N'Tráng miệng',N'Chè đậu xanh',N'Chè ngọt thanh',20000,0,190,5,34,2);

/* Âu - Pizza */
INSERT INTO @FoodTemplate VALUES
(4,N'Món chính',N'Pizza hải sản size M',N'Đế mỏng, phô mai kéo sợi',149000,0,980,42,102,44),
(4,N'Món chính',N'Pizza pepperoni size M',N'Vị mặn thơm đặc trưng',139000,0,940,40,96,42),
(4,N'Món chính',N'Mỳ Ý bò bằm',N'Sốt cà chua bò bằm',79000,0,760,28,92,24),
(4,N'Ăn kèm',N'Khoai tây múi cau',N'Khoai nướng giòn',39000,1,360,5,44,18),
(4,N'Ăn kèm',N'Gà viên chiên',N'Chicken bites giòn',49000,1,420,20,24,24),
(4,N'Combo',N'Combo pizza 2 người',N'Pizza + mỳ ý + 2 nước',299000,0,1600,66,176,64),
(4,N'Đồ uống',N'Nước ngọt có ga',N'Lon 330ml',20000,0,140,0,35,0),
(4,N'Tráng miệng',N'Bánh tiramisu',N'Tiramisu mềm mịn',45000,0,320,6,36,16);

/* Trà sữa / Đồ uống */
INSERT INTO @FoodTemplate VALUES
(5,N'Đồ uống',N'Trà sữa trân châu đường đen',N'Trà sữa béo thơm',42000,0,340,5,58,10),
(5,N'Đồ uống',N'Trà đào cam sả',N'Trà trái cây thanh mát',36000,0,160,1,38,0),
(5,N'Đồ uống',N'Trà vải hoa hồng',N'Hương thơm dịu nhẹ',38000,0,170,1,40,0),
(5,N'Đồ uống',N'Sữa tươi trân châu',N'Sữa tươi kết hợp topping',39000,0,300,6,45,9),
(5,N'Đồ uống',N'Cafe muối',N'Đặc sản miền Trung',35000,0,180,3,22,8),
(5,N'Ăn kèm',N'Bánh su kem',N'Bánh ngọt ăn kèm trà',28000,0,250,4,30,10),
(5,N'Combo',N'Combo 2 trà sữa',N'2 ly size M tùy chọn',79000,0,650,10,110,18),
(5,N'Tráng miệng',N'Pudding trứng',N'Pudding mềm mịn',22000,0,180,4,24,7);

/* Chay */
INSERT INTO @FoodTemplate VALUES
(6,N'Món chính',N'Cơm chay thập cẩm',N'Rau củ kho, đậu hũ, cơm nóng',59000,0,620,20,92,14),
(6,N'Món chính',N'Bún riêu chay',N'Nước dùng thanh ngọt từ rau củ',55000,0,540,16,84,10),
(6,N'Món chính',N'Mì xào nấm chay',N'Nấm tươi xào rau củ',57000,0,560,18,86,12),
(6,N'Ăn kèm',N'Chả giò chay',N'Chả giò nhân rau củ',39000,1,340,8,40,16),
(6,N'Ăn kèm',N'Đậu hũ sốt nấm',N'Đậu hũ non sốt nấm',42000,0,290,14,18,14),
(6,N'Combo',N'Combo chay 2 người',N'2 món chính + 2 nước',169000,0,1180,36,170,28),
(6,N'Đồ uống',N'Trà atiso',N'Trà thảo mộc thanh lọc',26000,0,90,0,22,0),
(6,N'Tráng miệng',N'Chè hạt sen',N'Chè ngọt thanh nhẹ',25000,0,170,5,30,1);

/* Món chung cho mọi quán */
INSERT INTO @FoodTemplate VALUES
(0,N'Đồ uống',N'Nước suối',N'Nước uống đóng chai',12000,0,0,0,0,0),
(0,N'Đồ uống',N'Coca Cola',N'Lon 330ml',18000,0,140,0,35,0),
(0,N'Đồ uống',N'Nước cam ép',N'Cam tươi nguyên chất',32000,0,130,2,30,0),
(0,N'Ăn kèm',N'Khoai tây chiên',N'Khoai tây giòn nóng',35000,1,420,6,48,22),
(0,N'Ăn kèm',N'Nem rán',N'Nem rán giòn',36000,1,390,10,36,22),
(0,N'Tráng miệng',N'Bánh flan',N'Flan caramel mềm mịn',22000,0,190,5,26,7),
(0,N'Tráng miệng',N'Sữa chua dẻo',N'Sữa chua mát lạnh',25000,0,160,4,22,6),
(0,N'Combo',N'Combo tiết kiệm',N'Món chính + nước + tráng miệng',99000,0,900,28,110,24);

/* 4) FoodItems */
INSERT INTO dbo.FoodItems (
    merchant_user_id,
    category_id,
    name,
    description,
    price,
    image_url,
    is_available,
    is_fried,
    calories,
    protein_g,
    carbs_g,
    fat_g
)
SELECT
    mc.merchant_user_id,
    c.id,
    ft.item_name,
    ft.item_description,
    CAST(ft.base_price + ((mc.merchant_user_id % 6) * 1000) AS DECIMAL(18,2)),
    NULL,
    1,
    ft.is_fried,
    ft.calories,
    ft.protein_g,
    ft.carbs_g,
    ft.fat_g
FROM @MerchantCuisine mc
JOIN dbo.Categories c ON c.merchant_user_id = mc.merchant_user_id
JOIN @FoodTemplate ft
    ON ft.category_name = c.name
   AND (ft.cuisine_seq = 0 OR ft.cuisine_seq = mc.cuisine_seq)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.FoodItems fi
    WHERE fi.merchant_user_id = mc.merchant_user_id
      AND fi.name = ft.item_name
);

DECLARE @MerchantInserted INT = (
    SELECT COUNT(*)
    FROM dbo.MerchantProfiles mp
    JOIN dbo.Users u ON u.id = mp.user_id
    WHERE u.phone BETWEEN N'0938000001' AND N'0938000100'
);

DECLARE @FoodInserted INT = (
    SELECT COUNT(*)
    FROM dbo.FoodItems fi
    JOIN dbo.Users u ON u.id = fi.merchant_user_id
    WHERE u.phone BETWEEN N'0938000001' AND N'0938000100'
);

PRINT N'✅ Seed thực tế hơn hoàn tất.';
PRINT N'   - Số quán trong dải seed: ' + CAST(@MerchantInserted AS NVARCHAR(20));
PRINT N'   - Tổng số món trong dải seed: ' + CAST(@FoodInserted AS NVARCHAR(20));
GO
