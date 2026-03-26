/* =========================================================
   CLICK EAT - FULL DATABASE (CẤU TRÚC CLICK EAT 2 + DATA 1111)
   Bản hoàn chỉnh 100% - Đã fix toàn bộ lỗi khóa ngoại & AI
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
   1) DROP TABLES
   ========================= */
DROP TRIGGER IF EXISTS dbo.TR_CartItems_EnforceSingleMerchant;
GO

IF OBJECT_ID('dbo.WithdrawalRequests','U') IS NOT NULL DROP TABLE dbo.WithdrawalRequests;
IF OBJECT_ID('dbo.MerchantWithdrawals','U') IS NOT NULL DROP TABLE dbo.MerchantWithdrawals;
IF OBJECT_ID('dbo.MerchantWallets','U') IS NOT NULL DROP TABLE dbo.MerchantWallets;
IF OBJECT_ID('dbo.ShipperWallets','U') IS NOT NULL DROP TABLE dbo.ShipperWallets;
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
IF OBJECT_ID('dbo.RefundRequests','U') IS NOT NULL DROP TABLE dbo.RefundRequests;
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
IF OBJECT_ID('dbo.Messages','U') IS NOT NULL DROP TABLE dbo.Messages;
IF OBJECT_ID('dbo.Users','U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* =========================
   2) USERS, AUTH, MESSAGES & APPEALS
   ========================= */
CREATE TABLE dbo.Users (
    id            BIGINT IDENTITY(1,1) PRIMARY KEY,
    full_name     NVARCHAR(100)    NOT NULL,
    email         NVARCHAR(150)    NULL,
    phone         NVARCHAR(20)     NOT NULL,
    password_hash NVARCHAR(255)    NULL,
    role          NVARCHAR(20)     NOT NULL,  
    status        NVARCHAR(20)     NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'ACTIVE',
    avatar_url    NVARCHAR(500)    NULL,      
    created_at    DATETIME2        NOT NULL CONSTRAINT DF_Users_Created DEFAULT SYSUTCDATETIME(),
    updated_at    DATETIME2        NOT NULL CONSTRAINT DF_Users_Updated DEFAULT SYSUTCDATETIME()
);
CREATE UNIQUE INDEX UX_Users_Phone ON dbo.Users(phone);
CREATE UNIQUE INDEX UX_Users_Email ON dbo.Users(email) WHERE email IS NOT NULL;
ALTER TABLE dbo.Users ADD CONSTRAINT CK_Users_Role CHECK (role IN (N'GUEST',N'CUSTOMER',N'MERCHANT',N'SHIPPER',N'ADMIN'));
ALTER TABLE dbo.Users ADD CONSTRAINT CK_Users_Status CHECK (status IN (N'ACTIVE',N'INACTIVE'));
GO

-- Bảng lưu tin nhắn Chat AI & Realtime
CREATE TABLE dbo.Messages (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_Messages_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Msg_Sender FOREIGN KEY (sender_id) REFERENCES dbo.Users(id) ON DELETE CASCADE,
    CONSTRAINT FK_Msg_Receiver FOREIGN KEY (receiver_id) REFERENCES dbo.Users(id) ON DELETE NO ACTION
);
GO

