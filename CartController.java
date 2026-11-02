
package com.tap.controllers;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.tap.daoImpl.MenuDaoImpl;
import com.tap.model.CartItem;
import com.tap.model.Menu;
import com.tap.util.CouponUtil;
import com.tap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cart")
public class CartController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String source = req.getParameter("source");

        HttpSession session = req.getSession();

        @SuppressWarnings("unchecked")
        List<CartItem> cart =
                (List<CartItem>) session.getAttribute("cart");

        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        populateRestaurantDetails(cart);

        // ADD TO CART
        if ("add".equals(action)) {

            String menuIdParameter = req.getParameter("menuId");
            String restaurantId = req.getParameter("restaurantId");

            if (menuIdParameter == null) {
                resp.sendRedirect("cart");
                return;
            }

            try {
                int menuId = Integer.parseInt(menuIdParameter);

                MenuDaoImpl menuDao = new MenuDaoImpl();
                Menu menu = menuDao.getMenu(menuId);

                if (menu != null && menu.isAvailable()) {

                    boolean exists = false;

                    for (CartItem item : cart) {
                        if (item.getMenuId() == menuId) {
                            item.setQuantity(item.getQuantity() + 1);
                            exists = true;
                            break;
                        }
                    }

                    if (!exists) {
                        CartItem cartItem = new CartItem(
                                menu.getMenuId(),
                                menu.getItemName(),
                                menu.getPrice(),
                                menu.getImagePath(),
                                1,
                                menu.getRestaurantId(),
                                null
                        );

                        cart.add(cartItem);
                    }
                }

                populateRestaurantDetails(cart);
                session.setAttribute("cart", cart);

                if ("menu".equals(source) && restaurantId != null) {
                    resp.sendRedirect(
                            "menu?restaurantId=" + restaurantId
                            + "&scrollTo=" + menuId
                    );
                } else {
                    resp.sendRedirect("cart");
                }

            } catch (NumberFormatException e) {
                resp.sendRedirect("cart");
            }

            return;
        }

        // INCREASE QUANTITY
        if ("increase".equals(action)) {

            String menuIdParameter = req.getParameter("menuId");

            if (menuIdParameter == null) {
                resp.sendRedirect("cart");
                return;
            }

            try {
                int menuId = Integer.parseInt(menuIdParameter);

                for (CartItem item : cart) {
                    if (item.getMenuId() == menuId) {
                        item.setQuantity(item.getQuantity() + 1);
                        break;
                    }
                }

                session.setAttribute("cart", cart);

                if ("menu".equals(source)) {
                    String restaurantId = req.getParameter("restaurantId");

                    if (restaurantId != null) {
                        resp.sendRedirect(
                                "menu?restaurantId=" + restaurantId
                                + "&scrollTo=" + menuId
                        );
                    } else {
                        resp.sendRedirect("cart");
                    }
                } else {
                    resp.sendRedirect("cart");
                }

            } catch (NumberFormatException e) {
                resp.sendRedirect("cart");
            }

            return;
        }

        // DECREASE QUANTITY
        if ("decrease".equals(action)) {

            String menuIdParameter = req.getParameter("menuId");

            if (menuIdParameter == null) {
                resp.sendRedirect("cart");
                return;
            }

            try {
                int menuId = Integer.parseInt(menuIdParameter);

                for (int i = 0; i < cart.size(); i++) {
                    CartItem item = cart.get(i);

                    if (item.getMenuId() == menuId) {
                        if (item.getQuantity() > 1) {
                            item.setQuantity(item.getQuantity() - 1);
                        } else {
                            cart.remove(i);
                        }
                        break;
                    }
                }

                session.setAttribute("cart", cart);

                if ("menu".equals(source)) {
                    String restaurantId = req.getParameter("restaurantId");

                    if (restaurantId != null) {
                        resp.sendRedirect(
                                "menu?restaurantId=" + restaurantId
                                + "&scrollTo=" + menuId
                        );
                    } else {
                        resp.sendRedirect("cart");
                    }
                } else {
                    resp.sendRedirect("cart");
                }

            } catch (NumberFormatException e) {
                resp.sendRedirect("cart");
            }

            return;
        }

        // REMOVE ONE ITEM
        if ("remove".equals(action)) {

            String menuIdParameter = req.getParameter("menuId");

            if (menuIdParameter == null) {
                resp.sendRedirect("cart");
                return;
            }

            try {
                int menuId = Integer.parseInt(menuIdParameter);

                cart.removeIf(item -> item.getMenuId() == menuId);

                session.setAttribute("cart", cart);

            } catch (NumberFormatException e) {
                // Invalid menu ID: leave cart unchanged.
            }

            resp.sendRedirect("cart");
            return;
        }

        // CLEAR ALL ITEMS
        if ("clear".equals(action)) {

            cart.clear();

            session.setAttribute("cart", cart);
            session.removeAttribute("couponCode");

            resp.sendRedirect("cart");
            return;
        }

        // APPLY COUPON
        if ("applyCoupon".equals(action)) {

            String couponCode = req.getParameter("couponCode");

            if (couponCode == null || couponCode.trim().isEmpty()) {
                session.setAttribute(
                        "couponMessage",
                        "Please enter a coupon code."
                );
                session.setAttribute("couponMessageType", "error");
                resp.sendRedirect("cart");
                return;
            }

            couponCode = couponCode.trim().toUpperCase();

            BigDecimal subtotal = BigDecimal.ZERO;

            for (CartItem item : cart) {
                BigDecimal itemTotal = item.getPrice().multiply(
                        BigDecimal.valueOf(item.getQuantity())
                );

                subtotal = subtotal.add(itemTotal);
            }

            String message =
                    CouponUtil.getCouponMessage(couponCode, subtotal);

            BigDecimal discount =
                    CouponUtil.calculateDiscount(couponCode, subtotal);

            if (discount.compareTo(BigDecimal.ZERO) > 0) {

                session.setAttribute("couponCode", couponCode);
                session.setAttribute("couponMessage", message);
                session.setAttribute("couponMessageType", "success");

            } else {

                session.removeAttribute("couponCode");
                session.setAttribute("couponMessage", message);
                session.setAttribute("couponMessageType", "error");
            }

            resp.sendRedirect("cart");
            return;
        }

        // REMOVE APPLIED COUPON
        if ("removeCoupon".equals(action)) {

            session.removeAttribute("couponCode");
            session.setAttribute("couponMessage", "Coupon removed.");
            session.setAttribute("couponMessageType", "success");

            resp.sendRedirect("cart");
            return;
        }

        // OPEN CART PAGE
        session.setAttribute("cart", cart);
        req.setAttribute("cart", cart);

        req.getRequestDispatcher("cart.jsp").forward(req, resp);
    }

    /**
     * Loads each cart item's restaurant ID and name from the database.
     * This information is used to group items and calculate separate bills.
     */
    private void populateRestaurantDetails(List<CartItem> cart) {

        if (cart == null || cart.isEmpty()) {
            return;
        }

        String sql =
                "SELECT m.restaurantId, r.name AS restaurantName "
                + "FROM menu m "
                + "JOIN restaurant r "
                + "ON r.restaurantId = m.restaurantId "
                + "WHERE m.menuId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            for (CartItem item : cart) {

                if (item == null) {
                    continue;
                }

                if (item.getRestaurantId() > 0
                        && item.getRestaurantName() != null
                        && !item.getRestaurantName().trim().isEmpty()) {
                    continue;
                }

                statement.setInt(1, item.getMenuId());

                try (ResultSet rs = statement.executeQuery()) {

                    if (rs.next()) {
                        item.setRestaurantId(
                                rs.getInt("restaurantId")
                        );

                        item.setRestaurantName(
                                rs.getString("restaurantName")
                        );
                    }
                }
            }

        } catch (Exception e) {
            log("Could not load restaurant details for cart items.", e);
        }
    }
}
