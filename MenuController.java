package com.tap.controllers;

import java.io.IOException;
import java.util.List;

import com.tap.daoImpl.MenuDaoImpl;
import com.tap.model.Menu;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Get restaurant ID from URL
        int restaurantId =
                Integer.parseInt(req.getParameter("restaurantId"));

        // Create DAO
        MenuDaoImpl menuDao = new MenuDaoImpl();

        // Get menu items for this restaurant
        List<Menu> menuList =
                menuDao.getMenusByRestaurant(restaurantId);

        // Send data to JSP
        req.setAttribute("menuList", menuList);

        // Send restaurant ID also
        req.setAttribute("restaurantId", restaurantId);

        // Open menu JSP
        req.getRequestDispatcher("menu.jsp")
           .forward(req, resp);
    }
}