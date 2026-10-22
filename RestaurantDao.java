package com.tap.dao;

import java.util.List;

import com.tap.model.Restaurant;

public interface RestaurantDao {

    // Create
    void addRestaurant(Restaurant restaurant);

    // Read
    Restaurant getRestaurant(int restaurantId);

    List<Restaurant> getAllRestaurants();

    List<Restaurant> getActiveRestaurants();

    List<Restaurant> getRestaurantsByCuisine(String cuisineType);

    List<Restaurant> getRestaurantsByAdmin(int adminUserId);

    // Update
    void updateRestaurant(Restaurant restaurant);

    // Delete
    void deleteRestaurant(int restaurantId);
}