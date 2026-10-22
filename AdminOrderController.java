package com.tap.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin-orders")
public class AdminOrderController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Object userIdObject = session.getAttribute("userId");

        if (userIdObject == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = Integer.parseInt(userIdObject.toString());

        /*
         * For now, this checks whether the logged-in user
         * is an ADMIN.
         */
        String role = (String) session.getAttribute("role");

        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        String sql =
                "SELECT o.orderId, o.userId, o.restaurantId, " +
                "o.orderDate, o.totalAmount, o.status, " +
                "o.paymentMode, " +
                "u.username, u.phone, u.address, " +
                "r.name AS restaurantName, " +
                "r.imagePath AS restaurantImage " +
                "FROM orders o " +
                "JOIN user u ON o.userId = u.userId " +
                "JOIN restaurant r ON o.restaurantId = r.restaurantId " +
                "ORDER BY o.orderDate DESC";

        List<OrderData> orders = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                OrderData order = new OrderData();

                order.orderId =
                        resultSet.getInt("orderId");

                order.userId =
                        resultSet.getInt("userId");

                order.restaurantId =
                        resultSet.getInt("restaurantId");

                order.orderDate =
                        resultSet.getTimestamp("orderDate");

                order.totalAmount =
                        resultSet.getBigDecimal("totalAmount");

                order.status =
                        resultSet.getString("status");

                order.paymentMode =
                        resultSet.getString("paymentMode");

                order.username =
                        resultSet.getString("username");

                order.phone =
                        resultSet.getString("phone");

                order.address =
                        resultSet.getString("address");

                order.restaurantName =
                        resultSet.getString("restaurantName");

                order.restaurantImage =
                        resultSet.getString("restaurantImage");

                orders.add(order);
            }

            request.setAttribute("adminOrders", orders);

            request.getRequestDispatcher(
                    "admin-orders.jsp"
            ).forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load orders."
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Object userIdObject = session.getAttribute("userId");

        if (userIdObject == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        String action = request.getParameter("action");

        if (!"updateStatus".equals(action)) {
            response.sendRedirect("admin-orders");
            return;
        }

        String orderIdParam =
                request.getParameter("orderId");

        String newStatus =
                request.getParameter("status");

        if (orderIdParam == null ||
            newStatus == null) {

            response.sendRedirect("admin-orders");
            return;
        }

        int orderId;

        try {

            orderId =
                    Integer.parseInt(orderIdParam);

        } catch (NumberFormatException e) {

            response.sendRedirect("admin-orders");
            return;
        }

        /*
         * Only these statuses are allowed.
         */
        if (!isValidStatus(newStatus)) {

            response.sendRedirect("admin-orders");
            return;
        }

        String sql =
                "UPDATE orders " +
                "SET status = ? " +
                "WHERE orderId = ?";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, newStatus);
            statement.setInt(2, orderId);

            statement.executeUpdate();

            response.sendRedirect(
                    "admin-orders?updated=true"
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to update order status."
            );
        }
    }

    private boolean isValidStatus(String status) {

        return "PLACED".equals(status)
                || "PREPARING".equals(status)
                || "OUT_FOR_DELIVERY".equals(status)
                || "DELIVERED".equals(status)
                || "CANCELLED".equals(status);
    }

    /*
     * Simple internal DTO.
     * This avoids depending on changes to your existing Order model.
     */
    public static class OrderData {

        public int orderId;
        public int userId;
        public int restaurantId;

        public java.sql.Timestamp orderDate;

        public java.math.BigDecimal totalAmount;

        public String status;
        public String paymentMode;

        public String username;
        public String phone;
        public String address;

        public String restaurantName;
        public String restaurantImage;
    }
}