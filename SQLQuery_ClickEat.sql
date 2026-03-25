/* =========================================================
   CLICK EAT - FULL DATABASE (CREATE + SEED) - SQL SERVER
   One-shot script: Create DB -> Drop old tables -> Create schema -> Seed
   Fixed:
   - Removed duplicate vehicle_name / license_plate ALTER
   - No multiple cascade paths (AutoCartProposals merchant FK NO ACTION)
   - Trigger uses table variable
   ========================================================= */

SET NOCOUNT ON;
GO

/* =========================
   0) CREATE DATABASE
   ========================= */
IF DB_ID(N'ClickEat') IS NULL
BEGIN
    CREATE DATABASE ClickEat;
END
GO

USE ClickEat;
GO

/* =========================
   1) DROP TABLES (for rerun)
   ========================= */
DROP TRIGGER IF EXISTS dbo.TR_CartItems_EnforceSingleMerchant;
GO

IF OBJECT_ID('dbo.AutoCartProposalItems','U') IS NOT NULL DROP TABLE dbo.AutoCartProposalItems;
IF OBJECT_ID('dbo.AutoCartProposals','U') IS NOT NULL DROP TABLE dbo.AutoCartProposals;
IF OBJECT_ID('dbo.AIMessages','U') IS NOT NULL DROP TABLE dbo.AIMessages;
IF OBJECT_ID('dbo.AIConversations','U') IS NOT NULL DROP TABLE dbo.AIConversations;

IF OBJECT_ID('dbo.UserBehaviorEvents','U') IS NOT NULL DROP TABLE dbo.UserBehaviorEvents;
IF OBJECT_ID('dbo.Notifications','U') IS NOT NULL DROP TABLE dbo.Notifications;

IF OBJECT_ID('dbo.Ratings','U') IS NOT NULL DROP TABLE dbo.Ratings;

IF OBJECT_ID('dbo.FailedDeliveryResolutions','U') IS NOT NULL DROP TABLE dbo.FailedDeliveryResolutions;
IF OBJECT_ID('dbo.DeliveryIssues','U') IS NOT NULL DROP TABLE dbo.DeliveryIssues;

IF OBJECT_ID('dbo.OrderClaims','U') IS NOT NULL DROP TABLE dbo.OrderClaims;

IF OBJECT_ID('dbo.ShipperAvailability','U') IS NOT NULL DROP TABLE dbo.ShipperAvailability;
IF OBJECT_ID('dbo.WithdrawalRequests','U') IS NOT NULL DROP TABLE dbo.WithdrawalRequests;
IF OBJECT_ID('dbo.ShipperWallets','U') IS NOT NULL DROP TABLE dbo.ShipperWallets;
IF OBJECT_ID('dbo.ShipperReviews','U') IS NOT NULL DROP TABLE dbo.ShipperReviews;
IF OBJECT_ID('dbo.ShipperProfiles','U') IS NOT NULL DROP TABLE dbo.ShipperProfiles;

IF OBJECT_ID('dbo.VoucherUsages','U') IS NOT NULL DROP TABLE dbo.VoucherUsages;
IF OBJECT_ID('dbo.Vouchers','U') IS NOT NULL DROP TABLE dbo.Vouchers;

IF OBJECT_ID('dbo.PaymentTransactions','U') IS NOT NULL DROP TABLE dbo.PaymentTransactions;

IF OBJECT_ID('dbo.OrderIssues','U') IS NOT NULL DROP TABLE dbo.OrderIssues;
IF OBJECT_ID('dbo.OrderStatusHistory','U') IS NOT NULL DROP TABLE dbo.OrderStatusHistory;
IF OBJECT_ID('dbo.OrderItems','U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders','U') IS NOT NULL DROP TABLE dbo.Orders;

IF OBJECT_ID('dbo.CartItems','U') IS NOT NULL DROP TABLE dbo.CartItems;
IF OBJECT_ID('dbo.Carts','U') IS NOT NULL DROP TABLE dbo.Carts;

IF OBJECT_ID('dbo.FoodItems','U') IS NOT NULL DROP TABLE dbo.FoodItems;
IF OBJECT_ID('dbo.Categories','U') IS NOT NULL DROP TABLE dbo.Categories;

IF OBJECT_ID('dbo.MerchantKYC','U') IS NOT NULL DROP TABLE dbo.MerchantKYC;
IF OBJECT_ID('dbo.MerchantProfiles','U') IS NOT NULL DROP TABLE dbo.MerchantProfiles;

IF OBJECT_ID('dbo.CustomerProfiles','U') IS NOT NULL DROP TABLE dbo.CustomerProfiles;
IF OBJECT_ID('dbo.Addresses','U') IS NOT NULL DROP TABLE dbo.Addresses;

IF OBJECT_ID('dbo.GuestSessions','U') IS NOT NULL DROP TABLE dbo.GuestSessions;

IF OBJECT_ID('dbo.UserAppeals','U') IS NOT NULL DROP TABLE dbo.UserAppeals;
IF OBJECT_ID('dbo.UserAuthProviders','U') IS NOT NULL DROP TABLE dbo.UserAuthProviders;
IF OBJECT_ID('dbo.Users','U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* =========================
   2) USERS & AUTH
   ========================= */
CREATE TABLE dbo.Users (
    id            BIGINT IDENTITY(1,1) PRIMARY KEY,
    full_name     NVARCHAR(100)    NOT NULL,
    email         NVARCHAR(150)    NULL,
    phone         NVARCHAR(20)     NOT NULL,
    password_hash NVARCHAR(255)    NULL,
    avatar_url    NVARCHAR(500)    NULL,
    role          NVARCHAR(20)     NOT NULL,
    status        NVARCHAR(20)     NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'ACTIVE',
    created_at    DATETIME2        NOT NULL CONSTRAINT DF_Users_Created DEFAULT SYSUTCDATETIME(),
    updated_at    DATETIME2        NOT NULL CONSTRAINT DF_Users_Updated DEFAULT SYSUTCDATETIME()
);

CREATE UNIQUE INDEX UX_Users_Phone ON dbo.Users(phone);
CREATE UNIQUE INDEX UX_Users_Email ON dbo.Users(email) WHERE email IS NOT NULL;

ALTER TABLE dbo.Users
ADD CONSTRAINT CK_Users_Role CHECK (role IN (N'GUEST',N'CUSTOMER',N'MERCHANT',N'SHIPPER',N'ADMIN'));

ALTER TABLE dbo.Users
ADD CONSTRAINT CK_Users_Status CHECK (status IN (N'ACTIVE',N'INACTIVE'));
GO

CREATE TABLE dbo.UserAuthProviders (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id          BIGINT         NOT NULL,
    provider         NVARCHAR(30)   NOT NULL,
    provider_user_id NVARCHAR(100)  NOT NULL,
    linked_at        DATETIME2      NOT NULL CONSTRAINT DF_UserAuthProviders_Linked DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_UserAuthProviders_User
        FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);

ALTER TABLE dbo.UserAuthProviders
ADD CONSTRAINT CK_UserAuthProviders_Provider CHECK (provider IN (N'GOOGLE'));

CREATE UNIQUE INDEX UX_UserAuthProviders_ProviderUser ON dbo.UserAuthProviders(provider, provider_user_id);
GO

CREATE TABLE dbo.UserAppeals (
    id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id     BIGINT         NOT NULL,
    reason      NVARCHAR(1000) NOT NULL,
    status      NVARCHAR(20)   NOT NULL CONSTRAINT DF_UserAppeals_Status DEFAULT 'PENDING',
    admin_note  NVARCHAR(500)  NULL,
    created_at  DATETIME2      NOT NULL CONSTRAINT DF_UserAppeals_Created DEFAULT SYSUTCDATETIME(),
    resolved_at DATETIME2      NULL,

    CONSTRAINT FK_UserAppeals_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE,
    CONSTRAINT CK_UserAppeals_Status CHECK (status IN (N'PENDING',N'APPROVED',N'REJECTED'))
);
GO

/* =========================
   3) GUEST SESSION
   ========================= */
CREATE TABLE dbo.GuestSessions (
    guest_id      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_GuestSessions_Id DEFAULT NEWID() PRIMARY KEY,
    contact_phone NVARCHAR(20)     NULL,
    contact_email NVARCHAR(150)    NULL,
    created_at    DATETIME2        NOT NULL CONSTRAINT DF_GuestSessions_Created DEFAULT SYSUTCDATETIME(),
    expires_at    DATETIME2        NULL
);
GO

/* =========================
   4) CUSTOMER PROFILE & ADDRESSES
   ========================= */
