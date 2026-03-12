package com.clickeat.model;

import java.sql.Timestamp;

public class MerchantWallet {

    private int merchantUserId;
    private double balance;
    private Timestamp updatedAt;

    public MerchantWallet() {
    }

    public int getMerchantUserId() {
        return merchantUserId;
    }

    public void setMerchantUserId(int merchantUserId) {
        this.merchantUserId = merchantUserId;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
