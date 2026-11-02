
package com.tap.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.dao.UserDao;
import com.tap.model.User;
import com.tap.util.DBConnection;

public class UserDaoImpl implements UserDao {

    // SQL QUERIES

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

    private static final String UPDATE_PASSWORD_BY_EMAIL =
            "UPDATE user SET password = ? WHERE email = ?";


    // CHECK WHETHER PASSWORD IS ALREADY A BCRYPT HASH

    private boolean isBCryptHash(String password) {
        return password != null
                && (password.startsWith("$2a$")
                || password.startsWith("$2b$")
                || password.startsWith("$2y$"));
    }


    // ADD USER - HASH PASSWORD BEFORE SAVING

    @Override
    public void addUser(User user) {

        if (user == null || user.getPassword() == null
                || user.getPassword().isEmpty()) {
            throw new IllegalArgumentException(
                    "User and password are required.");
        }

        String hashedPassword =
                BCrypt.hashpw(user.getPassword(), BCrypt.gensalt(12));

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_USER)) {

            statement.setString(1, user.getUsername());
            statement.setString(2, hashedPassword);
            statement.setString(3, user.getEmail());
            statement.setString(4, user.getPhone());
            statement.setString(5, user.getAddress());
            statement.setString(6, user.getRole());

            statement.executeUpdate();

            System.out.println("User added successfully!");

        } catch (SQLException e) {
            throw new RuntimeException("Unable to register user.", e);
        }
    }


    // GET USER BY ID

    @Override
    public User getUser(int userId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_USER_BY_ID)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return extractUserFromResultSet(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }


    // GET USER BY EMAIL

    @Override
    public User getUserByEmail(String email) {

        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_USER_BY_EMAIL)) {

            statement.setString(1, email.trim());

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return extractUserFromResultSet(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }


    // GET ALL USERS

    @Override
    public List<User> getAllUsers() {

        List<User> users = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ALL_USERS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                users.add(extractUserFromResultSet(resultSet));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }


    // UPDATE USER

    @Override
    public void updateUser(User user) {

        if (user == null) {
            throw new IllegalArgumentException("User is required.");
        }

        String password = user.getPassword();

        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException(
                    "Password cannot be null or empty.");
        }

        // Hash plain-text passwords only.
        if (!isBCryptHash(password)) {
            password = BCrypt.hashpw(password, BCrypt.gensalt(12));
        }

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_USER)) {

            statement.setString(1, user.getUsername());
            statement.setString(2, password);
            statement.setString(3, user.getEmail());
            statement.setString(4, user.getPhone());
            statement.setString(5, user.getAddress());
            statement.setString(6, user.getRole());
            statement.setInt(7, user.getUserId());

            statement.executeUpdate();

            System.out.println("User updated successfully!");

        } catch (SQLException e) {
            throw new RuntimeException("Unable to update user.", e);
        }
    }


    // UPDATE PASSWORD BY EMAIL

    @Override
    public boolean updatePasswordByEmail(String email, String newPassword) {

        if (email == null || email.trim().isEmpty()
                || newPassword == null || newPassword.length() < 6) {
            return false;
        }

        String hashedPassword =
                BCrypt.hashpw(newPassword, BCrypt.gensalt(12));

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_PASSWORD_BY_EMAIL)) {

            statement.setString(1, hashedPassword);
            statement.setString(2, email.trim());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    // DELETE USER

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


    // RESULT SET TO USER OBJECT

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