CREATE TABLE dbo.CustomerProfiles (
    user_id              BIGINT      NOT NULL PRIMARY KEY,
    default_address_id   BIGINT      NULL,
    food_preferences     NVARCHAR(1000) NULL,
    allergies            NVARCHAR(1000) NULL,
    health_goal          NVARCHAR(200)  NULL,
    daily_calorie_target INT            NULL,
    created_at           DATETIME2   NOT NULL CONSTRAINT DF_CustomerProfiles_Created DEFAULT SYSUTCDATETIME(),
    updated_at           DATETIME2   NOT NULL CONSTRAINT DF_CustomerProfiles_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_CustomerProfiles_User
        FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.Addresses (
    id             BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id        BIGINT        NOT NULL,
    receiver_name  NVARCHAR(100) NOT NULL,
    receiver_phone NVARCHAR(20)  NOT NULL,
    address_line   NVARCHAR(255) NOT NULL,
    province_code  NVARCHAR(20)  NOT NULL,
    province_name  NVARCHAR(100) NOT NULL,
    district_code  NVARCHAR(20)  NOT NULL,
    district_name  NVARCHAR(100) NOT NULL,
    ward_code      NVARCHAR(20)  NOT NULL,
    ward_name      NVARCHAR(100) NOT NULL,
    latitude       DECIMAL(10,7) NULL,
    longitude      DECIMAL(10,7) NULL,
    is_default     BIT           NOT NULL CONSTRAINT DF_Addresses_IsDefault DEFAULT 0,
    note           NVARCHAR(255) NULL,
    created_at     DATETIME2     NOT NULL CONSTRAINT DF_Addresses_Created DEFAULT SYSUTCDATETIME(),
    updated_at     DATETIME2     NOT NULL CONSTRAINT DF_Addresses_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Addresses_User
        FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);

CREATE INDEX IX_Addresses_User ON dbo.Addresses(user_id, is_default);
GO

ALTER TABLE dbo.CustomerProfiles
ADD CONSTRAINT FK_CustomerProfiles_DefaultAddress
    FOREIGN KEY (default_address_id) REFERENCES dbo.Addresses(id);
GO

/* =========================
   5) MERCHANT & KYC
   ========================= */
CREATE TABLE dbo.MerchantProfiles (
    user_id           BIGINT        NOT NULL PRIMARY KEY,
    shop_name         NVARCHAR(120) NOT NULL,
    shop_phone        NVARCHAR(20)  NOT NULL,
    shop_address_line NVARCHAR(255) NOT NULL,
    province_code     NVARCHAR(20)  NOT NULL,
    province_name     NVARCHAR(100) NOT NULL,
    district_code     NVARCHAR(20)  NOT NULL,
    district_name     NVARCHAR(100) NOT NULL,
    ward_code         NVARCHAR(20)  NOT NULL,
    ward_name         NVARCHAR(100) NOT NULL,
    latitude          DECIMAL(10,7) NULL,
    longitude         DECIMAL(10,7) NULL,
    source_platform   NVARCHAR(20)  NULL,
    status            NVARCHAR(20)  NOT NULL CONSTRAINT DF_MerchantProfiles_Status DEFAULT 'PENDING',
    created_at        DATETIME2     NOT NULL CONSTRAINT DF_MerchantProfiles_Created DEFAULT SYSUTCDATETIME(),
    updated_at        DATETIME2     NOT NULL CONSTRAINT DF_MerchantProfiles_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_MerchantProfiles_User
        FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);

ALTER TABLE dbo.MerchantProfiles
ADD CONSTRAINT CK_MerchantProfiles_Status CHECK (status IN (N'PENDING',N'APPROVED',N'REJECTED',N'SUSPENDED'));
GO

ALTER TABLE dbo.MerchantProfiles
ADD CONSTRAINT CK_MerchantProfiles_SourcePlatform CHECK (source_platform IS NULL OR source_platform IN (N'NONE',N'GRABFOOD',N'SHOPEEFOOD',N'OTHER'));
GO

CREATE TABLE dbo.MerchantKYC (
    id                      BIGINT IDENTITY(1,1) PRIMARY KEY,
    merchant_user_id        BIGINT        NOT NULL,
    business_name           NVARCHAR(150) NOT NULL,
    business_license_number NVARCHAR(50)  NULL,
    document_url            NVARCHAR(500) NULL,
    submitted_at            DATETIME2     NOT NULL CONSTRAINT DF_MerchantKYC_Submitted DEFAULT SYSUTCDATETIME(),
    reviewed_by_admin_id    BIGINT        NULL,
    review_status           NVARCHAR(20)  NOT NULL CONSTRAINT DF_MerchantKYC_Status DEFAULT 'SUBMITTED',
    review_note             NVARCHAR(255) NULL,

    CONSTRAINT FK_MerchantKYC_Merchant
        FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_MerchantKYC_Admin
        FOREIGN KEY (reviewed_by_admin_id) REFERENCES dbo.Users(id)
);

ALTER TABLE dbo.MerchantKYC
ADD CONSTRAINT CK_MerchantKYC_Status CHECK (review_status IN (N'SUBMITTED',N'UNDER_REVIEW',N'APPROVED',N'REJECTED'));
GO

/* =========================
   6) MENU
   ========================= */
CREATE TABLE dbo.Categories (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    merchant_user_id BIGINT        NOT NULL,
    name             NVARCHAR(100) NOT NULL,
    is_active        BIT           NOT NULL CONSTRAINT DF_Categories_Active DEFAULT 1,
    sort_order       INT           NOT NULL CONSTRAINT DF_Categories_Sort DEFAULT 0,

    CONSTRAINT FK_Categories_Merchant
        FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
);
CREATE INDEX IX_Categories_Merchant ON dbo.Categories(merchant_user_id);
GO

CREATE TABLE dbo.FoodItems (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    merchant_user_id BIGINT        NOT NULL,
    category_id      BIGINT        NOT NULL,
    name             NVARCHAR(150) NOT NULL,
    description      NVARCHAR(500) NULL,
    price            DECIMAL(18,2) NOT NULL,
    image_url        NVARCHAR(500) NULL,
    is_available     BIT           NOT NULL CONSTRAINT DF_FoodItems_Available DEFAULT 1,
    is_fried         BIT           NOT NULL CONSTRAINT DF_FoodItems_IsFried DEFAULT 0,
    calories         INT           NULL,
    protein_g        DECIMAL(10,2) NULL,
    carbs_g          DECIMAL(10,2) NULL,
    fat_g            DECIMAL(10,2) NULL,
    created_at       DATETIME2     NOT NULL CONSTRAINT DF_FoodItems_Created DEFAULT SYSUTCDATETIME(),
    updated_at       DATETIME2     NOT NULL CONSTRAINT DF_FoodItems_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_FoodItems_Merchant
        FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_FoodItems_Category
        FOREIGN KEY (category_id) REFERENCES dbo.Categories(id)
);

CREATE INDEX IX_FoodItems_Merchant ON dbo.FoodItems(merchant_user_id);
CREATE INDEX IX_FoodItems_Category ON dbo.FoodItems(category_id);
GO

/* =========================
   7) CARTS & CART ITEMS
   ========================= */
CREATE TABLE dbo.Carts (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_user_id BIGINT           NULL,
    guest_id         UNIQUEIDENTIFIER NULL,
    merchant_user_id BIGINT           NULL,
    status           NVARCHAR(20)     NOT NULL CONSTRAINT DF_Carts_Status DEFAULT 'ACTIVE',
    created_at       DATETIME2        NOT NULL CONSTRAINT DF_Carts_Created DEFAULT SYSUTCDATETIME(),
    updated_at       DATETIME2        NOT NULL CONSTRAINT DF_Carts_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Carts_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Carts_Guest    FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT FK_Carts_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id),
    CONSTRAINT CK_Carts_Owner CHECK (
        (customer_user_id IS NOT NULL AND guest_id IS NULL) OR
        (customer_user_id IS NULL AND guest_id IS NOT NULL)
    )
);

ALTER TABLE dbo.Carts
ADD CONSTRAINT CK_Carts_Status CHECK (status IN (N'ACTIVE',N'CHECKED_OUT',N'ABANDONED'));
GO

CREATE TABLE dbo.CartItems (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    cart_id             BIGINT        NOT NULL,
    food_item_id        BIGINT        NOT NULL,
    quantity            INT           NOT NULL,
    unit_price_snapshot DECIMAL(18,2) NOT NULL,
    note                NVARCHAR(255) NULL,

    CONSTRAINT FK_CartItems_Cart FOREIGN KEY (cart_id) REFERENCES dbo.Carts(id) ON DELETE CASCADE,
    CONSTRAINT FK_CartItems_Food FOREIGN KEY (food_item_id) REFERENCES dbo.FoodItems(id),
    CONSTRAINT CK_CartItems_Qty CHECK (quantity > 0)
);

CREATE INDEX IX_CartItems_Cart ON dbo.CartItems(cart_id);
CREATE UNIQUE INDEX UX_CartItems_CartFood ON dbo.CartItems(cart_id, food_item_id);
GO

CREATE TRIGGER dbo.TR_CartItems_EnforceSingleMerchant
ON dbo.CartItems
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @x TABLE (
        cart_id BIGINT,
        food_item_id BIGINT,
        food_merchant BIGINT
    );

    INSERT INTO @x(cart_id, food_item_id, food_merchant)
    SELECT i.cart_id, i.food_item_id, f.merchant_user_id
    FROM inserted i
    JOIN dbo.FoodItems f ON f.id = i.food_item_id;

    UPDATE c
    SET c.merchant_user_id = x.food_merchant,
        c.updated_at = SYSUTCDATETIME()
    FROM dbo.Carts c
    JOIN @x x ON x.cart_id = c.id
    WHERE c.merchant_user_id IS NULL;

    IF EXISTS (
        SELECT 1
        FROM @x x
        JOIN dbo.Carts c ON c.id = x.cart_id
        WHERE c.merchant_user_id IS NOT NULL
          AND c.merchant_user_id <> x.food_merchant
    )
    BEGIN
        RAISERROR(N'Cart chỉ được chứa món từ 1 cửa hàng. Vui lòng tạo giỏ mới cho cửa hàng khác.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* =========================
   8) ORDERS
   ========================= */
CREATE TABLE dbo.Orders (
    id                    BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_code            NVARCHAR(30)     NOT NULL,
    customer_user_id      BIGINT           NULL,
    guest_id              UNIQUEIDENTIFIER NULL,
    merchant_user_id      BIGINT           NOT NULL,
    shipper_user_id       BIGINT           NULL,
    receiver_name         NVARCHAR(100)    NOT NULL,
    receiver_phone        NVARCHAR(20)     NOT NULL,
    delivery_address_line NVARCHAR(255)    NOT NULL,
    province_code         NVARCHAR(20)     NOT NULL,
    province_name         NVARCHAR(100)    NOT NULL,
    district_code         NVARCHAR(20)     NOT NULL,
    district_name         NVARCHAR(100)    NOT NULL,
    ward_code             NVARCHAR(20)     NOT NULL,
    ward_name             NVARCHAR(100)    NOT NULL,
    latitude              DECIMAL(10,7)    NULL,
    longitude             DECIMAL(10,7)    NULL,
    delivery_note         NVARCHAR(255)    NULL,
    payment_method        NVARCHAR(20)     NOT NULL,
    payment_status        NVARCHAR(20)     NOT NULL CONSTRAINT DF_Orders_PaymentStatus DEFAULT 'UNPAID',
    order_status          NVARCHAR(30)     NOT NULL CONSTRAINT DF_Orders_OrderStatus DEFAULT 'CREATED',
    expires_at            DATETIME2        NULL,
    subtotal_amount       DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_Subtotal DEFAULT 0,
    delivery_fee          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_DeliveryFee DEFAULT 0,
    discount_amount       DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_Discount DEFAULT 0,
    total_amount          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_Total DEFAULT 0,
    created_at            DATETIME2        NOT NULL CONSTRAINT DF_Orders_Created DEFAULT SYSUTCDATETIME(),
    accepted_at           DATETIME2        NULL,
    ready_at              DATETIME2        NULL,
    picked_up_at          DATETIME2        NULL,
    delivered_at          DATETIME2        NULL,
    cancelled_at          DATETIME2        NULL,
    proof_image_url       NVARCHAR(500)    NULL,

    CONSTRAINT UQ_Orders_Code UNIQUE(order_code),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Orders_Guest    FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT FK_Orders_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id),
    CONSTRAINT FK_Orders_Shipper  FOREIGN KEY (shipper_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT CK_Orders_Owner CHECK (
        (customer_user_id IS NOT NULL AND guest_id IS NULL) OR
        (customer_user_id IS NULL AND guest_id IS NOT NULL)
    )
);

ALTER TABLE dbo.Orders
ADD CONSTRAINT CK_Orders_PaymentMethod CHECK (payment_method IN (N'COD',N'VNPAY'));

ALTER TABLE dbo.Orders
ADD CONSTRAINT CK_Orders_PaymentStatus CHECK (payment_status IN (N'UNPAID',N'PENDING',N'PAID',N'FAILED',N'REFUNDED'));

ALTER TABLE dbo.Orders
ADD CONSTRAINT CK_Orders_OrderStatus CHECK (order_status IN (
    N'CREATED',N'PENDING_PAYMENT',N'PAID',N'MERCHANT_ACCEPTED',N'MERCHANT_REJECTED',
    N'PREPARING',N'READY_FOR_PICKUP',N'PICKED_UP',N'DELIVERING',N'DELIVERED',
    N'CANCELLED',N'FAILED',N'REFUNDED'
));

