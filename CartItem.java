
package com.tap.model;

import java.math.BigDecimal;

public class CartItem {

    private int menuId;
    private String itemName;
    private BigDecimal price;
    private String imagePath;
    private int quantity;

    // Restaurant details for multi-restaurant ordering
    private int restaurantId;
    private String restaurantName;

    public CartItem() {
    }

    public CartItem(int menuId, String itemName,
                    BigDecimal price, String imagePath,
                    int quantity) {
        this.menuId = menuId;
        this.itemName = itemName;
        this.price = price;
        this.imagePath = imagePath;
        this.quantity = quantity;
    }

    public CartItem(int menuId, String itemName,
                    BigDecimal price, String imagePath,
                    int quantity, int restaurantId,
                    String restaurantName) {

        this(menuId, itemName, price, imagePath, quantity);
        this.restaurantId = restaurantId;
        this.restaurantName = restaurantName;
    }

    public int getMenuId() {
        return menuId;
    }

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getRestaurantName() {
        return restaurantName;
    }

    public void setRestaurantName(String restaurantName) {
        this.restaurantName = restaurantName;
    }

    public BigDecimal getTotalPrice() {
        if (price == null) {
            return BigDecimal.ZERO;
        }

        return price.multiply(BigDecimal.valueOf(quantity));
    }
}
