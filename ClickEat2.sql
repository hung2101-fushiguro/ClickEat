/* =========================================================
   CLICK EAT - FULL DATABASE (CREATE + SEED) - SQL SERVER
   One-shot script: Tự động Drop bảng cũ -> Tạo bảng mới -> Insert Data
   Bao gồm đầy đủ tính năng: Avatar, Kháng cáo, Rút tiền, Quản lý Shipper...
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
   1) DROP TABLES (Thứ tự phải chuẩn để không dính lỗi Foreign Key)
   ========================= */
DROP TRIGGER IF EXISTS dbo.TR_CartItems_EnforceSingleMerchant;
GO

IF OBJECT_ID('dbo.WithdrawalRequests','U') IS NOT NULL DROP TABLE dbo.WithdrawalRequests;
IF OBJECT_ID('dbo.ShipperWallets','U') IS NOT NULL DROP TABLE dbo.ShipperWallets;
IF OBJECT_ID('dbo.MerchantWithdrawals','U') IS NOT NULL DROP TABLE dbo.MerchantWithdrawals;
IF OBJECT_ID('dbo.MerchantWallets','U') IS NOT NULL DROP TABLE dbo.MerchantWallets;
IF OBJECT_ID('dbo.RefundRequests','U') IS NOT NULL DROP TABLE dbo.RefundRequests;
IF OBJECT_ID('dbo.Messages','U') IS NOT NULL DROP TABLE dbo.Messages;
IF OBJECT_ID('dbo.UserAppeals','U') IS NOT NULL DROP TABLE dbo.UserAppeals;
IF OBJECT_ID('dbo.OrderIssues','U') IS NOT NULL DROP TABLE dbo.OrderIssues;
IF OBJECT_ID('dbo.ShipperReviews','U') IS NOT NULL DROP TABLE dbo.ShipperReviews;
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
IF OBJECT_ID('dbo.ShipperProfiles','U') IS NOT NULL DROP TABLE dbo.ShipperProfiles;
IF OBJECT_ID('dbo.VoucherUsages','U') IS NOT NULL DROP TABLE dbo.VoucherUsages;
IF OBJECT_ID('dbo.Vouchers','U') IS NOT NULL DROP TABLE dbo.Vouchers;
IF OBJECT_ID('dbo.PaymentTransactions','U') IS NOT NULL DROP TABLE dbo.PaymentTransactions;
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
IF OBJECT_ID('dbo.UserAuthProviders','U') IS NOT NULL DROP TABLE dbo.UserAuthProviders;
IF OBJECT_ID('dbo.Users','U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* =========================
   2) USERS, AUTH & APPEALS
   ========================= */
CREATE TABLE dbo.Users (
    id            BIGINT IDENTITY(1,1) PRIMARY KEY,
    full_name     NVARCHAR(100)    NOT NULL,
    email         NVARCHAR(150)    NULL,
    phone         NVARCHAR(20)     NOT NULL,
    password_hash NVARCHAR(255)    NULL,
    role          NVARCHAR(20)     NOT NULL,  -- GUEST/CUSTOMER/MERCHANT/SHIPPER/ADMIN
    status        NVARCHAR(20)     NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'ACTIVE',
    avatar_url    NVARCHAR(500)    NULL,      -- Đã tích hợp tính năng Upload ảnh
    created_at    DATETIME2        NOT NULL CONSTRAINT DF_Users_Created DEFAULT SYSUTCDATETIME(),
    updated_at    DATETIME2        NOT NULL CONSTRAINT DF_Users_Updated DEFAULT SYSUTCDATETIME()
);

CREATE UNIQUE INDEX UX_Users_Phone ON dbo.Users(phone);
CREATE UNIQUE INDEX UX_Users_Email ON dbo.Users(email) WHERE email IS NOT NULL;
ALTER TABLE dbo.Users ADD CONSTRAINT CK_Users_Role CHECK (role IN (N'GUEST',N'CUSTOMER',N'MERCHANT',N'SHIPPER',N'ADMIN'));
ALTER TABLE dbo.Users ADD CONSTRAINT CK_Users_Status CHECK (status IN (N'ACTIVE',N'INACTIVE'));
GO

