
package com.tap.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.util.DBConnection;

@WebServlet("/favourite")
public class FavouriteController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // LOAD SAVED FAVOURITES
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(
                String.valueOf(session.getAttribute("userId"))
            );
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String, Object>> restaurantFavourites =
            new ArrayList<>();

        List<Map<String, Object>> foodFavourites =
            new ArrayList<>();

        String restaurantSql =
            "SELECT r.restaurantId, r.name, " +
            "r.cuisineType AS description, r.imagePath, r.rating " +
            "FROM favourites f " +
            "JOIN restaurant r ON r.restaurantId = f.itemId " +
            "WHERE f.userId = ? AND f.itemType = 'restaurant' " +
            "ORDER BY f.createdAt DESC";

        String foodSql =
            "SELECT m.menuId, m.itemName AS name, " +
            "m.description, m.imagePath, m.price " +
            "FROM favourites f " +
            "JOIN menu m ON m.menuId = f.itemId " +
            "WHERE f.userId = ? AND f.itemType = 'food' " +
            "ORDER BY f.createdAt DESC";

        try (Connection connection = DBConnection.getConnection()) {

            // Retrieve restaurant favourites
            try (PreparedStatement ps =
                     connection.prepareStatement(restaurantSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();

                        item.put("restaurantId",
                                 rs.getInt("restaurantId"));
                        item.put("name", rs.getString("name"));
                        item.put("description",
                                 rs.getString("description"));
                        item.put("imagePath",
                                 rs.getString("imagePath"));
                        item.put("rating", rs.getObject("rating"));

                        restaurantFavourites.add(item);
                    }
                }
            }

            // Retrieve food favourites
            try (PreparedStatement ps =
                     connection.prepareStatement(foodSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();

                        item.put("menuId", rs.getInt("menuId"));
                        item.put("name", rs.getString("name"));
                        item.put("description",
                                 rs.getString("description"));
                        item.put("imagePath",
                                 rs.getString("imagePath"));
                        item.put("price", rs.getObject("price"));

                        foodFavourites.add(item);
                    }
                }
            }

            request.setAttribute(
                "restaurantFavourites", restaurantFavourites
            );

            request.setAttribute(
                "foodFavourites", foodFavourites
            );

            request.getRequestDispatcher("/favourites.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            getServletContext().log(
                "Unable to load favourites", e
            );

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Unable to load favourites. Check the Tomcat console."
            );
        }
    }

    // SAVE OR REMOVE FAVOURITES
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Please log in first.\"}"
            );
            return;
        }

        int userId;
        int itemId;
        String itemType = request.getParameter("itemType");

        try {
            userId = Integer.parseInt(
                String.valueOf(session.getAttribute("userId"))
            );
            itemId = Integer.parseInt(request.getParameter("itemId"));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Invalid favourite details.\"}"
            );
            return;
        }

        if (itemId <= 0 || itemType == null ||
            !(itemType.equals("restaurant") ||
              itemType.equals("food"))) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Invalid favourite type or ID.\"}"
            );
            return;
        }

        try (Connection connection = DBConnection.getConnection()) {

            String checkSql =
                "SELECT favouriteId FROM favourites " +
                "WHERE userId = ? AND itemId = ? AND itemType = ?";

            boolean exists;

            try (PreparedStatement ps =
                     connection.prepareStatement(checkSql)) {

                ps.setInt(1, userId);
                ps.setInt(2, itemId);
                ps.setString(3, itemType);

                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                String deleteSql =
                    "DELETE FROM favourites " +
                    "WHERE userId = ? AND itemId = ? AND itemType = ?";

                try (PreparedStatement ps =
                         connection.prepareStatement(deleteSql)) {

                    ps.setInt(1, userId);
                    ps.setInt(2, itemId);
                    ps.setString(3, itemType);
                    ps.executeUpdate();
                }

                response.getWriter().write(
                    "{\"success\":true,\"saved\":false}"
                );

            } else {
                String insertSql =
                    "INSERT INTO favourites (userId, itemId, itemType) " +
                    "VALUES (?, ?, ?)";

                try (PreparedStatement ps =
                         connection.prepareStatement(insertSql)) {

                    ps.setInt(1, userId);
                    ps.setInt(2, itemId);
                    ps.setString(3, itemType);
                    ps.executeUpdate();
                }

                response.getWriter().write(
                    "{\"success\":true,\"saved\":true}"
                );
            }

        } catch (SQLException e) {
            getServletContext().log(
                "Unable to update favourite", e
            );

            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            response.getWriter().write(
                "{\"success\":false,\"message\":\"Unable to save favourite.\"}"
            );
        }
    }
}
