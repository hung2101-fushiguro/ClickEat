package com.clickeat.dal.impl;

import com.clickeat.model.Voucher;
import com.clickeat.model.MerchantProfile;
import java.util.List;

public class CheckVoucher {
    public static void main(String[] args) {
        System.out.println("--- CHECKING VOUCHERS ---");
        VoucherDAO vDao = new VoucherDAO();
        MerchantProfileDAO mDao = new MerchantProfileDAO();
        
        List<Voucher> all = vDao.findAll();
        System.out.println("Total vouchers in DB: " + all.size());
        for (Voucher v : all) {
            System.out.println("====================================");
            System.out.println("ID: " + v.getId() + " | Code: " + v.getCode() + " | Title: " + v.getTitle());
            System.out.println("- is_published: " + v.isPublished());
            System.out.println("- status: " + v.getStatus());
            System.out.println("- start_at: " + v.getStartAt());
            System.out.println("- end_at: " + v.getEndAt());
            
            MerchantProfile mp = mDao.getByUserId(v.getMerchantUserId());
            if (mp != null) {
                System.out.println("- merchant_status: " + mp.getStatus());
            } else {
                System.out.println("- merchant_status: NULL (Merchant Profile NOT FOUND for ID " + v.getMerchantUserId() + ")");
            }
        }
        
        System.out.println("====================================");
        List<Voucher> active = vDao.getActiveVouchers(10);
        System.out.println("Total active vouchers returned by getActiveVouchers: " + active.size());
    }
}
