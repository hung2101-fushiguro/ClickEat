/* Merchant checklist patch
   - Add missing merchant/catalog columns used by UI
   - Add/ensure performance indexes for merchant dashboard filters
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'min_order_amount')
BEGIN
    ALTER TABLE dbo.MerchantProfiles ADD min_order_amount DECIMAL(18,2) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'is_open')
BEGIN
    ALTER TABLE dbo.MerchantProfiles ADD is_open BIT NOT NULL CONSTRAINT DF_MerchantProfiles_IsOpen DEFAULT 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'rejection_reason')
BEGIN
    ALTER TABLE dbo.MerchantProfiles ADD rejection_reason NVARCHAR(255) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.FoodItems') AND name = 'out_of_stock_reason')
BEGIN
    ALTER TABLE dbo.FoodItems ADD out_of_stock_reason NVARCHAR(255) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Orders_Merchant_Status' AND object_id = OBJECT_ID(N'dbo.Orders')
)
BEGIN
    CREATE INDEX IX_Orders_Merchant_Status ON dbo.Orders(merchant_user_id, order_status, created_at);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Ratings_Target_Created' AND object_id = OBJECT_ID(N'dbo.Ratings')
)
BEGIN
    CREATE INDEX IX_Ratings_Target_Created ON dbo.Ratings(target_user_id, created_at);
END
GO

/* Verify demo voucher DEMO15K */
SELECT TOP 1 id, merchant_user_id, code, title, status, is_published, start_at, end_at
FROM dbo.Vouchers
WHERE code = N'DEMO15K';
GO