CREATE INDEX IX_Orders_Merchant_Status ON dbo.Orders(merchant_user_id, order_status, created_at);
CREATE INDEX IX_Orders_Shipper_Status  ON dbo.Orders(shipper_user_id, order_status, created_at);
CREATE INDEX IX_Orders_Customer_Created ON dbo.Orders(customer_user_id, created_at) WHERE customer_user_id IS NOT NULL;
GO

CREATE TABLE dbo.OrderItems (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id            BIGINT        NOT NULL,
    food_item_id        BIGINT        NOT NULL,
    item_name_snapshot  NVARCHAR(150) NOT NULL,
    unit_price_snapshot DECIMAL(18,2) NOT NULL,
    quantity            INT           NOT NULL,
    note                NVARCHAR(255) NULL,

    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_Food  FOREIGN KEY (food_item_id) REFERENCES dbo.FoodItems(id),
    CONSTRAINT CK_OrderItems_Qty CHECK (quantity > 0)
);

CREATE INDEX IX_OrderItems_Order ON dbo.OrderItems(order_id);
GO

CREATE TABLE dbo.OrderStatusHistory (
    id                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id           BIGINT        NOT NULL,
    from_status        NVARCHAR(30)  NULL,
    to_status          NVARCHAR(30)  NOT NULL,
    updated_by_role    NVARCHAR(20)  NOT NULL,
    updated_by_user_id BIGINT        NULL,
    note               NVARCHAR(255) NULL,
    created_at         DATETIME2     NOT NULL CONSTRAINT DF_OrderStatusHistory_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_OrderStatusHistory_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderStatusHistory_User  FOREIGN KEY (updated_by_user_id) REFERENCES dbo.Users(id)
);

ALTER TABLE dbo.OrderStatusHistory
ADD CONSTRAINT CK_OrderStatusHistory_Role CHECK (updated_by_role IN (N'CUSTOMER',N'GUEST',N'MERCHANT',N'SHIPPER',N'ADMIN',N'SYSTEM'));

CREATE INDEX IX_OrderStatusHistory_Order ON dbo.OrderStatusHistory(order_id, created_at);
GO

