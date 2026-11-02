
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.Restaurant" %>

<%!
    private String esc(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String resolveImage(String path, String contextPath) {
        String fallback =
            "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"
            + "?auto=format&fit=crop&w=900&q=80";

        if (path == null || path.trim().isEmpty()) {
            return fallback;
        }

        path = path.trim().replace("\\", "/");

        if (path.length() >= 2 &&
            ((path.startsWith("\"") && path.endsWith("\"")) ||
             (path.startsWith("'") && path.endsWith("'")))) {
            path = path.substring(1, path.length() - 1).trim();
        }

        if (path.matches("(?i)^https?://.+")) {
            return path;
        }

        if (path.startsWith("//")) {
            return "https:" + path;
        }

        if (path.startsWith("www.")) {
            return "https://" + path;
        }

        while (path.startsWith("/")) {
            path = path.substring(1);
        }

        return contextPath + "/" + path;
    }
%>

<%
    String contextPath = request.getContextPath();

    int restaurantId = 0;
    String restaurantIdParam = request.getParameter("restaurantId");

    if (restaurantIdParam == null) {
        Object idAttribute = request.getAttribute("restaurantId");

        if (idAttribute != null) {
            restaurantIdParam = String.valueOf(idAttribute);
        }
    }

    try {
        if (restaurantIdParam != null) {
            restaurantId = Integer.parseInt(restaurantIdParam);
        }
    } catch (NumberFormatException e) {
        restaurantId = 0;
    }

    List<Menu> menuList =
        (List<Menu>) request.getAttribute("menuList");

    if (menuList == null) {
        menuList = new ArrayList<Menu>();
    }

    Restaurant restaurant =
        (Restaurant) request.getAttribute("restaurant");

    String restaurantImageUrl =
        restaurant != null
            ? resolveImage(restaurant.getImagePath(), contextPath)
            : contextPath + "/images/food-placeholder.jpg";

    String restaurantName =
        restaurant != null && restaurant.getName() != null
            ? restaurant.getName()
            : "Discover Our Menu";

    String cuisineType =
        restaurant != null && restaurant.getCuisineType() != null
            ? restaurant.getCuisineType()
            : "";

    String restaurantAddress =
        restaurant != null && restaurant.getAddress() != null
            ? restaurant.getAddress()
            : "";

    List<CartItem> cart = new ArrayList<CartItem>();

    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        cart = (List<CartItem>) cartObject;
    }

    int cartCount = 0;
    BigDecimal cartTotal = BigDecimal.ZERO;

    for (CartItem item : cart) {
        if (item != null) {
            cartCount += item.getQuantity();

            if (item.getPrice() != null) {
                cartTotal = cartTotal.add(
                    item.getPrice().multiply(
                        BigDecimal.valueOf(item.getQuantity())
                    )
                );
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <meta name="description"
          content="Explore delicious dishes and order your favourites on Yumlet.">

    <title>Yumlet | <%= esc(restaurantName) %></title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/navbar.css">

    <link rel="stylesheet"
          href="<%= contextPath %>/css/footer.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect"
          href="https://fonts.gstatic.com"
          crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&display=swap"
          rel="stylesheet">

    <style>
        :root {
            --chocolate: #3b1d0e;
            --chocolate-dark: #30170d;
            --brown: #48230f;
            --beige: #f5e7cf;
            --beige-light: #fff0d9;
            --beige-border: #e7d1b2;
            --muted: #80634d;
            --accent: #8c4b2d;
            --green: #347447;
            --shadow-sm: 0 6px 20px rgba(0,0,0,.12);
            --shadow: 0 14px 30px rgba(0,0,0,.22);
        }

        * {
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
            scroll-padding-top: 100px;
        }

        body {
            margin: 0;
            font-family: "DM Sans", Arial, sans-serif;
            background: var(--chocolate);
            color: var(--brown);
            overflow-x: hidden;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        button {
            font: inherit;
        }

        img {
            display: block;
            max-width: 100%;
        }

        .container {
            width: min(1180px, 92%);
            margin: auto;
        }

        .menu-hero {
            position: relative;
            display: flex;
            align-items: center;
            min-height: 310px;
            overflow: hidden;
            background-color: var(--chocolate-dark);
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        .menu-hero-content {
            width: min(1180px, 92%);
            margin: auto;
            padding: 55px 0;
        }

        .eyebrow {
            margin-bottom: 12px;
            color: #e3b98d;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 2px;
        }

        .hero-title {
            max-width: 750px;
            margin: 0;
            color: #fff0d9;
            font-family: "Playfair Display", Georgia, serif;
            font-size: clamp(38px, 5.5vw, 62px);
            line-height: 1.12;
        }

        .hero-text {
            max-width: 610px;
            margin-top: 16px;
            color: rgba(255,255,255,.88);
            font-size: 14px;
            line-height: 1.8;
        }

        .restaurant-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 9px 18px;
            margin-top: 14px;
            color: #ffe4c6;
            font-size: 12px;
        }

        .menu-section {
            min-height: 60vh;
            padding: 48px 0 100px;
            background: var(--chocolate);
        }

        .section-heading {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 22px;
            margin-bottom: 28px;
        }

        .section-heading-left .eyebrow {
            color: #e3b98d;
        }

        .section-title {
            margin: 0;
            color: var(--beige-light);
            font-family: "Playfair Display", Georgia, serif;
            font-size: clamp(29px, 4vw, 42px);
            line-height: 1.2;
        }

        .section-description {
            max-width: 580px;
            margin-top: 10px;
            color: #e2cbb4;
            font-size: 13px;
            line-height: 1.7;
        }

        .cart-summary-mini {
            flex-shrink: 0;
            padding: 13px 17px;
            border: 1px solid #d8b995;
            border-radius: 13px;
            background: var(--beige);
            box-shadow: var(--shadow-sm);
        }

        .cart-summary-mini small {
            display: block;
            color: var(--muted);
            font-size: 11px;
            font-weight: 700;
        }

        .cart-summary-mini strong {
            display: block;
            margin-top: 4px;
            color: var(--brown);
            font-size: 16px;
        }

        .cart-link {
            display: inline-block;
            margin-top: 7px;
            color: var(--accent);
            font-size: 12px;
            font-weight: 800;
        }

        .cart-link:hover {
            text-decoration: underline;
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            align-items: stretch;
            gap: 23px;
        }

        .menu-card {
            display: flex;
            flex-direction: column;
            min-width: 0;
            overflow: hidden;
            border: 1px solid var(--beige-border);
            border-radius: 18px;
            background: var(--beige);
            box-shadow: var(--shadow-sm);
            opacity: 0;
            transform: translateY(30px);
            transition:
                opacity .45s ease,
                transform .45s ease,
                box-shadow .25s ease;
        }

        .menu-card.show-card {
            opacity: 1;
            transform: translateY(0);
        }

        .menu-card.show-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow);
        }

        .menu-image {
            position: relative;
            height: 195px;
            flex-shrink: 0;
            overflow: hidden;
            background: #ead5b8;
        }

        .menu-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform .35s ease;
        }

        .menu-card:hover .menu-image img {
            transform: scale(1.04);
        }

        .food-tag {
            position: absolute;
            top: 12px;
            left: 12px;
            max-width: calc(100% - 75px);
            padding: 7px 10px;
            border-radius: 20px;
            background: rgba(255,248,236,.96);
            color: var(--brown);
            font-size: 9px;
            font-weight: 800;
            letter-spacing: .5px;
        }

        .available-dot {
            position: absolute;
            right: 10px;
            bottom: 10px;
            padding: 7px 10px;
            border-radius: 20px;
            background: #fff8ec;
            color: var(--green);
            font-size: 10px;
            font-weight: 800;
        }

        .food-favourite {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 2;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 39px;
            height: 39px;
            border: 0;
            border-radius: 50%;
            background: rgba(255,248,236,.97);
            color: var(--brown);
            box-shadow: 0 3px 10px rgba(0,0,0,.16);
            cursor: pointer;
            transition: transform .2s ease, color .2s ease;
        }

        .food-favourite:hover {
            transform: scale(1.1);
        }

        .food-favourite:disabled {
            opacity: .65;
            cursor: wait;
        }

        .food-favourite svg {
            width: 21px;
            height: 21px;
            fill: none;
            stroke: currentColor;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .food-favourite.active {
            color: #e53945;
        }

        .food-favourite.active svg {
            fill: #e53945;
            stroke: #e53945;
        }

        .food-favourite:focus-visible {
            outline: 3px solid #c58b5b;
            outline-offset: 3px;
        }

        .menu-body {
            display: flex;
            flex-direction: column;
            flex: 1;
            padding: 17px;
        }

        .menu-top {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 10px;
        }

        .menu-name {
            margin: 0;
            color: var(--brown);
            font-family: "Playfair Display", Georgia, serif;
            font-size: 19px;
            font-weight: 700;
            line-height: 1.35;
            overflow-wrap: anywhere;
        }

        .menu-price {
            flex-shrink: 0;
            color: var(--accent);
            font-size: 16px;
            font-weight: 800;
        }

        .menu-description {
            margin: 10px 0 15px;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.65;
            overflow-wrap: anywhere;
        }

        .menu-actions {
            display: flex;
            align-items: center;
            min-height: 41px;
            margin-top: auto;
        }

        .add-button {
            width: 100%;
            min-height: 41px;
            padding: 10px 13px;
            border: 0;
            border-radius: 9px;
            background: var(--brown);
            color: #fff5e6;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            transition: background .2s ease, transform .2s ease;
        }

        .add-button:hover:not(:disabled) {
            background: #704126;
            transform: translateY(-1px);
        }

        .add-button:disabled {
            background: #e3d7c7;
            color: #806e60;
            cursor: not-allowed;
        }

        .quantity-control {
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;
            min-height: 41px;
            overflow: hidden;
            border: 1px solid #d2b99a;
            border-radius: 9px;
            background: #efddc1;
        }

        .quantity-control button {
            width: 43px;
            height: 41px;
            border: 0;
            background: transparent;
            color: var(--brown);
            font-size: 22px;
            font-weight: 800;
            cursor: pointer;
        }

        .quantity-control button:hover {
            background: #e5ceb0;
        }

        .quantity-value {
            color: var(--brown);
            font-size: 14px;
            font-weight: 800;
        }

        .empty-menu {
            grid-column: 1 / -1;
            padding: 48px 20px;
            border: 1px dashed #c5a17c;
            border-radius: 18px;
            background: var(--beige);
            color: var(--brown);
            text-align: center;
        }

        .empty-menu-icon {
            margin-bottom: 12px;
            font-size: 38px;
        }

        .empty-menu h3 {
            margin: 0 0 10px;
            font-family: "Playfair Display", Georgia, serif;
            font-size: 23px;
        }

        .empty-menu p {
            max-width: 480px;
            margin: auto;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.7;
        }

        .floating-cart {
            position: fixed;
            right: 22px;
            bottom: 22px;
            z-index: 900;
            display: flex;
            align-items: center;
            gap: 11px;
            min-width: 180px;
            padding: 12px 15px;
            border: 1px solid rgba(255,255,255,.15);
            border-radius: 14px;
            background: var(--brown);
            color: white;
            box-shadow: 0 12px 30px rgba(0,0,0,.25);
        }

        .cart-icon {
            font-size: 23px;
        }

        .floating-cart-text {
            display: flex;
            flex: 1;
            flex-direction: column;
            gap: 3px;
        }

        .floating-cart-text strong {
            font-size: 13px;
        }

        .floating-cart-text span {
            color: #e9c6a4;
            font-size: 12px;
        }

        .cart-count-badge {
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 25px;
            height: 25px;
            padding: 0 6px;
            border-radius: 20px;
            background: #8c4b2d;
            color: white;
            font-size: 12px;
            font-weight: 800;
        }

        .toast {
            position: fixed;
            left: 50%;
            bottom: 95px;
            z-index: 1200;
            padding: 12px 18px;
            border-radius: 10px;
            background: var(--beige);
            color: var(--brown);
            font-size: 13px;
            box-shadow: var(--shadow);
            opacity: 0;
            pointer-events: none;
            transform: translate(-50%, 12px);
            transition: opacity .25s, transform .25s;
        }

        .toast.show {
            opacity: 1;
            transform: translate(-50%, 0);
        }

        @media (max-width: 1000px) {
            .menu-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 760px) {
            .menu-hero {
                min-height: 280px;
            }

            .menu-hero-content {
                padding: 42px 0;
            }

            .hero-title {
                font-size: clamp(35px, 8vw, 48px);
            }

            .section-heading {
                align-items: flex-start;
                flex-direction: column;
            }

            .cart-summary-mini {
                width: 100%;
            }

            .menu-section {
                padding: 38px 0 95px;
            }
        }

        @media (max-width: 600px) {
            .menu-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .menu-image {
                height: 220px;
            }

            .menu-body {
                padding: 17px;
            }

            .menu-name {
                font-size: 20px;
            }
        }

        @media (max-width: 430px) {
            .floating-cart {
                right: 12px;
                bottom: 12px;
                min-width: 165px;
                padding: 10px 12px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            html {
                scroll-behavior: auto;
            }

            .menu-card,
            .menu-card.show-card,
            .menu-card.show-card:hover {
                opacity: 1;
                transform: none;
                transition: none;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/navbar.jsp" />

<section class="menu-hero"
         style="background-image: url('<%= esc(restaurantImageUrl) %>');">

    <div class="menu-hero-content">
        <div class="eyebrow">WELCOME TO YUMLET</div>

        <h1 class="hero-title"><%= esc(restaurantName) %></h1>

        <p class="hero-text">
            Explore the menu, choose your favourites, and build your perfect meal.
        </p>

        <% if (!cuisineType.isEmpty() || !restaurantAddress.isEmpty()) { %>
            <div class="restaurant-meta">
                <% if (!cuisineType.isEmpty()) { %>
                    <span><%= esc(cuisineType) %></span>
                <% } %>

                <% if (!restaurantAddress.isEmpty()) { %>
                    <span><%= esc(restaurantAddress) %></span>
                <% } %>
            </div>
        <% } %>
    </div>
</section>

<main class="menu-section">
    <div class="container">

        <div class="section-heading">
            <div class="section-heading-left">
                <div class="eyebrow">TODAY'S MENU</div>

                <h2 class="section-title">Pick your favourites</h2>

                <p class="section-description">
                    Add anything you love. Adjust quantities right here
                    and enjoy your favourite dishes.
                </p>
            </div>

            <div class="cart-summary-mini">
                <small>YOUR CART</small>

                <strong>
                    <%= cartCount %>
                    item<%= cartCount == 1 ? "" : "s" %>
                    &nbsp;·&nbsp; ₹<%= cartTotal.setScale(2, RoundingMode.HALF_UP).toPlainString() %>
                </strong>

                <a class="cart-link" href="<%= contextPath %>/cart">
                    View Cart &rarr;
                </a>
            </div>
        </div>

        <div class="menu-grid">

            <% if (menuList.isEmpty()) { %>

                <div class="empty-menu">
                    <div class="empty-menu-icon">🍽️</div>
                    <h3>No menu items available</h3>
                    <p>
                        This restaurant hasn't added any dishes yet.
                        Please check back again soon.
                    </p>
                </div>

            <% } else { %>

                <% for (Menu menu : menuList) {
                    if (menu == null) continue;

                    int menuId = menu.getMenuId();

                    String itemName = menu.getItemName();
                    String description = menu.getDescription();

                    BigDecimal price = menu.getPrice();

                    String imagePath = menu.getImagePath();
                    String imageUrl = resolveImage(imagePath, contextPath);

                    boolean available = menu.isAvailable();

                    int quantity = 0;

                    for (CartItem cartItem : cart) {
                        if (cartItem != null &&
                            cartItem.getMenuId() == menuId) {
                            quantity = cartItem.getQuantity();
                            break;
                        }
                    }
                %>

                    <article class="menu-card" id="menu-<%= menuId %>">

                        <div class="menu-image">

                            <img
                                src="<%= esc(imageUrl) %>"
                                alt="<%= esc(itemName) %>"
                                loading="lazy"
                                onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80';"
                            >

                            <span class="food-tag">YUMLET MENU</span>

                            <button
                                type="button"
                                class="food-favourite"
                                data-id="<%= menuId %>"
                                data-name="<%= esc(itemName) %>"
                                data-restaurant-id="<%= restaurantId %>"
                                aria-label="Add <%= esc(itemName) %> to favourites"
                                aria-pressed="false"
                                title="Add to favourites"
                            >
                                <svg viewBox="0 0 24 24" aria-hidden="true">
                                    <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8z"/>
                                </svg>
                            </button>

                            <% if (available) { %>
                                <span class="available-dot">Available</span>
                            <% } %>

                        </div>

                        <div class="menu-body">

                            <div class="menu-top">
                                <h3 class="menu-name"><%= esc(itemName) %></h3>

                                <span class="menu-price">
                                    ₹<%= price != null
                                        ? price.setScale(0, RoundingMode.HALF_UP).toPlainString()
                                        : "0" %>
                                </span>
                            </div>

                            <p class="menu-description">
                                <%= description != null &&
                                    !description.trim().isEmpty()
                                    ? esc(description)
                                    : "Deliciously prepared with fresh ingredients and full of flavour." %>
                            </p>

                            <div class="menu-actions" id="actions-<%= menuId %>">

                                <% if (!available) { %>

                                    <button type="button"
                                            class="add-button"
                                            disabled>
                                        Currently unavailable
                                    </button>

                                <% } else if (quantity == 0) { %>

                                    <button
                                        type="button"
                                        class="add-button"
                                        onclick="addItem(<%= menuId %>, <%= restaurantId %>)"
                                    >
                                        + Add to Cart
                                    </button>

                                <% } else { %>

                                    <div class="quantity-control">

                                        <button
                                            type="button"
                                            aria-label="Decrease quantity"
                                            onclick="decreaseItem(<%= menuId %>, <%= restaurantId %>)"
                                        >−</button>

                                        <span class="quantity-value"
                                              id="quantity-<%= menuId %>">
                                            <%= quantity %>
                                        </span>

                                        <button
                                            type="button"
                                            aria-label="Increase quantity"
                                            onclick="increaseItem(<%= menuId %>, <%= restaurantId %>)"
                                        >+</button>

                                    </div>

                                <% } %>

                            </div>
                        </div>
                    </article>

                <% } %>

            <% } %>

        </div>
    </div>
</main>

<a href="<%= contextPath %>/cart"
   class="floating-cart"
   id="floatingCart">

    <div class="cart-icon">🛒</div>

    <div class="floating-cart-text">
        <strong>View Cart</strong>

        <span id="floatingCartTotal">
            ₹<%= cartTotal.setScale(2, RoundingMode.HALF_UP).toPlainString() %>
        </span>
    </div>

    <span class="cart-count-badge" id="cartCount">
        <%= cartCount %>
    </span>
</a>

<div class="toast" id="toast" role="status" aria-live="polite">
    Updated successfully
</div>

<script>
(function () {
    "use strict";

    const contextPath = "<%= contextPath %>";

    /*
     * Retains the existing cart controller's query-parameter approach.
     * Confirm that your CartController supports these action names.
     */
    function changeCart(action, menuId, restaurantId) {
        if (!menuId || !restaurantId || restaurantId <= 0) {
            showToast("Unable to update cart. Please try again.");
            return;
        }

        const params = new URLSearchParams({
            action: action,
            menuId: String(menuId),
            restaurantId: String(restaurantId),
            source: "menu"
        });

        window.location.href = contextPath + "/cart?" + params.toString();
    }

    window.addItem = function (menuId, restaurantId) {
        changeCart("add", menuId, restaurantId);
    };

    window.increaseItem = function (menuId, restaurantId) {
        changeCart("increase", menuId, restaurantId);
    };

    window.decreaseItem = function (menuId, restaurantId) {
        changeCart("decrease", menuId, restaurantId);
    };

    function showToast(message) {
        const toast = document.getElementById("toast");

        if (!toast) return;

        toast.textContent = message;
        toast.classList.add("show");

        if (window.yumletToastTimer) {
            clearTimeout(window.yumletToastTimer);
        }

        window.yumletToastTimer = setTimeout(function () {
            toast.classList.remove("show");
        }, 1800);
    }

    /*
     * Food favourites are submitted to the existing /favourite controller.
     */
    document.querySelectorAll(".food-favourite").forEach(
        function (button) {
            button.addEventListener("click", async function () {
                const itemId = button.dataset.id;

                if (!itemId) {
                    showToast("Unable to identify this food item.");
                    return;
                }

                button.disabled = true;

                try {
                    const response = await fetch(
                        contextPath + "/favourite",
                        {
                            method: "POST",
                            credentials: "same-origin",
                            headers: {
                                "Content-Type":
                                    "application/x-www-form-urlencoded; charset=UTF-8"
                            },
                            body: new URLSearchParams({
                                itemId: itemId,
                                itemType: "food"
                            })
                        }
                    );

                    if (response.status === 401) {
                        showToast("Please log in to save favourites.");
                        return;
                    }

                    const result = await response.json();

                    if (!response.ok || !result.success) {
                        showToast(
                            result.message ||
                            "Could not update favourite."
                        );
                        return;
                    }

                    const saved = result.saved === true;

                    updateHeart(button, saved);

                    showToast(
                        saved
                            ? "Added to favourites"
                            : "Removed from favourites"
                    );

                } catch (error) {
                    console.error("Food favourite error:", error);
                    showToast("Unable to update favourite. Please try again.");
                } finally {
                    button.disabled = false;
                }
            });
        }
    );

    function updateHeart(button, saved) {
        button.classList.toggle("active", saved);
        button.setAttribute("aria-pressed", String(saved));

        const name = button.dataset.name || "food item";

        button.setAttribute(
            "aria-label",
            saved
                ? "Remove " + name + " from favourites"
                : "Add " + name + " to favourites"
        );

        button.title = saved
            ? "Remove from favourites"
            : "Add to favourites";
    }

    /*
     * Card entrance animation.
     */
    const cards = document.querySelectorAll(".menu-card");

    const reduceMotion = window.matchMedia(
        "(prefers-reduced-motion: reduce)"
    ).matches;

    if (reduceMotion || !("IntersectionObserver" in window)) {
        cards.forEach(function (card) {
            card.classList.add("show-card");
        });
    } else {
        const observer = new IntersectionObserver(
            function (entries) {
                entries.forEach(function (entry) {
                    if (entry.isIntersecting) {
                        entry.target.classList.add("show-card");
                    }
                });
            },
            { threshold: 0.15 }
        );

        cards.forEach(function (card, index) {
            card.style.transitionDelay = (index % 3) * 80 + "ms";
            observer.observe(card);
        });
    }

    /*
     * Scroll to a requested menu item, if the URL contains ?scrollTo=ID.
     */
    window.addEventListener("load", function () {
        const params = new URLSearchParams(window.location.search);
        const scrollToId = params.get("scrollTo");

        if (scrollToId && /^\d+$/.test(scrollToId)) {
            const item = document.getElementById("menu-" + scrollToId);

            if (item) {
                item.scrollIntoView({
                    behavior: "auto",
                    block: "center"
                });
            }
        }
    });

})();
</script>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
