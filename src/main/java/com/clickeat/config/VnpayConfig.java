package com.clickeat.config;

public class VnpayConfig {

    // TODO: thay bằng thông tin sandbox thật của bạn
    public static final String VNP_TMN_CODE = "EZ1YCPZG";
    public static final String VNP_HASH_SECRET = "ISEPO8G29V848A6E7Z8EVA54PL8FVJ13";

    // Sandbox URL chính thức
    public static final String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

public static final String VNP_RETURN_URL = "https://piscine-jaunita-unjoyfully.ngrok-free.dev/ClickEat2/vnpay-return";
    public static final String VNP_IPN_URL = "https://piscine-jaunita-unjoyfully.ngrok-free.dev/ClickEat2/vnpay-ipn";

    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";
    public static final String VNP_CURR_CODE = "VND";
    public static final String VNP_LOCALE = "vn";
    public static final String VNP_ORDER_TYPE = "other";

    private VnpayConfig() {
    }
}