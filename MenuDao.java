package com.tap.dao;

import java.util.List;

import com.tap.model.Menu;

public interface MenuDao {

    // Create
    void addMenu(Menu menu);

    // Read
    Menu getMenu(int menuId);

    List<Menu> getAllMenus();

    List<Menu> getMenusByRestaurant(int restaurantId);

    List<Menu> getAvailableMenus(int restaurantId);

    // Update
    void updateMenu(Menu menu);

    // Delete
    void deleteMenu(int menuId);
}