package com.tap.controllers;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.tap.daoImpl.UserDaoImpl;
import com.tap.model.User;

@WebServlet("/signup")
public class SignupController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDaoImpl userDao;

    @Override
    public void init() throws ServletException {

        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect("signup.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // Get form data

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String address = request.getParameter("address");


        // Basic validation

        if (username == null || username.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || address == null || address.trim().isEmpty()) {

            request.setAttribute(
                    "errorMessage",
                    "Please fill in all the fields."
            );

            request.getRequestDispatcher("signup.jsp")
                   .forward(request, response);

            return;
        }


        // Check whether email already exists

        User existingUser = userDao.getUserByEmail(email);

        if (existingUser != null) {

            request.setAttribute(
                    "errorMessage",
                    "An account with this email already exists."
            );

            request.getRequestDispatcher("signup.jsp")
                   .forward(request, response);

            return;
        }


        // Create User object

        User user = new User();

        user.setUsername(username.trim());
        user.setPassword(password);
        user.setEmail(email.trim());
        user.setPhone(phone.trim());
        user.setAddress(address.trim());

        // Normal customer account

        user.setRole("USER");


        // Save user

        userDao.addUser(user);


        // Show success message

        request.setAttribute(
                "successMessage",
                "Account created successfully! Please login."
        );

        request.getRequestDispatcher("signup.jsp")
               .forward(request, response);
    }
}