CREATE TABLE dbo.UserAuthProviders (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id          BIGINT         NOT NULL,
    provider         NVARCHAR(30)   NOT NULL, -- GOOGLE
    provider_user_id NVARCHAR(100)  NOT NULL,
    linked_at        DATETIME2      NOT NULL CONSTRAINT DF_UserAuthProviders_Linked DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_UserAuthProviders_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
ALTER TABLE dbo.UserAuthProviders ADD CONSTRAINT CK_UserAuthProviders_Provider CHECK (provider IN (N'GOOGLE'));
CREATE UNIQUE INDEX UX_UserAuthProviders_ProviderUser ON dbo.UserAuthProviders(provider, provider_user_id);
GO

-- Bảng Đơn kháng cáo (Dành cho User bị Ban)
CREATE TABLE dbo.UserAppeals (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    reason NVARCHAR(1000) NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_UserAppeals_Status DEFAULT 'PENDING', -- PENDING/APPROVED/REJECTED
    admin_note NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_UserAppeals_Created DEFAULT SYSUTCDATETIME(),
    resolved_at DATETIME2 NULL,
    CONSTRAINT FK_UserAppeals_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
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
    CONSTRAINT FK_CustomerProfiles_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
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
    CONSTRAINT FK_Addresses_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
CREATE INDEX IX_Addresses_User ON dbo.Addresses(user_id, is_default);
GO

ALTER TABLE dbo.CustomerProfiles ADD CONSTRAINT FK_CustomerProfiles_DefaultAddress FOREIGN KEY (default_address_id) REFERENCES dbo.Addresses(id);
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
    commission_rate   DECIMAL(5,2)  NULL CONSTRAINT DF_MerchantProfiles_CommissionRate DEFAULT 0.15,
    status            NVARCHAR(20)  NOT NULL CONSTRAINT DF_MerchantProfiles_Status DEFAULT 'PENDING',
    created_at        DATETIME2     NOT NULL CONSTRAINT DF_MerchantProfiles_Created DEFAULT SYSUTCDATETIME(),
    updated_at        DATETIME2     NOT NULL CONSTRAINT DF_MerchantProfiles_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_MerchantProfiles_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
ALTER TABLE dbo.MerchantProfiles ADD CONSTRAINT CK_MerchantProfiles_Status CHECK (status IN (N'PENDING',N'APPROVED',N'REJECTED',N'SUSPENDED'));
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
    CONSTRAINT FK_MerchantKYC_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_MerchantKYC_Admin FOREIGN KEY (reviewed_by_admin_id) REFERENCES dbo.Users(id)
);
ALTER TABLE dbo.MerchantKYC ADD CONSTRAINT CK_MerchantKYC_Status CHECK (review_status IN (N'SUBMITTED',N'UNDER_REVIEW',N'APPROVED',N'REJECTED'));
GO

/* =========================
    5.1) MERCHANT WALLET
    (Cần tạo trước khi seed dùng MerchantWallets)
    ========================= */
CREATE TABLE dbo.MerchantWallets (
     merchant_user_id BIGINT        NOT NULL PRIMARY KEY,
     balance          DECIMAL(18,2) NOT NULL CONSTRAINT DF_MerchantWallets_Balance DEFAULT 0,
     updated_at       DATETIME2     NOT NULL CONSTRAINT DF_MerchantWallets_Updated DEFAULT SYSUTCDATETIME(),
     CONSTRAINT FK_MerchantWallets_Merchant FOREIGN KEY (merchant_user_id)
          REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
);
GO

/* =========================
   6) MENU: CATEGORIES & FOOD ITEMS
   ========================= */
CREATE TABLE dbo.Categories (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    merchant_user_id BIGINT        NOT NULL,
    name             NVARCHAR(100) NOT NULL,
    is_active        BIT           NOT NULL CONSTRAINT DF_Categories_Active DEFAULT 1,
    sort_order       INT           NOT NULL CONSTRAINT DF_Categories_Sort DEFAULT 0,
    CONSTRAINT FK_Categories_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
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
    CONSTRAINT FK_FoodItems_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_FoodItems_Category FOREIGN KEY (category_id) REFERENCES dbo.Categories(id)
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
    CONSTRAINT CK_Carts_Owner CHECK ((customer_user_id IS NOT NULL AND guest_id IS NULL) OR (customer_user_id IS NULL AND guest_id IS NOT NULL))
);
ALTER TABLE dbo.Carts ADD CONSTRAINT CK_Carts_Status CHECK (status IN (N'ACTIVE',N'CHECKED_OUT',N'ABANDONED'));
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
ON dbo.CartItems AFTER INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @x TABLE (cart_id BIGINT, food_item_id BIGINT, food_merchant BIGINT);
    INSERT INTO @x(cart_id, food_item_id, food_merchant) SELECT i.cart_id, i.food_item_id, f.merchant_user_id FROM inserted i JOIN dbo.FoodItems f ON f.id = i.food_item_id;
    UPDATE c SET c.merchant_user_id = x.food_merchant, c.updated_at = SYSUTCDATETIME() FROM dbo.Carts c JOIN @x x ON x.cart_id = c.id WHERE c.merchant_user_id IS NULL;
    IF EXISTS (SELECT 1 FROM @x x JOIN dbo.Carts c ON c.id = x.cart_id WHERE c.merchant_user_id IS NOT NULL AND c.merchant_user_id <> x.food_merchant)
    BEGIN
        RAISERROR(N'Cart chỉ được chứa món từ 1 cửa hàng.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* =========================
   8) ORDERS + STATUS HISTORY + ISSUES
   ========================= */
CREATE TABLE dbo.Orders (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_code          NVARCHAR(30)     NOT NULL,
    customer_user_id    BIGINT           NULL,
    guest_id            UNIQUEIDENTIFIER NULL,
    merchant_user_id    BIGINT           NOT NULL,
    shipper_user_id     BIGINT           NULL,
    receiver_name       NVARCHAR(100)    NOT NULL,
    receiver_phone      NVARCHAR(20)     NOT NULL,
    delivery_address_line NVARCHAR(255)  NOT NULL,
    province_code       NVARCHAR(20)     NOT NULL,
    province_name       NVARCHAR(100)    NOT NULL,
    district_code       NVARCHAR(20)     NOT NULL,
    district_name       NVARCHAR(100)    NOT NULL,
    ward_code           NVARCHAR(20)     NOT NULL,
    ward_name           NVARCHAR(100)    NOT NULL,
    latitude            DECIMAL(10,7)    NULL,
    longitude           DECIMAL(10,7)    NULL,
    delivery_note       NVARCHAR(255)    NULL,
    payment_method      NVARCHAR(20)     NOT NULL, 
    payment_status      NVARCHAR(20)     NOT NULL CONSTRAINT DF_Orders_PaymentStatus DEFAULT 'UNPAID', 
    order_status        NVARCHAR(30)     NOT NULL CONSTRAINT DF_Orders_OrderStatus DEFAULT 'CREATED',
    expires_at          DATETIME2        NULL,
    subtotal_amount     DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_Subtotal DEFAULT 0,
    delivery_fee        DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_DeliveryFee DEFAULT 0,
    discount_amount     DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_Discount DEFAULT 0,
    app_fee             DECIMAL(18,2)    NULL CONSTRAINT DF_Orders_AppFee DEFAULT 0,
    total_amount        DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_Total DEFAULT 0,
    proof_image_url     NVARCHAR(500)    NULL, -- Đã tích hợp ảnh bằng chứng giao hàng
    created_at          DATETIME2        NOT NULL CONSTRAINT DF_Orders_Created DEFAULT SYSUTCDATETIME(),
    accepted_at         DATETIME2        NULL,
    ready_at            DATETIME2        NULL,
    picked_up_at        DATETIME2        NULL,
    delivered_at        DATETIME2        NULL,
    cancelled_at        DATETIME2        NULL,
    CONSTRAINT UQ_Orders_Code UNIQUE(order_code),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Orders_Guest    FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT FK_Orders_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id),
    CONSTRAINT FK_Orders_Shipper  FOREIGN KEY (shipper_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT CK_Orders_Owner CHECK ((customer_user_id IS NOT NULL AND guest_id IS NULL) OR (customer_user_id IS NULL AND guest_id IS NOT NULL))
);
ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_PaymentMethod CHECK (payment_method IN (N'COD',N'VNPAY'));
ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_PaymentStatus CHECK (payment_status IN (N'UNPAID',N'PENDING',N'PAID',N'FAILED',N'REFUNDED'));
ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_OrderStatus CHECK (order_status IN (N'CREATED',N'PENDING_PAYMENT',N'PAID',N'MERCHANT_ACCEPTED',N'MERCHANT_REJECTED',N'PREPARING',N'READY_FOR_PICKUP',N'PICKED_UP',N'DELIVERING',N'DELIVERED',N'CANCELLED',N'FAILED',N'REFUNDED'));
CREATE INDEX IX_Orders_Merchant_Status ON dbo.Orders(merchant_user_id, order_status, created_at);
CREATE INDEX IX_Orders_Shipper_Status  ON dbo.Orders(shipper_user_id, order_status, created_at);
CREATE INDEX IX_Orders_Customer_Created ON dbo.Orders(customer_user_id, created_at) WHERE customer_user_id IS NOT NULL;
GO

CREATE TABLE dbo.OrderItems (
    id                   BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id             BIGINT        NOT NULL,
    food_item_id         BIGINT        NOT NULL,
    item_name_snapshot   NVARCHAR(150) NOT NULL,
    unit_price_snapshot  DECIMAL(18,2) NOT NULL,
    quantity             INT           NOT NULL,
    note                 NVARCHAR(255) NULL,
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
ALTER TABLE dbo.OrderStatusHistory ADD CONSTRAINT CK_OrderStatusHistory_Role CHECK (updated_by_role IN (N'CUSTOMER',N'GUEST',N'MERCHANT',N'SHIPPER',N'ADMIN',N'SYSTEM'));
CREATE INDEX IX_OrderStatusHistory_Order ON dbo.OrderStatusHistory(order_id, created_at);
GO

CREATE TABLE dbo.OrderIssues (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    reporter_user_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id),
    issue_type VARCHAR(50) NOT NULL,
    description NVARCHAR(500),
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT GETDATE()
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
ALTER TABLE dbo.PaymentTransactions ADD CONSTRAINT CK_PaymentTransactions_Provider CHECK (provider IN (N'VNPAY',N'COD'));
ALTER TABLE dbo.PaymentTransactions ADD CONSTRAINT CK_PaymentTransactions_Status CHECK (status IN (N'INITIATED',N'PENDING',N'SUCCESS',N'FAILED',N'REFUNDED'));
CREATE INDEX IX_PaymentTransactions_Order ON dbo.PaymentTransactions(order_id);
CREATE UNIQUE INDEX UX_PaymentTransactions_VnpTxnRef ON dbo.PaymentTransactions(vnp_txn_ref) WHERE vnp_txn_ref IS NOT NULL;
CREATE UNIQUE INDEX UX_PaymentTransactions_VnpTransactionNo ON dbo.PaymentTransactions(vnp_transaction_no) WHERE vnp_transaction_no IS NOT NULL;
GO

/* =========================
   10) VOUCHERS
   ========================= */
CREATE TABLE dbo.Vouchers (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    merchant_user_id    BIGINT        NOT NULL,
    code                NVARCHAR(50)  NOT NULL,
    title               NVARCHAR(200) NULL,
    description         NVARCHAR(1000) NULL,
    discount_type       NVARCHAR(10)  NOT NULL, 
    discount_value      DECIMAL(18,2) NOT NULL,
    max_discount_amount DECIMAL(18,2) NULL,
    min_order_amount    DECIMAL(18,2) NULL,
    start_at            DATETIME2     NOT NULL,
    end_at              DATETIME2     NOT NULL,
    max_uses_total      INT           NULL,
    max_uses_per_user   INT           NULL,
    is_published        BIT           NOT NULL CONSTRAINT DF_Vouchers_Published DEFAULT 0,
    status              NVARCHAR(20)  NOT NULL CONSTRAINT DF_Vouchers_Status DEFAULT 'ACTIVE', 
    created_at          DATETIME2     NOT NULL CONSTRAINT DF_Vouchers_Created DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2     NOT NULL CONSTRAINT DF_Vouchers_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Vouchers_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
);
ALTER TABLE dbo.Vouchers ADD CONSTRAINT CK_Vouchers_DiscountType CHECK (discount_type IN (N'PERCENT',N'FIXED'));
ALTER TABLE dbo.Vouchers ADD CONSTRAINT CK_Vouchers_Status CHECK (status IN (N'ACTIVE',N'INACTIVE'));
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
    CONSTRAINT FK_VoucherUsages_Order   FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_VoucherUsages_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_VoucherUsages_Guest FOREIGN KEY (guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT CK_VoucherUsages_Owner CHECK ((customer_user_id IS NOT NULL AND guest_id IS NULL) OR (customer_user_id IS NULL AND guest_id IS NOT NULL))
);
CREATE UNIQUE INDEX UX_VoucherUsages_Order ON dbo.VoucherUsages(order_id);
GO

/* =========================
   11) SHIPPER + WALLET + CLAIMS
   ========================= */
CREATE TABLE dbo.ShipperProfiles (
    user_id      BIGINT       NOT NULL PRIMARY KEY,
    vehicle_type NVARCHAR(20) NOT NULL, -- MOTORBIKE/BIKE
    vehicle_name  NVARCHAR(100) NULL,   -- Đã tích hợp Tên xe
    license_plate NVARCHAR(20) NULL,    -- Đã tích hợp Biển số
    status       NVARCHAR(20) NOT NULL CONSTRAINT DF_ShipperProfiles_Status DEFAULT 'ACTIVE',
    created_at   DATETIME2    NOT NULL CONSTRAINT DF_ShipperProfiles_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ShipperProfiles_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
ALTER TABLE dbo.ShipperProfiles ADD CONSTRAINT CK_ShipperProfiles_Vehicle CHECK (vehicle_type IN (N'MOTORBIKE',N'BIKE'));
ALTER TABLE dbo.ShipperProfiles ADD CONSTRAINT CK_ShipperProfiles_Status CHECK (status IN (N'ACTIVE',N'SUSPENDED'));
GO

CREATE TABLE dbo.ShipperWallets (
    shipper_user_id BIGINT NOT NULL PRIMARY KEY,
    balance         DECIMAL(18,2) NOT NULL CONSTRAINT DF_ShipperWallets_Balance DEFAULT 0,
    updated_at      DATETIME2 NOT NULL CONSTRAINT DF_ShipperWallets_Updated DEFAULT SYSUTCDATETIME(),
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
    CONSTRAINT FK_WithdrawalRequests_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.ShipperProfiles(user_id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.ShipperAvailability (
    shipper_user_id   BIGINT       NOT NULL PRIMARY KEY,
    is_online         BIT          NOT NULL CONSTRAINT DF_ShipperAvailability_Online DEFAULT 0,
    current_status    NVARCHAR(20) NOT NULL CONSTRAINT DF_ShipperAvailability_Status DEFAULT 'AVAILABLE', 
    current_latitude  DECIMAL(10,7) NULL,
    current_longitude DECIMAL(10,7) NULL,
    updated_at        DATETIME2    NOT NULL CONSTRAINT DF_ShipperAvailability_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ShipperAvailability_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.ShipperProfiles(user_id) ON DELETE CASCADE
);
ALTER TABLE dbo.ShipperAvailability ADD CONSTRAINT CK_ShipperAvailability_Status CHECK (current_status IN (N'AVAILABLE',N'BUSY'));
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
ALTER TABLE dbo.OrderClaims ADD CONSTRAINT CK_OrderClaims_Status CHECK (status IN (N'CLAIMED',N'CONFIRMED',N'EXPIRED',N'CANCELLED'));
CREATE UNIQUE INDEX UX_OrderClaims_ActiveOrder ON dbo.OrderClaims(order_id) WHERE status IN (N'CLAIMED',N'CONFIRMED');
GO

/* =========================
   12) DELIVERY ISSUES + ADMIN RESOLUTION
   ========================= */
CREATE TABLE dbo.DeliveryIssues (
    id             BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id        BIGINT       NOT NULL,
    shipper_user_id BIGINT       NOT NULL,
    issue_type     NVARCHAR(30)  NOT NULL, 
    attempts_count INT           NOT NULL CONSTRAINT DF_DeliveryIssues_Attempts DEFAULT 0,
    note           NVARCHAR(255) NULL,
    created_at     DATETIME2     NOT NULL CONSTRAINT DF_DeliveryIssues_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_DeliveryIssues_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_DeliveryIssues_Shipper FOREIGN KEY (shipper_user_id) REFERENCES dbo.Users(id)
);
GO

CREATE TABLE dbo.FailedDeliveryResolutions (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id             BIGINT       NOT NULL,
    handled_by_admin_id  BIGINT       NOT NULL,
    resolution_type     NVARCHAR(30)  NOT NULL, 
    note                NVARCHAR(255) NULL,
    created_at          DATETIME2     NOT NULL CONSTRAINT DF_FailedDeliveryResolutions_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_FailedDeliveryResolutions_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_FailedDeliveryResolutions_Admin FOREIGN KEY (handled_by_admin_id) REFERENCES dbo.Users(id)
);
GO

/* =========================
   13) RATINGS & REVIEWS
   ========================= */
CREATE TABLE dbo.Ratings (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id          BIGINT           NOT NULL,
    rater_customer_id BIGINT           NULL,
    rater_guest_id    UNIQUEIDENTIFIER NULL,
    target_type       NVARCHAR(20)     NOT NULL, 
    target_user_id    BIGINT           NOT NULL,
    stars             INT              NOT NULL,
    comment           NVARCHAR(500)    NULL,
    created_at        DATETIME2        NOT NULL CONSTRAINT DF_Ratings_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Ratings_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_Ratings_RaterCustomer FOREIGN KEY (rater_customer_id) REFERENCES dbo.Users(id),
    CONSTRAINT FK_Ratings_RaterGuest FOREIGN KEY (rater_guest_id) REFERENCES dbo.GuestSessions(guest_id),
    CONSTRAINT FK_Ratings_TargetUser FOREIGN KEY (target_user_id) REFERENCES dbo.Users(id),
    CONSTRAINT CK_Ratings_Rater CHECK ((rater_customer_id IS NOT NULL AND rater_guest_id IS NULL) OR (rater_customer_id IS NULL AND rater_guest_id IS NOT NULL)),
    CONSTRAINT CK_Ratings_TargetType CHECK (target_type IN (N'MERCHANT',N'SHIPPER')),
    CONSTRAINT CK_Ratings_Stars CHECK (stars BETWEEN 1 AND 5)
);
CREATE UNIQUE INDEX UX_Ratings_OrderTarget ON dbo.Ratings(order_id, target_type);
GO

CREATE TABLE dbo.ShipperReviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Orders(id), 
    shipper_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id), 
    customer_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id), 
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);
GO

/* =========================
   14) USER BEHAVIOR EVENTS + NOTIFICATIONS
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
    CONSTRAINT CK_UserBehaviorEvents_Owner CHECK ((customer_user_id IS NOT NULL AND guest_id IS NULL) OR (customer_user_id IS NULL AND guest_id IS NOT NULL))
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
    CONSTRAINT CK_Notifications_Target CHECK ((user_id IS NOT NULL AND guest_id IS NULL) OR (user_id IS NULL AND guest_id IS NOT NULL))
);
CREATE INDEX IX_Notifications_User ON dbo.Notifications(user_id, is_read, created_at) WHERE user_id IS NOT NULL;
CREATE INDEX IX_Notifications_Guest ON dbo.Notifications(guest_id, is_read, created_at) WHERE guest_id IS NOT NULL;
GO

/* =========================
   15) AI CHAT + AUTO-CART
   ========================= */
CREATE TABLE dbo.AIConversations (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_user_id BIGINT    NOT NULL,
    created_at       DATETIME2 NOT NULL CONSTRAINT DF_AIConversations_Created DEFAULT SYSUTCDATETIME(),
    last_activity_at DATETIME2 NOT NULL CONSTRAINT DF_AIConversations_Last DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_AIConversations_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.AIMessages (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    conversation_id BIGINT        NOT NULL,
    role            NVARCHAR(20)  NOT NULL, 
    content         NVARCHAR(MAX) NOT NULL,
    created_at      DATETIME2     NOT NULL CONSTRAINT DF_AIMessages_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_AIMessages_Conversation FOREIGN KEY (conversation_id) REFERENCES dbo.AIConversations(id) ON DELETE CASCADE,
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
    CONSTRAINT FK_AutoCartProposals_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE,
    CONSTRAINT FK_AutoCartProposals_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE NO ACTION,
    CONSTRAINT FK_AutoCartProposals_Conversation FOREIGN KEY (conversation_id) REFERENCES dbo.AIConversations(id) ON DELETE NO ACTION,
    CONSTRAINT CK_AutoCartProposals_Status CHECK (status IN (N'PROPOSED',N'CONFIRMED',N'REJECTED',N'EXPIRED'))
);
GO

CREATE TABLE dbo.AutoCartProposalItems (
    id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    proposal_id  BIGINT        NOT NULL,
    food_item_id BIGINT        NOT NULL,
    quantity     INT           NOT NULL,
    unit_price   DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_AutoCartProposalItems_Proposal FOREIGN KEY (proposal_id) REFERENCES dbo.AutoCartProposals(id) ON DELETE CASCADE,
    CONSTRAINT FK_AutoCartProposalItems_Food FOREIGN KEY (food_item_id) REFERENCES dbo.FoodItems(id),
    CONSTRAINT CK_AutoCartProposalItems_Qty CHECK (quantity > 0)
);
CREATE UNIQUE INDEX UX_AutoCartProposalItems_ProposalFood ON dbo.AutoCartProposalItems(proposal_id, food_item_id);
GO

/* =========================================================
   16) SEED DATA 
   ========================================================= */
BEGIN TRY
    BEGIN TRAN;

    /* ---- Users ---- */
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

    /* ---- Google providers ---- */
    INSERT INTO dbo.UserAuthProviders(user_id,provider,provider_user_id)
    VALUES
    (@c1,N'GOOGLE',N'google-sub-c1'),
    (@c2,N'GOOGLE',N'google-sub-c2'),
    (@c3,N'GOOGLE',N'google-sub-c3'),
    (@c4,N'GOOGLE',N'google-sub-c4'),
    (@c5,N'GOOGLE',N'google-sub-c5');

    /* ---- Guests ---- */
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

    /* ---- Customer profiles ---- */
    INSERT INTO dbo.CustomerProfiles(user_id,food_preferences,allergies,health_goal,daily_calorie_target)
    VALUES
    (@c1,N'Ít dầu, thích cay vừa, nhiều rau', N'Hải sản', N'Giữ dáng', 2000),
    (@c2,N'Thích combo, không ăn quá cay', NULL, N'Tăng cân nhẹ', 2400),
    (@c3,N'Ưu tiên món nướng, hạn chế đồ chiên', NULL, N'Tăng cơ', 2600),
    (@c4,N'Ăn thanh đạm, ít muối', NULL, N'Sức khỏe', 1900),
    (@c5,N'Không ăn ngọt, thích nước không đường', NULL, N'Giảm mỡ', 2100);

    /* ---- Addresses ---- */
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

    /* ---- Merchant profiles ---- */
    INSERT INTO dbo.MerchantProfiles
    (user_id,shop_name,shop_phone,shop_address_line,province_code,province_name,district_code,district_name,ward_code,ward_name,latitude,longitude,status)
    VALUES
    (@m1,N'Lollibee Q1', N'0280000002', N'10 Đồng Khởi',          N'79',N'TP.HCM',N'760',N'Quận 1',     N'26734',N'Bến Nghé',   10.77500,106.70400,N'APPROVED'),
    (@m2,N'Lollibee Q3', N'0280000003', N'250 CMT8',              N'79',N'TP.HCM',N'770',N'Quận 3',     N'27349',N'Phường 10',  10.78400,106.68000,N'APPROVED'),
    (@m3,N'Lollibee BT', N'0280000004', N'120 Xô Viết Nghệ Tĩnh', N'79',N'TP.HCM',N'769',N'Bình Thạnh',N'27145',N'Phường 21',  10.80400,106.71300,N'APPROVED'),
    (@m4,N'Lollibee TD', N'0280000005', N'5 Kha Vạn Cân',         N'79',N'TP.HCM',N'762',N'Thủ Đức',   N'26848',N'Linh Chiểu', 10.85000,106.75800,N'PENDING'),
    (@m5,N'Lollibee DN', N'0236000006', N'99 Nguyễn Văn Linh',    N'48',N'Đà Nẵng',N'490',N'Hải Châu', N'20194',N'Phước Ninh', 16.06000,108.22200,N'PENDING');

    /* ---- Merchant KYC ---- */
    INSERT INTO dbo.MerchantKYC(merchant_user_id,business_name,business_license_number,document_url,reviewed_by_admin_id,review_status,review_note)
    VALUES
    (@m1,N'Hộ KD Lollibee Q1',N'GP-001',N'https://example.com/kyc/m1.pdf',@admin,N'APPROVED',N'OK'),
    (@m2,N'Hộ KD Lollibee Q3',N'GP-002',N'https://example.com/kyc/m2.pdf',@admin,N'APPROVED',N'OK'),
    (@m3,N'Hộ KD Lollibee BT',N'GP-003',N'https://example.com/kyc/m3.pdf',@admin,N'UNDER_REVIEW',N'Đang kiểm tra'),
    (@m4,N'Hộ KD Lollibee TD',NULL,     N'https://example.com/kyc/m4.pdf',@admin,N'SUBMITTED',NULL),
    (@m5,N'Hộ KD Lollibee DN',NULL,     N'https://example.com/kyc/m5.pdf',@admin,N'REJECTED',N'Thiếu thông tin (resubmit được)');

    /* ---- Categories ---- */
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

    /* ---- Food items (10) ---- */
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

    /* ---- Carts ---- */
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

    /* ---- CartItems ---- */
    INSERT INTO dbo.CartItems(cart_id,food_item_id,quantity,unit_price_snapshot,note)
    VALUES
    (@cart1,@fi1,2,45000,NULL),
    (@cart2,@fi3,1,79000,N'Ít đá'),
    (@cart3,@fi7,2,30000,NULL),
    (@cart4,@fi5,1,55000,NULL),
    (@cart5,@fi9,3,25000,N'Giao nhanh');

    /* ---- Shipper profiles + availability ---- */
    INSERT INTO dbo.ShipperProfiles(user_id,vehicle_type, vehicle_name, license_plate, status)
    VALUES
    (@s1,N'MOTORBIKE', N'Honda Vision', N'29A1-12345', N'ACTIVE'),
    (@s2,N'MOTORBIKE', N'Yamaha Exciter', N'59B2-67890', N'ACTIVE'),
    (@s3,N'MOTORBIKE', NULL, NULL, N'ACTIVE'),
    (@s4,N'BIKE', NULL, NULL, N'ACTIVE'),
    (@s5,N'MOTORBIKE', NULL, NULL, N'ACTIVE');

    INSERT INTO dbo.ShipperAvailability(shipper_user_id,is_online,current_status,current_latitude,current_longitude)
    VALUES
    (@s1,1,N'BUSY',10.7760,106.7010),
    (@s2,1,N'BUSY',10.7725,106.6985),
    (@s3,1,N'AVAILABLE',10.7758,106.7002),
    (@s4,1,N'AVAILABLE',10.8050,106.7135),
    (@s5,0,N'AVAILABLE',NULL,NULL);

    /* Cấp ví tiền (0đ) cho các shipper đang có trong hệ thống */
    INSERT INTO dbo.ShipperWallets (shipper_user_id, balance)
    SELECT user_id, 0 FROM dbo.ShipperProfiles;

    /* ---- Orders ---- */
    INSERT INTO dbo.Orders
    (order_code,customer_user_id,guest_id,merchant_user_id,shipper_user_id,
     receiver_name,receiver_phone,delivery_address_line,
     province_code,province_name,district_code,district_name,ward_code,ward_name,
     latitude,longitude,delivery_note,
     payment_method,payment_status,order_status,expires_at,
     subtotal_amount,delivery_fee,discount_amount,total_amount,
     accepted_at,ready_at,picked_up_at,delivered_at,cancelled_at)
    VALUES
    (N'ORD0001',@c1,NULL,@m1,@s1,
     N'Huy',N'0900000012',N'12 Nguyễn Huệ',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26734',N'Bến Nghé',
     10.77653,106.70098,N'Gọi trước',
     N'COD',N'PAID',N'DELIVERED',NULL,
     90000,15000,0,105000,
     DATEADD(MINUTE,-40,SYSUTCDATETIME()),DATEADD(MINUTE,-30,SYSUTCDATETIME()),DATEADD(MINUTE,-25,SYSUTCDATETIME()),DATEADD(MINUTE,-5,SYSUTCDATETIME()),NULL),

    (N'ORD0002',@c2,NULL,@m2,@s2,
     N'Lan',N'0900000013',N'34 Lê Lợi',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26737',N'Bến Thành',
     10.77216,106.69817,NULL,
     N'VNPAY',N'PAID',N'DELIVERING',NULL,
     79000,15000,5000,89000,
     DATEADD(MINUTE,-25,SYSUTCDATETIME()),DATEADD(MINUTE,-15,SYSUTCDATETIME()),DATEADD(MINUTE,-10,SYSUTCDATETIME()),NULL,NULL),

    (N'ORD0003',@c3,NULL,@m3,NULL,
     N'Minh',N'0900000014',N'88 Điện Biên Phủ',
     N'79',N'TP.HCM',N'769',N'Bình Thạnh',N'27145',N'Phường 21',
     10.80520,106.71290,N'Để lễ tân',
     N'COD',N'UNPAID',N'READY_FOR_PICKUP',NULL,
     55000,12000,0,67000,
     DATEADD(MINUTE,-20,SYSUTCDATETIME()),DATEADD(MINUTE,-5,SYSUTCDATETIME()),NULL,NULL,NULL),

    (N'ORD0004',NULL,@g1,@m1,@s3,
     N'Guest 1',N'0987000001',N'100 Lý Tự Trọng',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26734',N'Bến Nghé',
     10.77590,106.70010,NULL,
     N'COD',N'UNPAID',N'FAILED',NULL,
     50000,15000,0,65000,
     DATEADD(MINUTE,-35,SYSUTCDATETIME()),DATEADD(MINUTE,-25,SYSUTCDATETIME()),DATEADD(MINUTE,-15,SYSUTCDATETIME()),NULL,NULL),

    (N'ORD0005',NULL,@g2,@m2,NULL,
     N'Guest 2',N'0987000002',N'50 Pasteur',
     N'79',N'TP.HCM',N'760',N'Quận 1',N'26737',N'Bến Thành',
     10.77180,106.69900,N'Hủy nếu chờ lâu',
     N'VNPAY',N'FAILED',N'CANCELLED',DATEADD(MINUTE,15,SYSUTCDATETIME()),
     89000,15000,0,104000,
     NULL,NULL,NULL,NULL,SYSUTCDATETIME());

    DECLARE @o1 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0001');
    DECLARE @o2 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0002');
    DECLARE @o3 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0003');
    DECLARE @o4 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0004');
    DECLARE @o5 BIGINT = (SELECT id FROM dbo.Orders WHERE order_code=N'ORD0005');

    /* ---- OrderItems ---- */
    INSERT INTO dbo.OrderItems(order_id,food_item_id,item_name_snapshot,unit_price_snapshot,quantity,note)
    VALUES
    (@o1,@fi1,N'Gà rán giòn',45000,2,NULL),
    (@o2,@fi3,N'Combo 1',79000,1,NULL),
    (@o3,@fi5,N'Burger gà',55000,1,NULL),
    (@o4,@fi2,N'Gà cay',50000,1,NULL),
    (@o5,@fi4,N'Combo 2',89000,1,NULL);

    /* ---- Status history ---- */
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

    /* ---- Payments ---- */
    INSERT INTO dbo.PaymentTransactions(order_id,provider,amount,status,provider_txn_ref,vnp_txn_ref,vnp_transaction_no,vnp_response_code,vnp_pay_date,callback_payload)
    VALUES
    (@o1,N'COD', 105000,N'SUCCESS',NULL,NULL,NULL,NULL,NULL,NULL),
    (@o2,N'VNPAY',89000,N'SUCCESS',N'VNPAY-TXN-0002',N'ORD0002',N'1234567890',N'00',N'20260225160000',N'{"vnp_ResponseCode":"00"}'),
    (@o3,N'COD',  67000,N'INITIATED',NULL,NULL,NULL,NULL,NULL,NULL),
    (@o4,N'COD',  65000,N'FAILED',NULL,NULL,NULL,NULL,NULL,NULL),
    (@o5,N'VNPAY',104000,N'FAILED',N'VNPAY-TXN-0005',N'ORD0005',NULL,N'99',NULL,N'{"vnp_ResponseCode":"99"}');

    /* ---- Settle delivered seed orders to keep wallets aligned with app logic ---- */
    DECLARE @SettleOrderCode NVARCHAR(30);
    DECLARE @SettleProof NVARCHAR(255);
    DECLARE @SettleOrderId BIGINT;
    DECLARE @SettleMerchantId BIGINT;
    DECLARE @SettleShipperId BIGINT;
    DECLARE @SettleSubtotal DECIMAL(18,2);
    DECLARE @SettleDiscount DECIMAL(18,2);
    DECLARE @SettleDelivery DECIMAL(18,2);
    DECLARE @SettleTotal DECIMAL(18,2);
    DECLARE @SettleAppFee DECIMAL(18,2);
    DECLARE @SettleCommission DECIMAL(18,4);
    DECLARE @SettleCommissionPresent BIT;
    DECLARE @SettleGross DECIMAL(18,2);
    DECLARE @SettleEffectiveAppFee DECIMAL(18,2);
    DECLARE @SettleMerchantIncome DECIMAL(18,2);

    /* helper to settle one order idempotently (only when proof is missing) */
    DECLARE @SeedOrders TABLE(order_code NVARCHAR(30), proof NVARCHAR(255));
    INSERT INTO @SeedOrders(order_code, proof)
    VALUES (N'ORD0001', N'seed/proof_ord0001.jpg'),
           (N'DEMO1W_VIP_001', N'seed/proof_demo1w_vip_001.jpg');

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT order_code, proof FROM @SeedOrders;
    OPEN cur;
    FETCH NEXT FROM cur INTO @SettleOrderCode, @SettleProof;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SettleOrderId = NULL;
        SELECT @SettleOrderId = id,
               @SettleMerchantId = merchant_user_id,
               @SettleShipperId = shipper_user_id,
               @SettleSubtotal = ISNULL(subtotal_amount, 0),
               @SettleDiscount = ISNULL(discount_amount, 0),
               @SettleDelivery = ISNULL(delivery_fee, 0),
               @SettleTotal = ISNULL(total_amount, 0),
               @SettleAppFee = ISNULL(app_fee, 0),
               @SettleCommission = mp.commission_rate,
               @SettleCommissionPresent = CASE WHEN mp.commission_rate IS NULL THEN 0 ELSE 1 END,
               @SettleGross = NULL,
               @SettleEffectiveAppFee = NULL,
               @SettleMerchantIncome = NULL
        FROM dbo.Orders o WITH (UPDLOCK, ROWLOCK)
        LEFT JOIN dbo.MerchantProfiles mp ON mp.user_id = o.merchant_user_id
        WHERE o.order_code = @SettleOrderCode AND o.order_status = N'DELIVERED';

        IF @SettleOrderId IS NOT NULL
        BEGIN
            DECLARE @CurrentProof NVARCHAR(255) = (SELECT proof_image_url FROM dbo.Orders WHERE id = @SettleOrderId);
            IF @CurrentProof IS NULL OR LTRIM(RTRIM(@CurrentProof)) = N''
            BEGIN
                SET @SettleGross = @SettleTotal - @SettleDelivery;
                IF @SettleGross < 0 SET @SettleGross = @SettleSubtotal - @SettleDiscount;
                IF @SettleGross < 0 SET @SettleGross = 0;

                SET @SettleEffectiveAppFee = @SettleAppFee;
                IF @SettleEffectiveAppFee <= 0 AND @SettleCommissionPresent = 1
                BEGIN
                    DECLARE @Rate DECIMAL(18,4) = @SettleCommission;
                    IF @Rate > 1 SET @Rate = @Rate / 100.0;
                    IF @Rate > 0 SET @SettleEffectiveAppFee = @SettleGross * @Rate;
                END
                IF @SettleEffectiveAppFee < 0 SET @SettleEffectiveAppFee = 0;
                IF @SettleEffectiveAppFee > @SettleGross SET @SettleEffectiveAppFee = @SettleGross;

                SET @SettleMerchantIncome = @SettleGross - @SettleEffectiveAppFee;
                IF @SettleMerchantIncome < 0 SET @SettleMerchantIncome = 0;

                BEGIN TRY
                    BEGIN TRAN;
                        UPDATE dbo.Orders
                        SET proof_image_url = @SettleProof
                        WHERE id = @SettleOrderId;

                        UPDATE dbo.ShipperWallets
                        SET balance = balance + @SettleDelivery, updated_at = SYSUTCDATETIME()
                        WHERE shipper_user_id = @SettleShipperId;

                        UPDATE dbo.MerchantWallets
                        SET balance = balance + @SettleMerchantIncome, updated_at = SYSUTCDATETIME()
                        WHERE merchant_user_id = @SettleMerchantId;
                    COMMIT TRAN;
                END TRY
                BEGIN CATCH
                    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
                END CATCH
            END
        END

        FETCH NEXT FROM cur INTO @SettleOrderCode, @SettleProof;
    END
    CLOSE cur;
    DEALLOCATE cur;

    /* ---- Vouchers ---- */
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

    /* ---- Delivery issues + resolutions ---- */
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
    (@o1,@admin,N'RETURNED',N'Ghi nhận hoàn về (demo)'),
    (@o5,@admin,N'CANCEL',N'Thanh toán thất bại - hủy'),
    (@o3,@admin,N'RETRY',N'Chờ shipper nhận đơn');

    /* ---- Ratings ---- */
    INSERT INTO dbo.Ratings(order_id,rater_customer_id,rater_guest_id,target_type,target_user_id,stars,comment)
    VALUES
    (@o1,@c1,NULL,N'SHIPPER',@s1,5,N'Giao nhanh, thân thiện'),
    (@o1,@c1,NULL,N'MERCHANT',@m1,4,N'Đồ ăn ngon'),
    (@o2,@c2,NULL,N'MERCHANT',@m2,5,N'Combo ổn, đóng gói tốt'),
    (@o4,NULL,@g1,N'SHIPPER',@s3,2,N'Gọi không được'),
    (@o5,NULL,@g2,N'MERCHANT',@m2,3,N'Đặt không thành công');

    /* ---- Behavior events ---- */
    INSERT INTO dbo.UserBehaviorEvents(customer_user_id,guest_id,event_type,food_item_id,keyword)
    VALUES
    (@c1,NULL,N'VIEW_ITEM',@fi1,NULL),
    (@c2,NULL,N'SEARCH',NULL,N'combo'),
    (@c3,NULL,N'ADD_TO_CART',@fi5,NULL),
    (NULL,@g1,N'VIEW_ITEM',@fi2,NULL),
    (NULL,@g2,N'ORDER_PLACED',@fi3,NULL);

    /* ---- Notifications ---- */
    INSERT INTO dbo.Notifications(user_id,guest_id,type,content,is_read)
    VALUES
    (@c1,NULL,N'ORDER_CONFIRMED',N'Đơn ORD0001 đã được xác nhận.',1),
    (@c2,NULL,N'STATUS_CHANGED', N'Đơn ORD0002 đang được giao.',0),
    (NULL,@g1,N'FAILED',         N'Đơn ORD0004 giao thất bại. Vui lòng liên hệ hỗ trợ.',0),
    (@m1,NULL,N'NEW_ORDER',      N'Bạn có đơn hàng mới ORD0003.',0),
    (@s1,NULL,N'ASSIGNED_ORDER', N'Bạn được gán đơn ORD0001.',1);

    /* ---- OrderClaims demo ---- */
    INSERT INTO dbo.OrderClaims(order_id,shipper_user_id,status,expires_at)
    VALUES
    (@o3,@s3,N'CLAIMED',DATEADD(SECOND,60,SYSUTCDATETIME()));

    /* ---- AI chat + Auto-cart ---- */
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
    PRINT N'✅ ClickEat: TẠO BẢNG + DỮ LIỆU MẪU (Bao gồm các tính năng mới) HOÀN TẤT.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT N'❌ ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

/* =========================================================
   MERGED FROM: danang_merchants_seed.sql
   Seed thực tế hơn cho Đà Nẵng (~100 quán) - idempotent
   ========================================================= */

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
    cuisine_seq INT,
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

INSERT INTO @FoodTemplate VALUES
(1,N'Món chính',N'Lẩu hải sản chua cay',N'Tôm, mực, nghêu, rau nấm tươi',169000,0,860,52,78,28),
(1,N'Món chính',N'Cơm chiên hải sản',N'Cơm rang cùng tôm mực và rau củ',79000,0,720,26,94,20),
(1,N'Món chính',N'Mì xào hải sản',N'Mì xào đậm vị sốt đặc trưng',85000,0,690,28,88,18),
(1,N'Ăn kèm',N'Hàu nướng mỡ hành',N'Hàu tươi nướng thơm',99000,0,430,24,14,26),
(1,N'Ăn kèm',N'Tôm sú nướng muối ớt',N'Tôm sú nướng vị cay nhẹ',129000,0,510,36,8,28),
(1,N'Combo',N'Combo hải sản 2 người',N'Gồm lẩu + món nướng + nước',329000,0,1450,74,130,56),
(1,N'Đồ uống',N'Nước sâm mát lạnh',N'Thức uống giải nhiệt',25000,0,120,1,29,0),
(1,N'Tráng miệng',N'Rau câu dừa',N'Rau câu dừa thanh mát',28000,0,190,2,36,2),
(2,N'Món chính',N'Cơm tấm sườn bì chả',N'Món cơm tấm truyền thống',65000,0,760,35,84,22),
(2,N'Món chính',N'Cơm gà xối mỡ',N'Cơm gà giòn da, sốt đặc biệt',69000,1,820,34,82,30),
(2,N'Món chính',N'Cơm bò lúc lắc',N'Bò mềm xào tiêu đen',79000,0,790,32,86,26),
(2,N'Ăn kèm',N'Canh rong biển thịt bằm',N'Canh nóng ăn kèm cơm',29000,0,180,10,14,7),
(2,N'Ăn kèm',N'Trứng ốp la',N'Một phần trứng ốp la',15000,0,110,7,1,8),
(2,N'Combo',N'Combo cơm văn phòng',N'Cơm + canh + nước',89000,0,980,42,112,24),
(2,N'Đồ uống',N'Trà đá',N'Trà đá phục vụ tại bàn',5000,0,0,0,0,0),
(2,N'Tráng miệng',N'Sữa chua nha đam',N'Sữa chua thanh mát',22000,0,140,4,22,4),
(3,N'Món chính',N'Bún bò đặc biệt',N'Nước dùng ninh xương đậm đà',59000,0,640,30,82,16),
(3,N'Món chính',N'Phở tái nạm',N'Phở bò truyền thống',62000,0,610,31,78,14),
(3,N'Món chính',N'Mì Quảng gà',N'Mì Quảng chuẩn vị miền Trung',55000,0,590,24,80,14),
(3,N'Ăn kèm',N'Quẩy giòn',N'Phần quẩy ăn kèm',12000,1,180,3,20,9),
(3,N'Ăn kèm',N'Gân bò hầm',N'Phần topping thêm',25000,0,160,12,2,10),
(3,N'Combo',N'Combo bún bò + nước',N'Một tô + nước giải khát',79000,0,760,33,98,18),
(3,N'Đồ uống',N'Nước mơ đá',N'Nước mơ chua ngọt',22000,0,120,0,30,0),
(3,N'Tráng miệng',N'Chè đậu xanh',N'Chè ngọt thanh',20000,0,190,5,34,2),
(4,N'Món chính',N'Pizza hải sản size M',N'Đế mỏng, phô mai kéo sợi',149000,0,980,42,102,44),
(4,N'Món chính',N'Pizza pepperoni size M',N'Vị mặn thơm đặc trưng',139000,0,940,40,96,42),
(4,N'Món chính',N'Mỳ Ý bò bằm',N'Sốt cà chua bò bằm',79000,0,760,28,92,24),
(4,N'Ăn kèm',N'Khoai tây múi cau',N'Khoai nướng giòn',39000,1,360,5,44,18),
(4,N'Ăn kèm',N'Gà viên chiên',N'Chicken bites giòn',49000,1,420,20,24,24),
(4,N'Combo',N'Combo pizza 2 người',N'Pizza + mỳ ý + 2 nước',299000,0,1600,66,176,64),
(4,N'Đồ uống',N'Nước ngọt có ga',N'Lon 330ml',20000,0,140,0,35,0),
(4,N'Tráng miệng',N'Bánh tiramisu',N'Tiramisu mềm mịn',45000,0,320,6,36,16),
(5,N'Đồ uống',N'Trà sữa trân châu đường đen',N'Trà sữa béo thơm',42000,0,340,5,58,10),
(5,N'Đồ uống',N'Trà đào cam sả',N'Trà trái cây thanh mát',36000,0,160,1,38,0),
(5,N'Đồ uống',N'Trà vải hoa hồng',N'Hương thơm dịu nhẹ',38000,0,170,1,40,0),
(5,N'Đồ uống',N'Sữa tươi trân châu',N'Sữa tươi kết hợp topping',39000,0,300,6,45,9),
(5,N'Đồ uống',N'Cafe muối',N'Đặc sản miền Trung',35000,0,180,3,22,8),
(5,N'Ăn kèm',N'Bánh su kem',N'Bánh ngọt ăn kèm trà',28000,0,250,4,30,10),
(5,N'Combo',N'Combo 2 trà sữa',N'2 ly size M tùy chọn',79000,0,650,10,110,18),
(5,N'Tráng miệng',N'Pudding trứng',N'Pudding mềm mịn',22000,0,180,4,24,7),
(6,N'Món chính',N'Cơm chay thập cẩm',N'Rau củ kho, đậu hũ, cơm nóng',59000,0,620,20,92,14),
(6,N'Món chính',N'Bún riêu chay',N'Nước dùng thanh ngọt từ rau củ',55000,0,540,16,84,10),
(6,N'Món chính',N'Mì xào nấm chay',N'Nấm tươi xào rau củ',57000,0,560,18,86,12),
(6,N'Ăn kèm',N'Chả giò chay',N'Chả giò nhân rau củ',39000,1,340,8,40,16),
(6,N'Ăn kèm',N'Đậu hũ sốt nấm',N'Đậu hũ non sốt nấm',42000,0,290,14,18,14),
(6,N'Combo',N'Combo chay 2 người',N'2 món chính + 2 nước',169000,0,1180,36,170,28),
(6,N'Đồ uống',N'Trà atiso',N'Trà thảo mộc thanh lọc',26000,0,90,0,22,0),
(6,N'Tráng miệng',N'Chè hạt sen',N'Chè ngọt thanh nhẹ',25000,0,170,5,30,1),
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

/* =========================================================
   MERGED SECTION (giữ nguyên logic khi chạy)
   Gộp trực tiếp từ:
   1) patch_missing_tables.sql
   2) merchant_checklist_patch.sql
   3) full_demo_seed_1week.sql
   ========================================================= */

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

/* App fee / commission sync (merged from ClickEat_AppFee_Update.sql) */
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.MerchantProfiles') AND name = 'commission_rate'
)
BEGIN
    ALTER TABLE dbo.MerchantProfiles ADD commission_rate DECIMAL(5,2) NULL CONSTRAINT DF_MerchantProfiles_CommissionRate DEFAULT 0.15;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = 'app_fee'
)
BEGIN
    ALTER TABLE dbo.Orders ADD app_fee DECIMAL(18,2) NULL CONSTRAINT DF_Orders_AppFee DEFAULT 0;
END
GO

UPDATE dbo.MerchantProfiles
SET commission_rate = 0.15
WHERE commission_rate IS NULL;
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

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Orders_Merchant_Created' AND object_id = OBJECT_ID(N'dbo.Orders')
)
BEGIN
    CREATE INDEX IX_Orders_Merchant_Created
        ON dbo.Orders(merchant_user_id, created_at)
        INCLUDE(order_status, total_amount, discount_amount, delivered_at);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Ratings_Merchant_TargetCreated' AND object_id = OBJECT_ID(N'dbo.Ratings')
)
BEGIN
    CREATE INDEX IX_Ratings_Merchant_TargetCreated
        ON dbo.Ratings(target_type, target_user_id, created_at);
