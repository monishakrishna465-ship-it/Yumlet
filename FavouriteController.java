
package com.tap.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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

        if (itemId <= 0 ||
            itemType == null ||
            !(itemType.equals("restaurant") || itemType.equals("food"))) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Invalid favourite type or ID.\"}"
            );
            return;
        }

        try (Connection connection = DBConnection.getConnection()) {

            String checkSql =
                "SELECT favouriteId FROM favourites "
              + "WHERE userId = ? AND itemId = ? AND itemType = ?";

            boolean exists = false;

            try (PreparedStatement check =
                     connection.prepareStatement(checkSql)) {

                check.setInt(1, userId);
                check.setInt(2, itemId);
                check.setString(3, itemType);

                try (ResultSet rs = check.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                String deleteSql =
                    "DELETE FROM favourites "
                  + "WHERE userId = ? AND itemId = ? AND itemType = ?";

                try (PreparedStatement delete =
                         connection.prepareStatement(deleteSql)) {

                    delete.setInt(1, userId);
                    delete.setInt(2, itemId);
                    delete.setString(3, itemType);
                    delete.executeUpdate();
                }

                response.getWriter().write(
                    "{\"success\":true,\"saved\":false}"
                );

            } else {
                String insertSql =
                    "INSERT INTO favourites (userId, itemId, itemType) "
                  + "VALUES (?, ?, ?)";

                try (PreparedStatement insert =
                         connection.prepareStatement(insertSql)) {

                    insert.setInt(1, userId);
                    insert.setInt(2, itemId);
                    insert.setString(3, itemType);
                    insert.executeUpdate();
                }

                response.getWriter().write(
                    "{\"success\":true,\"saved\":true}"
                );
            }

        } catch (SQLException e) {
            getServletContext().log("Unable to update favourite", e);

            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Unable to save favourite.\"}"
            );
        }
    }
}
