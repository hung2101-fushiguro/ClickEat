package com.clickeat.model;

import java.sql.Timestamp;

public class MerchantWithdrawal {

    private long id;
    private int merchantUserId;
    private double amount;
    private String bankName;
    private String bankAccountNumber;
    private String status;
    private Timestamp createdAt;
    private Timestamp processedAt;

    public MerchantWithdrawal() {
    }

    
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public int getMerchantUserId() {
        return merchantUserId;
    }

    public void setMerchantUserId(int merchantUserId) {
        this.merchantUserId = merchantUserId;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getBankAccountNumber() {
        return bankAccountNumber;
    }

    public void setBankAccountNumber(String bankAccountNumber) {
        this.bankAccountNumber = bankAccountNumber;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(Timestamp processedAt) {
        this.processedAt = processedAt;
    }
}
