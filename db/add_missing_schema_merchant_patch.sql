/* =========================================================
   ClickEat - Add missing schema patch (merchant runtime)
   Safe to run multiple times (idempotent)
   SQL Server
   ========================================================= */

SET NOCOUNT ON;
GO

/* 0) MerchantProfiles: add missing merchant settings columns */
IF OBJECT_ID(N'dbo.MerchantProfiles', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH(N'dbo.MerchantProfiles', N'shop_avatar') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD shop_avatar NVARCHAR(500) NULL;
    END

    IF COL_LENGTH(N'dbo.MerchantProfiles', N'business_hours') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD business_hours NVARCHAR(MAX) NULL;
    END

    IF COL_LENGTH(N'dbo.MerchantProfiles', N'notification_settings') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD notification_settings NVARCHAR(MAX) NULL;
    END

    IF COL_LENGTH(N'dbo.MerchantProfiles', N'min_order_amount') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD min_order_amount DECIMAL(18,2) NULL;
    END

    IF COL_LENGTH(N'dbo.MerchantProfiles', N'is_open') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD is_open BIT NULL
            CONSTRAINT DF_MerchantProfiles_IsOpen DEFAULT (1);
    END

    IF COL_LENGTH(N'dbo.MerchantProfiles', N'rejection_reason') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD rejection_reason NVARCHAR(500) NULL;
    END

    IF COL_LENGTH(N'dbo.MerchantProfiles', N'shop_description') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD shop_description NVARCHAR(1000) NULL;
    END

    IF COL_LENGTH(N'dbo.MerchantProfiles', N'source_platform') IS NULL
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD source_platform NVARCHAR(20) NULL;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = N'CK_MerchantProfiles_SourcePlatform'
          AND parent_object_id = OBJECT_ID(N'dbo.MerchantProfiles')
    )
    BEGIN
        ALTER TABLE dbo.MerchantProfiles
        ADD CONSTRAINT CK_MerchantProfiles_SourcePlatform
            CHECK (source_platform IS NULL OR source_platform IN (N'NONE', N'GRABFOOD', N'SHOPEEFOOD', N'OTHER'));
    END
END
GO

/* 1) FoodItems: add out_of_stock_reason if missing */
IF OBJECT_ID(N'dbo.FoodItems', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.FoodItems', N'out_of_stock_reason') IS NULL
BEGIN
    ALTER TABLE dbo.FoodItems
    ADD out_of_stock_reason NVARCHAR(255) NULL;
END
GO

/* 2) Orders: add app_fee if missing */
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.Orders', N'app_fee') IS NULL
BEGIN
    ALTER TABLE dbo.Orders
    ADD app_fee DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Orders_AppFee DEFAULT (0);
END
GO

/* 3) Messages table (merchant/customer chat) */
IF OBJECT_ID(N'dbo.Messages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Messages (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        sender_id BIGINT NOT NULL,
        receiver_id BIGINT NOT NULL,
        content NVARCHAR(2000) NOT NULL,
        is_read BIT NOT NULL CONSTRAINT DF_Messages_IsRead DEFAULT (0),
        created_at DATETIME2 NOT NULL CONSTRAINT DF_Messages_Created DEFAULT SYSUTCDATETIME(),

        CONSTRAINT FK_Messages_Sender FOREIGN KEY (sender_id) REFERENCES dbo.Users(id),
        CONSTRAINT FK_Messages_Receiver FOREIGN KEY (receiver_id) REFERENCES dbo.Users(id)
    );

    CREATE INDEX IX_Messages_SenderReceiverCreated
        ON dbo.Messages(sender_id, receiver_id, created_at DESC);

    CREATE INDEX IX_Messages_ReceiverCreated
        ON dbo.Messages(receiver_id, created_at DESC);
END
GO

/* 4) MerchantWallets table */
IF OBJECT_ID(N'dbo.MerchantWallets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MerchantWallets (
        merchant_user_id BIGINT NOT NULL PRIMARY KEY,
        balance DECIMAL(18,2) NOT NULL CONSTRAINT DF_MerchantWallets_Balance DEFAULT (0),
        updated_at DATETIME2 NOT NULL CONSTRAINT DF_MerchantWallets_Updated DEFAULT SYSUTCDATETIME(),

        CONSTRAINT FK_MerchantWallets_Merchant
            FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
    );
END
GO

/* 5) MerchantWithdrawals table */
IF OBJECT_ID(N'dbo.MerchantWithdrawals', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MerchantWithdrawals (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        merchant_user_id BIGINT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        bank_name NVARCHAR(100) NULL,
        bank_account_number NVARCHAR(50) NULL,
        status NVARCHAR(20) NOT NULL CONSTRAINT DF_MerchantWithdrawals_Status DEFAULT (N'PENDING'),
        created_at DATETIME2 NOT NULL CONSTRAINT DF_MerchantWithdrawals_Created DEFAULT SYSUTCDATETIME(),
        processed_at DATETIME2 NULL,

        CONSTRAINT FK_MerchantWithdrawals_Merchant
            FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE,
        CONSTRAINT CK_MerchantWithdrawals_Status
            CHECK (status IN (N'PENDING', N'APPROVED', N'REJECTED')),
        CONSTRAINT CK_MerchantWithdrawals_Amount
            CHECK (amount > 0)
    );

    CREATE INDEX IX_MerchantWithdrawals_MerchantCreated
        ON dbo.MerchantWithdrawals(merchant_user_id, created_at DESC);

    CREATE INDEX IX_MerchantWithdrawals_Status
        ON dbo.MerchantWithdrawals(status, created_at);
END
GO

/* 6) Ratings: add reply_comment + merchant review indexes for pagination/filter */
IF OBJECT_ID(N'dbo.Ratings', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH(N'dbo.Ratings', N'reply_comment') IS NULL
    BEGIN
        ALTER TABLE dbo.Ratings
        ADD reply_comment NVARCHAR(1000) NULL;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Ratings_TargetCreated'
          AND object_id = OBJECT_ID(N'dbo.Ratings')
    )
    BEGIN
        IF COL_LENGTH(N'dbo.Ratings', N'reply_comment') IS NOT NULL
        BEGIN
            EXEC sp_executesql N'
                CREATE INDEX IX_Ratings_TargetCreated
                ON dbo.Ratings(target_type, target_user_id, created_at DESC)
                INCLUDE (stars, reply_comment, order_id, rater_customer_id, comment);';
        END
        ELSE
        BEGIN
            EXEC sp_executesql N'
                CREATE INDEX IX_Ratings_TargetCreated
                ON dbo.Ratings(target_type, target_user_id, created_at DESC)
                INCLUDE (stars, order_id, rater_customer_id, comment);';
        END
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Ratings_MerchantUnansweredCreated'
          AND object_id = OBJECT_ID(N'dbo.Ratings')
    )
    BEGIN
        IF COL_LENGTH(N'dbo.Ratings', N'reply_comment') IS NOT NULL
        BEGIN
            EXEC sp_executesql N'
                CREATE INDEX IX_Ratings_MerchantUnansweredCreated
                ON dbo.Ratings(target_user_id, created_at DESC)
                INCLUDE (stars, order_id, rater_customer_id, comment)
                WHERE target_type = N''MERCHANT'' AND reply_comment IS NULL;';
        END
    END
END
GO

PRINT N'Patch completed: missing merchant/chat schema objects and ratings indexes were added if absent.';
GO