END
GO

/* Verify demo voucher DEMO15K */
SELECT TOP 1 id, merchant_user_id, code, title, status, is_published, start_at, end_at
FROM dbo.Vouchers
WHERE code = N'DEMO15K';
GO

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

/* Final normalization: đồng bộ app_fee sau toàn bộ seed */
UPDATE o
SET o.app_fee = ROUND(
    CASE
        WHEN mp.commission_rate IS NULL OR mp.commission_rate <= 0 THEN 0
        WHEN mp.commission_rate > 1 THEN
            CASE WHEN (ISNULL(o.total_amount, 0) - ISNULL(o.delivery_fee, 0)) < 0 THEN 0
                 ELSE (ISNULL(o.total_amount, 0) - ISNULL(o.delivery_fee, 0)) * (mp.commission_rate / 100.0)
            END
        ELSE
            CASE WHEN (ISNULL(o.total_amount, 0) - ISNULL(o.delivery_fee, 0)) < 0 THEN 0
                 ELSE (ISNULL(o.total_amount, 0) - ISNULL(o.delivery_fee, 0)) * mp.commission_rate
            END
    END
, 2)
FROM dbo.Orders o
JOIN dbo.MerchantProfiles mp ON mp.user_id = o.merchant_user_id
WHERE (o.app_fee IS NULL OR o.app_fee = 0)
  AND o.order_status IN (N'PAID', N'MERCHANT_ACCEPTED', N'PREPARING', N'READY_FOR_PICKUP', N'PICKED_UP', N'DELIVERING', N'DELIVERED');
GO