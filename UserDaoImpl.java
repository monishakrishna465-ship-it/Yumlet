package com.tap.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.UserDao;
import com.tap.model.User;
import com.tap.util.DBConnection;

public class UserDaoImpl implements UserDao {

    // SQL Queries

    private static final String INSERT_USER =
            "INSERT INTO user (username, password, email, phone, address, role) "
          + "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_USER_BY_ID =
            "SELECT * FROM user WHERE userId = ?";

    private static final String SELECT_USER_BY_EMAIL =
            "SELECT * FROM user WHERE email = ?";

    private static final String SELECT_ALL_USERS =
            "SELECT * FROM user";

    private static final String UPDATE_USER =
            "UPDATE user SET username = ?, password = ?, email = ?, "
          + "phone = ?, address = ?, role = ? WHERE userId = ?";

    private static final String DELETE_USER =
            "DELETE FROM user WHERE userId = ?";


    // =========================
    // ADD USER
    // =========================

    @Override
    public void addUser(User user) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_USER)) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getPassword());
            statement.setString(3, user.getEmail());
            statement.setString(4, user.getPhone());
            statement.setString(5, user.getAddress());
            statement.setString(6, user.getRole());

            statement.executeUpdate();

            System.out.println("User added successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // GET USER BY ID
    // =========================

    @Override
    public User getUser(int userId) {

        User user = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_USER_BY_ID)) {

            statement.setInt(1, userId);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {

                user = extractUserFromResultSet(resultSet);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }


    // =========================
    // GET USER BY EMAIL
    // =========================

    @Override
    public User getUserByEmail(String email) {

        User user = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_USER_BY_EMAIL)) {

            statement.setString(1, email);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {

                user = extractUserFromResultSet(resultSet);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }


    // =========================
    // GET ALL USERS
    // =========================

    @Override
    public List<User> getAllUsers() {

        List<User> users = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ALL_USERS)) {

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                User user = extractUserFromResultSet(resultSet);

                users.add(user);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }


    // =========================
    // UPDATE USER
    // =========================

    @Override
    public void updateUser(User user) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_USER)) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getPassword());
            statement.setString(3, user.getEmail());
            statement.setString(4, user.getPhone());
            statement.setString(5, user.getAddress());
            statement.setString(6, user.getRole());
            statement.setInt(7, user.getUserId());

            statement.executeUpdate();

            System.out.println("User updated successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // DELETE USER
    // =========================

    @Override
    public void deleteUser(int userId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_USER)) {

            statement.setInt(1, userId);

            statement.executeUpdate();

            System.out.println("User deleted successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // RESULTSET → USER OBJECT
    // =========================

    private User extractUserFromResultSet(ResultSet resultSet)
            throws SQLException {

        User user = new User();

        user.setUserId(resultSet.getInt("userId"));
        user.setUsername(resultSet.getString("username"));
        user.setPassword(resultSet.getString("password"));
        user.setEmail(resultSet.getString("email"));
        user.setPhone(resultSet.getString("phone"));
        user.setAddress(resultSet.getString("address"));
        user.setRole(resultSet.getString("role"));

        return user;
    }
}