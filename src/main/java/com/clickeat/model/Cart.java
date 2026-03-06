package com.clickeat.model;

import java.sql.Timestamp;

public class Cart {

    private int id;
    private Integer customerUserId;
    private String guestId;
    private Integer merchantUserId;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Cart() {
    }

    public Cart(int id, Integer customerUserId, String guestId, Integer merchantUserId, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.customerUserId = customerUserId;
        this.guestId = guestId;
        this.merchantUserId = merchantUserId;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getCustomerUserId() {
        return customerUserId;
    }

    public void setCustomerUserId(Integer customerUserId) {
        this.customerUserId = customerUserId;
    }

    public Integer getMerchantUserId() {
        return merchantUserId;
    }

    public void setMerchantUserId(Integer merchantUserId) {
        this.merchantUserId = merchantUserId;
    }

    public String getGuestId() {
        return guestId;
    }

    public void setGuestId(String guestId) {
        this.guestId = guestId;
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

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