CREATE TABLE dbo.OrderIssues (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id         BIGINT        NOT NULL,
    reporter_user_id BIGINT        NOT NULL,
    issue_type       NVARCHAR(50)  NOT NULL,
    description      NVARCHAR(500) NULL,
    status           NVARCHAR(20)  NOT NULL CONSTRAINT DF_OrderIssues_Status DEFAULT 'PENDING',
    created_at       DATETIME2     NOT NULL CONSTRAINT DF_OrderIssues_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_OrderIssues_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderIssues_Reporter FOREIGN KEY (reporter_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT CK_OrderIssues_Status CHECK (status IN (N'PENDING',N'IN_PROGRESS',N'RESOLVED',N'REJECTED'))
);
GO

/* =========================
   9) PAYMENTS
   ========================= */
CREATE TABLE dbo.PaymentTransactions (
    id                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id           BIGINT        NOT NULL,
    provider           NVARCHAR(20)  NOT NULL,
    amount             DECIMAL(18,2) NOT NULL,
    status             NVARCHAR(20)  NOT NULL,
    provider_txn_ref   NVARCHAR(100) NULL,
    vnp_txn_ref        NVARCHAR(100) NULL,
    vnp_transaction_no NVARCHAR(100) NULL,
    vnp_response_code  NVARCHAR(20)  NULL,
    vnp_pay_date       NVARCHAR(50)  NULL,
    request_payload    NVARCHAR(MAX) NULL,
    callback_payload   NVARCHAR(MAX) NULL,
    created_at         DATETIME2     NOT NULL CONSTRAINT DF_PaymentTransactions_Created DEFAULT SYSUTCDATETIME(),
    updated_at         DATETIME2     NOT NULL CONSTRAINT DF_PaymentTransactions_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_PaymentTransactions_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE
);

ALTER TABLE dbo.PaymentTransactions
ADD CONSTRAINT CK_PaymentTransactions_Provider CHECK (provider IN (N'VNPAY',N'COD'));

ALTER TABLE dbo.PaymentTransactions
ADD CONSTRAINT CK_PaymentTransactions_Status CHECK (status IN (N'INITIATED',N'PENDING',N'SUCCESS',N'FAILED',N'REFUNDED'));

CREATE INDEX IX_PaymentTransactions_Order ON dbo.PaymentTransactions(order_id);
CREATE UNIQUE INDEX UX_PaymentTransactions_VnpTxnRef ON dbo.PaymentTransactions(vnp_txn_ref) WHERE vnp_txn_ref IS NOT NULL;
CREATE UNIQUE INDEX UX_PaymentTransactions_VnpTransactionNo ON dbo.PaymentTransactions(vnp_transaction_no) WHERE vnp_transaction_no IS NOT NULL;
GO

/* =========================
   10) VOUCHERS
   ========================= */
CREATE TABLE dbo.Vouchers (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    merchant_user_id    BIGINT         NOT NULL,
    code                NVARCHAR(50)   NOT NULL,
    title               NVARCHAR(200)  NULL,
    description         NVARCHAR(1000) NULL,
    discount_type       NVARCHAR(10)   NOT NULL,
    discount_value      DECIMAL(18,2)  NOT NULL,
    max_discount_amount DECIMAL(18,2)  NULL,
    min_order_amount    DECIMAL(18,2)  NULL,
    start_at            DATETIME2      NOT NULL,
    end_at              DATETIME2      NOT NULL,
    max_uses_total      INT            NULL,
    max_uses_per_user   INT            NULL,
    is_published        BIT            NOT NULL CONSTRAINT DF_Vouchers_Published DEFAULT 0,
    status              NVARCHAR(20)   NOT NULL CONSTRAINT DF_Vouchers_Status DEFAULT 'ACTIVE',
    created_at          DATETIME2      NOT NULL CONSTRAINT DF_Vouchers_Created DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2      NOT NULL CONSTRAINT DF_Vouchers_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Vouchers_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
);

ALTER TABLE dbo.Vouchers
ADD CONSTRAINT CK_Vouchers_DiscountType CHECK (discount_type IN (N'PERCENT',N'FIXED'));

ALTER TABLE dbo.Vouchers
ADD CONSTRAINT CK_Vouchers_Status CHECK (status IN (N'ACTIVE',N'INACTIVE'));

CREATE UNIQUE INDEX UX_Vouchers_MerchantCode ON dbo.Vouchers(merchant_user_id, code);
GO

CREATE TABLE dbo.VoucherUsages (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    voucher_id       BIGINT           NOT NULL,
    order_id         BIGINT           NOT NULL,
    customer_user_id BIGINT           NULL,
    guest_id         UNIQUEIDENTIFIER NULL,
    used_at          DATETIME2        NOT NULL CONSTRAINT DF_VoucherUsages_Used DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_VoucherUsages_Voucher FOREIGN KEY (voucher_id) REFERENCES dbo.Vouchers(id),
    CONSTRAINT FK_VoucherUsages_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_VoucherUsages_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_VoucherUsages_Guest FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT CK_VoucherUsages_Owner CHECK (
        (customer_user_id IS NOT NULL AND guest_id IS NULL) OR
        (customer_user_id IS NULL AND guest_id IS NOT NULL)
    )
);

CREATE UNIQUE INDEX UX_VoucherUsages_Order ON dbo.VoucherUsages(order_id);
GO

/* =========================
   11) SHIPPER
   ========================= */
CREATE TABLE dbo.ShipperProfiles (
    user_id       BIGINT        NOT NULL PRIMARY KEY,
    vehicle_type  NVARCHAR(20)  NOT NULL,
    vehicle_name  NVARCHAR(100) NULL,
    license_plate NVARCHAR(20)  NULL,
    status        NVARCHAR(20)  NOT NULL CONSTRAINT DF_ShipperProfiles_Status DEFAULT 'ACTIVE',
    created_at    DATETIME2     NOT NULL CONSTRAINT DF_ShipperProfiles_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_ShipperProfiles_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);

ALTER TABLE dbo.ShipperProfiles
ADD CONSTRAINT CK_ShipperProfiles_Vehicle CHECK (vehicle_type IN (N'MOTORBIKE',N'BIKE'));

ALTER TABLE dbo.ShipperProfiles
ADD CONSTRAINT CK_ShipperProfiles_Status CHECK (status IN (N'ACTIVE',N'SUSPENDED'));
GO

CREATE TABLE dbo.ShipperAvailability (
    shipper_user_id   BIGINT        NOT NULL PRIMARY KEY,
    is_online         BIT           NOT NULL CONSTRAINT DF_ShipperAvailability_Online DEFAULT 0,
    current_status    NVARCHAR(20)  NOT NULL CONSTRAINT DF_ShipperAvailability_Status DEFAULT 'AVAILABLE',
    current_latitude  DECIMAL(10,7) NULL,
    current_longitude DECIMAL(10,7) NULL,
    updated_at        DATETIME2     NOT NULL CONSTRAINT DF_ShipperAvailability_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_ShipperAvailability_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.ShipperProfiles(user_id) ON DELETE CASCADE
);

ALTER TABLE dbo.ShipperAvailability
ADD CONSTRAINT CK_ShipperAvailability_Status CHECK (current_status IN (N'AVAILABLE',N'BUSY'));

CREATE INDEX IX_ShipperAvailability_Filter ON dbo.ShipperAvailability(is_online, current_status);
GO

CREATE TABLE dbo.OrderClaims (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id        BIGINT       NOT NULL,
    shipper_user_id BIGINT       NOT NULL,
    status          NVARCHAR(20) NOT NULL,
    claimed_at      DATETIME2    NOT NULL CONSTRAINT DF_OrderClaims_Claimed DEFAULT SYSUTCDATETIME(),
    expires_at      DATETIME2    NOT NULL,
    confirmed_at    DATETIME2    NULL,

    CONSTRAINT FK_OrderClaims_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderClaims_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.Users(id)
);

ALTER TABLE dbo.OrderClaims
ADD CONSTRAINT CK_OrderClaims_Status CHECK (status IN (N'CLAIMED',N'CONFIRMED',N'EXPIRED',N'CANCELLED'));

CREATE UNIQUE INDEX UX_OrderClaims_ActiveOrder
ON dbo.OrderClaims(order_id)
WHERE status IN (N'CLAIMED',N'CONFIRMED');
GO

CREATE TABLE dbo.ShipperWallets (
    shipper_user_id BIGINT        NOT NULL PRIMARY KEY,
    balance         DECIMAL(18,2) NOT NULL CONSTRAINT DF_ShipperWallets_Balance DEFAULT 0,
    updated_at      DATETIME2     NOT NULL CONSTRAINT DF_ShipperWallets_Updated DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_ShipperWallets_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.ShipperProfiles(user_id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.WithdrawalRequests (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    shipper_user_id     BIGINT        NOT NULL,
    amount              DECIMAL(18,2) NOT NULL,
    bank_name           NVARCHAR(100) NULL,
    bank_account_number NVARCHAR(50)  NULL,
    status              NVARCHAR(20)  NOT NULL CONSTRAINT DF_WithdrawalRequests_Status DEFAULT 'PENDING',
    created_at          DATETIME2     NOT NULL CONSTRAINT DF_WithdrawalRequests_Created DEFAULT SYSUTCDATETIME(),
    processed_at        DATETIME2     NULL,

    CONSTRAINT FK_WithdrawalRequests_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.ShipperProfiles(user_id) ON DELETE CASCADE,
    CONSTRAINT CK_WithdrawalRequests_Status CHECK (status IN (N'PENDING',N'APPROVED',N'REJECTED')),
    CONSTRAINT CK_WithdrawalRequests_Amount CHECK (amount > 0)
);
GO

CREATE TABLE dbo.ShipperReviews (
    id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id     BIGINT        NOT NULL,
    shipper_id   BIGINT        NOT NULL,
    customer_id  BIGINT        NOT NULL,
    rating       INT           NOT NULL,
    comment      NVARCHAR(500) NULL,
    created_at   DATETIME2     NOT NULL CONSTRAINT DF_ShipperReviews_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_ShipperReviews_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_ShipperReviews_Shipper FOREIGN KEY (shipper_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_ShipperReviews_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Users(id),
    CONSTRAINT CK_ShipperReviews_Rating CHECK (rating BETWEEN 1 AND 5)
);
GO

/* =========================
   12) DELIVERY ISSUES
   ========================= */
CREATE TABLE dbo.DeliveryIssues (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id        BIGINT       NOT NULL,
    shipper_user_id BIGINT       NOT NULL,
    issue_type      NVARCHAR(30) NOT NULL,
    attempts_count  INT          NOT NULL CONSTRAINT DF_DeliveryIssues_Attempts DEFAULT 0,
    note            NVARCHAR(255) NULL,
    created_at      DATETIME2     NOT NULL CONSTRAINT DF_DeliveryIssues_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_DeliveryIssues_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_DeliveryIssues_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.Users(id)
);
GO

CREATE TABLE dbo.FailedDeliveryResolutions (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id            BIGINT       NOT NULL,
    handled_by_admin_id BIGINT       NOT NULL,
    resolution_type     NVARCHAR(30) NOT NULL,
    note                NVARCHAR(255) NULL,
    created_at          DATETIME2     NOT NULL CONSTRAINT DF_FailedDeliveryResolutions_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_FailedDeliveryResolutions_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_FailedDeliveryResolutions_Admin FOREIGN KEY (handled_by_admin_id) REFERENCES dbo.Users(id)
);
GO

/* =========================
   13) RATINGS
   ========================= */
CREATE TABLE dbo.Ratings (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id         BIGINT           NOT NULL,
    rater_customer_id BIGINT          NULL,
    rater_guest_id   UNIQUEIDENTIFIER NULL,
    target_type      NVARCHAR(20)     NOT NULL,
    target_user_id   BIGINT           NOT NULL,
    stars            INT              NOT NULL,
    comment          NVARCHAR(500)    NULL,
    reply_comment    NVARCHAR(1000)   NULL,
    created_at       DATETIME2        NOT NULL CONSTRAINT DF_Ratings_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Ratings_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_Ratings_RaterCustomer FOREIGN KEY (rater_customer_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Ratings_RaterGuest FOREIGN KEY (rater_guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT FK_Ratings_TargetUser FOREIGN KEY (target_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT CK_Ratings_Rater CHECK (
        (rater_customer_id IS NOT NULL AND rater_guest_id IS NULL) OR
        (rater_customer_id IS NULL AND rater_guest_id IS NOT NULL)
    ),
    CONSTRAINT CK_Ratings_TargetType CHECK (target_type IN (N'MERCHANT',N'SHIPPER')),
    CONSTRAINT CK_Ratings_Stars CHECK (stars BETWEEN 1 AND 5)
);

CREATE UNIQUE INDEX UX_Ratings_OrderTarget ON dbo.Ratings(order_id, target_type);
CREATE INDEX IX_Ratings_TargetCreated ON dbo.Ratings(target_type, target_user_id, created_at DESC) INCLUDE (stars, reply_comment, order_id, rater_customer_id, comment);
CREATE INDEX IX_Ratings_MerchantUnansweredCreated ON dbo.Ratings(target_user_id, created_at DESC) INCLUDE (stars, order_id, rater_customer_id, comment) WHERE target_type = N'MERCHANT' AND reply_comment IS NULL;
GO

/* =========================
   14) USER EVENTS & NOTIFICATIONS
   ========================= */
CREATE TABLE dbo.UserBehaviorEvents (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_user_id BIGINT           NULL,
    guest_id         UNIQUEIDENTIFIER NULL,
    event_type       NVARCHAR(30)     NOT NULL,
    food_item_id     BIGINT           NULL,
    keyword          NVARCHAR(200)    NULL,
    created_at       DATETIME2        NOT NULL CONSTRAINT DF_UserBehaviorEvents_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_UserBehaviorEvents_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE,
    CONSTRAINT FK_UserBehaviorEvents_Guest FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT FK_UserBehaviorEvents_Food FOREIGN KEY (food_item_id) REFERENCES dbo.FoodItems(id),
    CONSTRAINT CK_UserBehaviorEvents_Owner CHECK (
        (customer_user_id IS NOT NULL AND guest_id IS NULL) OR
        (customer_user_id IS NULL AND guest_id IS NOT NULL)
    )
);

CREATE INDEX IX_UserBehaviorEvents_Customer ON dbo.UserBehaviorEvents(customer_user_id, created_at) WHERE customer_user_id IS NOT NULL;
CREATE INDEX IX_UserBehaviorEvents_Guest ON dbo.UserBehaviorEvents(guest_id, created_at) WHERE guest_id IS NOT NULL;
GO

CREATE TABLE dbo.Notifications (
    id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id    BIGINT           NULL,
    guest_id   UNIQUEIDENTIFIER NULL,
    type       NVARCHAR(50)     NOT NULL,
    content    NVARCHAR(500)    NOT NULL,
    is_read    BIT              NOT NULL CONSTRAINT DF_Notifications_Read DEFAULT 0,
    created_at DATETIME2        NOT NULL CONSTRAINT DF_Notifications_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Notifications_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Notifications_Guest FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT CK_Notifications_Target CHECK (
        (user_id IS NOT NULL AND guest_id IS NULL) OR
        (user_id IS NULL AND guest_id IS NOT NULL)
    )
);

CREATE INDEX IX_Notifications_User ON dbo.Notifications(user_id, is_read, created_at) WHERE user_id IS NOT NULL;
CREATE INDEX IX_Notifications_Guest ON dbo.Notifications(guest_id, is_read, created_at) WHERE guest_id IS NOT NULL;
GO

/* =========================
   15) AI CHAT + AUTO CART
   ========================= */
CREATE TABLE dbo.AIConversations (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_user_id BIGINT    NOT NULL,
    created_at       DATETIME2 NOT NULL CONSTRAINT DF_AIConversations_Created DEFAULT SYSUTCDATETIME(),
    last_activity_at DATETIME2 NOT NULL CONSTRAINT DF_AIConversations_Last DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_AIConversations_Customer
        FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.AIMessages (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    conversation_id BIGINT        NOT NULL,
    role            NVARCHAR(20)  NOT NULL,
    content         NVARCHAR(MAX) NOT NULL,
    created_at      DATETIME2     NOT NULL CONSTRAINT DF_AIMessages_Created DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_AIMessages_Conversation
        FOREIGN KEY (conversation_id) REFERENCES dbo.AIConversations(id) ON DELETE CASCADE,
    CONSTRAINT CK_AIMessages_Role CHECK (role IN (N'USER',N'ASSISTANT',N'SYSTEM'))
);
GO

CREATE TABLE dbo.AutoCartProposals (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_user_id BIGINT        NOT NULL,
    merchant_user_id BIGINT        NOT NULL,
    conversation_id  BIGINT        NULL,
    status           NVARCHAR(20)  NOT NULL CONSTRAINT DF_AutoCartProposals_Status DEFAULT 'PROPOSED',
    created_at       DATETIME2     NOT NULL CONSTRAINT DF_AutoCartProposals_Created DEFAULT SYSUTCDATETIME(),
    expires_at       DATETIME2     NULL,

    CONSTRAINT FK_AutoCartProposals_Customer
        FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE,
    CONSTRAINT FK_AutoCartProposals_Merchant
        FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_AutoCartProposals_Conversation
        FOREIGN KEY (conversation_id) REFERENCES dbo.AIConversations(id) ON DELETE NO ACTION,
    CONSTRAINT CK_AutoCartProposals_Status CHECK (status IN (N'PROPOSED',N'CONFIRMED',N'REJECTED',N'EXPIRED'))
);
GO

CREATE TABLE dbo.AutoCartProposalItems (
    id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    proposal_id  BIGINT        NOT NULL,
    food_item_id BIGINT        NOT NULL,
    quantity     INT           NOT NULL,
    unit_price   DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_AutoCartProposalItems_Proposal
        FOREIGN KEY (proposal_id) REFERENCES dbo.AutoCartProposals(id) ON DELETE CASCADE,
    CONSTRAINT FK_AutoCartProposalItems_Food
        FOREIGN KEY (food_item_id) REFERENCES dbo.FoodItems(id),
    CONSTRAINT CK_AutoCartProposalItems_Qty CHECK (quantity > 0)
);

CREATE UNIQUE INDEX UX_AutoCartProposalItems_ProposalFood ON dbo.AutoCartProposalItems(proposal_id, food_item_id);
GO

/* =========================================================
   16) SEED DATA
   ========================================================= */
BEGIN TRY
    BEGIN TRAN;

    INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status)
    VALUES
    (N'Admin ClickEat',      N'admin@clickeat.vn',     N'0900000001', N'hash_admin', N'ADMIN',   N'ACTIVE'),
    (N'Merchant 1',          N'merchant1@shop.vn',     N'0900000002', N'hash_m1',    N'MERCHANT',N'ACTIVE'),
    (N'Merchant 2',          N'merchant2@shop.vn',     N'0900000003', N'hash_m2',    N'MERCHANT',N'ACTIVE'),
    (N'Merchant 3',          N'merchant3@shop.vn',     N'0900000004', N'hash_m3',    N'MERCHANT',N'ACTIVE'),
    (N'Merchant 4',          N'merchant4@shop.vn',     N'0900000005', N'hash_m4',    N'MERCHANT',N'ACTIVE'),
    (N'Merchant 5',          N'merchant5@shop.vn',     N'0900000006', N'hash_m5',    N'MERCHANT',N'ACTIVE'),
    (N'Shipper 1',           N'shipper1@clickeat.vn',  N'0900000007', N'hash_s1',    N'SHIPPER', N'ACTIVE'),
    (N'Shipper 2',           N'shipper2@clickeat.vn',  N'0900000008', N'hash_s2',    N'SHIPPER', N'ACTIVE'),
    (N'Shipper 3',           N'shipper3@clickeat.vn',  N'0900000009', N'hash_s3',    N'SHIPPER', N'ACTIVE'),
    (N'Shipper 4',           N'shipper4@clickeat.vn',  N'0900000010', N'hash_s4',    N'SHIPPER', N'ACTIVE'),
    (N'Shipper 5',           N'shipper5@clickeat.vn',  N'0900000011', N'hash_s5',    N'SHIPPER', N'ACTIVE'),
    (N'Customer 1',          N'customer1@clickeat.vn', N'0900000012', N'hash_c1',    N'CUSTOMER',N'ACTIVE'),
    (N'Customer 2',          N'customer2@clickeat.vn', N'0900000013', N'hash_c2',    N'CUSTOMER',N'ACTIVE'),
    (N'Customer 3',          N'customer3@clickeat.vn', N'0900000014', N'hash_c3',    N'CUSTOMER',N'ACTIVE'),
    (N'Customer 4',          N'customer4@clickeat.vn', N'0900000015', N'hash_c4',    N'CUSTOMER',N'ACTIVE'),
    (N'Customer 5',          N'customer5@clickeat.vn', N'0900000016', N'hash_c5',    N'CUSTOMER',N'ACTIVE');

    DECLARE @admin BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000001');
    DECLARE @m1 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000002');
    DECLARE @m2 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000003');
    DECLARE @m3 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000004');
    DECLARE @m4 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000005');
    DECLARE @m5 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000006');

    DECLARE @s1 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000007');
    DECLARE @s2 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000008');
    DECLARE @s3 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000009');
    DECLARE @s4 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000010');
    DECLARE @s5 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000011');

    DECLARE @c1 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000012');
    DECLARE @c2 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000013');
    DECLARE @c3 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000014');
    DECLARE @c4 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000015');
    DECLARE @c5 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000016');

    INSERT INTO dbo.UserAuthProviders(user_id,provider,provider_user_id)
    VALUES
    (@c1,N'GOOGLE',N'google-sub-c1'),
    (@c2,N'GOOGLE',N'google-sub-c2'),
    (@c3,N'GOOGLE',N'google-sub-c3'),
    (@c4,N'GOOGLE',N'google-sub-c4'),
    (@c5,N'GOOGLE',N'google-sub-c5');

    DECLARE @g1 UNIQUEIDENTIFIER = NEWID();
    DECLARE @g2 UNIQUEIDENTIFIER = NEWID();
    DECLARE @g3 UNIQUEIDENTIFIER = NEWID();
    DECLARE @g4 UNIQUEIDENTIFIER = NEWID();
    DECLARE @g5 UNIQUEIDENTIFIER = NEWID();

    INSERT INTO dbo.GuestSessions(guest_id,contact_phone,contact_email,expires_at)
    VALUES
    (@g1,N'0987000001',N'guest1@mail.com',DATEADD(DAY,7,SYSUTCDATETIME())),
    (@g2,N'0987000002',N'guest2@mail.com',DATEADD(DAY,7,SYSUTCDATETIME())),
    (@g3,N'0987000003',N'guest3@mail.com',DATEADD(DAY,7,SYSUTCDATETIME())),
    (@g4,N'0987000004',N'guest4@mail.com',DATEADD(DAY,7,SYSUTCDATETIME())),
    (@g5,N'0987000005',N'guest5@mail.com',DATEADD(DAY,7,SYSUTCDATETIME()));

    INSERT INTO dbo.CustomerProfiles(user_id,food_preferences,allergies,health_goal,daily_calorie_target)
    VALUES
    (@c1,N'Ít dầu, thích cay vừa, nhiều rau', N'Hải sản', N'Giữ dáng', 2000),
    (@c2,N'Thích combo, không ăn quá cay', NULL, N'Tăng cân nhẹ', 2400),
    (@c3,N'Ưu tiên món nướng, hạn chế đồ chiên', NULL, N'Tăng cơ', 2600),
    (@c4,N'Ăn thanh đạm, ít muối', NULL, N'Sức khỏe', 1900),
    (@c5,N'Không ăn ngọt, thích nước không đường', NULL, N'Giảm mỡ', 2100);

    INSERT INTO dbo.Addresses
    (user_id,receiver_name,receiver_phone,address_line,province_code,province_name,district_code,district_name,ward_code,ward_name,latitude,longitude,is_default,note)
    VALUES
    (@c1,N'Huy', N'0900000012', N'12 Nguyễn Huệ',      N'79',N'TP.HCM',N'760',N'Quận 1',     N'26734',N'Bến Nghé',   10.77653,106.70098,1,N'Gọi trước khi giao'),
    (@c2,N'Lan', N'0900000013', N'34 Lê Lợi',          N'79',N'TP.HCM',N'760',N'Quận 1',     N'26737',N'Bến Thành',  10.77216,106.69817,1,NULL),
    (@c3,N'Minh',N'0900000014', N'88 Điện Biên Phủ',   N'79',N'TP.HCM',N'769',N'Bình Thạnh',N'27145',N'Phường 21',  10.80520,106.71290,1,N'Để lễ tân'),
    (@c4,N'Nga', N'0900000015', N'15 Võ Văn Ngân',     N'79',N'TP.HCM',N'762',N'Thủ Đức',   N'26848',N'Linh Chiểu', 10.85140,106.75790,1,NULL),
    (@c5,N'Phúc',N'0900000016', N'20 Nguyễn Văn Linh', N'48',N'Đà Nẵng',N'490',N'Hải Châu', N'20194',N'Phước Ninh', 16.06060,108.22220,1,N'Giao giờ trưa');

    UPDATE dbo.CustomerProfiles SET default_address_id = (SELECT TOP 1 id FROM dbo.Addresses WHERE user_id=@c1 AND is_default=1) WHERE user_id=@c1;
    UPDATE dbo.CustomerProfiles SET default_address_id = (SELECT TOP 1 id FROM dbo.Addresses WHERE user_id=@c2 AND is_default=1) WHERE user_id=@c2;
    UPDATE dbo.CustomerProfiles SET default_address_id = (SELECT TOP 1 id FROM dbo.Addresses WHERE user_id=@c3 AND is_default=1) WHERE user_id=@c3;
    UPDATE dbo.CustomerProfiles SET default_address_id = (SELECT TOP 1 id FROM dbo.Addresses WHERE user_id=@c4 AND is_default=1) WHERE user_id=@c4;
    UPDATE dbo.CustomerProfiles SET default_address_id = (SELECT TOP 1 id FROM dbo.Addresses WHERE user_id=@c5 AND is_default=1) WHERE user_id=@c5;

    INSERT INTO dbo.MerchantProfiles
    (user_id,shop_name,shop_phone,shop_address_line,province_code,province_name,district_code,district_name,ward_code,ward_name,latitude,longitude,status)
    VALUES
    (@m1,N'Lollibee Q1', N'0280000002', N'10 Đồng Khởi',          N'79',N'TP.HCM',N'760',N'Quận 1',     N'26734',N'Bến Nghé',   10.77500,106.70400,N'APPROVED'),
    (@m2,N'Lollibee Q3', N'0280000003', N'250 CMT8',              N'79',N'TP.HCM',N'770',N'Quận 3',     N'27349',N'Phường 10',  10.78400,106.68000,N'APPROVED'),
    (@m3,N'Lollibee BT', N'0280000004', N'120 Xô Viết Nghệ Tĩnh', N'79',N'TP.HCM',N'769',N'Bình Thạnh',N'27145',N'Phường 21',  10.80400,106.71300,N'APPROVED'),
    (@m4,N'Lollibee TD', N'0280000005', N'5 Kha Vạn Cân',         N'79',N'TP.HCM',N'762',N'Thủ Đức',   N'26848',N'Linh Chiểu', 10.85000,106.75800,N'APPROVED'),
    (@m5,N'Lollibee DN', N'0236000006', N'99 Nguyễn Văn Linh',    N'48',N'Đà Nẵng',N'490',N'Hải Châu', N'20194',N'Phước Ninh', 16.06000,108.22200,N'PENDING');

    INSERT INTO dbo.MerchantKYC(merchant_user_id,business_name,business_license_number,document_url,reviewed_by_admin_id,review_status,review_note)
    VALUES
    (@m1,N'Hộ KD Lollibee Q1',N'GP-001',N'https://example.com/kyc/m1.pdf',@admin,N'APPROVED',N'OK'),
    (@m2,N'Hộ KD Lollibee Q3',N'GP-002',N'https://example.com/kyc/m2.pdf',@admin,N'APPROVED',N'OK'),
    (@m3,N'Hộ KD Lollibee BT',N'GP-003',N'https://example.com/kyc/m3.pdf',@admin,N'UNDER_REVIEW',N'Đang kiểm tra'),
    (@m4,N'Hộ KD Lollibee TD',NULL,     N'https://example.com/kyc/m4.pdf',@admin,N'SUBMITTED',NULL),
    (@m5,N'Hộ KD Lollibee DN',NULL,     N'https://example.com/kyc/m5.pdf',@admin,N'REJECTED',N'Thiếu thông tin');

    INSERT INTO dbo.Categories(merchant_user_id,name,is_active,sort_order)
    VALUES
    (@m1,N'Gà rán',1,1),
    (@m2,N'Combo',1,1),
    (@m3,N'Burger',1,1),
    (@m4,N'Đồ uống',1,1),
    (@m5,N'Tráng miệng',1,1);

    DECLARE @cat_m1 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m1 AND name=N'Gà rán');
    DECLARE @cat_m2 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m2 AND name=N'Combo');
    DECLARE @cat_m3 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m3 AND name=N'Burger');
    DECLARE @cat_m4 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m4 AND name=N'Đồ uống');
    DECLARE @cat_m5 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m5 AND name=N'Tráng miệng');

    INSERT INTO dbo.FoodItems(merchant_user_id,category_id,name,description,price,image_url,is_available,is_fried,calories,protein_g,carbs_g,fat_g)
    VALUES
    (@m1,@cat_m1,N'Gà rán giòn',N'Gà rán truyền thống',45000,NULL,1,1,520,28,35,22),
    (@m1,@cat_m1,N'Gà cay',     N'Gà rán sốt cay',     50000,NULL,1,1,560,30,38,24),
    (@m2,@cat_m2,N'Combo 1',    N'Gà + khoai + nước',  79000,NULL,1,1,850,35,95,30),
    (@m2,@cat_m2,N'Combo 2',    N'Gà + burger + nước', 89000,NULL,1,1,980,40,110,35),
    (@m3,@cat_m3,N'Burger gà',  N'Burger gà giòn',     55000,NULL,1,1,650,26,70,25),
    (@m3,@cat_m3,N'Burger cá',  N'Burger cá',          52000,NULL,1,0,540,22,60,18),
    (@m4,@cat_m4,N'Trà đào',    N'Nước uống',          30000,NULL,1,0,140,0,35,0),
    (@m4,@cat_m4,N'Coca',       N'Nước uống',          20000,NULL,1,0,150,0,39,0),
    (@m5,@cat_m5,N'Kem vani',   N'Tráng miệng',        25000,NULL,1,0,210,4,24,10),
    (@m5,@cat_m5,N'Bánh flan',  N'Tráng miệng',        22000,NULL,1,0,180,6,22,6);

    DECLARE @fi1 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Gà rán giòn');
    DECLARE @fi2 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Gà cay');
    DECLARE @fi3 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Combo 1');
    DECLARE @fi4 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Combo 2');
    DECLARE @fi5 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Burger gà');
    DECLARE @fi6 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Burger cá');
    DECLARE @fi7 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Trà đào');
    DECLARE @fi9 BIGINT = (SELECT TOP 1 id FROM dbo.FoodItems WHERE name=N'Kem vani');

    INSERT INTO dbo.Carts(customer_user_id,guest_id,merchant_user_id,status)
    VALUES
    (@c1,NULL,@m1,N'ACTIVE'),
    (@c2,NULL,@m2,N'ACTIVE'),
    (@c3,NULL,@m4,N'ACTIVE'),
    (NULL,@g1,@m3,N'ACTIVE'),
    (NULL,@g2,@m5,N'ACTIVE');

    DECLARE @cart1 BIGINT = (SELECT MIN(id) FROM dbo.Carts WHERE customer_user_id=@c1);
    DECLARE @cart2 BIGINT = (SELECT MIN(id) FROM dbo.Carts WHERE customer_user_id=@c2);
    DECLARE @cart3 BIGINT = (SELECT MIN(id) FROM dbo.Carts WHERE customer_user_id=@c3);
    DECLARE @cart4 BIGINT = (SELECT MIN(id) FROM dbo.Carts WHERE guest_id=@g1);
    DECLARE @cart5 BIGINT = (SELECT MIN(id) FROM dbo.Carts WHERE guest_id=@g2);

    INSERT INTO dbo.CartItems(cart_id,food_item_id,quantity,unit_price_snapshot,note)
    VALUES
    (@cart1,@fi1,2,45000,NULL),
    (@cart2,@fi3,1,79000,N'Ít đá'),
    (@cart3,@fi7,2,30000,NULL),
    (@cart4,@fi5,1,55000,NULL),
    (@cart5,@fi9,3,25000,N'Giao nhanh');

    INSERT INTO dbo.ShipperProfiles(user_id,vehicle_type,vehicle_name,license_plate,status)
    VALUES
    (@s1,N'MOTORBIKE',N'Honda Vision',    N'29A1-12345',N'ACTIVE'),
    (@s2,N'MOTORBIKE',N'Yamaha Exciter',  N'59B2-67890',N'ACTIVE'),
    (@s3,N'MOTORBIKE',N'Honda Wave Alpha',N'43H1-11223',N'ACTIVE'),
    (@s4,N'BIKE',     N'Xe đạp thể thao', N'BIKE-0004', N'ACTIVE'),
    (@s5,N'MOTORBIKE',N'Honda Air Blade', N'92K1-55667',N'ACTIVE');

    INSERT INTO dbo.ShipperAvailability(shipper_user_id,is_online,current_status,current_latitude,current_longitude)
    VALUES
    (@s1,1,N'BUSY',10.7760,106.7010),
    (@s2,1,N'BUSY',10.7725,106.6985),
    (@s3,1,N'AVAILABLE',10.7758,106.7002),
    (@s4,1,N'AVAILABLE',10.8050,106.7135),
    (@s5,0,N'AVAILABLE',NULL,NULL);

    INSERT INTO dbo.ShipperWallets(shipper_user_id,balance)
    VALUES
    (@s1,0),(@s2,0),(@s3,0),(@s4,0),(@s5,0);

    INSERT INTO dbo.Orders
    (order_code,customer_user_id,guest_id,merchant_user_id,shipper_user_id,
     receiver_name,receiver_phone,delivery_address_line,
     province_code,province_name,district_code,district_name,ward_code,ward_name,
     latitude,longitude,delivery_note,
     payment_method,payment_status,order_status,expires_at,
     subtotal_amount,delivery_fee,discount_amount,total_amount,
     accepted_at,ready_at,picked_up_at,delivered_at,cancelled_at)
    VALUES
    (N'ORD0001',@c1,NULL,@m1,@s1,N'Huy',N'0900000012',N'12 Nguyễn Huệ',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26734',N'Bến Nghé',10.77653,106.70098,N'Gọi trước',
     N'COD',N'PAID',N'DELIVERED',NULL,90000,15000,0,105000,
     DATEADD(MINUTE,-40,SYSUTCDATETIME()),DATEADD(MINUTE,-30,SYSUTCDATETIME()),DATEADD(MINUTE,-25,SYSUTCDATETIME()),DATEADD(MINUTE,-5,SYSUTCDATETIME()),NULL),

    (N'ORD0002',@c2,NULL,@m2,@s2,N'Lan',N'0900000013',N'34 Lê Lợi',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26737',N'Bến Thành',10.77216,106.69817,NULL,
     N'VNPAY',N'PAID',N'DELIVERING',NULL,79000,15000,5000,89000,
     DATEADD(MINUTE,-25,SYSUTCDATETIME()),DATEADD(MINUTE,-15,SYSUTCDATETIME()),DATEADD(MINUTE,-10,SYSUTCDATETIME()),NULL,NULL),

    (N'ORD0003',@c3,NULL,@m3,NULL,N'Minh',N'0900000014',N'88 Điện Biên Phủ',
     N'79',N'TP.HCM',N'769',N'Bình Thạnh',N'27145',N'Phường 21',10.80520,106.71290,N'Để lễ tân',
     N'COD',N'UNPAID',N'READY_FOR_PICKUP',NULL,55000,12000,0,67000,
     DATEADD(MINUTE,-20,SYSUTCDATETIME()),DATEADD(MINUTE,-5,SYSUTCDATETIME()),NULL,NULL,NULL),

    (N'ORD0004',NULL,@g1,@m1,@s3,N'Guest 1',N'0987000001',N'100 Lý Tự Trọng',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26734',N'Bến Nghé',10.77590,106.70010,NULL,
     N'COD',N'UNPAID',N'FAILED',NULL,50000,15000,0,65000,
     DATEADD(MINUTE,-35,SYSUTCDATETIME()),DATEADD(MINUTE,-25,SYSUTCDATETIME()),DATEADD(MINUTE,-15,SYSUTCDATETIME()),NULL,NULL),

    (N'ORD0005',NULL,@g2,@m2,NULL,N'Guest 2',N'0987000002',N'50 Pasteur',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26737',N'Bến Thành',10.77180,106.69900,N'Hủy nếu chờ lâu',
     N'VNPAY',N'FAILED',N'CANCELLED',DATEADD(MINUTE,15,SYSUTCDATETIME()),89000,15000,0,104000,
     NULL,NULL,NULL,NULL,SYSUTCDATETIME());

    DECLARE @o1 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0001');
    DECLARE @o2 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0002');
    DECLARE @o3 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0003');
    DECLARE @o4 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0004');
    DECLARE @o5 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0005');

    INSERT INTO dbo.OrderItems(order_id,food_item_id,item_name_snapshot,unit_price_snapshot,quantity,note)
    VALUES
    (@o1,@fi1,N'Gà rán giòn',45000,2,NULL),
    (@o2,@fi3,N'Combo 1',79000,1,NULL),
    (@o3,@fi5,N'Burger gà',55000,1,NULL),
    (@o4,@fi2,N'Gà cay',50000,1,NULL),
    (@o5,@fi4,N'Combo 2',89000,1,NULL);

    INSERT INTO dbo.OrderStatusHistory(order_id,from_status,to_status,updated_by_role,updated_by_user_id,note)
    VALUES
    (@o1,NULL,N'CREATED',N'CUSTOMER',@c1,NULL),
    (@o1,N'CREATED',N'MERCHANT_ACCEPTED',N'MERCHANT',@m1,NULL),
    (@o1,N'MERCHANT_ACCEPTED',N'PREPARING',N'MERCHANT',@m1,NULL),
    (@o1,N'PREPARING',N'READY_FOR_PICKUP',N'MERCHANT',@m1,NULL),
    (@o1,N'READY_FOR_PICKUP',N'PICKED_UP',N'SHIPPER',@s1,NULL),
    (@o1,N'PICKED_UP',N'DELIVERED',N'SHIPPER',@s1,NULL),
    (@o4,NULL,N'CREATED',N'GUEST',NULL,NULL),
    (@o4,N'CREATED',N'MERCHANT_ACCEPTED',N'MERCHANT',@m1,NULL),
    (@o4,N'MERCHANT_ACCEPTED',N'DELIVERING',N'SHIPPER',@s3,NULL),
    (@o4,N'DELIVERING',N'FAILED',N'SHIPPER',@s3,N'No answer');

    INSERT INTO dbo.PaymentTransactions(order_id,provider,amount,status,provider_txn_ref,vnp_txn_ref,vnp_transaction_no,vnp_response_code,vnp_pay_date,callback_payload)
    VALUES
    (@o1,N'COD',105000,N'SUCCESS',NULL,NULL,NULL,NULL,NULL,NULL),
    (@o2,N'VNPAY',89000,N'SUCCESS',N'VNPAY-TXN-0002',N'ORD0002',N'1234567890',N'00',N'20260225160000',N'{"vnp_ResponseCode":"00"}'),
    (@o3,N'COD',67000,N'INITIATED',NULL,NULL,NULL,NULL,NULL,NULL),
    (@o4,N'COD',65000,N'FAILED',NULL,NULL,NULL,NULL,NULL,NULL),
    (@o5,N'VNPAY',104000,N'FAILED',N'VNPAY-TXN-0005',N'ORD0005',NULL,N'99',NULL,N'{"vnp_ResponseCode":"99"}');

    INSERT INTO dbo.Vouchers
    (merchant_user_id,code,title,description,discount_type,discount_value,max_discount_amount,min_order_amount,start_at,end_at,max_uses_total,max_uses_per_user,is_published,status)
    VALUES
    (@m1,N'CLICK5', N'Giảm 5k',  N'Giảm 5k cho đơn từ 50k', N'FIXED',   5000, NULL, 50000, DATEADD(DAY,-1,SYSUTCDATETIME()), DATEADD(DAY,30,SYSUTCDATETIME()), 500,2,1,N'ACTIVE'),
    (@m2,N'CLICK10',N'Giảm 10%', N'Giảm 10% tối đa 20k',    N'PERCENT', 10,   20000,80000, DATEADD(DAY,-1,SYSUTCDATETIME()), DATEADD(DAY,30,SYSUTCDATETIME()), 300,1,1,N'ACTIVE'),
    (@m3,N'FRYFREE',N'Giảm 10k', N'Giảm 10k cho đơn từ 90k',N'FIXED',   10000,NULL, 90000, DATEADD(DAY,-1,SYSUTCDATETIME()), DATEADD(DAY,10,SYSUTCDATETIME()), 200,1,1,N'ACTIVE'),
    (@m4,N'NEWUSER',N'Giảm 15k', N'Giảm 15k cho đơn từ 70k',N'FIXED',   15000,NULL, 70000, DATEADD(DAY,-1,SYSUTCDATETIME()), DATEADD(DAY,20,SYSUTCDATETIME()), 100,1,1,N'ACTIVE'),
    (@m5,N'WEEKEND',N'Giảm 5%',  N'Giảm 5% cuối tuần',      N'PERCENT', 5,    15000,40000, DATEADD(DAY,-1,SYSUTCDATETIME()), DATEADD(DAY,60,SYSUTCDATETIME()), 999,3,0,N'INACTIVE');

    DECLARE @v1 BIGINT = (SELECT id FROM dbo.Vouchers WHERE merchant_user_id=@m1 AND code=N'CLICK5');
    DECLARE @v2 BIGINT = (SELECT id FROM dbo.Vouchers WHERE merchant_user_id=@m2 AND code=N'CLICK10');
    DECLARE @v3 BIGINT = (SELECT id FROM dbo.Vouchers WHERE merchant_user_id=@m3 AND code=N'FRYFREE');
    DECLARE @v4 BIGINT = (SELECT id FROM dbo.Vouchers WHERE merchant_user_id=@m4 AND code=N'NEWUSER');
    DECLARE @v5 BIGINT = (SELECT id FROM dbo.Vouchers WHERE merchant_user_id=@m5 AND code=N'WEEKEND');

    INSERT INTO dbo.VoucherUsages(voucher_id,order_id,customer_user_id,guest_id)
    VALUES
    (@v2,@o2,@c2,NULL),
    (@v1,@o1,@c1,NULL),
    (@v3,@o3,@c3,NULL),
    (@v4,@o4,NULL,@g1),
    (@v5,@o5,NULL,@g2);

    INSERT INTO dbo.DeliveryIssues(order_id,shipper_user_id,issue_type,attempts_count,note)
    VALUES
    (@o4,@s3,N'NO_ANSWER',3,N'Khách không nghe máy'),
    (@o2,@s2,N'WRONG_ADDRESS',1,N'Địa chỉ thiếu số nhà'),
    (@o1,@s1,N'OTHER',0,N'Giao trễ do kẹt xe'),
    (@o4,@s3,N'WAIT_TOO_LONG',1,N'Chờ 10 phút không gặp'),
    (@o5,@s4,N'NO_ANSWER',2,N'Khách bận');

    INSERT INTO dbo.FailedDeliveryResolutions(order_id,handled_by_admin_id,resolution_type,note)
    VALUES
    (@o4,@admin,N'CANCEL',N'Giao thất bại - hủy đơn'),
    (@o2,@admin,N'RETRY',N'Liên hệ khách cập nhật địa chỉ'),
    (@o1,@admin,N'RETURNED',N'Ghi nhận hoàn về'),
    (@o5,@admin,N'CANCEL',N'Thanh toán thất bại - hủy'),
    (@o3,@admin,N'RETRY',N'Chờ shipper nhận đơn');

    INSERT INTO dbo.Ratings(order_id,rater_customer_id,rater_guest_id,target_type,target_user_id,stars,comment)
    VALUES
    (@o1,@c1,NULL,N'SHIPPER',@s1,5,N'Giao nhanh, thân thiện'),
    (@o1,@c1,NULL,N'MERCHANT',@m1,4,N'Đồ ăn ngon'),
    (@o2,@c2,NULL,N'MERCHANT',@m2,5,N'Combo ổn, đóng gói tốt'),
    (@o4,NULL,@g1,N'SHIPPER',@s3,2,N'Gọi không được'),
    (@o5,NULL,@g2,N'MERCHANT',@m2,3,N'Đặt không thành công');

    INSERT INTO dbo.OrderIssues(order_id,reporter_user_id,issue_type,description,status)
    VALUES
    (@o2,@c2,N'WRONG_ADDRESS',N'Khách cập nhật lại địa chỉ giao hàng.',N'IN_PROGRESS'),
    (@o4,@admin,N'DELIVERY_FAILED',N'Đơn giao thất bại cần admin xử lý.',N'RESOLVED');

    INSERT INTO dbo.ShipperReviews(order_id,shipper_id,customer_id,rating,comment)
    VALUES
    (@o1,@s1,@c1,5,N'Shipper thân thiện và giao đúng giờ.'),
    (@o2,@s2,@c2,4,N'Giao hàng ổn, cần cập nhật địa chỉ kỹ hơn.');

    INSERT INTO dbo.WithdrawalRequests(shipper_user_id,amount,bank_name,bank_account_number,status,processed_at)
    VALUES
    (@s1,150000,N'MB Bank',N'123456789',N'APPROVED',SYSUTCDATETIME()),
    (@s3,80000,N'Vietcombank',N'987654321',N'PENDING',NULL);

    INSERT INTO dbo.UserBehaviorEvents(customer_user_id,guest_id,event_type,food_item_id,keyword)
    VALUES
    (@c1,NULL,N'VIEW_ITEM',@fi1,NULL),
    (@c2,NULL,N'SEARCH',NULL,N'combo'),
    (@c3,NULL,N'ADD_TO_CART',@fi5,NULL),
    (NULL,@g1,N'VIEW_ITEM',@fi2,NULL),
    (NULL,@g2,N'ORDER_PLACED',@fi3,NULL);

    INSERT INTO dbo.Notifications(user_id,guest_id,type,content,is_read)
    VALUES
    (@c1,NULL,N'ORDER_CONFIRMED',N'Đơn ORD0001 đã được xác nhận.',1),
    (@c2,NULL,N'STATUS_CHANGED',N'Đơn ORD0002 đang được giao.',0),
    (NULL,@g1,N'FAILED',N'Đơn ORD0004 giao thất bại. Vui lòng liên hệ hỗ trợ.',0),
    (@m1,NULL,N'NEW_ORDER',N'Bạn có đơn hàng mới ORD0003.',0),
    (@s1,NULL,N'ASSIGNED_ORDER',N'Bạn được gán đơn ORD0001.',1);

    INSERT INTO dbo.OrderClaims(order_id,shipper_user_id,status,expires_at)
    VALUES
    (@o3,@s3,N'CLAIMED',DATEADD(SECOND,60,SYSUTCDATETIME()));

    INSERT INTO dbo.AIConversations(customer_user_id) VALUES (@c1);
    DECLARE @conv BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.AIMessages(conversation_id,role,content)
    VALUES
    (@conv,N'USER',N'Mình muốn ăn ít dầu và hạn chế đồ chiên, gợi ý giúp.'),
    (@conv,N'ASSISTANT',N'Bạn có thể thử Burger cá hoặc Trà đào. Mình có thể thêm vào giỏ nếu bạn đồng ý.');

    INSERT INTO dbo.AutoCartProposals(customer_user_id,merchant_user_id,conversation_id,status,expires_at)
    VALUES (@c1,@m3,@conv,N'PROPOSED',DATEADD(MINUTE,10,SYSUTCDATETIME()));

    DECLARE @proposal BIGINT = SCOPE_IDENTITY();

    INSERT INTO dbo.AutoCartProposalItems(proposal_id,food_item_id,quantity,unit_price)
    VALUES
    (@proposal,@fi6,1,52000),
    (@proposal,@fi7,1,30000);

    COMMIT TRAN;
    PRINT N'ClickEat: CREATE + SEED completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT N'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

USE ClickEat;
GO

BEGIN TRY
    BEGIN TRAN;

    /* =========================================================
       1) THÊM 10 USER MỚI CÓ ROLE = MERCHANT
       ========================================================= */
    INSERT INTO dbo.Users(full_name, email, phone, password_hash, role, status)
    VALUES
    (N'Merchant 6',  N'merchant6@shop.vn',  N'0900001011', N'hash_m6',  N'MERCHANT', N'ACTIVE'),
    (N'Merchant 7',  N'merchant7@shop.vn',  N'0900001012', N'hash_m7',  N'MERCHANT', N'ACTIVE'),
    (N'Merchant 8',  N'merchant8@shop.vn',  N'0900001013', N'hash_m8',  N'MERCHANT', N'ACTIVE'),
    (N'Merchant 9',  N'merchant9@shop.vn',  N'0900001014', N'hash_m9',  N'MERCHANT', N'ACTIVE'),
    (N'Merchant 10', N'merchant10@shop.vn', N'0900001015', N'hash_m10', N'MERCHANT', N'ACTIVE'),
    (N'Merchant 11', N'merchant11@shop.vn', N'0900001016', N'hash_m11', N'MERCHANT', N'ACTIVE'),
    (N'Merchant 12', N'merchant12@shop.vn', N'0900001017', N'hash_m12', N'MERCHANT', N'ACTIVE'),
    (N'Merchant 13', N'merchant13@shop.vn', N'0900001018', N'hash_m13', N'MERCHANT', N'ACTIVE'),
    (N'Merchant 14', N'merchant14@shop.vn', N'0900001019', N'hash_m14', N'MERCHANT', N'ACTIVE'),
    (N'Merchant 15', N'merchant15@shop.vn', N'0900001020', N'hash_m15', N'MERCHANT', N'ACTIVE');

    DECLARE @m6  BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001011');
    DECLARE @m7  BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001012');
    DECLARE @m8  BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001013');
    DECLARE @m9  BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001014');
    DECLARE @m10 BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001015');
    DECLARE @m11 BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001016');
    DECLARE @m12 BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001017');
    DECLARE @m13 BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001018');
    DECLARE @m14 BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001019');
    DECLARE @m15 BIGINT = (SELECT id FROM dbo.Users WHERE phone = N'0900001020');

    /* =========================================================
       2) THÊM 10 CỬA HÀNG MỚI
       ========================================================= */
    INSERT INTO dbo.MerchantProfiles
    (
        user_id, shop_name, shop_phone, shop_address_line,
        province_code, province_name,
        district_code, district_name,
        ward_code, ward_name,
        latitude, longitude, status
    )
    VALUES
    (@m6,  N'Phở Hà Thành',         N'0241000001', N'25 Tràng Tiền',          N'01', N'Hà Nội',   N'001', N'Hoàn Kiếm',   N'00001', N'Tràng Tiền',      21.0245, 105.8572, N'APPROVED'),
    (@m7,  N'Bún Chả Phố Cổ',       N'0241000002', N'12 Hàng Mành',           N'01', N'Hà Nội',   N'001', N'Hoàn Kiếm',   N'00002', N'Hàng Gai',        21.0321, 105.8504, N'APPROVED'),
    (@m8,  N'Cơm Tấm Sài Gòn',      N'0281000003', N'88 Nguyễn Trãi',         N'79', N'TP.HCM',   N'760', N'Quận 1',      N'26737', N'Bến Thành',       10.7708, 106.6920, N'APPROVED'),
    (@m9,  N'Hủ Tiếu Nam Vang Q3',  N'0281000004', N'155 Cách Mạng Tháng 8',  N'79', N'TP.HCM',   N'770', N'Quận 3',      N'27349', N'Phường 10',       10.7818, 106.6821, N'APPROVED'),
    (@m10, N'Mì Quảng Đà Nẵng',     N'0236100005', N'45 Lê Duẩn',             N'48', N'Đà Nẵng',  N'490', N'Hải Châu',    N'20194', N'Phước Ninh',      16.0678, 108.2208, N'APPROVED'),
    (@m11, N'Bánh Tráng Cuốn DN',   N'0236100006', N'90 Nguyễn Văn Linh',     N'48', N'Đà Nẵng',  N'490', N'Hải Châu',    N'20195', N'Nam Dương',       16.0589, 108.2215, N'APPROVED'),
    (@m12, N'Lẩu Mắm Cần Thơ',      N'0292100007', N'20 Đại lộ Hòa Bình',     N'92', N'Cần Thơ',  N'916', N'Ninh Kiều',   N'31117', N'Tân An',          10.0342, 105.7872, N'APPROVED'),
    (@m13, N'Bánh Xèo Miền Tây',    N'0292100008', N'66 Mậu Thân',            N'92', N'Cần Thơ',  N'916', N'Ninh Kiều',   N'31120', N'Xuân Khánh',      10.0298, 105.7705, N'APPROVED'),
    (@m14, N'Bánh Đa Cua Hải Phòng',N'0225100009', N'18 Lạch Tray',           N'31', N'Hải Phòng',N'303', N'Ngô Quyền',   N'11110', N'Lạch Tray',       20.8449, 106.6881, N'APPROVED'),
    (@m15, N'Nem Cua Bể HP',        N'0225100010', N'50 Cầu Đất',             N'31', N'Hải Phòng',N'303', N'Ngô Quyền',   N'11111', N'Cầu Đất',         20.8574, 106.6827, N'APPROVED');

    /* =========================================================
       3) THÊM CATEGORY CHO 10 CỬA HÀNG
       ========================================================= */
    INSERT INTO dbo.Categories(merchant_user_id, name, is_active, sort_order)
    VALUES
    (@m6,  N'Món chính', 1, 1),
    (@m7,  N'Món chính', 1, 1),
    (@m8,  N'Món chính', 1, 1),
    (@m9,  N'Món nước',  1, 1),
    (@m10, N'Món chính', 1, 1),
    (@m11, N'Ăn vặt',    1, 1),
    (@m12, N'Lẩu',       1, 1),
    (@m13, N'Món chiên', 1, 1),
    (@m14, N'Món nước',  1, 1),
    (@m15, N'Hải sản',   1, 1);

    DECLARE @cat_m6  BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m6  AND name = N'Món chính' ORDER BY id DESC);
    DECLARE @cat_m7  BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m7  AND name = N'Món chính' ORDER BY id DESC);
    DECLARE @cat_m8  BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m8  AND name = N'Món chính' ORDER BY id DESC);
    DECLARE @cat_m9  BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m9  AND name = N'Món nước'  ORDER BY id DESC);
    DECLARE @cat_m10 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m10 AND name = N'Món chính' ORDER BY id DESC);
    DECLARE @cat_m11 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m11 AND name = N'Ăn vặt'    ORDER BY id DESC);
    DECLARE @cat_m12 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m12 AND name = N'Lẩu'       ORDER BY id DESC);
    DECLARE @cat_m13 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m13 AND name = N'Món chiên' ORDER BY id DESC);
    DECLARE @cat_m14 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m14 AND name = N'Món nước'  ORDER BY id DESC);
    DECLARE @cat_m15 BIGINT = (SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id = @m15 AND name = N'Hải sản'   ORDER BY id DESC);

    /* =========================================================
       4) THÊM 10 MÓN ĂN MỚI
       ========================================================= */
    INSERT INTO dbo.FoodItems
    (
        merchant_user_id, category_id, name, description, price, image_url,
        is_available, is_fried, calories, protein_g, carbs_g, fat_g
    )
    VALUES
    (@m6,  @cat_m6,  N'Phở bò tái',            N'Phở bò nước dùng truyền thống Hà Nội',      55000, NULL, 1, 0, 420, 25, 48, 10),
    (@m7,  @cat_m7,  N'Bún chả suất đầy đủ',   N'Bún chả nướng ăn kèm rau sống',             60000, NULL, 1, 0, 510, 24, 55, 16),
    (@m8,  @cat_m8,  N'Cơm tấm sườn bì chả',   N'Cơm tấm đặc trưng Sài Gòn',                  65000, NULL, 1, 0, 690, 30, 72, 20),
    (@m9,  @cat_m9,  N'Hủ tiếu Nam Vang',      N'Hủ tiếu nước topping đầy đủ',                58000, NULL, 1, 0, 500, 22, 60, 12),
    (@m10, @cat_m10, N'Mì Quảng gà',           N'Mì Quảng gà chuẩn vị Đà Nẵng',               52000, NULL, 1, 0, 470, 21, 54, 11),
    (@m11, @cat_m11, N'Bánh tráng cuốn thịt',  N'Bánh tráng cuốn thịt heo rau sống',          45000, NULL, 1, 0, 390, 18, 40, 13),
    (@m12, @cat_m12, N'Lẩu mắm cá basa',       N'Lẩu mắm miền Tây ăn kèm rau đặc sản',       179000, NULL, 1, 0, 820, 40, 50, 38),
    (@m13, @cat_m13, N'Bánh xèo tôm thịt',     N'Bánh xèo giòn nhân tôm thịt',                70000, NULL, 1, 1, 610, 20, 52, 28),
    (@m14, @cat_m14, N'Bánh đa cua',           N'Bánh đa đỏ nước cua Hải Phòng',              57000, NULL, 1, 0, 460, 23, 49, 12),
    (@m15, @cat_m15, N'Nem cua bể',            N'Nem cua bể chiên vàng giòn',                 85000, NULL, 1, 1, 530, 19, 34, 30);

    COMMIT TRAN;
    PRINT N'Đã thêm thành công 10 cửa hàng và 10 món ăn mới.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT N'Lỗi: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