CREATE TABLE dbo.UserAuthProviders (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id          BIGINT         NOT NULL,
    provider         NVARCHAR(30)   NOT NULL, 
    provider_user_id NVARCHAR(100)  NOT NULL,
    linked_at        DATETIME2      NOT NULL CONSTRAINT DF_UserAuthProviders_Linked DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_UserAuthProviders_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
ALTER TABLE dbo.UserAuthProviders ADD CONSTRAINT CK_UserAuthProviders_Provider CHECK (provider IN (N'GOOGLE'));
CREATE UNIQUE INDEX UX_UserAuthProviders_ProviderUser ON dbo.UserAuthProviders(provider, provider_user_id);
GO

CREATE TABLE dbo.UserAppeals (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    reason NVARCHAR(1000) NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_UserAppeals_Status DEFAULT 'PENDING', 
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
    image_url         NVARCHAR(500) NULL, -- Đã thêm cột ảnh
    business_hours    NVARCHAR(MAX) NULL, -- Đã thêm giờ mở cửa
    shop_avatar       NVARCHAR(MAX) NULL, 
    shop_description  NVARCHAR(MAX) NULL, 
    notification_settings NVARCHAR(MAX) NULL,
    status            NVARCHAR(20)  NOT NULL CONSTRAINT DF_MerchantProfiles_Status DEFAULT 'PENDING',
    created_at        DATETIME2     NOT NULL CONSTRAINT DF_MerchantProfiles_Created DEFAULT SYSUTCDATETIME(),
    updated_at        DATETIME2     NOT NULL CONSTRAINT DF_MerchantProfiles_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_MerchantProfiles_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
ALTER TABLE dbo.MerchantProfiles ADD CONSTRAINT CK_MerchantProfiles_Status CHECK (status IN (N'PENDING',N'APPROVED',N'REJECTED',N'SUSPENDED'));
GO

CREATE TABLE dbo.MerchantWallets (
    merchant_user_id BIGINT NOT NULL PRIMARY KEY,
    balance DECIMAL(18,2) NOT NULL CONSTRAINT DF_MerchantWallets_Balance DEFAULT 0,
    updated_at DATETIME2 NOT NULL CONSTRAINT DF_MerchantWallets_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_MerchantWallets_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.MerchantWithdrawals (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    merchant_user_id BIGINT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    bank_name NVARCHAR(100) NULL, 
    bank_account_number NVARCHAR(50)  NULL, 
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_MerchantWithdrawals_Status DEFAULT 'PENDING',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_MerchantWithdrawals_Created DEFAULT SYSUTCDATETIME(),
    processed_at DATETIME2 NULL,
    CONSTRAINT FK_MerchantWithdrawals_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id) ON DELETE CASCADE
);
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
    CONSTRAINT FK_Carts_Merchant FOREIGN KEY (merchant_user_id) REFERENCES dbo.MerchantProfiles(user_id)
);
GO

CREATE TABLE dbo.CartItems (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    cart_id             BIGINT        NOT NULL,
    food_item_id        BIGINT        NOT NULL,
    quantity            INT           NOT NULL,
    unit_price_snapshot DECIMAL(18,2) NOT NULL,
    note                NVARCHAR(255) NULL,
    CONSTRAINT FK_CartItems_Cart FOREIGN KEY (cart_id) REFERENCES dbo.Carts(id) ON DELETE CASCADE,
    CONSTRAINT FK_CartItems_Food FOREIGN KEY (food_item_id) REFERENCES dbo.FoodItems(id)
);
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
    total_amount        DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Orders_Total DEFAULT 0,
    proof_image_url     NVARCHAR(500)    NULL,
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
    CONSTRAINT FK_Orders_Shipper  FOREIGN KEY (shipper_user_id) REFERENCES dbo.Users(id)
);
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
    CONSTRAINT FK_OrderItems_Food  FOREIGN KEY (food_item_id) REFERENCES dbo.FoodItems(id)
);
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

CREATE TABLE dbo.RefundRequests (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    merchant_user_id BIGINT NOT NULL,
    refund_amount DECIMAL(18,2) NOT NULL,
    reason NVARCHAR(255) NOT NULL,
    status NVARCHAR(20) DEFAULT 'COMPLETED',
    created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Refund_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id)
);
GO

/* =========================
   9) PAYMENTS & VOUCHERS
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
GO

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
GO

CREATE TABLE dbo.VoucherUsages (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    voucher_id       BIGINT           NOT NULL,
    order_id         BIGINT           NOT NULL,
    customer_user_id BIGINT           NULL,
    guest_id         UNIQUEIDENTIFIER NULL,
    used_at          DATETIME2        NOT NULL CONSTRAINT DF_VoucherUsages_Used DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_VoucherUsages_Voucher FOREIGN KEY (voucher_id) REFERENCES dbo.Vouchers(id),
    CONSTRAINT FK_VoucherUsages_Order   FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE
);
GO

/* =========================
   10) SHIPPER PROFILES
   ========================= */
