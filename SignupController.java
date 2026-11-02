
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

        response.sendRedirect(request.getContextPath() + "/signup.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String address = request.getParameter("address");

        if (isEmpty(username) || isEmpty(email)
                || isEmpty(phone) || isEmpty(password)
                || isEmpty(address)) {

            showError(request, response,
                    "Please fill in all the fields.");
            return;
        }

        if (password.length() < 6) {
            showError(request, response,
                    "Password must contain at least 6 characters.");
            return;
        }

        email = email.trim();

        User existingUser = userDao.getUserByEmail(email);

        if (existingUser != null) {
            showError(request, response,
                    "An account with this email already exists.");
            return;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setEmail(email);
        user.setPhone(phone.trim());
        user.setPassword(password);
        user.setAddress(address.trim());
        user.setRole("USER");

        userDao.addUser(user);

        // Show a success message on the login page.
        request.getSession().setAttribute(
                "signupSuccess",
                "Account created successfully! Please log in."
        );

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/signup.jsp")
               .forward(request, response);
    }
}
