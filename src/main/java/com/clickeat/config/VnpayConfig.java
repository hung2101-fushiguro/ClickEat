/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.config;

/**
 *
 * @author DELL
 */
public class VnpayConfig {

    public static final String VNP_TMN_CODE = "";
    public static final String VNP_HASH_SECRET = "";

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
