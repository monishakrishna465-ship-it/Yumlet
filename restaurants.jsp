
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Restaurant" %>

<%
    String cp = request.getContextPath();

    List<Restaurant> restaurants =
        (List<Restaurant>) request.getAttribute("restaurants");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="<%= cp %>">

    <title>Restaurants | Yumlet</title>

    <link rel="stylesheet" href="<%= cp %>/css/navbar.css">
    <link rel="stylesheet" href="<%= cp %>/css/footer.css">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #3b1d0e;
            color: #48230f;
        }

        .restaurant-page {
            min-height: 70vh;
            padding: 42px 6%;
            background: #3b1d0e;
        }

        .restaurant-heading {
            text-align: center;
            margin-bottom: 35px;
        }

        .restaurant-heading .eyebrow {
            color: #e3b98d;
            font-size: 12px;
            font-weight: bold;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        .restaurant-heading h1 {
            margin: 12px 0;
            font-family: Georgia, serif;
            font-size: clamp(30px, 4vw, 44px);
            color: #fff0d9;
        }

        .restaurant-heading p {
            margin: 0 auto;
            max-width: 600px;
            color: #ead5bf;
            line-height: 1.7;
        }

        .restaurant-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            align-items: stretch;
            gap: 25px;
            max-width: 1600px;
            margin: 0 auto;
        }

        .restaurant-card {
            overflow: hidden;
            display: flex;
            flex-direction: column;
            background: #f5e7cf;
            border: 1px solid #e7d1b2;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.18);

            opacity: 0;
            transform: translateY(38px) scale(.97);

            transition:
                opacity .45s ease,
                transform .7s cubic-bezier(.22, 1.25, .36, 1),
                box-shadow .25s ease;
        }

        .restaurant-card.show-card {
            opacity: 1;
            transform: translateY(0) scale(1);
        }

        .restaurant-card.show-card:hover {
            transform: translateY(-5px) scale(1.01);
            box-shadow: 0 15px 32px rgba(0, 0, 0, .28);
        }

        .restaurant-image-wrapper {
            position: relative;
            width: 100%;
            height: 215px;
            flex-shrink: 0;
            overflow: hidden;
            background: #ead5b8;
        }

        .restaurant-image {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform .35s ease;
        }

        .restaurant-card:hover .restaurant-image {
            transform: scale(1.04);
        }

        .favourite-btn {
            position: absolute;
            top: 13px;
            right: 13px;
            z-index: 2;
            width: 42px;
            height: 42px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
            border-radius: 50%;
            background: rgba(255, 248, 236, .96);
            color: #48230f;
            cursor: pointer;
            box-shadow: 0 3px 12px rgba(0, 0, 0, .18);
            transition: transform .2s ease, background .2s ease;
        }

        .favourite-btn:hover {
            transform: scale(1.1);
        }

        .favourite-btn:disabled {
            cursor: wait;
            opacity: .65;
        }

        .favourite-btn svg {
            width: 22px;
            height: 22px;
            fill: none;
            stroke: currentColor;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .favourite-btn.active {
            background: #fff0e8;
            color: #e53945;
        }

        .favourite-btn.active svg {
            fill: #e53945;
            stroke: #e53945;
        }

        .favourite-btn:focus-visible {
            outline: 3px solid #c58b5b;
            outline-offset: 3px;
        }

        .restaurant-details {
            display: flex;
            flex-direction: column;
            flex: 1;
            padding: 18px;
            min-height: 0;
        }

        .restaurant-details h2 {
            margin: 0 0 8px;
            font-family: Georgia, serif;
            font-size: 23px;
            line-height: 1.3;
            color: #48230f;
        }

        .cuisine {
            margin: 0 0 12px;
            color: #80634d;
            font-size: 15px;
        }

        .restaurant-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 9px;
            margin-bottom: 15px;
            font-size: 13px;
        }

        .restaurant-meta span {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 8px 12px;
            border-radius: 25px;
            background: #efddc1;
            color: #48230f;
        }

        .restaurant-address {
            min-height: 0;
            margin-bottom: 15px;
            color: #80634d;
            font-size: 13px;
            line-height: 1.5;
        }

        .restaurant-actions {
            display: flex;
            gap: 10px;
            margin-top: auto;
        }

        .restaurant-actions a {
            display: inline-flex;
            flex: 1;
            align-items: center;
            justify-content: center;
            min-height: 44px;
            padding: 10px;
            border: 1px solid #48230f;
            border-radius: 9px;
            background: #48230f;
            color: #fff5e6;
            font-size: 14px;
            font-weight: bold;
            text-decoration: none;
            transition: background .2s ease;
        }

        .restaurant-actions a:hover {
            background: #704126;
        }

        .empty-state {
            grid-column: 1 / -1;
            padding: 45px 20px;
            text-align: center;
            border: 1px dashed #c5a17c;
            border-radius: 18px;
            background: #f5e7cf;
            color: #48230f;
        }

        .empty-state h2 {
            font-family: Georgia, serif;
        }

        @media (max-width: 1050px) {
            .restaurant-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 650px) {
            .restaurant-page {
                padding: 30px 18px;
            }

            .restaurant-grid {
                grid-template-columns: 1fr;
                gap: 22px;
            }

            .restaurant-image-wrapper {
                height: 220px;
            }

            .restaurant-details h2 {
                font-size: 22px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .restaurant-card,
            .restaurant-card.show-card,
            .restaurant-card.show-card:hover {
                opacity: 1;
                transform: none;
                transition: none;
            }

            .restaurant-card:hover .restaurant-image {
                transform: none;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/navbar.jsp" />

<main class="restaurant-page">

    <section class="restaurant-heading">
        <span class="eyebrow">Made for your cravings</span>

        <h1>Discover Restaurants</h1>

        <p>
            From your favourite comfort food to something new,
            find your next delicious meal with Yumlet.
        </p>
    </section>

    <section class="restaurant-grid">

        <% if (restaurants != null && !restaurants.isEmpty()) { %>

            <% for (Restaurant restaurant : restaurants) {

                String image = restaurant.getImagePath();

                if (image == null || image.trim().isEmpty()) {
                    image = "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80";
                }

                String restaurantName = restaurant.getName() == null
                    ? "Restaurant" : restaurant.getName();

                String cuisine = restaurant.getCuisineType() == null
                    ? "Delicious food" : restaurant.getCuisineType();

                String address = restaurant.getAddress() == null
                    ? "" : restaurant.getAddress();

                int restaurantId = restaurant.getRestaurantId();

                String safeName = restaurantName
                    .replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;");

                String safeCuisine = cuisine
                    .replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;");

                String safeImage = image
                    .replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;");
            %>

                <article class="restaurant-card">

                    <div class="restaurant-image-wrapper">

                        <img
                            class="restaurant-image"
                            src="<%= safeImage %>"
                            alt="<%= safeName %>"
                            loading="lazy"
                            onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80';"
                        >

                        <button
                            type="button"
                            class="favourite-btn"
                            data-id="<%= restaurantId %>"
                            data-name="<%= safeName %>"
                            aria-label="Add <%= safeName %> to favourites"
                            aria-pressed="false"
                            title="Add to favourites"
                        >
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8z"/>
                            </svg>
                        </button>

                    </div>

                    <div class="restaurant-details">

                        <h2><%= safeName %></h2>

                        <p class="cuisine"><%= safeCuisine %></p>

                        <div class="restaurant-meta">
                            <span>⭐ <%= restaurant.getRating() %></span>
                            <span>🕒 <%= restaurant.getDeliveryTime() %> min</span>
                        </div>

                        <div class="restaurant-address">
                            <%= address %>
                        </div>

                        <div class="restaurant-actions">
                            <a href="<%= cp %>/menu?restaurantId=<%= restaurantId %>">
                                View Menu
                            </a>
                        </div>

                    </div>

                </article>

            <% } %>

        <% } else { %>

            <div class="empty-state">
                <h2>Our kitchens are getting ready!</h2>
                <p>No restaurants are available to display right now.</p>
                <p>Please check your restaurant controller and database.</p>
            </div>

        <% } %>

    </section>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
(function () {
    "use strict";

    const contextPath =
        document.querySelector('meta[name="context-path"]').content;

    function updateHeart(button, saved) {
        button.classList.toggle("active", saved);
        button.setAttribute("aria-pressed", String(saved));

        const name = button.dataset.name || "restaurant";

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

    async function toggleFavourite(button) {
        if (button.dataset.busy === "true") {
            return;
        }

        const itemId = button.dataset.id;

        if (!itemId) {
            alert("Restaurant ID is missing.");
            return;
        }

        button.dataset.busy = "true";
        button.disabled = true;

        try {
            const response = await fetch(contextPath + "/favourite", {
                method: "POST",
                credentials: "same-origin",
                headers: {
                    "Content-Type":
                        "application/x-www-form-urlencoded;charset=UTF-8"
                },
                body: new URLSearchParams({
                    itemId: itemId,
                    itemType: "restaurant"
                })
            });

            if (response.status === 401) {
                alert("Please log in to save your favourites.");
                window.location.href = contextPath + "/login.jsp";
                return;
            }

            const result = await response.json();

            if (!response.ok || !result.success) {
                throw new Error(
                    result.message || "Could not update your favourite."
                );
            }

            updateHeart(button, result.saved);

        } catch (error) {
            console.error("Favourite error:", error);

            alert(
                error.message ||
                "Unable to update your favourite. Please try again."
            );
        } finally {
            button.disabled = false;
            button.dataset.busy = "false";
        }
    }

    // One click handler per heart; no localStorage handler.
    document.querySelectorAll(".favourite-btn").forEach(function (button) {
        button.addEventListener("click", function () {
            toggleFavourite(button);
        });
    });

    // Restaurant card entrance animation.
    const cards = document.querySelectorAll(".restaurant-card");

    const reduceMotion = window.matchMedia(
        "(prefers-reduced-motion: reduce)"
    ).matches;

    if (reduceMotion || !("IntersectionObserver" in window)) {
        cards.forEach(function (card) {
            card.classList.add("show-card");
        });
    } else {
        const observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.remove("show-card");

                    void entry.target.offsetWidth;

                    entry.target.classList.add("show-card");
                } else {
                    entry.target.classList.remove("show-card");
                }
            });
        }, {
            threshold: 0.15
        });

        cards.forEach(function (card, index) {
            card.style.transitionDelay = (index % 3) * 90 + "ms";
            observer.observe(card);
        });
    }
})();
</script>

</body>
</html>
