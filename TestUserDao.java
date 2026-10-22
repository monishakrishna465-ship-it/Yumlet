package com.tap.util;

import com.tap.dao.UserDao;
import com.tap.daoImpl.UserDaoImpl;
import com.tap.model.User;

public class TestUserDao {

    public static void main(String[] args) {

        UserDao userDao = new UserDaoImpl();

        // Create a new user
        User user = new User();

        user.setUsername("Monisha");
        user.setPassword("test123");
        user.setEmail("monisha@test.com");
        user.setPhone("9876543210");
        user.setAddress("Bangalore");
        user.setRole("USER");

        // Add user to database
        userDao.addUser(user);

        System.out.println("User added successfully!");
    }
}