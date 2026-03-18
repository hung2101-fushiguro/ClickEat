/* =========================================================
   CLICKEAT - PATCH: MISSING & INCOMPLETE TABLES
   Chạy file này SAU khi đã chạy ClickEat2.sql để bổ sung
   các bảng còn thiếu và sửa lỗi thứ tự tạo bảng.
   ========================================================= */

USE ClickEat;
GO

/* =========================
   1) Messages (Merchant–Customer Chat)
   Bảng này bị thiếu hoàn toàn trong ClickEat2.sql nhưng
   MessageDAO.java đang truy vấn trực tiếp vào nó.
   ========================= */
IF OBJECT_ID('dbo.Messages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Messages (
        id          BIGINT IDENTITY(1,1) PRIMARY KEY,
        sender_id   BIGINT        NOT NULL,
        receiver_id BIGINT        NOT NULL,
        content     NVARCHAR(MAX) NOT NULL,
        is_read     BIT           NOT NULL CONSTRAINT DF_Messages_IsRead DEFAULT 0,
        created_at  DATETIME2     NOT NULL CONSTRAINT DF_Messages_Created DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Messages_Sender   FOREIGN KEY (sender_id)   REFERENCES dbo.Users(id),
        CONSTRAINT FK_Messages_Receiver FOREIGN KEY (receiver_id) REFERENCES dbo.Users(id)
    );
    CREATE INDEX IX_Messages_Pair ON dbo.Messages(sender_id, receiver_id, created_at);
    PRINT N'✅ Tạo bảng Messages thành công.';
END
ELSE
    PRINT N'ℹ️  Bảng Messages đã tồn tại.';
GO

/* =========================
   2) MerchantWallets (Fix thứ tự trong ClickEat2.sql)
   Trong ClickEat2.sql, bảng này được tạo TRƯỚC MerchantProfiles
   nên sẽ lỗi FK nếu chạy lại từ đầu trên DB trống.
   ========================= */
IF OBJECT_ID('dbo.MerchantWallets', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MerchantWallets (
        merchant_user_id BIGINT        NOT NULL PRIMARY KEY,
        balance          DECIMAL(18,2) NOT NULL CONSTRAINT DF_MerchantWallets_Balance DEFAULT 0,
        updated_at       DATETIME2     NOT NULL CONSTRAINT DF_MerchantWallets_Updated DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_MerchantWallets_Merchant FOREIGN KEY (merchant_user_id)
            REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
    );
    PRINT N'✅ Tạo bảng MerchantWallets thành công.';
END
ELSE
    PRINT N'ℹ️  Bảng MerchantWallets đã tồn tại.';
GO

/* =========================
   3) MerchantWithdrawals (tương tự)
   ========================= */
IF OBJECT_ID('dbo.MerchantWithdrawals', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MerchantWithdrawals (
        id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
        merchant_user_id    BIGINT        NOT NULL,
        amount              DECIMAL(18,2) NOT NULL,
        bank_name           NVARCHAR(100) NULL,
        bank_account_number NVARCHAR(50)  NULL,
        status              NVARCHAR(20)  NOT NULL CONSTRAINT DF_MerchantWithdrawals_Status DEFAULT 'PENDING',
        created_at          DATETIME2     NOT NULL CONSTRAINT DF_MerchantWithdrawals_Created DEFAULT SYSUTCDATETIME(),
        processed_at        DATETIME2     NULL,
        CONSTRAINT FK_MerchantWithdrawals_Merchant FOREIGN KEY (merchant_user_id)
            REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
    );
    PRINT N'✅ Tạo bảng MerchantWithdrawals thành công.';
END
ELSE
    PRINT N'ℹ️  Bảng MerchantWithdrawals đã tồn tại.';
GO

/* =========================
   4) RefundRequests (có thể thiếu nếu ClickEat2.sql chạy lỗi bước đầu)
   ========================= */
IF OBJECT_ID('dbo.RefundRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RefundRequests (
        id               BIGINT IDENTITY(1,1) PRIMARY KEY,
        order_id         BIGINT        NOT NULL,
        merchant_user_id BIGINT        NOT NULL,
        refund_amount    DECIMAL(18,2) NOT NULL,
        reason           NVARCHAR(255) NOT NULL,
        status           NVARCHAR(20)  NOT NULL CONSTRAINT DF_RefundRequests_Status DEFAULT 'COMPLETED',
        created_at       DATETIME2     NOT NULL CONSTRAINT DF_RefundRequests_Created DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_RefundRequests_Order    FOREIGN KEY (order_id)         REFERENCES dbo.Orders(id),
        CONSTRAINT FK_RefundRequests_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id)
    );
    PRINT N'✅ Tạo bảng RefundRequests thành công.';
END
ELSE
    PRINT N'ℹ️  Bảng RefundRequests đã tồn tại.';
GO

/* =========================
   5) Seed dữ liệu MerchantWallets cho các merchant đã tồn tại
   (Chạy lại an toàn - chỉ insert nếu chưa có)
   ========================= */
INSERT INTO dbo.MerchantWallets (merchant_user_id, balance)
SELECT user_id, 0
FROM dbo.MerchantProfiles
WHERE user_id NOT IN (SELECT merchant_user_id FROM dbo.MerchantWallets);
PRINT N'✅ Đã bổ sung MerchantWallets cho merchant chưa có ví.';
GO

/* =========================
   6) reply_comment column trong Ratings (nếu chưa có)
   ========================= */
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Ratings') AND name = 'reply_comment'
)
BEGIN
    ALTER TABLE dbo.Ratings ADD reply_comment NVARCHAR(MAX) NULL;
    PRINT N'✅ Đã thêm cột reply_comment vào Ratings.';
END
ELSE
    PRINT N'ℹ️  Cột reply_comment đã tồn tại.';
GO

/* =========================
   7) Các cột bổ sung cho MerchantProfiles (nếu chưa có)
   ========================= */
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'business_hours')
    ALTER TABLE dbo.MerchantProfiles ADD business_hours NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'shop_avatar')
    ALTER TABLE dbo.MerchantProfiles ADD shop_avatar NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'shop_description')
    ALTER TABLE dbo.MerchantProfiles ADD shop_description NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'notification_settings')
    ALTER TABLE dbo.MerchantProfiles ADD notification_settings NVARCHAR(MAX) NULL;
PRINT N'✅ Kiểm tra và bổ sung cột MerchantProfiles hoàn tất.';
GO

PRINT N'';
PRINT N'✅ Patch hoàn tất. Tất cả các bảng thiếu đã được tạo/kiểm tra.';
GO
