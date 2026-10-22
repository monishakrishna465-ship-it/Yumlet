
package com.tap.controllers;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.daoImpl.UserDaoImpl;
import com.tap.model.User;

@WebServlet("/profile")
public class ProfileController extends HttpServlet {

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

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login?from=profile");
            return;
        }

        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?from=profile");
            return;
        }

        User user = userDao.getUser(userId);

        if (user == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Keep the session synchronized with the latest database details.
        updateSessionDetails(session, user);

        request.setAttribute("profileUser", user);

        request.getRequestDispatcher("/profile.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login?from=profile");
            return;
        }

        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?from=profile");
            return;
        }

        // Always load the user by the ID stored in the session.
        // Never accept a user ID submitted by the browser.
        User user = userDao.getUser(userId);

        if (user == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        if (username.isEmpty() || email.isEmpty()) {
            request.setAttribute(
                "errorMessage",
                "Name and email are required."
            );

            request.setAttribute("profileUser", user);
            request.getRequestDispatcher("/profile.jsp")
                   .forward(request, response);
            return;
        }

        if (username.length() > 100
                || email.length() > 254
                || phone.length() > 30
                || address.length() > 1000) {

            request.setAttribute(
                "errorMessage",
                "One or more fields exceed the allowed length."
            );

            // Show the submitted values again.
            user.setUsername(username);
            user.setEmail(email);
            user.setPhone(phone);
            user.setAddress(address);

            request.setAttribute("profileUser", user);
            request.getRequestDispatcher("/profile.jsp")
                   .forward(request, response);
            return;
        }

        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            request.setAttribute(
                "errorMessage",
                "Please enter a valid email address."
            );

            user.setUsername(username);
            user.setEmail(email);
            user.setPhone(phone);
            user.setAddress(address);

            request.setAttribute("profileUser", user);
            request.getRequestDispatcher("/profile.jsp")
                   .forward(request, response);
            return;
        }

        // Preserve password, role and user ID from the database object.
        user.setUsername(username);
        user.setEmail(email);
        user.setPhone(phone);
        user.setAddress(address);

        userDao.updateUser(user);

        // Read back the saved record before confirming success.
        User updatedUser = userDao.getUser(userId);

        if (updatedUser == null
                || !username.equals(updatedUser.getUsername())
                || !email.equals(updatedUser.getEmail())
                || !phone.equals(updatedUser.getPhone())
                || !address.equals(updatedUser.getAddress())) {

            request.setAttribute(
                "errorMessage",
                "We couldn't confirm your changes were saved. Please try again."
            );

            request.setAttribute(
                "profileUser",
                updatedUser != null ? updatedUser : user
            );

            request.getRequestDispatcher("/profile.jsp")
                   .forward(request, response);
            return;
        }

        updateSessionDetails(session, updatedUser);

        // Post/Redirect/Get prevents accidental duplicate submissions.
        response.sendRedirect(
            request.getContextPath() + "/profile?updated=true"
        );
    }

    private Integer getLoggedInUserId(HttpSession session) {
        Object value = session.getAttribute("userId");

        if (value instanceof Integer) {
            return (Integer) value;
        }

        if (value instanceof Number) {
            return ((Number) value).intValue();
        }

        return null;
    }

    private void updateSessionDetails(HttpSession session, User user) {
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("phone", user.getPhone());
        session.setAttribute("address", user.getAddress());
        session.setAttribute("role", user.getRole());
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
