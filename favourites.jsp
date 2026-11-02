
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,java.util.Map,java.util.ArrayList" %>

<%!
    private String esc(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String resolveImage(String imagePath, String contextPath) {
        if (imagePath == null || imagePath.trim().isEmpty()) {
            return contextPath + "/images/food-placeholder.jpg";
        }

        imagePath = imagePath.trim().replace("\\", "/");

        if (imagePath.startsWith("https://")
                || imagePath.startsWith("http://")) {
            return imagePath;
        }

        while (imagePath.startsWith("/")) {
            imagePath = imagePath.substring(1);
        }

        return contextPath + "/" + imagePath;
    }
%>

<%
    String contextPath = request.getContextPath();

    List<Map<String, Object>> restaurantFavourites =
        (List<Map<String, Object>>) request.getAttribute("restaurantFavourites");

    List<Map<String, Object>> foodFavourites =
        (List<Map<String, Object>>) request.getAttribute("foodFavourites");

    if (restaurantFavourites == null) {
        restaurantFavourites = new ArrayList<Map<String, Object>>();
    }

    if (foodFavourites == null) {
        foodFavourites = new ArrayList<Map<String, Object>>();
    }

    int totalFavourites =
        restaurantFavourites.size() + foodFavourites.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>My Favourites | Eatero</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/navbar.css">
    <link rel="stylesheet" href="<%= contextPath %>/css/footer.css">

    <style>
        :root {
            --chocolate: #3B2419;
            --chocolate-light: #543524;
            --beige: #F4E6D1;
            --beige-light: #FFF8ED;
            --brown-text: #432B1F;
            --muted: #806B5B;
            --border: #DDC6AA;
            --accent: #A65F35;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: "Segoe UI", Arial, Helvetica, sans-serif;
            background: var(--chocolate);
            color: var(--beige-light);
            min-height: 100vh;
        }

        .favourites-page {
            width: 100%;
            max-width: 1250px;
            margin: 0 auto;
            padding: 38px 24px 55px;
        }

        .favourites-header {
            margin-bottom: 28px;
        }

        .eyebrow {
            display: inline-block;
            color: #E7B58C;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 10px;
        }

        .favourites-header h1 {
            font-size: clamp(28px, 4vw, 40px);
            line-height: 1.2;
            margin-bottom: 10px;
            color: #FFF3E2;
        }

        .favourites-header p {
            color: #D7C0AA;
            font-size: 15px;
            line-height: 1.7;
        }

        .favourites-shell {
            background: var(--beige);
            color: var(--brown-text);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 22px;
            padding: 26px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.18);
        }

        .favourites-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 18px;
            margin-bottom: 26px;
        }

        .favourites-count {
            font-size: 15px;
            font-weight: 700;
            color: var(--brown-text);
        }

        .favourites-count span {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 29px;
            height: 29px;
            margin-left: 7px;
            padding: 0 8px;
            background: var(--chocolate);
            color: #FFF3E2;
            border-radius: 50px;
            font-size: 13px;
        }

        .filter-buttons {
            display: flex;
            gap: 9px;
            flex-wrap: wrap;
        }

        .filter-btn {
            border: 1px solid var(--border);
            border-radius: 30px;
            padding: 10px 17px;
            background: var(--beige-light);
            color: var(--brown-text);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.2s ease;
        }

        .filter-btn:hover,
        .filter-btn.active {
            background: var(--chocolate);
            color: #FFF3E2;
            border-color: var(--chocolate);
        }

        .favourites-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 22px;
        }

        .favourite-card {
            background: var(--beige-light);
            border: 1px solid var(--border);
            border-radius: 17px;
            overflow: hidden;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .favourite-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 25px rgba(59, 36, 25, 0.12);
        }

        .favourite-image {
            width: 100%;
            height: 190px;
            object-fit: cover;
            display: block;
            background: #E6D1B8;
        }

        .favourite-content {
            padding: 18px;
        }

        .favourite-type {
            display: inline-block;
            padding: 5px 10px;
            margin-bottom: 11px;
            border-radius: 20px;
            background: #EBD5BA;
            color: #69452F;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .favourite-content h3 {
            color: var(--brown-text);
            font-size: 19px;
            margin-bottom: 8px;
            overflow-wrap: anywhere;
        }

        .favourite-description {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.6;
            min-height: 42px;
            overflow-wrap: anywhere;
        }

        .favourite-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 16px;
            padding-top: 13px;
            border-top: 1px solid #E8D7C2;
            font-size: 13px;
            font-weight: 700;
            color: var(--brown-text);
        }

        .rating {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: #875020;
        }

        .rating svg {
            display: block;
            width: 15px;
            height: 15px;
            flex-shrink: 0;
        }

        .price {
            color: #54723D;
            font-size: 15px;
        }

        .empty-state {
            text-align: center;
            padding: 55px 18px;
            background: var(--beige-light);
            border: 1px dashed #C8AB8A;
            border-radius: 17px;
        }

        .empty-heart {
            width: 45px;
            height: 45px;
            margin: 0 auto 15px;
            color: #A65F35;
        }

        .empty-heart svg {
            display: block;
            width: 100%;
            height: 100%;
            fill: none;
            stroke: currentColor;
            stroke-width: 1.7;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .favourites-header h1 .heading-heart {
            display: inline-block;
            width: 25px;
            height: 25px;
            vertical-align: middle;
            color: #E7B58C;
        }

        .heading-heart svg {
            display: block;
            width: 100%;
            height: 100%;
            fill: #E7B58C;
            stroke: #E7B58C;
        }

        .empty-state h2 {
            color: var(--brown-text);
            font-size: 23px;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: var(--muted);
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 23px;
        }

        .browse-btn {
            display: inline-block;
            padding: 12px 22px;
            background: var(--chocolate);
            color: #FFF3E2;
            border-radius: 9px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            transition: background 0.2s ease;
        }

        .browse-btn:hover {
            background: var(--chocolate-light);
        }

        .hidden-card {
            display: none !important;
        }

        @media (max-width: 900px) {
            .favourites-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 600px) {
            .favourites-page {
                padding: 26px 14px 38px;
            }

            .favourites-shell {
                padding: 17px;
                border-radius: 17px;
            }

            .favourites-toolbar {
                align-items: flex-start;
                flex-direction: column;
            }

            .favourites-grid {
                grid-template-columns: 1fr;
            }

            .favourite-image {
                height: 210px;
            }

            .filter-buttons {
                width: 100%;
            }

            .filter-btn {
                padding: 9px 13px;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="/includes/navbar.jsp" />

    <main class="favourites-page">

        <header class="favourites-header">
            <span class="eyebrow">Your personal collection</span>

            <h1>
                My Favourites
                <span class="heading-heart" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8z"/>
                    </svg>
                </span>
            </h1>

            <p>All the food and restaurants you love, together in one place.</p>
        </header>

        <section class="favourites-shell">

            <div class="favourites-toolbar">
                <div class="favourites-count">
                    Saved favourites
                    <span><%= totalFavourites %></span>
                </div>

                <div class="filter-buttons">
                    <button type="button" class="filter-btn active" data-filter="all">All</button>
                    <button type="button" class="filter-btn" data-filter="restaurant">Restaurants</button>
                    <button type="button" class="filter-btn" data-filter="food">Food</button>
                </div>
            </div>

            <% if (totalFavourites == 0) { %>

                <div class="empty-state">

                    <div class="empty-heart" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8z"/>
                        </svg>
                    </div>

                    <h2>No favourites yet</h2>

                    <p>
                        Your favourite restaurants and dishes will appear here
                        when you save them.
                    </p>

                    <a class="browse-btn" href="<%= contextPath %>/restaurant">
                        Explore Restaurants
                    </a>
                </div>

            <% } else { %>

                <div class="favourites-grid" id="favouritesGrid">

                    <% for (Map<String, Object> restaurant : restaurantFavourites) {

                        String name = String.valueOf(
                            restaurant.get("name") == null ? "" : restaurant.get("name"));

                        String description = String.valueOf(
                            restaurant.get("description") == null ? "" : restaurant.get("description"));

                        String imagePath = String.valueOf(
                            restaurant.get("imagePath") == null ? "" : restaurant.get("imagePath"));

                        Object rating = restaurant.get("rating");

                        String imageUrl = resolveImage(imagePath, contextPath);
                    %>

                        <article class="favourite-card" data-category="restaurant">

                            <img class="favourite-image"
                                 src="<%= esc(imageUrl) %>"
                                 alt="<%= esc(name) %>"
                                 loading="lazy"
                                 onerror="this.onerror=null;this.src='<%= contextPath %>/images/food-placeholder.jpg';">

                            <div class="favourite-content">

                                <span class="favourite-type">Restaurant</span>

                                <h3><%= esc(name) %></h3>

                                <p class="favourite-description"><%= esc(description) %></p>

                                <div class="favourite-meta">
                                    <span>
                                        <% if (rating != null
                                                && !String.valueOf(rating).trim().isEmpty()) { %>

                                            <span class="rating">
                                                <svg viewBox="0 0 24 24" aria-hidden="true">
                                                    <path fill="currentColor" d="M12 2.5l2.9 5.9 6.5.9-4.7 4.6 1.1 6.5-5.8-3.1-5.8 3.1 1.1-6.5-4.7-4.6 6.5-.9z"/>
                                                </svg>
                                                <%= esc(String.valueOf(rating)) %>
                                            </span>

                                        <% } else { %>

                                            Your saved restaurant

                                        <% } %>
                                    </span>
                                </div>

                            </div>
                        </article>

                    <% } %>

                    <% for (Map<String, Object> food : foodFavourites) {

                        String name = String.valueOf(
                            food.get("name") == null ? "" : food.get("name"));

                        String description = String.valueOf(
                            food.get("description") == null ? "" : food.get("description"));

                        String imagePath = String.valueOf(
                            food.get("imagePath") == null ? "" : food.get("imagePath"));

                        Object price = food.get("price");

                        String imageUrl = resolveImage(imagePath, contextPath);
                    %>

                        <article class="favourite-card" data-category="food">

                            <img class="favourite-image"
                                 src="<%= esc(imageUrl) %>"
                                 alt="<%= esc(name) %>"
                                 loading="lazy"
                                 onerror="this.onerror=null;this.src='<%= contextPath %>/images/food-placeholder.jpg';">

                            <div class="favourite-content">

                                <span class="favourite-type">Food</span>

                                <h3><%= esc(name) %></h3>

                                <p class="favourite-description"><%= esc(description) %></p>

                                <div class="favourite-meta">

                                    <span>Saved dish</span>

                                    <% if (price != null
                                            && !String.valueOf(price).trim().isEmpty()) { %>

                                        <span class="price">
                                            &#8377;<%= esc(String.valueOf(price)) %>
                                        </span>

                                    <% } %>

                                </div>

                            </div>
                        </article>

                    <% } %>

                </div>

            <% } %>

        </section>
    </main>

    <jsp:include page="/includes/footer.jsp" />

    <script>
        document.addEventListener("DOMContentLoaded", function () {

            const filterButtons = document.querySelectorAll(".filter-btn");
            const favouriteCards = document.querySelectorAll(".favourite-card");

            filterButtons.forEach(function (button) {

                button.addEventListener("click", function () {

                    const selectedFilter = this.dataset.filter;

                    filterButtons.forEach(function (item) {
                        item.classList.remove("active");
                    });

                    this.classList.add("active");

                    favouriteCards.forEach(function (card) {

                        const category = card.dataset.category;

                        if (selectedFilter === "all" || category === selectedFilter) {
                            card.classList.remove("hidden-card");
                        } else {
                            card.classList.add("hidden-card");
                        }
                    });
                });
            });
        });
    </script>

</body>
</html>
