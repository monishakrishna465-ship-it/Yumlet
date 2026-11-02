
package com.tap.controllers;

import java.io.IOException;
import java.util.List;

import com.tap.daoImpl.MenuDaoImpl;
import com.tap.daoImpl.RestaurantDaoImpl;
import com.tap.model.Menu;
import com.tap.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String restaurantIdParam = req.getParameter("restaurantId");

        if (restaurantIdParam == null || restaurantIdParam.trim().isEmpty()) {
            resp.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Restaurant ID is required."
            );
            return;
        }

        int restaurantId;

        try {
            restaurantId = Integer.parseInt(restaurantIdParam);
        } catch (NumberFormatException e) {
            resp.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid restaurant ID."
            );
            return;
        }

        MenuDaoImpl menuDao = new MenuDaoImpl();
        RestaurantDaoImpl restaurantDao = new RestaurantDaoImpl();

        List<Menu> menuList =
                menuDao.getMenusByRestaurant(restaurantId);

        /*
         * IMPORTANT:
         * Replace getRestaurantById(restaurantId) with the
         * actual single-restaurant lookup method in your DAO.
         */
        Restaurant restaurant = restaurantDao.getRestaurant(restaurantId);

        if (restaurant == null) {
            resp.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Restaurant not found."
            );
            return;
        }

        req.setAttribute("restaurant", restaurant);
        req.setAttribute("menuList", menuList);
        req.setAttribute("restaurantId", restaurantId);

        req.getRequestDispatcher("/menu.jsp").forward(req, resp);
    }
}
