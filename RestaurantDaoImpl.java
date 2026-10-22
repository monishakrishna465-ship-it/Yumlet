package com.tap.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.RestaurantDao;
import com.tap.model.Restaurant;
import com.tap.util.DBConnection;

public class RestaurantDaoImpl implements RestaurantDao {

    private static final String INSERT_RESTAURANT =
            "INSERT INTO restaurant "
          + "(name, cuisineType, deliveryTime, address, adminUserId, rating, isActive, imagePath) "
          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_RESTAURANT_BY_ID =
            "SELECT * FROM restaurant WHERE restaurantId = ?";

    private static final String SELECT_ALL_RESTAURANTS =
            "SELECT * FROM restaurant";

    private static final String SELECT_ACTIVE_RESTAURANTS =
            "SELECT * FROM restaurant WHERE isActive = true";

    private static final String SELECT_RESTAURANTS_BY_CUISINE =
            "SELECT * FROM restaurant WHERE cuisineType = ?";

    private static final String SELECT_RESTAURANTS_BY_ADMIN =
            "SELECT * FROM restaurant WHERE adminUserId = ?";

    private static final String UPDATE_RESTAURANT =
            "UPDATE restaurant SET name = ?, cuisineType = ?, "
          + "deliveryTime = ?, address = ?, adminUserId = ?, "
          + "rating = ?, isActive = ?, imagePath = ? "
          + "WHERE restaurantId = ?";

    private static final String DELETE_RESTAURANT =
            "DELETE FROM restaurant WHERE restaurantId = ?";


    // =========================
    // ADD RESTAURANT
    // =========================

    @Override
    public void addRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_RESTAURANT)) {

            statement.setString(1, restaurant.getName());
            statement.setString(2, restaurant.getCuisineType());
            statement.setInt(3, restaurant.getDeliveryTime());
            statement.setString(4, restaurant.getAddress());
            statement.setInt(5, restaurant.getAdminUserId());
            statement.setDouble(6, restaurant.getRating());
            statement.setBoolean(7, restaurant.isActive());
            statement.setString(8, restaurant.getImagePath());

            statement.executeUpdate();

            System.out.println("Restaurant added successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // GET RESTAURANT BY ID
    // =========================

    @Override
    public Restaurant getRestaurant(int restaurantId) {

        Restaurant restaurant = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_RESTAURANT_BY_ID)) {

            statement.setInt(1, restaurantId);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {
                restaurant = extractRestaurantFromResultSet(resultSet);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurant;
    }


    // =========================
    // GET ALL RESTAURANTS
    // =========================

    @Override
    public List<Restaurant> getAllRestaurants() {

        List<Restaurant> restaurants = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ALL_RESTAURANTS)) {

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Restaurant restaurant =
                        extractRestaurantFromResultSet(resultSet);

                restaurants.add(restaurant);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }


    // =========================
    // GET ACTIVE RESTAURANTS
    // =========================

    @Override
    public List<Restaurant> getActiveRestaurants() {

        List<Restaurant> restaurants = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ACTIVE_RESTAURANTS)) {

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Restaurant restaurant =
                        extractRestaurantFromResultSet(resultSet);

                restaurants.add(restaurant);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }


    // =========================
    // GET BY CUISINE
    // =========================

    @Override
    public List<Restaurant> getRestaurantsByCuisine(String cuisineType) {

        List<Restaurant> restaurants = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_RESTAURANTS_BY_CUISINE)) {

            statement.setString(1, cuisineType);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Restaurant restaurant =
                        extractRestaurantFromResultSet(resultSet);

                restaurants.add(restaurant);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }


    // =========================
    // GET BY ADMIN
    // =========================

    @Override
    public List<Restaurant> getRestaurantsByAdmin(int adminUserId) {

        List<Restaurant> restaurants = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_RESTAURANTS_BY_ADMIN)) {

            statement.setInt(1, adminUserId);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Restaurant restaurant =
                        extractRestaurantFromResultSet(resultSet);

                restaurants.add(restaurant);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }


    // =========================
    // UPDATE RESTAURANT
    // =========================

    @Override
    public void updateRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_RESTAURANT)) {

            statement.setString(1, restaurant.getName());
            statement.setString(2, restaurant.getCuisineType());
            statement.setInt(3, restaurant.getDeliveryTime());
            statement.setString(4, restaurant.getAddress());
            statement.setInt(5, restaurant.getAdminUserId());
            statement.setDouble(6, restaurant.getRating());
            statement.setBoolean(7, restaurant.isActive());
            statement.setString(8, restaurant.getImagePath());
            statement.setInt(9, restaurant.getRestaurantId());

            statement.executeUpdate();

            System.out.println("Restaurant updated successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // DELETE RESTAURANT
    // =========================

    @Override
    public void deleteRestaurant(int restaurantId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_RESTAURANT)) {

            statement.setInt(1, restaurantId);

            statement.executeUpdate();

            System.out.println("Restaurant deleted successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // RESULTSET → RESTAURANT
    // =========================

    private Restaurant extractRestaurantFromResultSet(ResultSet resultSet)
            throws SQLException {

        Restaurant restaurant = new Restaurant();

        restaurant.setRestaurantId(
                resultSet.getInt("restaurantId"));

        restaurant.setName(
                resultSet.getString("name"));

        restaurant.setCuisineType(
                resultSet.getString("cuisineType"));

        restaurant.setDeliveryTime(
                resultSet.getInt("deliveryTime"));

        restaurant.setAddress(
                resultSet.getString("address"));

        restaurant.setAdminUserId(
                resultSet.getInt("adminUserId"));

        restaurant.setRating(
                resultSet.getDouble("rating"));

        restaurant.setActive(
                resultSet.getBoolean("isActive"));

        restaurant.setImagePath(
                resultSet.getString("imagePath"));

        return restaurant;
    }
}