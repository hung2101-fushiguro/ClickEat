package com.clickeat.model;

public class CartItemView {

    private int cartItemId;      // CartItems.id
    private int cartId;          // CartItems.cart_id
    private int foodItemId;      // CartItems.food_item_id

    private String name;         // FoodItems.name
    private String imageUrl;     // FoodItems.image_url

    private double unitPrice;    // CartItems.unit_price_snapshot
    private int quantity;
    private String selectedSize;
    private String selectedToppings;
    private String optionSummary;

    public CartItemView() {
    }

    public int getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(int cartItemId) {
        this.cartItemId = cartItemId;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public int getFoodItemId() {
        return foodItemId;
    }

    public void setFoodItemId(int foodItemId) {
        this.foodItemId = foodItemId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getSelectedSize() {
        return selectedSize;
    }

    public void setSelectedSize(String selectedSize) {
        this.selectedSize = selectedSize;
    }

    public String getSelectedToppings() {
        return selectedToppings;
    }

    public void setSelectedToppings(String selectedToppings) {
        this.selectedToppings = selectedToppings;
    }

    public String getOptionSummary() {
        return optionSummary;
    }

    public void setOptionSummary(String optionSummary) {
        this.optionSummary = optionSummary;
    }

    public double getLineTotal() {
        return unitPrice * quantity;
    }
}
