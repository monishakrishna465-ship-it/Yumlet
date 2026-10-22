package com.tap.controllers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.tap.daoImpl.MenuDaoImpl;
import com.tap.model.CartItem;
import com.tap.model.Menu;

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


        String action =
            req.getParameter("action");


        String source =
            req.getParameter("source");


        HttpSession session =
            req.getSession();


        /*
         * Get existing cart
         */

        @SuppressWarnings("unchecked")
        List<CartItem> cart =
            (List<CartItem>) session.getAttribute("cart");


        /*
         * If cart doesn't exist,
         * create a new one.
         */

        if (cart == null) {

            cart = new ArrayList<>();
        }



        /* =====================================================
           ADD TO CART
        ===================================================== */

        if ("add".equals(action)) {


            String menuIdParameter =
                req.getParameter("menuId");


            String restaurantId =
                req.getParameter("restaurantId");


            if (menuIdParameter == null) {

                resp.sendRedirect("cart");

                return;
            }


            int menuId =
                Integer.parseInt(
                    menuIdParameter
                );


            /*
             * Get menu item from database
             */

            MenuDaoImpl menuDao =
                new MenuDaoImpl();


            Menu menu =
                menuDao.getMenu(menuId);


            if (menu != null &&
                menu.isAvailable()) {


                boolean exists = false;


                /*
                 * Check whether item
                 * already exists.
                 */

                for (CartItem item : cart) {

                    if (item.getMenuId() ==
                        menuId) {


                        /*
                         * Already exists:
                         * increase quantity.
                         */

                        item.setQuantity(
                            item.getQuantity() + 1
                        );


                        exists = true;

                        break;
                    }
                }


                /*
                 * Item doesn't exist:
                 * add it with quantity 1.
                 */

                if (!exists) {

                    CartItem cartItem =
                        new CartItem(
                            menu.getMenuId(),
                            menu.getItemName(),
                            menu.getPrice(),
                            menu.getImagePath(),
                            1
                        );


                    cart.add(cartItem);
                }
            }


            /*
             * Save updated cart
             */

            session.setAttribute(
                "cart",
                cart
            );


            /*
             * If Add to Cart came
             * from menu page,
             * return to menu.
             */

            if ("menu".equals(source) &&
                restaurantId != null) {


                resp.sendRedirect(
                    "menu?restaurantId="
                    + restaurantId
                    + "&scrollTo="
                    + menuId
                );


            } else {


                /*
                 * Otherwise go to cart.
                 */

                resp.sendRedirect("cart");
            }


            return;
        }



        /* =====================================================
           INCREASE QUANTITY
        ===================================================== */

        if ("increase".equals(action)) {


            String menuIdParameter =
                req.getParameter("menuId");


            if (menuIdParameter == null) {

                resp.sendRedirect("cart");

                return;
            }


            int menuId =
                Integer.parseInt(
                    menuIdParameter
                );


            /*
             * Increase quantity
             */

            for (CartItem item : cart) {

                if (item.getMenuId() ==
                    menuId) {


                    item.setQuantity(
                        item.getQuantity() + 1
                    );


                    break;
                }
            }


            /*
             * Save cart
             */

            session.setAttribute(
                "cart",
                cart
            );


            /*
             * If request came from MENU
             */

            if ("menu".equals(source)) {


                String restaurantId =
                    req.getParameter(
                        "restaurantId"
                    );


                if (restaurantId != null) {


                    resp.sendRedirect(
                        "menu?restaurantId="
                        + restaurantId
                        + "&scrollTo="
                        + menuId
                    );


                } else {

                    resp.sendRedirect(
                        "cart"
                    );
                }


            } else {


                /*
                 * Request came from CART
                 */

                resp.sendRedirect(
                    "cart"
                );
            }


            return;
        }



        /* =====================================================
           DECREASE QUANTITY
        ===================================================== */

        if ("decrease".equals(action)) {


            String menuIdParameter =
                req.getParameter("menuId");


            if (menuIdParameter == null) {

                resp.sendRedirect("cart");

                return;
            }


            int menuId =
                Integer.parseInt(
                    menuIdParameter
                );


            /*
             * Find item
             */

            for (int i = 0;
                 i < cart.size();
                 i++) {


                CartItem item =
                    cart.get(i);


                if (item.getMenuId() ==
                    menuId) {


                    /*
                     * If quantity is more
                     * than 1, decrease it.
                     */

                    if (item.getQuantity() > 1) {


                        item.setQuantity(
                            item.getQuantity() - 1
                        );


                    } else {


                        /*
                         * Quantity is 1:
                         * remove item completely.
                         */

                        cart.remove(i);
                    }


                    break;
                }
            }


            /*
             * Save cart
             */

            session.setAttribute(
                "cart",
                cart
            );


            /*
             * If request came from MENU
             */

            if ("menu".equals(source)) {


                String restaurantId =
                    req.getParameter(
                        "restaurantId"
                    );


                if (restaurantId != null) {


                    resp.sendRedirect(
                        "menu?restaurantId="
                        + restaurantId
                        + "&scrollTo="
                        + menuId
                    );


                } else {

                    resp.sendRedirect(
                        "cart"
                    );
                }


            } else {


                /*
                 * Request came from CART
                 */

                resp.sendRedirect(
                    "cart"
                );
            }


            return;
        }



        /* =====================================================
           REMOVE ONE ITEM
        ===================================================== */

        if ("remove".equals(action)) {


            String menuIdParameter =
                req.getParameter("menuId");


            if (menuIdParameter == null) {

                resp.sendRedirect("cart");

                return;
            }


            int menuId =
                Integer.parseInt(
                    menuIdParameter
                );


            /*
             * Remove item completely
             */

            cart.removeIf(
                item ->
                    item.getMenuId() == menuId
            );


            /*
             * Save cart
             */

            session.setAttribute(
                "cart",
                cart
            );


            /*
             * Remove is normally
             * performed from cart.
             */

            resp.sendRedirect(
                "cart"
            );


            return;
        }



        /* =====================================================
           CLEAR ALL
        ===================================================== */

        if ("clear".equals(action)) {


            /*
             * Empty the entire cart
             */

            cart.clear();


            /*
             * Save empty cart
             */

            session.setAttribute(
                "cart",
                cart
            );


            /*
             * Return to cart page
             */

            resp.sendRedirect(
                "cart"
            );


            return;
        }



        /* =====================================================
           OPEN CART PAGE
        ===================================================== */

        session.setAttribute(
            "cart",
            cart
        );


        req.setAttribute(
            "cart",
            cart
        );


        req.getRequestDispatcher(
            "cart.jsp"
        ).forward(
            req,
            resp
        );
    }
}