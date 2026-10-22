
package com.tap.controllers;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

import com.tap.model.CartItem;
import com.tap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final BigDecimal DELIVERY_FEE =
            new BigDecimal("40.00");

    private static final BigDecimal PLATFORM_FEE =
            new BigDecimal("10.00");

    private static final BigDecimal DISCOUNT_THRESHOLD =
            new BigDecimal("500.00");

    private static final BigDecimal DISCOUNT =
            new BigDecimal("50.00");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/checkout.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        HttpSession session = request.getSession(false);

        // Verify login.
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    contextPath + "/login.jsp?message="
                    + "Please%20login%20before%20placing%20your%20order");
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(
                    session.getAttribute("userId").toString());
        } catch (NumberFormatException e) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // Verify cart.
        @SuppressWarnings("unchecked")
        List<CartItem> cart =
                (List<CartItem>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        // Read submitted checkout details.
        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));
        String landmark = trim(request.getParameter("landmark"));
        String city = trim(request.getParameter("city"));
        String pincode = trim(request.getParameter("pincode"));
        String paymentMode = trim(request.getParameter("paymentMode"));

        if (fullName.isEmpty()
                || phone.isEmpty()
                || address.isEmpty()
                || city.isEmpty()
                || pincode.isEmpty()
                || paymentMode.isEmpty()) {

            forwardWithError(request, response,
                    "Please fill all required checkout details.");
            return;
        }

        if (!phone.matches("\\d{10}")) {
            forwardWithError(request, response,
                    "Please enter a valid 10-digit phone number.");
            return;
        }

        if (!pincode.matches("\\d{6}")) {
            forwardWithError(request, response,
                    "Please enter a valid 6-digit pincode.");
            return;
        }

        // Only COD is enabled on the checkout page.
        if (!"COD".equals(paymentMode)) {
            forwardWithError(request, response,
                    "Please select Cash on Delivery.");
            return;
        }

        // Calculate the subtotal using cart items.
        BigDecimal subtotal = BigDecimal.ZERO;

        for (CartItem item : cart) {
            if (item == null
                    || item.getMenuId() <= 0
                    || item.getPrice() == null
                    || item.getQuantity() <= 0
                    || item.getPrice().compareTo(BigDecimal.ZERO) < 0) {

                forwardWithError(request, response,
                        "Your cart contains an invalid item. "
                        + "Please review your cart.");
                return;
            }

            subtotal = subtotal.add(
                    item.getPrice().multiply(
                            BigDecimal.valueOf(item.getQuantity())));
        }

        BigDecimal discount =
                subtotal.compareTo(DISCOUNT_THRESHOLD) >= 0
                        ? DISCOUNT
                        : BigDecimal.ZERO;

        BigDecimal totalAmount = subtotal
                .add(DELIVERY_FEE)
                .add(PLATFORM_FEE)
                .subtract(discount);

        if (totalAmount.compareTo(BigDecimal.ZERO) < 0) {
            totalAmount = BigDecimal.ZERO;
        }

        // Build the final delivery address.
        StringBuilder addressBuilder = new StringBuilder(address);

        if (!landmark.isEmpty()) {
            addressBuilder.append(", Near ").append(landmark);
        }

        addressBuilder.append(", ")
                .append(city)
                .append(" - ")
                .append(pincode);

        String finalAddress = addressBuilder.toString();

        Connection connection = null;
        boolean transactionCommitted = false;

        try {
            connection = DBConnection.getConnection();
            connection.setAutoCommit(false);

            // Find the restaurant belonging to the first menu item.
            int restaurantId;

            String restaurantSql =
                    "SELECT restaurantId FROM menu WHERE menuId = ?";

            try (PreparedStatement ps =
                         connection.prepareStatement(restaurantSql)) {

                ps.setInt(1, cart.get(0).getMenuId());

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException(
                                "A selected menu item no longer exists.");
                    }

                    restaurantId = rs.getInt("restaurantId");
                }
            }

            // Verify that all items belong to the same restaurant.
            try (PreparedStatement ps =
                         connection.prepareStatement(restaurantSql)) {

                for (CartItem item : cart) {
                    ps.setInt(1, item.getMenuId());

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException(
                                    "A selected menu item no longer exists.");
                        }

                        if (rs.getInt("restaurantId") != restaurantId) {
                            throw new IllegalArgumentException(
                                    "Please order items from one restaurant "
                                    + "at a time.");
                        }
                    }
                }
            }

            // Update the customer's saved phone and address.
            String updateUserSql =
                    "UPDATE user SET phone = ?, address = ? WHERE userId = ?";

            try (PreparedStatement ps =
                         connection.prepareStatement(updateUserSql)) {

                ps.setString(1, phone);
                ps.setString(2, finalAddress);
                ps.setInt(3, userId);

                if (ps.executeUpdate() == 0) {
                    throw new IllegalArgumentException(
                            "Your account could not be found. "
                            + "Please log in again.");
                }
            }

            // Insert the order and retrieve its generated ID.
            int orderId;

            String orderSql =
                    "INSERT INTO orders "
                    + "(userId, restaurantId, totalAmount, status, paymentMode) "
                    + "VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement ps = connection.prepareStatement(
                    orderSql, Statement.RETURN_GENERATED_KEYS)) {

                ps.setInt(1, userId);
                ps.setInt(2, restaurantId);
                ps.setBigDecimal(3, totalAmount);
                ps.setString(4, "PLACED");
                ps.setString(5, paymentMode);

                if (ps.executeUpdate() == 0) {
                    throw new IllegalStateException(
                            "Unable to create your order.");
                }

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new IllegalStateException(
                                "Order ID could not be generated.");
                    }

                    orderId = keys.getInt(1);
                }
            }

            // Insert each order item once.
            String orderItemSql =
                    "INSERT INTO orderItem "
                    + "(orderId, menuId, totalAmount, quantity) "
                    + "VALUES (?, ?, ?, ?)";

            try (PreparedStatement ps =
                         connection.prepareStatement(orderItemSql)) {

                for (CartItem item : cart) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, item.getMenuId());
                    ps.setBigDecimal(3,
                            item.getPrice().multiply(
                                    BigDecimal.valueOf(item.getQuantity())));
                    ps.setInt(4, item.getQuantity());
                    ps.addBatch();
                }

                ps.executeBatch();
            }

            // Commit the database transaction first.
            connection.commit();
            transactionCommitted = true;

            // Set the attributes expected by order-success.jsp.
            session.setAttribute("lastOrderId", orderId);
            session.setAttribute("lastOrderTotal", totalAmount);
            session.setAttribute("lastPaymentMode", paymentMode);
            session.setAttribute("lastOrderAddress", finalAddress);
            session.setAttribute("lastOrderName", fullName);

            // Update session details.
            session.setAttribute("username", fullName);
            session.setAttribute("phone", phone);
            session.setAttribute("address", finalAddress);

            // Clear cart after successful database commit.
            session.removeAttribute("cart");

            // Redirect to the order confirmation page.
            response.sendRedirect(
                    contextPath + "/order-success.jsp");
            return;

        } catch (IllegalArgumentException e) {

            if (!transactionCommitted && connection != null) {
                try {
                    connection.rollback();
                } catch (Exception rollbackException) {
                    log("Checkout rollback failed.", rollbackException);
                }
            }

            forwardWithError(request, response, e.getMessage());

        } catch (Exception e) {

            if (!transactionCommitted && connection != null) {
                try {
                    connection.rollback();
                } catch (Exception rollbackException) {
                    log("Checkout rollback failed.", rollbackException);
                }
            }

            log("Failed to place Eatero order.", e);

            forwardWithError(request, response,
                    "Something went wrong while placing your order. "
                    + "Please check the server console and try again.");

        } finally {

            if (connection != null) {
                try {
                    connection.setAutoCommit(true);
                    connection.close();
                } catch (Exception e) {
                    log("Could not close checkout database connection.", e);
                }
            }
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private void forwardWithError(HttpServletRequest request,
                                  HttpServletResponse response,
                                  String message)
            throws ServletException, IOException {

        request.setAttribute("error", message);

        request.getRequestDispatcher("/checkout.jsp")
                .forward(request, response);
    }
}