UPDATE FoodItems SET image_url = '/assets/images/id2-Ga-ran-gion.jpg' WHERE id = 1;
UPDATE FoodItems SET image_url = '/assets/images/id2-Ga-cay.jpg' WHERE id = 2;
UPDATE FoodItems SET image_url = '/assets/images/id3-Combo-1.jpg' WHERE id = 3;
UPDATE FoodItems SET image_url = '/assets/images/id3-Combo-2.jpg' WHERE id = 4;
UPDATE FoodItems SET image_url = '/assets/images/id4-Burger-ga.jpg' WHERE id = 5;
UPDATE FoodItems SET image_url = '/assets/images/id4-Burger-ca.jpg' WHERE id = 6;
UPDATE FoodItems SET image_url = '/assets/images/id5-Tra-dao.jpg' WHERE id = 7;
UPDATE FoodItems SET image_url = '/assets/images/id5-Coca.jpg' WHERE id = 8;
UPDATE FoodItems SET image_url = '/assets/images/id6-Kem-vani.jpg' WHERE id = 9;
UPDATE FoodItems SET image_url = '/assets/images/id6-Banh-flan.jpg' WHERE id = 10;
UPDATE FoodItems SET image_url = '/assets/images/id18-Pho-bo-tai.jpg' WHERE id = 11;
UPDATE FoodItems SET image_url = '/assets/images/id19-Bun-cha-suat-day-du.jpg' WHERE id = 12;
UPDATE FoodItems SET image_url = '/assets/images/id20-Com-tam-suon-bi-cha.jpg' WHERE id = 13;
UPDATE FoodItems SET image_url = '/assets/images/id21-Hu-tieu-Nam-Vang.jpg' WHERE id = 14;
UPDATE FoodItems SET image_url = '/assets/images/id22-Mi-Quang-ga.jpg' WHERE id = 15;
UPDATE FoodItems SET image_url = '/assets/images/id23-Banh-trang-cuon-thit.jpg' WHERE id = 16;
UPDATE FoodItems SET image_url = '/assets/images/id24-Lau-mam-ca-basa.jpg' WHERE id = 17;
UPDATE FoodItems SET image_url = '/assets/images/id25-Banh-xeo-tom-thit.jpg' WHERE id = 18;
UPDATE FoodItems SET image_url = '/assets/images/id26-Banh-da-cua.jpg' WHERE id = 19;
UPDATE FoodItems SET image_url = '/assets/images/id27-Nem-cua-be.jpg' WHERE id = 20;

