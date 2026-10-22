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

    // Delete
    void deleteUser(int userId);
}