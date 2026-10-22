package com.tap.controllers;

import java.io.IOException;
import java.util.List;

import com.tap.daoImpl.RestaurantDaoImpl;
import com.tap.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/restaurant")
public class RestaurantController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        RestaurantDaoImpl restaurantDao = new RestaurantDaoImpl();

        List<Restaurant> allRestaurants =
                restaurantDao.getAllRestaurants();

        req.setAttribute("restaurants", allRestaurants);

        req.getRequestDispatcher("restaurants.jsp")
           .forward(req, resp);
    }
}