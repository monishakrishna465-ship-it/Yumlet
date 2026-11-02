package com.tap.controllers;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.tap.daoImpl.DeliveryAddressDaoImpl;
import com.tap.model.CartItem;
import com.tap.model.DeliveryAddress;
import com.tap.util.CouponUtil;
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

    private static final BigDecimal DISCOUNT_THRESHOLD =
            new BigDecimal("499.00");

    private static final BigDecimal DISCOUNT =
            new BigDecimal("40.00");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(
                    String.valueOf(session.getAttribute("userId")));
        } catch (NumberFormatException e) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        Object cartObject = session.getAttribute("cart");

        if (!(cartObject instanceof List<?>)
                || ((List<?>) cartObject).isEmpty()) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) cartObject;

        populateRestaurantDetails(cart);
        session.setAttribute("cart", cart);
        loadSavedAddresses(request, userId);

        request.getRequestDispatcher("/checkout.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(
                    String.valueOf(session.getAttribute("userId")));
        } catch (NumberFormatException e) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        Object cartObject = session.getAttribute("cart");

        if (!(cartObject instanceof List<?>)
                || ((List<?>) cartObject).isEmpty()) {
            response.sendRedirect(contextPath + "/cart");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) cartObject;

        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));
        String landmark = trim(request.getParameter("landmark"));
        String city = trim(request.getParameter("city"));
        String pincode = trim(request.getParameter("pincode"));
        String paymentMode = trim(request.getParameter("paymentMode"));

        String savedAddressIdText =
                trim(request.getParameter("savedAddressId"));

        if (!savedAddressIdText.isEmpty()) {
            try {
                int savedAddressId = Integer.parseInt(savedAddressIdText);

                DeliveryAddressDaoImpl addressDao =
                        new DeliveryAddressDaoImpl();

                DeliveryAddress savedAddress =
                        addressDao.getAddressById(savedAddressId, userId);

                if (savedAddress == null) {
                    forwardWithError(request, response, userId,
                            "The selected address was not found.");
                    return;
                }

                fullName = trim(savedAddress.getFullName());
                phone = trim(savedAddress.getPhone());
                address = trim(savedAddress.getAddress());
                landmark = trim(savedAddress.getLandmark());
                city = trim(savedAddress.getCity());
                pincode = trim(savedAddress.getPincode());

            } catch (Exception e) {
                forwardWithError(request, response, userId,
                        "Could not load the selected address.");
                return;
            }
        }

        if (fullName.isEmpty() || phone.isEmpty()
                || address.isEmpty() || city.isEmpty()
                || pincode.isEmpty()) {
            forwardWithError(request, response, userId,
                    "Please fill all required checkout details.");
            return;
        }

        if (!phone.matches("\\d{10}")) {
            forwardWithError(request, response, userId,
                    "Please enter a valid 10-digit phone number.");
            return;
        }

        if (!pincode.matches("\\d{6}")) {
            forwardWithError(request, response, userId,
                    "Please enter a valid 6-digit pincode.");
            return;
        }

        boolean isCOD = "COD".equalsIgnoreCase(paymentMode);
        boolean isOnline = "DEMO_ONLINE".equalsIgnoreCase(paymentMode);

        String submittedMethod =
                trim(request.getParameter("demoPaymentMethod"));
        String submittedReference =
                trim(request.getParameter("demoPaymentReference"));

        if (!isCOD && !isOnline) {
            forwardWithError(request, response, userId,
                    "Please select a valid payment method.");
            return;
        }

        if (isOnline) {
            boolean validMethod =
                    "UPI".equalsIgnoreCase(submittedMethod)
                    || "CARD".equalsIgnoreCase(submittedMethod)
                    || "NETBANKING".equalsIgnoreCase(submittedMethod);

            Object confirmed = session.getAttribute("demoPaymentConfirmed");
            Object savedReference =
                    session.getAttribute("demoPaymentReference");
            Object savedMethod =
                    session.getAttribute("demoPaymentMethod");

            boolean validPayment =
                    Boolean.TRUE.equals(confirmed)
                    && savedReference instanceof String
                    && submittedReference.equals(savedReference)
                    && savedMethod instanceof String
                    && submittedMethod.equalsIgnoreCase(
                            (String) savedMethod)
                    && validMethod;

            if (!validPayment) {
                forwardWithError(request, response, userId,
                        "Please complete your payment before placing the order.");
                return;
            }
        }

        BigDecimal subtotal = BigDecimal.ZERO;

        for (CartItem item : cart) {
            if (item == null || item.getMenuId() <= 0
                    || item.getPrice() == null
                    || item.getQuantity() <= 0
                    || item.getPrice().compareTo(BigDecimal.ZERO) < 0) {
                forwardWithError(request, response, userId,
                        "Your cart contains an invalid item.");
                return;
            }

            subtotal = subtotal.add(
                    item.getPrice().multiply(
                            BigDecimal.valueOf(item.getQuantity())));
        }

        String couponCode =
                (String) session.getAttribute("couponCode");

        BigDecimal couponDiscount = BigDecimal.ZERO;
        String appliedCoupon = null;

        if (couponCode != null && !couponCode.trim().isEmpty()) {
            couponCode = couponCode.trim().toUpperCase();

            BigDecimal calculatedDiscount =
                    CouponUtil.calculateDiscount(couponCode, subtotal);

            if (calculatedDiscount != null
                    && calculatedDiscount.compareTo(BigDecimal.ZERO) > 0) {
                couponDiscount = calculatedDiscount;
                appliedCoupon = couponCode;
            } else {
                String message =
                        CouponUtil.getCouponMessage(couponCode, subtotal);
                session.removeAttribute("couponCode");
                forwardWithError(request, response, userId,
                        message + " Please return to your cart and select an eligible coupon.");
                return;
            }
        }

        BigDecimal automaticDiscount = BigDecimal.ZERO;

        if (subtotal.compareTo(DISCOUNT_THRESHOLD) >= 0) {
            automaticDiscount = DISCOUNT;
        }

        BigDecimal totalDiscount =
                automaticDiscount.add(couponDiscount);

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
        boolean committed = false;

        try {
            connection = DBConnection.getConnection();
            connection.setAutoCommit(false);

            Map<Integer, List<CartItem>> restaurantGroups =
                    new LinkedHashMap<>();

            Map<Integer, String> restaurantNames =
                    new LinkedHashMap<>();

            String restaurantSql =
                    "SELECT m.restaurantId, r.name AS restaurantName "
                    + "FROM menu m JOIN restaurant r "
                    + "ON r.restaurantId = m.restaurantId "
                    + "WHERE m.menuId = ?";

            try (PreparedStatement ps =
                         connection.prepareStatement(restaurantSql)) {

                for (CartItem item : cart) {
                    ps.setInt(1, item.getMenuId());

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException(
                                    "A selected menu item no longer exists.");
                        }

                        int restaurantId = rs.getInt("restaurantId");
                        String restaurantName =
                                rs.getString("restaurantName");

                        item.setRestaurantId(restaurantId);
                        item.setRestaurantName(restaurantName);

                        restaurantGroups.computeIfAbsent(
                                restaurantId,
                                key -> new ArrayList<>()).add(item);

                        restaurantNames.put(
                                restaurantId, restaurantName);
                    }
                }
            }

            if (restaurantGroups.isEmpty()) {
                throw new IllegalArgumentException("Your cart is empty.");
            }

            BigDecimal totalDeliveryFee =
                    DELIVERY_FEE.multiply(
                            BigDecimal.valueOf(restaurantGroups.size()));

            BigDecimal totalAmount = subtotal
                    .add(totalDeliveryFee)
                    .subtract(totalDiscount);

            if (totalAmount.compareTo(BigDecimal.ZERO) < 0) {
                totalAmount = BigDecimal.ZERO;
            }

            String updateUserSql =
                    "UPDATE user SET phone = ?, address = ? WHERE userId = ?";

            try (PreparedStatement ps =
                         connection.prepareStatement(updateUserSql)) {
                ps.setString(1, phone);
                ps.setString(2, finalAddress);
                ps.setInt(3, userId);

                if (ps.executeUpdate() == 0) {
                    throw new IllegalArgumentException(
                            "Your account could not be found. Please log in again.");
                }
            }

            String storedPaymentMode;

            if (isCOD) {
                storedPaymentMode = "COD";
            } else if ("UPI".equalsIgnoreCase(submittedMethod)) {
                storedPaymentMode = "UPI";
            } else if ("CARD".equalsIgnoreCase(submittedMethod)) {
                storedPaymentMode = "CARD";
            } else {
                storedPaymentMode = "NETBANKING";
            }

            List<Map<String, Object>> restaurantBills =
                    new ArrayList<>();

            List<Integer> createdOrderIds = new ArrayList<>();

            String orderSql =
                    "INSERT INTO orders "
                    + "(userId, restaurantId, orderDate, totalAmount, status, paymentMode) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";

            String orderItemSql =
                    "INSERT INTO orderItem "
                    + "(orderId, menuId, totalAmount, quantity) "
                    + "VALUES (?, ?, ?, ?)";

            BigDecimal discountRemaining = totalDiscount;
            int groupIndex = 0;
            int groupCount = restaurantGroups.size();

            for (Map.Entry<Integer, List<CartItem>> entry
                    : restaurantGroups.entrySet()) {

                int restaurantId = entry.getKey();
                List<CartItem> restaurantCart = entry.getValue();

                BigDecimal restaurantSubtotal = BigDecimal.ZERO;

                for (CartItem item : restaurantCart) {
                    restaurantSubtotal = restaurantSubtotal.add(
                            item.getPrice().multiply(
                                    BigDecimal.valueOf(item.getQuantity())));
                }

                groupIndex++;

                BigDecimal restaurantDiscount;

                if (groupIndex == groupCount) {
                    restaurantDiscount = discountRemaining;
                } else if (subtotal.compareTo(BigDecimal.ZERO) > 0) {
                    restaurantDiscount = totalDiscount
                            .multiply(restaurantSubtotal)
                            .divide(subtotal, 2,
                                    java.math.RoundingMode.HALF_UP);

                    if (restaurantDiscount.compareTo(discountRemaining) > 0) {
                        restaurantDiscount = discountRemaining;
                    }
                } else {
                    restaurantDiscount = BigDecimal.ZERO;
                }

                discountRemaining =
                        discountRemaining.subtract(restaurantDiscount);

                BigDecimal restaurantTotal = restaurantSubtotal
                        .add(DELIVERY_FEE)
                        .subtract(restaurantDiscount);

                if (restaurantTotal.compareTo(BigDecimal.ZERO) < 0) {
                    restaurantTotal = BigDecimal.ZERO;
                }

                int orderId;

                try (PreparedStatement ps = connection.prepareStatement(
                        orderSql, Statement.RETURN_GENERATED_KEYS)) {

                    ps.setInt(1, userId);
                    ps.setInt(2, restaurantId);
                    ps.setTimestamp(3,
                            new Timestamp(System.currentTimeMillis()));
                    ps.setBigDecimal(4, restaurantTotal);
                    ps.setString(5, "PLACED");
                    ps.setString(6, storedPaymentMode);
                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new IllegalStateException(
                                    "Order ID could not be generated.");
                        }

                        orderId = keys.getInt(1);
                    }
                }

                try (PreparedStatement ps =
                             connection.prepareStatement(orderItemSql)) {

                    for (CartItem item : restaurantCart) {
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

                createdOrderIds.add(orderId);

                Map<String, Object> bill = new LinkedHashMap<>();
                bill.put("orderId", orderId);
                bill.put("restaurantId", restaurantId);
                bill.put("restaurantName", restaurantNames.get(restaurantId));
                bill.put("subtotal", restaurantSubtotal);
                bill.put("deliveryFee", DELIVERY_FEE);
                bill.put("discount", restaurantDiscount);
                bill.put("total", restaurantTotal);

                restaurantBills.add(bill);
            }

            connection.commit();
            committed = true;

            session.setAttribute("lastOrderId", createdOrderIds.get(0));
            session.setAttribute("lastOrderIds", createdOrderIds);
            session.setAttribute("lastRestaurantBills", restaurantBills);
            session.setAttribute("lastOrderTotal", totalAmount);
            session.setAttribute("lastPaymentMode", storedPaymentMode);
            session.setAttribute("lastOrderAddress", finalAddress);
            session.setAttribute("lastOrderName", fullName);
            session.setAttribute("lastOrderDiscount", totalDiscount);

            if (appliedCoupon != null) {
                session.setAttribute("lastOrderCoupon", appliedCoupon);
            } else {
                session.removeAttribute("lastOrderCoupon");
            }

            session.setAttribute("username", fullName);
            session.setAttribute("phone", phone);
            session.setAttribute("address", finalAddress);

            session.removeAttribute("cart");
            session.removeAttribute("couponCode");
            session.removeAttribute("couponMessage");
            session.removeAttribute("couponMessageType");
            session.removeAttribute("demoPaymentConfirmed");
            session.removeAttribute("demoPaymentReference");
            session.removeAttribute("demoPaymentMethod");

            response.sendRedirect(contextPath + "/order-success.jsp");

        } catch (IllegalArgumentException e) {
            rollback(connection, committed);
            forwardWithError(request, response, userId, e.getMessage());

        } catch (Exception e) {
            rollback(connection, committed);
            log("Failed to place Eatero order.", e);

            forwardWithError(request, response, userId,
                    "Something went wrong while placing your order. Please try again.");

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

    private void populateRestaurantDetails(List<CartItem> cart) {
        String sql = "SELECT m.restaurantId, r.name AS restaurantName "
                + "FROM menu m JOIN restaurant r "
                + "ON r.restaurantId = m.restaurantId WHERE m.menuId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            for (CartItem item : cart) {
                ps.setInt(1, item.getMenuId());

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        item.setRestaurantId(rs.getInt("restaurantId"));
                        item.setRestaurantName(
                                rs.getString("restaurantName"));
                    }
                }
            }

        } catch (Exception e) {
            log("Could not load restaurant details for checkout.", e);
        }
    }

    private void rollback(Connection connection, boolean committed) {
        if (!committed && connection != null) {
            try {
                connection.rollback();
            } catch (Exception e) {
                log("Checkout rollback failed.", e);
            }
        }
    }

    private void loadSavedAddresses(HttpServletRequest request, int userId) {
        try {
            DeliveryAddressDaoImpl dao = new DeliveryAddressDaoImpl();

            request.setAttribute(
                    "savedAddresses",
                    dao.getAddressesByUserId(userId));

        } catch (Exception e) {
            log("Could not load saved delivery addresses.", e);
            request.setAttribute("savedAddresses", Collections.emptyList());
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private void forwardWithError(HttpServletRequest request,
                                  HttpServletResponse response,
                                  int userId,
                                  String message)
            throws ServletException, IOException {

        request.setAttribute("error", message);
        loadSavedAddresses(request, userId);

        request.getRequestDispatcher("/checkout.jsp")
                .forward(request, response);
    }
}