CREATE TABLE dbo.ShipperProfiles (
    user_id      BIGINT       NOT NULL PRIMARY KEY,
    vehicle_type NVARCHAR(20) NOT NULL, 
    vehicle_name  NVARCHAR(100) NULL,   
    license_plate NVARCHAR(20) NULL,    
    status       NVARCHAR(20) NOT NULL CONSTRAINT DF_ShipperProfiles_Status DEFAULT 'ACTIVE',
    created_at   DATETIME2    NOT NULL CONSTRAINT DF_ShipperProfiles_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ShipperProfiles_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
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
GO

/* =========================
   11) RATINGS & REVIEWS
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
    reply_comment     NVARCHAR(MAX)    NULL, -- Chủ quán trả lời
    created_at        DATETIME2        NOT NULL CONSTRAINT DF_Ratings_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Ratings_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.ShipperReviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Orders(id), 
    shipper_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id), 
    customer_id BIGINT NOT NULL FOREIGN KEY REFERENCES dbo.Users(id), 
    rating INT NOT NULL,
    comment NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);
GO

/* =========================
   12) USER BEHAVIOR EVENTS + NOTIFICATIONS
   ========================= */
CREATE TABLE dbo.UserBehaviorEvents (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_user_id BIGINT           NULL,
    guest_id         UNIQUEIDENTIFIER NULL,
    event_type       NVARCHAR(30)     NOT NULL, 
    food_item_id     BIGINT           NULL,
    keyword          NVARCHAR(200)    NULL,
    created_at       DATETIME2        NOT NULL CONSTRAINT DF_UserBehaviorEvents_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_UserBehaviorEvents_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.Notifications (
    id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id    BIGINT           NULL,
    guest_id   UNIQUEIDENTIFIER NULL,
    type       NVARCHAR(50)     NOT NULL,
    content    NVARCHAR(500)    NOT NULL,
    is_read    BIT              NOT NULL CONSTRAINT DF_Notifications_Read DEFAULT 0,
    created_at DATETIME2        NOT NULL CONSTRAINT DF_Notifications_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Notifications_User FOREIGN KEY (user_id) REFERENCES dbo.Users(id)
);
GO

/* =========================
   13) AI CHAT + AUTO-CART
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
    CONSTRAINT FK_AIMessages_Conversation FOREIGN KEY (conversation_id) REFERENCES dbo.AIConversations(id) ON DELETE CASCADE
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
    CONSTRAINT FK_AutoCartProposals_Customer FOREIGN KEY (customer_user_id) REFERENCES dbo.Users(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.AutoCartProposalItems (
    id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    proposal_id  BIGINT        NOT NULL,
    food_item_id BIGINT        NOT NULL,
    quantity     INT           NOT NULL,
    unit_price   DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_AutoCartProposalItems_Proposal FOREIGN KEY (proposal_id) REFERENCES dbo.AutoCartProposals(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.DeliveryIssues (
    id             BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id        BIGINT       NOT NULL,
    shipper_user_id BIGINT       NOT NULL,
    issue_type     NVARCHAR(30)  NOT NULL, 
    attempts_count INT           NOT NULL CONSTRAINT DF_DeliveryIssues_Attempts DEFAULT 0,
    note           NVARCHAR(255) NULL,
    created_at     DATETIME2     NOT NULL CONSTRAINT DF_DeliveryIssues_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_DeliveryIssues_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.FailedDeliveryResolutions (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id             BIGINT       NOT NULL,
    handled_by_admin_id  BIGINT       NOT NULL,
    resolution_type     NVARCHAR(30)  NOT NULL, 
    note                NVARCHAR(255) NULL,
    created_at          DATETIME2     NOT NULL CONSTRAINT DF_FailedDeliveryResolutions_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_FailedDeliveryResolutions_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE
);
GO

/* =========================================================
   14) SEED DATA (TÍCH HỢP 15 NHÀ HÀNG & 20 MÓN ĂN TỪ BẢN 1111)
   ========================================================= */
BEGIN TRY
    BEGIN TRAN;

    -- TẠO ADMIN VÀ KHÁCH HÀNG (Rút gọn để tập trung)
    INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status) VALUES (N'Admin ClickEat', N'admin@clickeat.vn', N'0900000001', N'hash_admin', N'ADMIN', N'ACTIVE');
    INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status) VALUES (N'Customer 1', N'customer1@clickeat.vn', N'0900000012', N'hash_c1', N'CUSTOMER',N'ACTIVE');
    DECLARE @admin BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000001');
    DECLARE @c1 BIGINT = (SELECT id FROM dbo.Users WHERE phone=N'0900000012');

    -- TẠO 15 NHÀ HÀNG
    INSERT INTO dbo.Users(full_name,email,phone,password_hash,role,status) VALUES
    (N'Merchant 1', N'merchant1@shop.vn', N'0900000002', N'hash_m1', N'MERCHANT',N'ACTIVE'), (N'Merchant 2', N'merchant2@shop.vn', N'0900000003', N'hash_m2', N'MERCHANT',N'ACTIVE'),
    (N'Merchant 3', N'merchant3@shop.vn', N'0900000004', N'hash_m3', N'MERCHANT',N'ACTIVE'), (N'Merchant 4', N'merchant4@shop.vn', N'0900000005', N'hash_m4', N'MERCHANT',N'ACTIVE'),
    (N'Merchant 5', N'merchant5@shop.vn', N'0900000006', N'hash_m5', N'MERCHANT',N'ACTIVE'), (N'Merchant 6', N'merchant6@shop.vn', N'0900001011', N'hash_m6', N'MERCHANT', N'ACTIVE'),
    (N'Merchant 7', N'merchant7@shop.vn', N'0900001012', N'hash_m7', N'MERCHANT', N'ACTIVE'), (N'Merchant 8', N'merchant8@shop.vn', N'0900001013', N'hash_m8', N'MERCHANT', N'ACTIVE'),
    (N'Merchant 9', N'merchant9@shop.vn', N'0900001014', N'hash_m9', N'MERCHANT', N'ACTIVE'), (N'Merchant 10',N'merchant10@shop.vn',N'0900001015', N'hash_m10',N'MERCHANT', N'ACTIVE'),
    (N'Merchant 11',N'merchant11@shop.vn',N'0900001016', N'hash_m11',N'MERCHANT', N'ACTIVE'), (N'Merchant 12',N'merchant12@shop.vn',N'0900001017', N'hash_m12',N'MERCHANT', N'ACTIVE'),
    (N'Merchant 13',N'merchant13@shop.vn',N'0900001018', N'hash_m13',N'MERCHANT', N'ACTIVE'), (N'Merchant 14',N'merchant14@shop.vn',N'0900001019', N'hash_m14',N'MERCHANT', N'ACTIVE'),
    (N'Merchant 15',N'merchant15@shop.vn',N'0900001020', N'hash_m15',N'MERCHANT', N'ACTIVE');

    DECLARE @m1 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900000002'), @m2 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900000003'), @m3 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900000004'),
    @m4 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900000005'), @m5 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900000006'), @m6 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001011'),
    @m7 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001012'), @m8 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001013'), @m9 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001014'),
    @m10 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001015'), @m11 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001016'), @m12 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001017'),
    @m13 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001018'), @m14 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001019'), @m15 BIGINT=(SELECT id FROM dbo.Users WHERE phone=N'0900001020');

    -- TẠO HỒ SƠ 15 NHÀ HÀNG KÈM HÌNH ẢNH
    INSERT INTO dbo.MerchantProfiles (user_id,shop_name,shop_phone,shop_address_line,province_code,province_name,district_code,district_name,ward_code,ward_name,status, image_url) VALUES
    (@m1,N'Lollibee Q1',N'0280000002',N'10 Đồng Khởi',N'79',N'TP.HCM',N'760',N'Quận 1',N'26734',N'Bến Nghé',N'APPROVED', '/assets/images/id2-Lollibee-Q1.jpg'),
    (@m2,N'Lollibee Q3',N'0280000003',N'250 CMT8',N'79',N'TP.HCM',N'770',N'Quận 3',N'27349',N'Phường 10',N'APPROVED', '/assets/images/id3-Lollibee-Q3.jpg'),
    (@m3,N'Lollibee BT',N'0280000004',N'120 Xô Viết Nghệ Tĩnh',N'79',N'TP.HCM',N'769',N'Bình Thạnh',N'27145',N'Phường 21',N'APPROVED', '/assets/images/id4-Lollibee-BT.jpg'),
    (@m4,N'Lollibee TD',N'0280000005',N'5 Kha Vạn Cân',N'79',N'TP.HCM',N'762',N'Thủ Đức',N'26848',N'Linh Chiểu',N'APPROVED', '/assets/images/id5-Lollibee-TD.jpg'),
    (@m5,N'Lollibee DN',N'0236000006',N'99 Nguyễn Văn Linh',N'48',N'Đà Nẵng',N'490',N'Hải Châu',N'20194',N'Phước Ninh',N'APPROVED', '/assets/images/id6-Lollibee-DN.jpg'),
    (@m6,N'Phở Hà Thành',N'0241000001',N'25 Tràng Tiền',N'01',N'Hà Nội',N'001',N'Hoàn Kiếm',N'00001',N'Tràng Tiền',N'APPROVED', '/assets/images/id18-Pho-Ha-Thanh.jpg'),
    (@m7,N'Bún Chả Phố Cổ',N'0241000002',N'12 Hàng Mành',N'01',N'Hà Nội',N'001',N'Hoàn Kiếm',N'00002',N'Hàng Gai',N'APPROVED', '/assets/images/id19-Bun-Cha-Pho-Co.jpg'),
    (@m8,N'Cơm Tấm Sài Gòn',N'0281000003',N'88 Nguyễn Trãi',N'79',N'TP.HCM',N'760',N'Quận 1',N'26737',N'Bến Thành',N'APPROVED', '/assets/images/id20-Com-Tam-Sai-Gon.jpg'),
    (@m9,N'Hủ Tiếu Nam Vang Q3',N'0281000004',N'155 Cách Mạng Tháng 8',N'79',N'TP.HCM',N'770',N'Quận 3',N'27349',N'Phường 10',N'APPROVED', '/assets/images/id21-Hu-Tieu-Nam-Vang-Q3.jpg'),
    (@m10,N'Mì Quảng Đà Nẵng',N'0236100005',N'45 Lê Duẩn',N'48',N'Đà Nẵng',N'490',N'Hải Châu',N'20194',N'Phước Ninh',N'APPROVED', '/assets/images/id22-Mi-Quang-Da-Nang.jpg'),
    (@m11,N'Bánh Tráng Cuốn DN',N'0236100006',N'90 Nguyễn Văn Linh',N'48',N'Đà Nẵng',N'490',N'Hải Châu',N'20195',N'Nam Dương',N'APPROVED', '/assets/images/id23-Banh-Trang-Cuon-DN.jpg'),
    (@m12,N'Lẩu Mắm Cần Thơ',N'0292100007',N'20 Đại lộ Hòa Bình',N'92',N'Cần Thơ',N'916',N'Ninh Kiều',N'31117',N'Tân An',N'APPROVED', '/assets/images/id24-Lau-Mam-Can-Tho.jpg'),
    (@m13,N'Bánh Xèo Miền Tây',N'0292100008',N'66 Mậu Thân',N'92',N'Cần Thơ',N'916',N'Ninh Kiều',N'31120',N'Xuân Khánh',N'APPROVED', '/assets/images/id25-Banh-Xeo-Mien-Tay.jpg'),
    (@m14,N'Bánh Đa Cua Hải Phòng',N'0225100009',N'18 Lạch Tray',N'31',N'Hải Phòng',N'303',N'Ngô Quyền',N'11110',N'Lạch Tray',N'APPROVED', '/assets/images/id26-Banh-Da-Cua-Hai-Phong.jpg'),
    (@m15,N'Nem Cua Bể HP',N'0225100010',N'50 Cầu Đất',N'31',N'Hải Phòng',N'303',N'Ngô Quyền',N'11111',N'Cầu Đất',N'APPROVED', '/assets/images/id27-Nem-Cua-Be-HP.jpg');

    -- TẠO VÍ TIỀN CHO 15 NHÀ HÀNG
    INSERT INTO dbo.MerchantWallets(merchant_user_id, balance) VALUES
    (@m1,0), (@m2,5000000), (@m3,0), (@m4,0), (@m5,0), (@m6,0), (@m7,0), (@m8,0), (@m9,0), (@m10,0), (@m11,0), (@m12,0), (@m13,0), (@m14,0), (@m15,0);

    -- DANH MỤC VÀ 20 MÓN ĂN CÓ HÌNH
    INSERT INTO dbo.Categories(merchant_user_id,name,is_active,sort_order) VALUES
    (@m1,N'Gà rán',1,1), (@m2,N'Combo',1,1), (@m3,N'Burger',1,1), (@m4,N'Đồ uống',1,1), (@m5,N'Tráng miệng',1,1),
    (@m6,N'Món chính',1,1), (@m7,N'Món chính',1,1), (@m8,N'Món chính',1,1), (@m9,N'Món nước',1,1), (@m10,N'Món chính',1,1),
    (@m11,N'Ăn vặt',1,1), (@m12,N'Lẩu',1,1), (@m13,N'Món chiên',1,1), (@m14,N'Món nước',1,1), (@m15,N'Hải sản',1,1);

    DECLARE @c_m1 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m1), @c_m2 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m2),
    @c_m3 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m3), @c_m4 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m4),
    @c_m5 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m5), @c_m6 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m6),
    @c_m7 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m7), @c_m8 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m8),
    @c_m9 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m9), @c_m10 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m10),
    @c_m11 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m11), @c_m12 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m12),
    @c_m13 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m13), @c_m14 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m14),
    @c_m15 BIGINT=(SELECT TOP 1 id FROM dbo.Categories WHERE merchant_user_id=@m15);

    INSERT INTO dbo.FoodItems(merchant_user_id,category_id,name,price,image_url,is_fried,calories) VALUES
    (@m1,@c_m1,N'Gà rán giòn',45000,'/assets/images/id2-Ga-ran-gion.jpg',1,520),
    (@m1,@c_m1,N'Gà cay',50000,'/assets/images/id2-Ga-cay.jpg',1,560),
    (@m2,@c_m2,N'Combo 1',79000,'/assets/images/id3-Combo-1.jpg',1,850),
    (@m2,@c_m2,N'Combo 2',89000,'/assets/images/id3-Combo-2.jpg',1,980),
    (@m3,@c_m3,N'Burger gà',55000,'/assets/images/id4-Burger-ga.jpg',1,650),
    (@m3,@c_m3,N'Burger cá',52000,'/assets/images/id4-Burger-ca.jpg',0,540),
    (@m4,@c_m4,N'Trà đào',30000,'/assets/images/id5-Tra-dao.jpg',0,140),
    (@m4,@c_m4,N'Coca',20000,'/assets/images/id5-Coca.jpg',0,150),
    (@m5,@c_m5,N'Kem vani',25000,'/assets/images/id6-Kem-vani.jpg',0,210),
    (@m5,@c_m5,N'Bánh flan',22000,'/assets/images/id6-Banh-flan.jpg',0,180),
    (@m6,@c_m6,N'Phở bò tái',55000,'/assets/images/id18-Pho-bo-tai.jpg',0,420),
    (@m7,@c_m7,N'Bún chả suất đầy đủ',60000,'/assets/images/id19-Bun-cha-suat-day-du.jpg',0,510),
    (@m8,@c_m8,N'Cơm tấm sườn bì chả',65000,'/assets/images/id20-Com-tam-suon-bi-cha.jpg',0,690),
    (@m9,@c_m9,N'Hủ tiếu Nam Vang',58000,'/assets/images/id21-Hu-tieu-Nam-Vang.jpg',0,500),
    (@m10,@c_m10,N'Mì Quảng gà',52000,'/assets/images/id22-Mi-Quang-ga.jpg',0,470),
    (@m11,@c_m11,N'Bánh tráng cuốn thịt',45000,'/assets/images/id23-Banh-trang-cuon-thit.jpg',0,390),
    (@m12,@c_m12,N'Lẩu mắm cá basa',179000,'/assets/images/id24-Lau-mam-ca-basa.jpg',0,820),
    (@m13,@c_m13,N'Bánh xèo tôm thịt',70000,'/assets/images/id25-Banh-xeo-tom-thit.jpg',1,610),
    (@m14,@c_m14,N'Bánh đa cua',57000,'/assets/images/id26-Banh-da-cua.jpg',0,460),
    (@m15,@c_m15,N'Nem cua bể',85000,'/assets/images/id27-Nem-cua-be.jpg',1,530);

    COMMIT TRAN;
    PRINT N'✅ CLICK EAT 2 FINAL: TẠO BẢNG + DỮ LIỆU MẪU HOÀN TẤT!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT N'❌ ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
--thêm
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

--thêm tiếp
ALTER TABLE dbo.Orders ADD shipper_accepted_at DATETIME2 NULL;
PRINT N'Đã thêm cột shipper_accepted_at thành công!';
GO

--Shipper ngâm đơn
UPDATE dbo.Orders
SET 
    shipper_user_id = NULL,             -- Xóa tên Shipper khỏi đơn
    order_status = 'READY_FOR_PICKUP',  -- Trả lại trạng thái Chờ người khác nhận
    shipper_accepted_at = NULL          -- Xóa luôn thời gian nhận cũ
WHERE 
    order_status = 'DELIVERING' 
    AND shipper_accepted_at IS NOT NULL
    AND DATEDIFF(MINUTE, shipper_accepted_at, SYSUTCDATETIME()) > 30;

PRINT N'✅ Đã dọn dẹp các đơn hàng bị ngâm quá 30 phút!';
GO