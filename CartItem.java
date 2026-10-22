package com.tap.model;

import java.math.BigDecimal;

public class CartItem {

    private int menuId;
    private String itemName;
    private BigDecimal price;
    private String imagePath;
    private int quantity;


    // Default Constructor
    public CartItem() {
    }


    // Constructor
    public CartItem(int menuId,
                    String itemName,
                    BigDecimal price,
                    String imagePath,
                    int quantity) {

        this.menuId = menuId;
        this.itemName = itemName;
        this.price = price;
        this.imagePath = imagePath;
        this.quantity = quantity;
    }


    // Getters and Setters

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


    // Calculate total for this item

    public BigDecimal getTotalPrice() {

        return price.multiply(
            BigDecimal.valueOf(quantity)
        );

    }
}