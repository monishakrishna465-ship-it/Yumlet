
package com.tap.controllers;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.daoImpl.UserDaoImpl;
import com.tap.model.User;

@WebServlet("/login")
public class LoginController extends HttpServlet {

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

        String from = request.getParameter("from");
        String returnTo = request.getParameter("returnTo");

        if (from != null) {
            request.setAttribute("from", from);
        }

        if (isSafeReturnTo(returnTo, request.getContextPath())) {
            request.setAttribute("returnTo", returnTo);
        }

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String from = request.getParameter("from");
        String returnTo = request.getParameter("returnTo");

        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {

            showError(request, response,
                    "Please enter your email and password.",
                    from, returnTo);
            return;
        }

        email = email.trim();

        User user = userDao.getUserByEmail(email);

        if (user == null) {
            showError(request, response,
                    "Invalid email or password.",
                    from, returnTo);
            return;
        }

        String storedPassword = user.getPassword();

        if (storedPassword == null || storedPassword.isEmpty()) {
            showError(request, response,
                    "Invalid email or password.",
                    from, returnTo);
            return;
        }

        boolean passwordMatches = false;
        boolean isBCryptHash =
                storedPassword.startsWith("$2a$")
                || storedPassword.startsWith("$2b$")
                || storedPassword.startsWith("$2y$");

        if (isBCryptHash) {

            try {
                passwordMatches =
                        BCrypt.checkpw(password, storedPassword);
            } catch (IllegalArgumentException e) {
                passwordMatches = false;
            }

        } else {
            // Support existing accounts whose passwords
            // are still stored as plain text.
            passwordMatches = storedPassword.equals(password);
        }

        if (!passwordMatches) {
            showError(request, response,
                    "Invalid email or password.",
                    from, returnTo);
            return;
        }

        // Upgrade a plain-text password after successful login.
        if (!isBCryptHash) {
            try {
                boolean updated =
                        userDao.updatePasswordByEmail(email, password);

                if (!updated) {
                    System.err.println(
                        "Warning: Password hash update failed for user ID "
                        + user.getUserId());
                }

            } catch (RuntimeException e) {
                // Do not expose password details in error messages.
                getServletContext().log(
                    "Could not upgrade password hash for user ID "
                    + user.getUserId(), e);
            }
        }

        // Create a fresh session after successful authentication.
     // Keep the existing session attributes, including the guest cart.
     // Rotate the session ID for security without deleting the cart.
     request.changeSessionId();

     HttpSession session = request.getSession();

        session.setAttribute("userId", user.getUserId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("phone", user.getPhone());
        session.setAttribute("address", user.getAddress());
        session.setAttribute("role", user.getRole());

        String contextPath = request.getContextPath();

        if ("checkout".equals(from)) {
            response.sendRedirect(contextPath + "/checkout");
            return;
        }

        if ("profile".equals(from)) {
            response.sendRedirect(contextPath + "/profile");
            return;
        }

        if (isSafeReturnTo(returnTo, contextPath)) {
            response.sendRedirect(contextPath + returnTo);
            return;
        }

        response.sendRedirect(contextPath + "/index.jsp");
    }

    private boolean isSafeReturnTo(String returnTo,
                                  String contextPath) {

        if (returnTo == null || returnTo.trim().isEmpty()) {
            return false;
        }

        if (!returnTo.startsWith("/")
                || returnTo.startsWith("//")
                || returnTo.contains("\\")
                || returnTo.contains("\r")
                || returnTo.contains("\n")
                || returnTo.contains("://")) {
            return false;
        }

        if (contextPath != null
                && !contextPath.isEmpty()
                && returnTo.startsWith(contextPath + "/")) {
            return false;
        }

        return true;
    }

    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           String message,
                           String from,
                           String returnTo)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);

        if (from != null) {
            request.setAttribute("from", from);
        }

        if (isSafeReturnTo(returnTo, request.getContextPath())) {
            request.setAttribute("returnTo", returnTo);
        }

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }
}
