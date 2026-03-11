-- ============================================================
-- ClickEat2 – Addons (DO NOT overwrite ClickEat2.sql)
-- Run this ONCE after ClickEat2.sql has been applied
-- ============================================================

-- Feature 1: Mở/Đóng nhận đơn (shop open/close toggle)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='MerchantProfiles' AND COLUMN_NAME='is_accepting_orders'
)
ALTER TABLE dbo.MerchantProfiles
    ADD is_accepting_orders BIT NOT NULL DEFAULT 1;

-- Feature 3: Lý do từ chối / huỷ đơn
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='Orders' AND COLUMN_NAME='cancel_reason'
)
ALTER TABLE dbo.Orders
    ADD cancel_reason NVARCHAR(200) NULL;

-- Feature 5: Thời gian chuẩn bị ước tính (phút)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='Orders' AND COLUMN_NAME='estimated_prep_minutes'
)
ALTER TABLE dbo.Orders
    ADD estimated_prep_minutes INT NULL;

-- P0: Reviews reply (merchant trả lời đánh giá)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='Ratings' AND COLUMN_NAME='reply'
)
ALTER TABLE dbo.Ratings
    ADD reply NVARCHAR(1000) NULL;

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='Ratings' AND COLUMN_NAME='replied_at'
)
ALTER TABLE dbo.Ratings
    ADD replied_at DATETIME NULL;

-- P0: Business hours (giờ hoạt động cửa hàng)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='MerchantProfiles' AND COLUMN_NAME='business_hours'
)
ALTER TABLE dbo.MerchantProfiles
    ADD business_hours NVARCHAR(500) NULL;

-- P0: Shop avatar (ảnh đại diện cửa hàng, base64)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME='MerchantProfiles' AND COLUMN_NAME='shop_avatar'
)
ALTER TABLE dbo.MerchantProfiles
    ADD shop_avatar NVARCHAR(MAX) NULL;
