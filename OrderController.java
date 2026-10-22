
package com.tap.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orders")
public class OrderController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        Object userIdObject = session == null
                ? null
                : session.getAttribute("userId");

        List<Map<String, Object>> orders = new ArrayList<>();

        // Always provide the orders list to the JSP.
        request.setAttribute("orders", orders);

        // A guest can open My Orders without being redirected to login.
        if (userIdObject == null) {
            request.setAttribute("isLoggedIn", false);

            request.getRequestDispatcher("/orders.jsp")
                   .forward(request, response);

            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(userIdObject.toString());
        } catch (NumberFormatException e) {
            // Invalid session user ID: do not query orders.
            request.setAttribute("isLoggedIn", false);

            request.getRequestDispatcher("/orders.jsp")
                   .forward(request, response);

            return;
        }

        request.setAttribute("isLoggedIn", true);

        String sql =
                "SELECT o.orderId, " +
                "o.restaurantId, " +
                "o.orderDate, " +
                "o.totalAmount, " +
                "o.status, " +
                "o.paymentMode, " +
                "r.name AS restaurantName, " +
                "r.imagePath AS restaurantImage " +
                "FROM orders o " +
                "JOIN restaurant r " +
                "ON o.restaurantId = r.restaurantId " +
                "WHERE o.userId = ? " +
                "ORDER BY o.orderDate DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> order = new HashMap<>();

                    int orderId = rs.getInt("orderId");

                    order.put("orderId", orderId);
                    order.put("restaurantId", rs.getInt("restaurantId"));
                    order.put("orderDate", rs.getTimestamp("orderDate"));
                    order.put("totalAmount", rs.getBigDecimal("totalAmount"));
                    order.put("status", rs.getString("status"));
                    order.put("paymentMode", rs.getString("paymentMode"));
                    order.put("restaurantName", rs.getString("restaurantName"));
                    order.put("restaurantImage", rs.getString("restaurantImage"));

                    List<Map<String, Object>> items =
                            getOrderItems(connection, orderId);

                    order.put("items", items);
                    orders.add(order);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load your orders. Please try again later."
            );
        }

        request.setAttribute("orders", orders);

        request.getRequestDispatcher("/orders.jsp")
               .forward(request, response);
    }

    private List<Map<String, Object>> getOrderItems(
            Connection connection,
            int orderId) throws Exception {

        List<Map<String, Object>> items = new ArrayList<>();

        String sql =
                "SELECT oi.orderItemId, " +
                "oi.menuId, " +
                "oi.totalAmount, " +
                "m.itemName, " +
                "m.imagePath " +
                "FROM orderItem oi " +
                "JOIN menu m ON oi.menuId = m.menuId " +
                "WHERE oi.orderId = ?";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, orderId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();

                    item.put("orderItemId", rs.getInt("orderItemId"));
                    item.put("menuId", rs.getInt("menuId"));
                    item.put("totalAmount", rs.getBigDecimal("totalAmount"));
                    item.put("itemName", rs.getString("itemName"));
                    item.put("imagePath", rs.getString("imagePath"));

                    items.add(item);
                }
            }
        }

        return items;
    }
}
