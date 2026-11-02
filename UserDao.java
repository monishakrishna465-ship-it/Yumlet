
package com.tap.dao;

import java.util.List;
import com.tap.model.User;

public interface UserDao {

    // Create
    void addUser(User user);

    // Read
    User getUser(int userId);

    User getUserByEmail(String email);

    List<User> getAllUsers();

    // Update
    void updateUser(User user);

    // Forgot Password: update password for a registered email
    boolean updatePasswordByEmail(String email, String newPassword);

    // Delete
    void deleteUser(int userId);
}
