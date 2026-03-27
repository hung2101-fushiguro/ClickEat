package com.clickeat.model;

import java.sql.Timestamp;

public class FoodItem {

    private int id;
    private int merchantUserId;
    private int categoryId;
    private String name;
    private String description;
    private double price;
    private String imageUrl;
    private boolean isAvailable;
    private boolean isFried;
    private Integer calories;
    private Double proteinG;
    private Double carbsG;
    private Double fatG;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    private String merchantName;
    private String categoryName;
    private double originalPrice;
    private int discountPercent;
    private double rating;
    private String badgeText;
    private String outOfStockReason;
    private String sizeOptions;
    private String toppingOptions;

    public FoodItem() {
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

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isAvailable() {
        return isAvailable;
    }

    public void setAvailable(boolean available) {
        isAvailable = available;
    }

    public boolean isFried() {
        return isFried;
    }

    public void setFried(boolean fried) {
        isFried = fried;
    }

    public Integer getCalories() {
        return calories;
    }

    public void setCalories(Integer calories) {
        this.calories = calories;
    }

    public Double getProteinG() {
        return proteinG;
    }

    public void setProteinG(Double proteinG) {
        this.proteinG = proteinG;
    }

    public Double getCarbsG() {
        return carbsG;
    }

    public void setCarbsG(Double carbsG) {
        this.carbsG = carbsG;
    }

    public Double getFatG() {
        return fatG;
    }

    public void setFatG(Double fatG) {
        this.fatG = fatG;
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

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public double getOriginalPrice() {
        return originalPrice;
    }

    public void setOriginalPrice(double originalPrice) {
        this.originalPrice = originalPrice;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(int discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public String getBadgeText() {
        return badgeText;
    }

    public void setBadgeText(String badgeText) {
        this.badgeText = badgeText;
    }

    public String getOutOfStockReason() {
        return outOfStockReason;
    }

    public void setOutOfStockReason(String outOfStockReason) {
        this.outOfStockReason = outOfStockReason;
    }

    public String getSizeOptions() {
        return sizeOptions;
    }

    public void setSizeOptions(String sizeOptions) {
        this.sizeOptions = sizeOptions;
    }

    public String getToppingOptions() {
        return toppingOptions;
    }

    public void setToppingOptions(String toppingOptions) {
        this.toppingOptions = toppingOptions;
    }
}
