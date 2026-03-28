-- ===========================================
-- SEED DATA CRAWLED FROM SHOPEEFOOD
-- ===========================================
USE ClickEat;
GO

BEGIN TRY
    BEGIN TRAN;

    -- Merchant Bánh Xèo Bà Dưỡng
    INSERT INTO dbo.Users(full_name, email, phone, password_hash, role, status)
    VALUES(N'Bánh Xèo Bà Dưỡng', N'merchant1000@shopeefood.vn', N'09001000', N'hash_pwd', N'MERCHANT', N'ACTIVE');

    DECLARE @m1000 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.MerchantProfiles(user_id, shop_name, shop_phone, shop_address_line, province_code, province_name, district_code, district_name, ward_code, ward_name, status, image_url)
    VALUES(@m1000, N'Bánh Xèo Bà Dưỡng', N'09001000', N'K280/23 Hoàng Diệu, Quận Hải Châu, Đà Nẵng', N'48', N'Đà Nẵng', N'000', N'Quận', N'000', N'Phường', N'APPROVED', N'https://mms.img.susercontent.com/vn-11134513-7r98o-lstq1bohfg7831@resize_ss640x400!@crop_w640_h400_cT');

    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES(@m1000, N'ĐẶC SẢN BÀ DƯỠNG', 1, 1);
    DECLARE @cat_m1000_1 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_1, N'Nem lụi', N'1 cây/Roll Chung Tay Giảm Chất Thải Nhựa Môi Trường. Quý Khách Hàng Cần Chén Đũa Nhựa Vui Lòng Note Vào Ghi Chú Cho Shipper. Chén Nhựa, Đũa Miễn Phí. Tô Nhựa Vui Lòng Oder Riêng.', 8500, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr2r4j6qgbkpd2', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_1, N'Bánh xèo/Cái/ 1 Pancake', N'1 cái Chung Tay Giảm Chất Thải Nhựa Môi Trường. Quý Khách Hàng Cần Chén Đũa Nhựa Vui Lòng Note Vào Ghi Chú Cho Shipper. Chén Nhựa, Đũa Miễn Phí. Tô Nhựa Vui Lòng Oder Riêng.', 24000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr2r4i0k61eh45', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_1, N'Bánh xèo/Dĩa( 4 Bánh)/ 1Plate= 4Pancake', N'Dĩa 4 cái / Dish Chung Tay Giảm Chất Thải Nhựa Môi Trường. Quý Khách Hàng Cần Chén Đũa Nhựa Vui Lòng Note Vào Ghi Chú Cho Shipper. Chén Nhựa, Đũa Miễn Phí. Tô Nhựa Vui Lòng Oder Riêng.', 94000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr2r4im7ad9537', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_1, N'Bún thịt nướng', N'Khách hàng cần tô nhựa. Vui lòng order riêng.', 40000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr2r5mv4e1spae', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_1, N'Tô Nhựa', N'', 2000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr35ii0x2a4kf4', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_1, N'Thịt bò nướng lá lốt', N'Dĩa / dish Chung Tay Giảm Chất Thải Nhựa Môi Trường. Quý Khách Hàng Cần Chén Đũa Nhựa Vui Lòng Note Vào Ghi Chú Cho Shipper. Chén Nhựa, Đũa Miễn Phí. Tô Nhựa Vui Lòng Oder Riêng.', 106000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr2r5m83br15ee', 1, 0, 500);

    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES(@m1000, N'DỤNG CỤ ĂN UỐNG (DINING UTENSILS)', 1, 2);
    DECLARE @cat_m1000_2 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_2, N'Chén Nhựa + Đũa (Plastic Bowl)', N'', 1, N'https://down-tx-vn.img.susercontent.com/vn-11134517-820l4-mgg0ykxbcwsqaf', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_2, N'Tô Nhựa(plastic bowl)', N'', 2000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-820l4-mefrho0pdds3d6', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_2, N'Ly Nhựa (Plastic Cups)', N'', 1, N'https://down-tx-vn.img.susercontent.com/vn-11134517-820l4-mgg1619m17uz30', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_2, N'Dĩa Nhựa Lớn-Plastic Plate', N'', 3000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-820l4-mi9s14boac5de3', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_2, N'Khăn Lạnh(wet wipe)', N'', 4000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-820l4-mefrkf1mzxttf5', 1, 0, 500);

    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES(@m1000, N'ĐỒ UỐNG( SỮA)', 1, 3);
    DECLARE @cat_m1000_3 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_3, N'Sữa bắp', N'', 16000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lqvtmngeparo41', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_3, N'Sữa Hạt Sen', N'', 16000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr5hhvbf0gxwbc', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_3, N'Nước Nha Đam', N'', 16000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr5hhxljoa6x65', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1000, @cat_m1000_3, N'Sữa Chua', N'', 16000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7r98o-lr5hhwi59xvoeb', 1, 0, 500);

    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES(@m1000, N'ĐỒ UỐNG (BIA)', 1, 4);
    DECLARE @cat_m1000_4 BIGINT = SCOPE_IDENTITY();


    -- Merchant Chè Xuân Trang - Lê Duẩn
    INSERT INTO dbo.Users(full_name, email, phone, password_hash, role, status)
    VALUES(N'Chè Xuân Trang - Lê Duẩn', N'merchant1001@shopeefood.vn', N'09001001', N'hash_pwd', N'MERCHANT', N'ACTIVE');

    DECLARE @m1001 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.MerchantProfiles(user_id, shop_name, shop_phone, shop_address_line, province_code, province_name, district_code, district_name, ward_code, ward_name, status, image_url)
    VALUES(@m1001, N'Chè Xuân Trang - Lê Duẩn', N'09001001', N'31 Lê Duẩn, Quận Hải Châu, Đà Nẵng', N'48', N'Đà Nẵng', N'000', N'Quận', N'000', N'Phường', N'APPROVED', N'https://down-tx-vn.img.susercontent.com/vn-11134513-7r98o-lstq69o8ygm138@resize_ss640x400!@crop_w640_h400_cT');

    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES(@m1001, N'Món Chính', 1, 1);
    DECLARE @cat_m1001_1 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1001, @cat_m1001_1, N'Tàu Hủ Singapore', N'', 25000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-820l4-mi328hwi8mwwff', 1, 0, 500);

    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES(@m1001, N'CÁC LOẠI RAU CÂU', 1, 2);
    DECLARE @cat_m1001_2 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1001, @cat_m1001_2, N'Rau Câu Dừa', N'', 20000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7ras8-malj2ubdaegxcd', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1001, @cat_m1001_2, N'Rau Câu Cacao', N'', 20000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7ras8-malj38xpuspj9d', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1001, @cat_m1001_2, N'Rau Câu Phomai', N'', 20000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7ras8-malj3u9qmw9kb9', 1, 0, 500);
    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1001, @cat_m1001_2, N'Rau Câu Trái Dừa', N'', 45000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7ras8-malj4vnzwt7cd1', 1, 0, 500);

    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES(@m1001, N'MÓN MẶN', 1, 3);
    DECLARE @cat_m1001_3 BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.FoodItems(merchant_user_id, category_id, name, description, price, image_url, is_available, is_fried, calories)
    VALUES(@m1001, @cat_m1001_3, N'Gỏi Bò Khô Gan Rim', N'', 32000, N'https://down-tx-vn.img.susercontent.com/vn-11134517-7ras8-malj5g30180o78', 1, 0, 500);

    COMMIT TRAN;
    PRINT N'ShopeeFood Crawled Data Seeded successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT N'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
