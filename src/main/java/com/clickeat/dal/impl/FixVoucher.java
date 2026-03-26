package com.clickeat.dal.impl;

import com.clickeat.model.Voucher;
import java.util.List;

public class FixVoucher {

    public static void main(String[] args) {
        System.out.println("--- FIXING VOUCHERS ---");
        VoucherDAO vDao = new VoucherDAO();
        List<Voucher> all = vDao.findAll();
        for (Voucher v : all) {
            String sql = "UPDATE Vouchers SET start_at = '2026-03-22 00:00:00', status = 'ACTIVE', is_published = 1 WHERE id = ?";
            vDao.update(sql, v.getId());
            System.out.println("Fixed Voucher ID: " + v.getId());
        }
    }
}
