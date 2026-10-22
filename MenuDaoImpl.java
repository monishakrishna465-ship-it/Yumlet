package com.tap.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.MenuDao;
import com.tap.model.Menu;
import com.tap.util.DBConnection;

public class MenuDaoImpl implements MenuDao {

    private static final String INSERT_MENU =
            "INSERT INTO menu "
          + "(restaurantId, itemName, description, price, isAvailable, imagePath) "
          + "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_MENU_BY_ID =
            "SELECT * FROM menu WHERE menuId = ?";

    private static final String SELECT_ALL_MENUS =
            "SELECT * FROM menu";

    private static final String SELECT_MENUS_BY_RESTAURANT =
            "SELECT * FROM menu WHERE restaurantId = ?";

    private static final String SELECT_AVAILABLE_MENUS =
            "SELECT * FROM menu WHERE restaurantId = ? AND isAvailable = true";

    private static final String UPDATE_MENU =
            "UPDATE menu SET restaurantId = ?, itemName = ?, "
          + "description = ?, price = ?, isAvailable = ?, imagePath = ? "
          + "WHERE menuId = ?";

    private static final String DELETE_MENU =
            "DELETE FROM menu WHERE menuId = ?";


    // =========================
    // ADD MENU
    // =========================

    @Override
    public void addMenu(Menu menu) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_MENU)) {

            statement.setInt(1, menu.getRestaurantId());
            statement.setString(2, menu.getItemName());
            statement.setString(3, menu.getDescription());
            statement.setBigDecimal(4, menu.getPrice());
            statement.setBoolean(5, menu.isAvailable());
            statement.setString(6, menu.getImagePath());

            statement.executeUpdate();

            System.out.println("Menu item added successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // GET MENU BY ID
    // =========================

    @Override
    public Menu getMenu(int menuId) {

        Menu menu = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_MENU_BY_ID)) {

            statement.setInt(1, menuId);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {
                menu = extractMenuFromResultSet(resultSet);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menu;
    }


    // =========================
    // GET ALL MENUS
    // =========================

    @Override
    public List<Menu> getAllMenus() {

        List<Menu> menus = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ALL_MENUS)) {

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Menu menu = extractMenuFromResultSet(resultSet);

                menus.add(menu);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menus;
    }


    // =========================
    // GET MENUS BY RESTAURANT
    // =========================

    @Override
    public List<Menu> getMenusByRestaurant(int restaurantId) {

        List<Menu> menus = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_MENUS_BY_RESTAURANT)) {

            statement.setInt(1, restaurantId);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Menu menu = extractMenuFromResultSet(resultSet);

                menus.add(menu);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menus;
    }


    // =========================
    // GET AVAILABLE MENUS
    // =========================

    @Override
    public List<Menu> getAvailableMenus(int restaurantId) {

        List<Menu> menus = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_AVAILABLE_MENUS)) {

            statement.setInt(1, restaurantId);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                Menu menu = extractMenuFromResultSet(resultSet);

                menus.add(menu);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menus;
    }


    // =========================
    // UPDATE MENU
    // =========================

    @Override
    public void updateMenu(Menu menu) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_MENU)) {

            statement.setInt(1, menu.getRestaurantId());
            statement.setString(2, menu.getItemName());
            statement.setString(3, menu.getDescription());
            statement.setBigDecimal(4, menu.getPrice());
            statement.setBoolean(5, menu.isAvailable());
            statement.setString(6, menu.getImagePath());
            statement.setInt(7, menu.getMenuId());

            statement.executeUpdate();

            System.out.println("Menu item updated successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // DELETE MENU
    // =========================

    @Override
    public void deleteMenu(int menuId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_MENU)) {

            statement.setInt(1, menuId);

            statement.executeUpdate();

            System.out.println("Menu item deleted successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // RESULTSET → MENU
    // =========================

    private Menu extractMenuFromResultSet(ResultSet resultSet)
            throws SQLException {

        Menu menu = new Menu();

        menu.setMenuId(
                resultSet.getInt("menuId"));

        menu.setRestaurantId(
                resultSet.getInt("restaurantId"));

        menu.setItemName(
                resultSet.getString("itemName"));

        menu.setDescription(
                resultSet.getString("description"));

        menu.setPrice(
                resultSet.getBigDecimal("price"));

        menu.setAvailable(
                resultSet.getBoolean("isAvailable"));

        menu.setImagePath(
                resultSet.getString("imagePath"));

        return menu;
    }
}