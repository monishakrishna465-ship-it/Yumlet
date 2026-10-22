
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

@WebServlet("/favourites")
public class favouritesController extends HttpServlet {

    private static final long serialVersionUID = 1L;

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

        List<Map<String, Object>> restaurantFavourites = new ArrayList<>();
        List<Map<String, Object>> foodFavourites = new ArrayList<>();

        String sql =
            "SELECT f.itemId, f.itemType, " +
            "r.name AS restaurantName, r.cuisineType, " +
            "r.rating, r.imagePath AS restaurantImage, " +
            "m.itemName, m.description, m.price, " +
            "m.imagePath AS foodImage " +
            "FROM favourites f " +
            "LEFT JOIN restaurant r " +
            "ON f.itemType = 'restaurant' " +
            "AND f.itemId = r.restaurantId " +
            "LEFT JOIN menu m " +
            "ON f.itemType = 'food' " +
            "AND f.itemId = m.menuId " +
            "WHERE f.userId = ? " +
            "ORDER BY f.createdAt DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {

                    Map<String, Object> item = new HashMap<>();

                    item.put("itemId", rs.getInt("itemId"));
                    item.put("itemType", rs.getString("itemType"));

                    if ("restaurant".equals(rs.getString("itemType"))) {
                        item.put("name", rs.getString("restaurantName"));
                        item.put("description", rs.getString("cuisineType"));
                        item.put("rating", rs.getObject("rating"));
                        item.put("imagePath", rs.getString("restaurantImage"));

                        if (rs.getString("restaurantName") != null) {
                            restaurantFavourites.add(item);
                        }

                    } else if ("food".equals(rs.getString("itemType"))) {
                        item.put("name", rs.getString("itemName"));
                        item.put("description", rs.getString("description"));
                        item.put("price", rs.getObject("price"));
                        item.put("imagePath", rs.getString("foodImage"));

                        if (rs.getString("itemName") != null) {
                            foodFavourites.add(item);
                        }
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load favourites. Check the database table and column names.",
                e
            );
        }

        request.setAttribute("restaurantFavourites", restaurantFavourites);
        request.setAttribute("foodFavourites", foodFavourites);

        request.getRequestDispatcher("/favourites.jsp")
               .forward(request, response);
    }
}
