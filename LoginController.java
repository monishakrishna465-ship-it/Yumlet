
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

        if ("checkout".equals(from)) {
            request.setAttribute("from", "checkout");
        } else if ("profile".equals(from)) {
            request.setAttribute("from", "profile");
        }

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String from = request.getParameter("from");

        if (email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {

            showError(request, response,
                    "Please enter your email and password.", from);
            return;
        }

        User user = userDao.getUserByEmail(email.trim());

        if (user == null) {
            showError(request, response,
                    "No account found with this email.", from);
            return;
        }

        if (user.getPassword() == null
                || !user.getPassword().equals(password)) {

            showError(request, response,
                    "Incorrect password.", from);
            return;
        }

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
        } else if ("profile".equals(from)) {
            response.sendRedirect(contextPath + "/profile");
        } else {
            response.sendRedirect(contextPath + "/index.jsp");
        }
    }

    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           String message,
                           String from)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);

        if ("checkout".equals(from) || "profile".equals(from)) {
            request.setAttribute("from", from);
        }

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }
}
