
package com.tap.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

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

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        int userId;
        int orderId;

        try {
            userId = Integer.parseInt(
                session.getAttribute("userId").toString()
            );

            orderId = Integer.parseInt(
                request.getParameter("orderId")
            );

            if (orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (Exception e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid order ID."
            );
            return;
        }

        String sql =
            "SELECT orderId, userId, orderDate, totalAmount, status, paymentMode " +
            "FROM orders WHERE orderId = ? AND userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    request.setAttribute("orderId",
                        rs.getInt("orderId"));

                    request.setAttribute("orderDate",
                        rs.getTimestamp("orderDate"));

                    request.setAttribute("totalAmount",
                        rs.getBigDecimal("totalAmount"));

                    request.setAttribute("orderStatus",
                        rs.getString("status"));

                    request.setAttribute("paymentMode",
                        rs.getString("paymentMode"));

                    request.getRequestDispatcher(
                        "/track-order.jsp"
                    ).forward(request, response);

                } else {
                    response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Order not found or you do not have permission to view it."
                    );
                }
            }

        } catch (Exception e) {
            throw new ServletException(
                "Error retrieving order tracking information.", e
            );
        }
    }
}
