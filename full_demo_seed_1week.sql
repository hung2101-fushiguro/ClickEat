/* =========================================================
   ClickEat - FULL DEMO SEED (1 WEEK) - IDEMPOTENT
   - Chạy SAU ClickEat2.sql và patch_missing_tables.sql
   - Mục tiêu: có dữ liệu thật để demo toàn hệ thống (Customer/Merchant/Shipper/Admin)
   - Script chạy lại nhiều lần KHÔNG lỗi (tự kiểm tra tồn tại trước khi insert)
   ========================================================= */

USE ClickEat;
GO
SET NOCOUNT ON;
GO

BEGIN TRY
    BEGIN TRAN;

    /* -------------------------
       Helpers (T-SQL inline)
       ------------------------- */
    DECLARE @now DATETIME2 = SYSUTCDATETIME();
    DECLARE @today DATE = CAST(@now AS DATE);

    /* Generate a unique-ish phone number (09xxxxxxxx). */
    DECLARE @phone NVARCHAR(20);

    /* =========================================================
       1) Core demo identities (by email as natural key)
       ========================================================= */

    DECLARE @AdminId BIGINT = (SELECT TOP 1 id FROM dbo.Users WHERE role = N'ADMIN');

    /* Customers */
    DECLARE @EmailCusVip NVARCHAR(200) = N'demo.vip@clickeat.vn';
    DECLARE @EmailCusComplaint NVARCHAR(200) = N'demo.complaint@clickeat.vn';
    DECLARE @EmailCusStudent NVARCHAR(200) = N'demo.student@clickeat.vn';

    DECLARE @CusVipId BIGINT = (SELECT id FROM dbo.Users WHERE email = @EmailCusVip);
    IF @CusVipId IS NULL
    BEGIN
        SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM dbo.Users WHERE phone = @phone)
            SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);

        INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
        VALUES (N'Demo VIP Customer', @EmailCusVip, @phone, N'hash_demo', N'CUSTOMER', N'ACTIVE');
        SET @CusVipId = SCOPE_IDENTITY();
    END

    DECLARE @CusComplaintId BIGINT = (SELECT id FROM dbo.Users WHERE email = @EmailCusComplaint);
    IF @CusComplaintId IS NULL
    BEGIN
        SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM dbo.Users WHERE phone = @phone)
            SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);

        INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
        VALUES (N'Demo Complaint Customer', @EmailCusComplaint, @phone, N'hash_demo', N'CUSTOMER', N'ACTIVE');
        SET @CusComplaintId = SCOPE_IDENTITY();
    END

    DECLARE @CusStudentId BIGINT = (SELECT id FROM dbo.Users WHERE email = @EmailCusStudent);
    IF @CusStudentId IS NULL
    BEGIN
        SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM dbo.Users WHERE phone = @phone)
            SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);

        INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
        VALUES (N'Demo Student Customer', @EmailCusStudent, @phone, N'hash_demo', N'CUSTOMER', N'ACTIVE');
        SET @CusStudentId = SCOPE_IDENTITY();
    END

    /* Customer profiles */
    IF NOT EXISTS (SELECT 1 FROM dbo.CustomerProfiles WHERE user_id = @CusVipId)
        INSERT INTO dbo.CustomerProfiles(user_id, food_preferences, allergies, health_goal, daily_calorie_target)
        VALUES (@CusVipId, N'Thích món nhiều đạm, ít ngọt', NULL, N'Tăng cơ', 2400);

    IF NOT EXISTS (SELECT 1 FROM dbo.CustomerProfiles WHERE user_id = @CusComplaintId)
        INSERT INTO dbo.CustomerProfiles(user_id, food_preferences, allergies, health_goal, daily_calorie_target)
        VALUES (@CusComplaintId, N'Ưu tiên sạch sẽ, nóng hổi', N'Hải sản', N'Giảm mỡ', 1600);

    IF NOT EXISTS (SELECT 1 FROM dbo.CustomerProfiles WHERE user_id = @CusStudentId)
        INSERT INTO dbo.CustomerProfiles(user_id, food_preferences, allergies, health_goal, daily_calorie_target)
        VALUES (@CusStudentId, N'Thích khuyến mãi, giá rẻ', NULL, N'Duy trì', 2000);


    /* Merchants */
    DECLARE @EmailMerBunBo NVARCHAR(200) = N'demo.merchant.bunbo@clickeat.vn';
    DECLARE @EmailMerTraSua NVARCHAR(200) = N'demo.merchant.trasua@clickeat.vn';

    DECLARE @MerBunBoUserId BIGINT = (SELECT id FROM dbo.Users WHERE email = @EmailMerBunBo);
    IF @MerBunBoUserId IS NULL
    BEGIN
        SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM dbo.Users WHERE phone = @phone)
            SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);

        INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
        VALUES (N'Demo Bun Bo Merchant', @EmailMerBunBo, @phone, N'hash_demo', N'MERCHANT', N'ACTIVE');
        SET @MerBunBoUserId = SCOPE_IDENTITY();
    END

    DECLARE @MerTraSuaUserId BIGINT = (SELECT id FROM dbo.Users WHERE email = @EmailMerTraSua);
    IF @MerTraSuaUserId IS NULL
    BEGIN
        SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM dbo.Users WHERE phone = @phone)
            SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);

        INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
        VALUES (N'Demo Tra Sua Merchant', @EmailMerTraSua, @phone, N'hash_demo', N'MERCHANT', N'ACTIVE');
        SET @MerTraSuaUserId = SCOPE_IDENTITY();
    END

    /* Merchant profiles (status must be PENDING/APPROVED/REJECTED/SUSPENDED) */
    IF NOT EXISTS (SELECT 1 FROM dbo.MerchantProfiles WHERE user_id = @MerBunBoUserId)
        INSERT INTO dbo.MerchantProfiles
        (user_id, shop_name, shop_phone, shop_address_line,
         province_code, province_name, district_code, district_name, ward_code, ward_name,
         latitude, longitude, status)
        VALUES
        (@MerBunBoUserId, N'Bún Bò Gia Truyền Demo', (SELECT phone FROM dbo.Users WHERE id=@MerBunBoUserId), N'12 Nguyễn Huệ',
         N'79', N'TP.HCM', N'760', N'Quận 1', N'26734', N'Bến Nghé',
         10.7765300, 106.7009800, N'APPROVED');

    IF NOT EXISTS (SELECT 1 FROM dbo.MerchantProfiles WHERE user_id = @MerTraSuaUserId)
        INSERT INTO dbo.MerchantProfiles
        (user_id, shop_name, shop_phone, shop_address_line,
         province_code, province_name, district_code, district_name, ward_code, ward_name,
         latitude, longitude, status)
        VALUES
        (@MerTraSuaUserId, N'Trà Sữa Tuyết Demo', (SELECT phone FROM dbo.Users WHERE id=@MerTraSuaUserId), N'34 Lê Lợi',
         N'79', N'TP.HCM', N'760', N'Quận 1', N'26737', N'Bến Thành',
         10.7721600, 106.6981700, N'APPROVED');

    /* Merchant wallets */
    IF NOT EXISTS (SELECT 1 FROM dbo.MerchantWallets WHERE merchant_user_id = @MerBunBoUserId)
        INSERT INTO dbo.MerchantWallets(merchant_user_id, balance) VALUES (@MerBunBoUserId, 0);
    IF NOT EXISTS (SELECT 1 FROM dbo.MerchantWallets WHERE merchant_user_id = @MerTraSuaUserId)
        INSERT INTO dbo.MerchantWallets(merchant_user_id, balance) VALUES (@MerTraSuaUserId, 0);


    /* Shippers */
    DECLARE @EmailShipPro NVARCHAR(200) = N'demo.shipper.pro@clickeat.vn';
    DECLARE @EmailShipNew NVARCHAR(200) = N'demo.shipper.new@clickeat.vn';

    DECLARE @ShipProId BIGINT = (SELECT id FROM dbo.Users WHERE email = @EmailShipPro);
    IF @ShipProId IS NULL
    BEGIN
        SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM dbo.Users WHERE phone = @phone)
            SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);

        INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
        VALUES (N'Demo Pro Shipper', @EmailShipPro, @phone, N'hash_demo', N'SHIPPER', N'ACTIVE');
        SET @ShipProId = SCOPE_IDENTITY();
    END

    DECLARE @ShipNewId BIGINT = (SELECT id FROM dbo.Users WHERE email = @EmailShipNew);
    IF @ShipNewId IS NULL
    BEGIN
        SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM dbo.Users WHERE phone = @phone)
            SET @phone = N'09' + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);

        INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
        VALUES (N'Demo New Shipper', @EmailShipNew, @phone, N'hash_demo', N'SHIPPER', N'ACTIVE');
        SET @ShipNewId = SCOPE_IDENTITY();
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.ShipperProfiles WHERE user_id = @ShipProId)
        INSERT INTO dbo.ShipperProfiles(user_id, vehicle_type, vehicle_name, license_plate, status)
        VALUES (@ShipProId, N'MOTORBIKE', N'Honda Vision', N'59D1-12345', N'ACTIVE');

    IF NOT EXISTS (SELECT 1 FROM dbo.ShipperProfiles WHERE user_id = @ShipNewId)
        INSERT INTO dbo.ShipperProfiles(user_id, vehicle_type, vehicle_name, license_plate, status)
        VALUES (@ShipNewId, N'MOTORBIKE', N'Wave Alpha', N'59X1-67890', N'ACTIVE');

    IF NOT EXISTS (SELECT 1 FROM dbo.ShipperWallets WHERE shipper_user_id = @ShipProId)
        INSERT INTO dbo.ShipperWallets(shipper_user_id, balance) VALUES (@ShipProId, 0);
    IF NOT EXISTS (SELECT 1 FROM dbo.ShipperWallets WHERE shipper_user_id = @ShipNewId)
        INSERT INTO dbo.ShipperWallets(shipper_user_id, balance) VALUES (@ShipNewId, 0);

    IF NOT EXISTS (SELECT 1 FROM dbo.ShipperAvailability WHERE shipper_user_id = @ShipProId)
        INSERT INTO dbo.ShipperAvailability(shipper_user_id, is_online, current_status, current_latitude, current_longitude)
        VALUES (@ShipProId, 1, N'AVAILABLE', 10.7760, 106.7010);


    /* =========================================================
       2) Catalog (Categories + FoodItems)
       ========================================================= */
    DECLARE @CatBunBoId BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @MerBunBoUserId AND name = N'Bún Bò');
    IF @CatBunBoId IS NULL
    BEGIN
        INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
        VALUES (@MerBunBoUserId, N'Bún Bò', 1, 1);
        SET @CatBunBoId = SCOPE_IDENTITY();
    END

    DECLARE @CatDrinkId BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @MerTraSuaUserId AND name = N'Đồ Uống');
    IF @CatDrinkId IS NULL
    BEGIN
        INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
        VALUES (@MerTraSuaUserId, N'Đồ Uống', 1, 1);
        SET @CatDrinkId = SCOPE_IDENTITY();
    END

    DECLARE @FiBunBoDacBietId BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE merchant_user_id=@MerBunBoUserId AND name=N'Bún bò đặc biệt');
    IF @FiBunBoDacBietId IS NULL
    BEGIN
        INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories, protein_g, carbs_g, fat_g)
        VALUES (@MerBunBoUserId, @CatBunBoId, N'Bún bò đặc biệt', N'Chả cua, gân, nạm', 75000, NULL, 1, 0, 620, 32, 78, 18);
        SET @FiBunBoDacBietId = SCOPE_IDENTITY();
    END

    DECLARE @FiTraSuaTcId BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE merchant_user_id=@MerTraSuaUserId AND name=N'Trà sữa trân châu');
    IF @FiTraSuaTcId IS NULL
    BEGIN
        INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories, protein_g, carbs_g, fat_g)
        VALUES (@MerTraSuaUserId, @CatDrinkId, N'Trà sữa trân châu', N'Đường 70%, đá 50%', 45000, NULL, 1, 0, 420, 8, 72, 10);
        SET @FiTraSuaTcId = SCOPE_IDENTITY();
    END


    /* =========================================================
       3) Voucher + usage
       ========================================================= */
    DECLARE @VoucherId BIGINT = (SELECT TOP 1 id FROM dbo.Vouchers WHERE merchant_user_id=@MerBunBoUserId AND code=N'DEMO15K');
    IF @VoucherId IS NULL
    BEGIN
        INSERT INTO dbo.Vouchers(merchant_user_id, code, title, description, discount_type, discount_value,
                                max_discount_amount, min_order_amount, start_at, end_at, max_uses_total, max_uses_per_user,
                                is_published, status)
        VALUES (@MerBunBoUserId, N'DEMO15K', N'Giảm 15K demo', N'Voucher demo 1 tuần', N'FIXED', 15000,
                NULL, 100000, DATEADD(DAY,-7,@now), DATEADD(DAY,7,@now), 200, 2,
                1, N'ACTIVE');
        SET @VoucherId = SCOPE_IDENTITY();
    END


    /* =========================================================
       4) Guest sessions + behavior events
       ========================================================= */
    DECLARE @Guest1 UNIQUEIDENTIFIER = (SELECT TOP 1 guest_id FROM dbo.GuestSessions WHERE contact_email = N'demo.guest1@clickeat.vn');
    IF @Guest1 IS NULL
    BEGIN
        INSERT INTO dbo.GuestSessions(contact_phone, contact_email, expires_at)
        VALUES (NULL, N'demo.guest1@clickeat.vn', DATEADD(DAY, 7, @now));
        SET @Guest1 = (SELECT guest_id FROM dbo.GuestSessions WHERE contact_email = N'demo.guest1@clickeat.vn');
    END

    -- a few realistic behavior events (both customer and guest)
    IF NOT EXISTS (SELECT 1 FROM dbo.UserBehaviorEvents WHERE customer_user_id=@CusStudentId AND event_type=N'SEARCH' AND keyword=N'trà sữa' AND created_at >= DATEADD(DAY,-7,@now))
        INSERT INTO dbo.UserBehaviorEvents(customer_user_id, guest_id, event_type, food_item_id, keyword, created_at)
        VALUES (@CusStudentId, NULL, N'SEARCH', NULL, N'trà sữa', DATEADD(DAY,-2,@now));

    IF NOT EXISTS (SELECT 1 FROM dbo.UserBehaviorEvents WHERE guest_id=@Guest1 AND event_type=N'VIEW_ITEM' AND food_item_id=@FiTraSuaTcId AND created_at >= DATEADD(DAY,-7,@now))
        INSERT INTO dbo.UserBehaviorEvents(customer_user_id, guest_id, event_type, food_item_id, keyword, created_at)
        VALUES (NULL, @Guest1, N'VIEW_ITEM', @FiTraSuaTcId, NULL, DATEADD(MINUTE,-30,@now));


    /* =========================================================
       5) Carts + CartItems (trigger enforces single merchant)
       ========================================================= */
    DECLARE @CartVip BIGINT = (SELECT TOP 1 id FROM dbo.Carts WHERE customer_user_id=@CusVipId AND status=N'ACTIVE');
    IF @CartVip IS NULL
    BEGIN
        INSERT INTO dbo.Carts(customer_user_id, guest_id, merchant_user_id, status)
        VALUES (@CusVipId, NULL, @MerBunBoUserId, N'ACTIVE');
        SET @CartVip = SCOPE_IDENTITY();
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.CartItems WHERE cart_id=@CartVip AND food_item_id=@FiBunBoDacBietId)
        INSERT INTO dbo.CartItems(cart_id, food_item_id, quantity, unit_price_snapshot, note)
        VALUES (@CartVip, @FiBunBoDacBietId, 1, 75000, NULL);


     /* =========================================================
         6) Orders in last 7 days (realistic distribution)
         - Use fixed order codes so the script is truly idempotent.
         ========================================================= */
     DECLARE @OrderCode1 NVARCHAR(30) = N'DEMO1W_VIP_001';

     DECLARE @Order1Id BIGINT = NULL;
     IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE order_code = @OrderCode1)
    BEGIN
        INSERT INTO dbo.Orders(
            order_code, customer_user_id, guest_id, merchant_user_id, shipper_user_id,
            receiver_name, receiver_phone, delivery_address_line,
            province_code, province_name, district_code, district_name, ward_code, ward_name,
            latitude, longitude, delivery_note,
            payment_method, payment_status, order_status, expires_at,
            subtotal_amount, delivery_fee, discount_amount, total_amount,
            accepted_at, ready_at, picked_up_at, delivered_at
        )
        VALUES (
            @OrderCode1, @CusVipId, NULL, @MerBunBoUserId, @ShipProId,
            N'Nguyễn Demo VIP', (SELECT phone FROM dbo.Users WHERE id=@CusVipId), N'12 Nguyễn Huệ',
            N'79', N'TP.HCM', N'760', N'Quận 1', N'26734', N'Bến Nghé',
            10.77653, 106.70098, N'Gọi trước 5 phút',
            N'VNPAY', N'PAID', N'DELIVERED', NULL,
            150000, 15000, 15000, 150000,
            DATEADD(DAY,-6,DATEADD(HOUR,4,@now)), DATEADD(DAY,-6,DATEADD(HOUR,4,@now)), DATEADD(DAY,-6,DATEADD(HOUR,4,@now)), DATEADD(DAY,-6,DATEADD(HOUR,5,@now))
        );
        SET @Order1Id = SCOPE_IDENTITY();

        INSERT INTO dbo.OrderItems(order_id, food_item_id, item_name_snapshot, unit_price_snapshot, quantity, note)
        VALUES (@Order1Id, @FiBunBoDacBietId, N'Bún bò đặc biệt', 75000, 2, NULL);

        INSERT INTO dbo.OrderStatusHistory(order_id, from_status, to_status, updated_by_role, updated_by_user_id, note, created_at)
        VALUES
            (@Order1Id, NULL, N'CREATED', N'CUSTOMER', @CusVipId, NULL, DATEADD(DAY,-6,@now)),
            (@Order1Id, N'CREATED', N'MERCHANT_ACCEPTED', N'MERCHANT', @MerBunBoUserId, NULL, DATEADD(DAY,-6,DATEADD(MINUTE,5,@now))),
            (@Order1Id, N'MERCHANT_ACCEPTED', N'DELIVERED', N'SHIPPER', @ShipProId, NULL, DATEADD(DAY,-6,DATEADD(HOUR,1,@now)));

        IF NOT EXISTS (SELECT 1 FROM dbo.VoucherUsages WHERE order_id=@Order1Id)
            INSERT INTO dbo.VoucherUsages(voucher_id, order_id, customer_user_id, guest_id)
            VALUES (@VoucherId, @Order1Id, @CusVipId, NULL);

        IF NOT EXISTS (SELECT 1 FROM dbo.PaymentTransactions WHERE order_id=@Order1Id)
            INSERT INTO dbo.PaymentTransactions(order_id, provider, amount, status, provider_txn_ref, vnp_txn_ref, vnp_transaction_no, vnp_response_code, vnp_pay_date)
            VALUES (@Order1Id, N'VNPAY', 150000, N'SUCCESS', N'DEMO-TXN-1', @OrderCode1, NULL, N'00', CONVERT(NVARCHAR(50), @now, 112));

        -- One rating for merchant + one for shipper (unique (order_id,target_type))
        IF NOT EXISTS (SELECT 1 FROM dbo.Ratings WHERE order_id=@Order1Id AND target_type=N'MERCHANT')
            INSERT INTO dbo.Ratings(order_id, rater_customer_id, rater_guest_id, target_type, target_user_id, stars, comment)
            VALUES (@Order1Id, @CusVipId, NULL, N'MERCHANT', @MerBunBoUserId, 5, N'Ngon, chuẩn vị.');

        IF NOT EXISTS (SELECT 1 FROM dbo.Ratings WHERE order_id=@Order1Id AND target_type=N'SHIPPER')
            INSERT INTO dbo.Ratings(order_id, rater_customer_id, rater_guest_id, target_type, target_user_id, stars, comment)
            VALUES (@Order1Id, @CusVipId, NULL, N'SHIPPER', @ShipProId, 5, N'Giao nhanh, thân thiện.');

        -- Notification
        INSERT INTO dbo.Notifications(user_id, guest_id, type, content, is_read)
        VALUES (@CusVipId, NULL, N'ORDER_CONFIRMED', N'Đơn ' + @OrderCode1 + N' đã được xác nhận.', 1);

        -- Chat history (Messages)
        IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE sender_id=@MerBunBoUserId AND receiver_id=@CusVipId AND created_at >= DATEADD(DAY,-7,@now))
            INSERT INTO dbo.Messages(sender_id, receiver_id, content, is_read, created_at)
            VALUES (@MerBunBoUserId, @CusVipId, N'Chào bạn, quán đang đông, giao trong 35-45 phút nhé.', 1, DATEADD(DAY,-6,DATEADD(MINUTE,2,@now)));
    END

    /* Complaint case: delivered then refund */
    DECLARE @OrderCode2 NVARCHAR(30) = N'DEMO1W_COMPLAINT_001';
    DECLARE @Order2Id BIGINT = NULL;

    INSERT INTO dbo.Orders(
        order_code, customer_user_id, guest_id, merchant_user_id, shipper_user_id,
        receiver_name, receiver_phone, delivery_address_line,
        province_code, province_name, district_code, district_name, ward_code, ward_name,
        payment_method, payment_status, order_status,
        subtotal_amount, delivery_fee, discount_amount, total_amount,
        accepted_at, delivered_at
    )
    SELECT
        @OrderCode2, @CusComplaintId, NULL, @MerBunBoUserId, @ShipProId,
        N'Lê Demo Khiếu Nại', (SELECT phone FROM dbo.Users WHERE id=@CusComplaintId), N'34 Lê Lợi',
        N'79', N'TP.HCM', N'760', N'Quận 1', N'26737', N'Bến Thành',
        N'VNPAY', N'PAID', N'DELIVERED',
        75000, 15000, 0, 90000,
        DATEADD(DAY,-1,DATEADD(HOUR,1,@now)), DATEADD(DAY,-1,DATEADD(HOUR,2,@now))
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE order_code=@OrderCode2);

    SET @Order2Id = (SELECT id FROM dbo.Orders WHERE order_code=@OrderCode2);

    IF @Order2Id IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.OrderItems WHERE order_id=@Order2Id)
            INSERT INTO dbo.OrderItems(order_id, food_item_id, item_name_snapshot, unit_price_snapshot, quantity, note)
            VALUES (@Order2Id, @FiBunBoDacBietId, N'Bún bò đặc biệt', 75000, 1, N'Ít cay');

        -- Order issue (schema: reporter_user_id, description, status)
        IF NOT EXISTS (SELECT 1 FROM dbo.OrderIssues WHERE order_id=@Order2Id)
            INSERT INTO dbo.OrderIssues(order_id, reporter_user_id, issue_type, description, status, created_at)
            VALUES (@Order2Id, @CusComplaintId, 'FOOD_QUALITY', N'Món bị nguội và thiếu rau.', 'PENDING', DATEADD(DAY,-1,DATEADD(HOUR,3,@now)));

        -- Appeal (schema is simple: user_id, reason, status, admin_note, resolved_at)
        IF NOT EXISTS (SELECT 1 FROM dbo.UserAppeals WHERE user_id=@CusComplaintId AND created_at >= DATEADD(DAY,-7,@now))
            INSERT INTO dbo.UserAppeals(user_id, reason, status, admin_note, resolved_at)
            VALUES (@CusComplaintId, N'Khiếu nại chất lượng món của đơn ' + @OrderCode2, N'APPROVED', N'Xác minh hợp lệ, tiến hành hoàn tiền.', DATEADD(DAY,-1,DATEADD(HOUR,6,@now)));

        -- Refund request
        IF NOT EXISTS (SELECT 1 FROM dbo.RefundRequests WHERE order_id=@Order2Id)
            INSERT INTO dbo.RefundRequests(order_id, merchant_user_id, refund_amount, reason, status, created_at)
            VALUES (@Order2Id, @MerBunBoUserId, 90000, N'Hoàn tiền theo khiếu nại', N'COMPLETED', DATEADD(DAY,-1,DATEADD(HOUR,6,@now)));

        -- Mark payment as refunded (optional)
        IF NOT EXISTS (SELECT 1 FROM dbo.PaymentTransactions WHERE order_id=@Order2Id)
            INSERT INTO dbo.PaymentTransactions(order_id, provider, amount, status, provider_txn_ref, vnp_txn_ref, vnp_response_code)
            VALUES (@Order2Id, N'VNPAY', 90000, N'REFUNDED', N'DEMO-TXN-2', @OrderCode2, N'00');

        UPDATE dbo.Orders
        SET payment_status = N'REFUNDED', order_status = N'REFUNDED'
        WHERE id = @Order2Id;

        INSERT INTO dbo.OrderStatusHistory(order_id, from_status, to_status, updated_by_role, updated_by_user_id, note, created_at)
        SELECT @Order2Id, N'DELIVERED', N'REFUNDED', N'ADMIN', @AdminId, N'Hoàn tiền theo khiếu nại', DATEADD(DAY,-1,DATEADD(HOUR,6,@now))
        WHERE NOT EXISTS (SELECT 1 FROM dbo.OrderStatusHistory WHERE order_id=@Order2Id AND to_status=N'REFUNDED');
    END


    /* =========================================================
       7) AI chat + auto cart proposal (only if AI feature is demoed)
       ========================================================= */
    DECLARE @ConvId BIGINT = (SELECT TOP 1 id FROM dbo.AIConversations WHERE customer_user_id=@CusStudentId ORDER BY id DESC);
    IF @ConvId IS NULL
    BEGIN
        INSERT INTO dbo.AIConversations(customer_user_id) VALUES (@CusStudentId);
        SET @ConvId = SCOPE_IDENTITY();

        INSERT INTO dbo.AIMessages(conversation_id, role, content)
        VALUES
            (@ConvId, N'USER', N'Mình có 50k, gợi ý đồ uống gần mình.'),
            (@ConvId, N'ASSISTANT', N'Bạn thử Trà sữa trân châu 45k, đang bán chạy.');
    END

    DECLARE @ProposalId BIGINT = (SELECT TOP 1 id FROM dbo.AutoCartProposals WHERE customer_user_id=@CusStudentId AND merchant_user_id=@MerTraSuaUserId ORDER BY id DESC);
    IF @ProposalId IS NULL
    BEGIN
        INSERT INTO dbo.AutoCartProposals(customer_user_id, merchant_user_id, conversation_id, status, expires_at)
        VALUES (@CusStudentId, @MerTraSuaUserId, @ConvId, N'PROPOSED', DATEADD(MINUTE, 30, @now));
        SET @ProposalId = SCOPE_IDENTITY();
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.AutoCartProposalItems WHERE proposal_id=@ProposalId AND food_item_id=@FiTraSuaTcId)
        INSERT INTO dbo.AutoCartProposalItems(proposal_id, food_item_id, quantity, unit_price)
        VALUES (@ProposalId, @FiTraSuaTcId, 1, 45000);


    /* =========================================================
       8) Withdrawals (merchant + shipper)
       ========================================================= */
    IF NOT EXISTS (SELECT 1 FROM dbo.MerchantWithdrawals WHERE merchant_user_id=@MerBunBoUserId AND created_at >= DATEADD(DAY,-7,@now))
        INSERT INTO dbo.MerchantWithdrawals(merchant_user_id, amount, bank_name, bank_account_number, status, created_at)
        VALUES (@MerBunBoUserId, 500000, N'Vietcombank', N'001122334455', N'PENDING', DATEADD(DAY,-2,@now));

    IF NOT EXISTS (SELECT 1 FROM dbo.WithdrawalRequests WHERE shipper_user_id=@ShipProId AND created_at >= DATEADD(DAY,-7,@now))
        INSERT INTO dbo.WithdrawalRequests(shipper_user_id, amount, bank_name, bank_account_number, status, created_at, processed_at)
        VALUES (@ShipProId, 300000, N'Techcombank', N'88990011', N'COMPLETED', DATEADD(DAY,-1,@now), DATEADD(DAY,-1,DATEADD(HOUR,1,@now)));


    COMMIT TRAN;
    PRINT N'✅ Seed demo 1 tuần thành công (idempotent).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;

    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @Line INT = ERROR_LINE();

    PRINT N'❌ Seed thất bại tại dòng: ' + CAST(@Line AS NVARCHAR(20));
    PRINT @Err;

    THROW;
END CATCH;
GO
