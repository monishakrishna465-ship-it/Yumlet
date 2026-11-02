
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.daoImpl.MenuDaoImpl" %>

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
        if (path == null || path.trim().isEmpty()) {
            return null;
        }

        path = path.trim().replace("\\", "/");

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

    private boolean matchesMood(Menu item, String mood) {
        String name = item.getItemName() == null
                ? "" : item.getItemName().toLowerCase(Locale.ROOT);

        String description = item.getDescription() == null
                ? "" : item.getDescription().toLowerCase(Locale.ROOT);

        String food = name + " " + description;
        String keywords;

        switch (mood) {
            case "period":
                keywords = "chocolate|banana|soup|rice|dal|khichdi|sweet|tea";
                break;

            case "sick":
                keywords = "soup|rice|idli|curd|khichdi|dal|rasam";
                break;

            case "happy":
                keywords = "pizza|burger|biryani|cake|ice cream|pasta";
                break;

            case "sad":
                keywords = "chocolate|cake|ice cream|biryani|noodles";
                break;

            case "diet":
                keywords = "salad|sprouts|idli|dosa|soup|fruit|grilled";
                break;

            case "late-night":
                keywords = "noodles|sandwich|burger|pizza|roll|fries";
                break;

            case "stress":
                keywords = "tea|coffee|chocolate|sandwich|dosa|snack";
                break;

            case "rainy":
                keywords = "pakora|bajji|soup|tea|coffee|samosa|vada";
                break;

            default:
                return false;
        }

        for (String keyword : keywords.split("\\|")) {
            if (food.contains(keyword)) {
                return true;
            }
        }

        return false;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    String contextPath = request.getContextPath();

    String mood = request.getParameter("mood");

    if (mood == null) {
        mood = "";
    }

    mood = mood.trim().toLowerCase(Locale.ROOT);

    String moodTitle;
    String moodDescription;

    switch (mood) {
        case "period":
            moodTitle = "Comfort Food for You";
            moodDescription = "Warm, comforting dishes for when you need extra care.";
            break;

        case "sick":
            moodTitle = "Feel-Good Food";
            moodDescription = "Explore simple, comforting food choices.";
            break;

        case "happy":
            moodTitle = "Celebrate Your Happiness";
            moodDescription = "Find delicious favourites to match your happy mood.";
            break;

        case "sad":
            moodTitle = "A Little Food Comfort";
            moodDescription = "Discover comforting treats for a difficult day.";
            break;

        case "diet":
            moodTitle = "Fresh and Light Choices";
            moodDescription = "Explore lighter dishes from the available menu.";
            break;

        case "late-night":
            moodTitle = "Late-Night Cravings";
            moodDescription = "Find something tasty for those late-night cravings.";
            break;

        case "stress":
            moodTitle = "Take a Tasty Break";
            moodDescription = "Find a snack or favourite dish for your break.";
            break;

        case "rainy":
            moodTitle = "Rainy-Day Cravings";
            moodDescription = "Explore warm and comforting rainy-day favourites.";
            break;

        default:
            moodTitle = "Mood-Based Recommendations";
            moodDescription = "Choose a mood to discover food you might enjoy.";
            break;
    }

    List<Menu> allMenus = new ArrayList<Menu>();

    try {
        allMenus = new MenuDaoImpl().getAllMenus();

        if (allMenus == null) {
            allMenus = new ArrayList<Menu>();
        }
    } catch (Exception e) {
        application.log("Unable to load mood recommendations", e);
    }

    List<Menu> recommendedMenus = new ArrayList<Menu>();
    Set<String> seenFoodNames = new HashSet<String>();

    for (Menu item : allMenus) {
        if (item == null || !item.isAvailable()) {
            continue;
        }

        if (!matchesMood(item, mood)) {
            continue;
        }

        String itemName = item.getItemName();

        if (itemName == null || itemName.trim().isEmpty()) {
            continue;
        }

        // Avoid displaying the same food name more than once.
        String normalizedName = itemName.trim().toLowerCase(Locale.ROOT);

        if (seenFoodNames.contains(normalizedName)) {
            continue;
        }

        seenFoodNames.add(normalizedName);
        recommendedMenus.add(item);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Yumlet | <%= esc(moodTitle) %></title>

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
            --brown: #48230f;
            --beige: #f5e7cf;
            --beige-light: #fff0d9;
            --border: #e7d1b2;
            --muted: #80634d;
            --accent: #8c4b2d;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: var(--chocolate);
            color: var(--beige-light);
            font-family: "DM Sans", Arial, sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .mood-hero {
            padding: 65px 20px 55px;
            text-align: center;
            background:
                radial-gradient(circle at top right, #744324, transparent 40%),
                var(--chocolate);
        }

        .mood-hero-inner {
            max-width: 850px;
            margin: auto;
        }

        .eyebrow {
            color: #e3b98d;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 2px;
        }

        .mood-title {
            margin: 15px 0;
            font-family: "Playfair Display", Georgia, serif;
            font-size: clamp(34px, 5vw, 54px);
            line-height: 1.2;
        }

        .mood-description {
            max-width: 650px;
            margin: 0 auto;
            color: #e2cbb4;
            font-size: 14px;
            line-height: 1.8;
        }

        .mood-section {
            width: min(1180px, 92%);
            margin: auto;
            padding: 15px 0 85px;
        }

        .top-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
        }

        .result-count {
            color: #e2cbb4;
            font-size: 13px;
        }

        .back-link {
            display: inline-block;
            padding: 10px 15px;
            border: 1px solid #cba783;
            border-radius: 9px;
            color: var(--beige-light);
            font-size: 12px;
            font-weight: 700;
        }

        .back-link:hover {
            background: #5a301b;
        }

        .food-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 24px;
        }

        .food-card {
            min-width: 0;
            overflow: hidden;
            border: 1px solid var(--border);
            border-radius: 17px;
            background: var(--beige);
            color: var(--brown);
            box-shadow: 0 8px 22px rgba(0, 0, 0, .14);
            transition: transform .25s ease, box-shadow .25s ease;
        }

        .food-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, .24);
        }

        .food-image {
            width: 100%;
            height: 210px;
            overflow: hidden;
            background: #ead5b8;
        }

        .food-image img {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform .35s ease;
        }

        .food-card:hover .food-image img {
            transform: scale(1.04);
        }

        .image-placeholder {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 15px;
            background: #ead5b8;
            color: var(--muted);
            font-size: 13px;
            text-align: center;
        }

        .food-body {
            display: flex;
            flex-direction: column;
            padding: 18px;
            min-height: 200px;
        }

        .food-top {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 10px;
        }

        .food-name {
            margin: 0;
            font-family: "Playfair Display", Georgia, serif;
            font-size: 20px;
            line-height: 1.35;
            overflow-wrap: anywhere;
        }

        .food-price {
            flex-shrink: 0;
            color: var(--accent);
            font-size: 16px;
            font-weight: 800;
        }

        .food-description {
            margin: 11px 0 18px;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.7;
            overflow-wrap: anywhere;
        }

        .add-button {
            display: block;
            width: 100%;
            margin-top: auto;
            padding: 12px;
            border: none;
            border-radius: 9px;
            background: var(--brown);
            color: #fff5e6;
            text-align: center;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            transition: background .2s ease;
        }

        .add-button:hover {
            background: #704126;
        }

        .empty-state {
            grid-column: 1 / -1;
            padding: 55px 20px;
            border: 1px dashed #c5a17c;
            border-radius: 17px;
            background: var(--beige);
            color: var(--brown);
            text-align: center;
        }

        .empty-state h2 {
            margin: 0 0 12px;
            font-family: "Playfair Display", Georgia, serif;
        }

        .empty-state p {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.8;
        }

        .browse-link {
            display: inline-block;
            margin-top: 10px;
            padding: 12px 17px;
            border-radius: 9px;
            background: var(--brown);
            color: white;
            font-size: 13px;
            font-weight: 700;
        }

        @media (max-width: 950px) {
            .food-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 600px) {
            .mood-hero {
                padding: 45px 18px;
            }

            .food-grid {
                grid-template-columns: 1fr;
                gap: 19px;
            }

            .food-image {
                height: 230px;
            }

            .top-actions {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition: none !important;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/navbar.jsp" />

<header class="mood-hero">
    <div class="mood-hero-inner">
        <div class="eyebrow">YUMLET · FOOD FOR YOUR MOOD</div>

        <h1 class="mood-title"><%= esc(moodTitle) %></h1>

        <p class="mood-description">
            <%= esc(moodDescription) %>
        </p>
    </div>
</header>

<main class="mood-section">

    <div class="top-actions">
        <span class="result-count">
            <%= recommendedMenus.size() %>
            food item<%= recommendedMenus.size() == 1 ? "" : "s" %>
            found
        </span>

        <a class="back-link"
           href="<%= contextPath %>/mood.jsp">
            &larr; Back to moods
        </a>
    </div>

    <div class="food-grid">

        <% if (recommendedMenus.isEmpty()) { %>

            <div class="empty-state">
                <h2>No matching dishes found</h2>

                <p>
                    We couldn't find available menu items matching this mood.
                    Explore the full menu to discover more food.
                </p>

                <a class="browse-link"
                   href="<%= contextPath %>/restaurant">
                    Browse Restaurants
                </a>
            </div>

        <% } else { %>

            <% for (Menu item : recommendedMenus) {

                String itemName = item.getItemName();
                String description = item.getDescription();

                String imageUrl = resolveImage(
                    item.getImagePath(),
                    contextPath
                );

                String price = item.getPrice() == null
                    ? "0"
                    : item.getPrice().toPlainString();

                int menuId = item.getMenuId();
                int restaurantId = item.getRestaurantId();
            %>

                <article class="food-card">

                    <div class="food-image">

                        <% if (imageUrl != null) { %>

                            <img
                                src="<%= esc(imageUrl) %>"
                                alt="<%= esc(itemName) %>"
                                loading="lazy"
                                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
                            >

                            <div class="image-placeholder"
                                 style="display:none;">
                                Image unavailable
                            </div>

                        <% } else { %>

                            <div class="image-placeholder">
                                No image available
                            </div>

                        <% } %>

                    </div>

                    <div class="food-body">

                        <div class="food-top">
                            <h2 class="food-name">
                                <%= esc(itemName) %>
                            </h2>

                            <span class="food-price">
                                ₹<%= esc(price) %>
                            </span>
                        </div>

                        <p class="food-description">
                            <%= description != null &&
                                !description.trim().isEmpty()
                                ? esc(description)
                                : "Deliciously prepared with fresh ingredients." %>
                        </p>

                        <a class="add-button"
                           href="<%= contextPath %>/cart?action=add&amp;menuId=<%= menuId %>&amp;restaurantId=<%= restaurantId %>&amp;source=menu">
                            + Add to Cart
                        </a>

                    </div>
                </article>

            <% } %>

        <% } %>

    </div>
</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
