
package com.tap.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/track-order")
public class OrderTrackingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // Check whether the user is logged in
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        int userId;
        int orderId;

        // Validate the user ID and order ID
        try {
            userId = Integer.parseInt(
                session.getAttribute("userId").toString()
            );

            String orderIdParam = request.getParameter("orderId");

            if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
                throw new NumberFormatException();
            }

            orderId = Integer.parseInt(orderIdParam);

            if (userId <= 0 || orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid user ID or order ID."
            );
            return;
        }

        String sql =
            "SELECT orderId, userId, restaurantId, orderDate, " +
            "totalAmount, status, paymentMode " +
            "FROM orders WHERE orderId = ? AND userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    request.setAttribute(
                        "orderId", rs.getInt("orderId")
                    );

                    request.setAttribute(
                        "restaurantId", rs.getInt("restaurantId")
                    );

                    request.setAttribute(
                        "orderDate", rs.getTimestamp("orderDate")
                    );

                    request.setAttribute(
                        "totalAmount", rs.getBigDecimal("totalAmount")
                    );

                    request.setAttribute(
                        "orderStatus", rs.getString("status")
                    );

                    request.setAttribute(
                        "paymentMode", rs.getString("paymentMode")
                    );

                    // Display the tracking JSP
                    request.getRequestDispatcher(
                        "/track-order.jsp"
                    ).forward(request, response);

                } else {
                    response.sendRedirect(
                        request.getContextPath() + "/orders"
                    );
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to retrieve order tracking details.", e
            );
        }
    }
}