ALTER TABLE MerchantProfiles
ADD image_url NVARCHAR(500);
GO

UPDATE MerchantProfiles SET image_url = '/assets/images/id2-Lollibee-Q1.jpg' WHERE user_id = 2;
UPDATE MerchantProfiles SET image_url = '/assets/images/id3-Lollibee-Q3.jpg' WHERE user_id = 3;
UPDATE MerchantProfiles SET image_url = '/assets/images/id4-Lollibee-BT.jpg' WHERE user_id = 4;
UPDATE MerchantProfiles SET image_url = '/assets/images/id5-Lollibee-TD.jpg' WHERE user_id = 5;
UPDATE MerchantProfiles SET image_url = '/assets/images/id6-Lollibee-DN.jpg' WHERE user_id = 6;
UPDATE MerchantProfiles SET image_url = '/assets/images/id18-Pho-Ha-Thanh.jpg' WHERE user_id = 17;
UPDATE MerchantProfiles SET image_url = '/assets/images/id19-Bun-Cha-Pho-Co.jpg' WHERE user_id = 18;
UPDATE MerchantProfiles SET image_url = '/assets/images/id20-Com-Tam-Sai-Gon.jpg' WHERE user_id = 19;
UPDATE MerchantProfiles SET image_url = '/assets/images/id21-Hu-Tieu-Nam-Vang-Q3.jpg' WHERE user_id = 20;
UPDATE MerchantProfiles SET image_url = '/assets/images/id22-Mi-Quang-Da-Nang.jpg' WHERE user_id = 21;
UPDATE MerchantProfiles SET image_url = '/assets/images/id23-Banh-Trang-Cuon-DN.jpg' WHERE user_id = 22;
UPDATE MerchantProfiles SET image_url = '/assets/images/id24-Lau-Mam-Can-Tho.jpg' WHERE user_id = 23;
UPDATE MerchantProfiles SET image_url = '/assets/images/id25-Banh-Xeo-Mien-Tay.jpg' WHERE user_id = 24;
UPDATE MerchantProfiles SET image_url = '/assets/images/id26-Banh-Da-Cua-Hai-Phong.jpg' WHERE user_id = 25;
UPDATE MerchantProfiles SET image_url = '/assets/images/id27-Nem-Cua-Be-HP.jpg' WHERE user_id = 26;