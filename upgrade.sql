/* =========================================
   ClickEat Upgrade: Customer Vouchers & Metadata
   ========================================= */

-- 1) MerchantProfiles: Thêm image_url để hỗ trợ ảnh đại diện cửa hàng riêng biệt
IF COL_LENGTH('dbo.MerchantProfiles', 'image_url') IS NULL
BEGIN
    ALTER TABLE dbo.MerchantProfiles
    ADD image_url NVARCHAR(500) NULL;
END
GO

-- 2) Orders: Liên kết đơn hàng với voucher đã áp dụng
IF COL_LENGTH('dbo.Orders', 'voucher_id') IS NULL
BEGIN
    ALTER TABLE dbo.Orders
    ADD voucher_id BIGINT NULL;

    ALTER TABLE dbo.Orders
    ADD CONSTRAINT FK_Orders_Voucher
        FOREIGN KEY (voucher_id) REFERENCES dbo.Vouchers(id);
END
GO

-- 3) CustomerVouchers: Bảng lưu trữ voucher khách hàng đã "thu thập"
IF OBJECT_ID('dbo.CustomerVouchers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CustomerVouchers (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        customer_user_id BIGINT NOT NULL,
        voucher_id BIGINT NOT NULL,
        saved_code NVARCHAR(50) NOT NULL,
        status NVARCHAR(20) NOT NULL CONSTRAINT DF_CustomerVouchers_Status DEFAULT N'SAVED',
        saved_at DATETIME2 NOT NULL CONSTRAINT DF_CustomerVouchers_SavedAt DEFAULT SYSUTCDATETIME(),
        used_at DATETIME2 NULL,

        CONSTRAINT FK_CustomerVouchers_Customer
            FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id),

        CONSTRAINT FK_CustomerVouchers_Voucher
            FOREIGN KEY (voucher_id) REFERENCES dbo.Vouchers(id)
    );

    ALTER TABLE dbo.CustomerVouchers
    ADD CONSTRAINT CK_CustomerVouchers_Status
    CHECK (status IN (N'SAVED', N'USED', N'EXPIRED'));

    CREATE UNIQUE INDEX UX_CustomerVouchers_CustomerVoucher
    ON dbo.CustomerVouchers(customer_user_id, voucher_id);
END
GO

-- 4) VoucherUsages: Hỗ trợ guest_id để theo dõi lượt dùng của khách vãng lai
IF COL_LENGTH('dbo.VoucherUsages', 'guest_id') IS NULL
BEGIN
    ALTER TABLE dbo.VoucherUsages
    ADD guest_id UNIQUEIDENTIFIER NULL;

    ALTER TABLE dbo.VoucherUsages
    ADD CONSTRAINT FK_VoucherUsages_Guest
        FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id);
END
GO

PRINT N'ClickEat SQL Upgrade completed successfully.';
