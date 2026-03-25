package com.clickeat.model;

import java.sql.Timestamp;

public class Voucher {

    private int id;
    private int merchantUserId;
    private String code;
    private String title;
    private String description;
    private String discountType;
    private double discountValue;
    private Double maxDiscountAmount;
    private Double minOrderAmount;
    private Timestamp startAt;
    private Timestamp endAt;
    private Integer maxUsesTotal;
    private Integer maxUsesPerUser;
    private boolean isPublished;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int usedOrderCount;

    // field hiển thị
    private String merchantName;
    private String displayDiscount;
    private String themeClass;
    private String merchantStatusLabel;
    private String merchantStatusClass;

    public Voucher() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getMerchantUserId() {
        return merchantUserId;
    }

    public void setMerchantUserId(int merchantUserId) {
        this.merchantUserId = merchantUserId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public double getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(double discountValue) {
        this.discountValue = discountValue;
    }

    public Double getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(Double maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public Double getMinOrderAmount() {
        return minOrderAmount;
    }

    public void setMinOrderAmount(Double minOrderAmount) {
        this.minOrderAmount = minOrderAmount;
    }

    public Timestamp getStartAt() {
        return startAt;
    }

    public void setStartAt(Timestamp startAt) {
        this.startAt = startAt;
    }

    public Timestamp getEndAt() {
        return endAt;
    }

    public void setEndAt(Timestamp endAt) {
        this.endAt = endAt;
    }

    public Integer getMaxUsesTotal() {
        return maxUsesTotal;
    }

    public void setMaxUsesTotal(Integer maxUsesTotal) {
        this.maxUsesTotal = maxUsesTotal;
    }

    public Integer getMaxUsesPerUser() {
        return maxUsesPerUser;
    }

    public void setMaxUsesPerUser(Integer maxUsesPerUser) {
        this.maxUsesPerUser = maxUsesPerUser;
    }

    public boolean isPublished() {
        return isPublished;
    }

    public void setPublished(boolean published) {
        isPublished = published;
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

    public String getMerchantName() {
        return merchantName;
    }

    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getDisplayDiscount() {
        return displayDiscount;
    }

    public void setDisplayDiscount(String displayDiscount) {
        this.displayDiscount = displayDiscount;
    }

    public String getThemeClass() {
        return themeClass;
    }

    public void setThemeClass(String themeClass) {
        this.themeClass = themeClass;
    }

    public String getMerchantStatusLabel() {
        return merchantStatusLabel;
    }

    public void setMerchantStatusLabel(String merchantStatusLabel) {
        this.merchantStatusLabel = merchantStatusLabel;
    }

    public String getMerchantStatusClass() {
        return merchantStatusClass;
    }

    public void setMerchantStatusClass(String merchantStatusClass) {
        this.merchantStatusClass = merchantStatusClass;
    }

    public int getUsedOrderCount() {
        return usedOrderCount;
    }

    public void setUsedOrderCount(int usedOrderCount) {
        this.usedOrderCount = usedOrderCount;
    }
}
