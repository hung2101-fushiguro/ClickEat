package com.clickeat.model;

import java.sql.Timestamp;

public class RefundRequest {

    private long id;
    private long orderId;
    private long merchantUserId;
    private double refundAmount;
    private String reason;
    private String status;
    private Timestamp createdAt;

    public RefundRequest() {
    }

    
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getOrderId() {
        return orderId;
    }

    public void setOrderId(long orderId) {
        this.orderId = orderId;
    }

    public long getMerchantUserId() {
        return merchantUserId;
    }

    public void setMerchantUserId(long merchantUserId) {
        this.merchantUserId = merchantUserId;
    }

    public double getRefundAmount() {
        return refundAmount;
    }

    public void setRefundAmount(double refundAmount) {
        this.refundAmount = refundAmount;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
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
}
