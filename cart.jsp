
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.util.CouponUtil" %>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String safeImage(String path, String contextPath) {
        String fallback = "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=700&q=80";
        if (path == null || path.trim().isEmpty()) return fallback;
        path = path.trim();
        if (path.startsWith("https://") || path.startsWith("http://")) return path;
        if (path.startsWith("/")) return contextPath + path;
        return contextPath + "/" + path;
    }
%>

<%
    String contextPath = request.getContextPath();

    List<CartItem> cart = new ArrayList<CartItem>();
    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        cart = (List<CartItem>) cartObject;
    }

    Map<Integer, List<CartItem>> restaurantGroups =
            new LinkedHashMap<Integer, List<CartItem>>();
    Map<Integer, String> restaurantNames =
            new LinkedHashMap<Integer, String>();

    for (CartItem item : cart) {
        if (item == null || item.getQuantity() <= 0) continue;

        int restaurantId = item.getRestaurantId();
        if (restaurantId <= 0) restaurantId = -1;

        restaurantGroups.computeIfAbsent(
                restaurantId,
                key -> new ArrayList<CartItem>()
        ).add(item);

        String restaurantName = item.getRestaurantName();

        if (restaurantName == null || restaurantName.trim().isEmpty()) {
            restaurantName = restaurantId > 0
                    ? "Restaurant " + restaurantId
                    : "Restaurant";
        }

        restaurantNames.put(restaurantId, restaurantName);
    }

    int itemCount = 0;
    BigDecimal subtotal = BigDecimal.ZERO;

    for (CartItem item : cart) {
        if (item != null && item.getQuantity() > 0) {
            itemCount += item.getQuantity();

            if (item.getPrice() != null) {
                subtotal = subtotal.add(
                    item.getPrice().multiply(
                        BigDecimal.valueOf(item.getQuantity())
                    )
                );
            }
        }
    }

    BigDecimal targetAmount = new BigDecimal("499.00");

    BigDecimal deliveryFee = subtotal.compareTo(BigDecimal.ZERO) > 0
            ? new BigDecimal("40.00").multiply(
                    BigDecimal.valueOf(restaurantGroups.size())
              )
            : BigDecimal.ZERO;

    BigDecimal discount = subtotal.compareTo(targetAmount) >= 0
            ? new BigDecimal("40.00")
            : BigDecimal.ZERO;

    String couponCode = (String) session.getAttribute("couponCode");
    String couponMessage = "";
    BigDecimal couponDiscount = BigDecimal.ZERO;

    if (couponCode != null && !couponCode.trim().isEmpty()) {
        couponMessage = CouponUtil.getCouponMessage(couponCode, subtotal);

        if ("Coupon applied successfully!".equals(couponMessage)) {
            couponDiscount =
                    CouponUtil.calculateDiscount(couponCode, subtotal);
        } else {
            session.removeAttribute("couponCode");
            couponCode = null;
        }
    }

    BigDecimal grandTotal = subtotal
            .add(deliveryFee)
            .subtract(discount)
            .subtract(couponDiscount);

    if (grandTotal.compareTo(BigDecimal.ZERO) < 0) {
        grandTotal = BigDecimal.ZERO;
    }

    BigDecimal remaining = targetAmount.subtract(subtotal);

    if (remaining.compareTo(BigDecimal.ZERO) < 0) {
        remaining = BigDecimal.ZERO;
    }

    int progress = subtotal.multiply(new BigDecimal("100"))
            .divide(targetAmount, 0, RoundingMode.DOWN).intValue();

    progress = Math.max(0, Math.min(100, progress));
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Cart | Yumlet</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/navbar.css">
    <link rel="stylesheet" href="<%= contextPath %>/css/footer.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --chocolate: #48230F;
            --cocoa: #30170D;
            --cream: #F5E9D8;
            --caramel: #B87545;
            --page: var(--cocoa);
            --text: var(--cocoa);
            --shadow: 0 18px 45px rgba(0,0,0,.22);
        }

        * { box-sizing: border-box; }

        html { scroll-behavior: smooth; }

        body {
            margin: 0;
            background: var(--page);
            color: var(--cream);
            font-family: "DM Sans", Arial, sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        button, input { font: inherit; }

        button, a { -webkit-tap-highlight-color: transparent; }

        .cart-container {
            width: min(1200px, calc(100% - 44px));
            margin: 42px auto 75px;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 23px;
        }

        .section-heading h2 {
            margin: 0;
            color: var(--cream);
            font-family: "Playfair Display", Georgia, serif;
            font-size: 29px;
        }

        .cart-count {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 16px;
            border: 1px solid var(--caramel);
            border-radius: 30px;
            background: var(--chocolate);
            color: var(--cream);
            font-size: 13px;
        }

        .cart-count strong {
            color: var(--caramel);
            font-size: 15px;
        }

        .cart-layout {
            display: grid;
            grid-template-columns: minmax(0, 1.65fr) minmax(290px, .8fr);
            align-items: start;
            gap: 26px;
        }

        .items-panel, .summary-card, .empty-cart {
            background: var(--cream);
            color: var(--cocoa);
            border: 1px solid var(--caramel);
            border-radius: 20px;
            box-shadow: var(--shadow);
        }

        .items-panel { padding: 6px 26px; }

        .restaurant-cart-group {
            margin-bottom: 18px;
            border: 1px solid rgba(184, 117, 69, .25);
            border-radius: 16px;
            overflow: hidden;
            background: rgba(255, 248, 236, .35);
        }

        .restaurant-cart-heading {
            padding: 14px 18px;
            background: var(--chocolate);
            color: var(--cream);
            font-weight: 800;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }

        .restaurant-cart-heading small {
            font-weight: 600;
            opacity: .8;
        }

        .restaurant-cart-group .cart-item { margin: 0 16px; }

        .restaurant-cart-bill {
            display: flex;
            justify-content: space-between;
            padding: 12px 18px;
            border-top: 1px dashed rgba(184, 117, 69, .4);
            color: var(--cocoa);
            font-size: 13px;
        }

        .cart-item {
            display: grid;
            grid-template-columns: 145px minmax(0, 1fr);
            align-items: center;
            gap: 22px;
            padding: 25px 0;
            border-bottom: 1px solid var(--caramel);
            animation: reveal .35s ease both;
        }

        @keyframes reveal {
            from { opacity: 0; transform: translateY(9px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .food-image-wrap {
            width: 145px;
            height: 135px;
            overflow: hidden;
            border: 1px solid var(--caramel);
            border-radius: 15px;
            background: var(--caramel);
        }

        .food-image {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform .35s ease;
        }

        .food-image-wrap:hover .food-image { transform: scale(1.07); }

        .item-content { min-width: 0; }

        .item-title-row {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 14px;
        }

        .item-title {
            margin: 0 0 8px;
            color: var(--cocoa);
            font-size: 19px;
            font-weight: 800;
            line-height: 1.4;
            overflow-wrap: anywhere;
        }

        .item-unit-price {
            color: var(--chocolate);
            font-size: 13px;
        }

        .item-total {
            color: var(--chocolate);
            font-size: 18px;
            font-weight: 800;
            white-space: nowrap;
        }

        .item-total-mobile {
            display: none;
            margin-top: 7px;
            color: var(--chocolate);
            font-weight: 800;
        }

        .item-bottom {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 14px;
            margin-top: 19px;
        }

        .quantity-control {
            display: inline-flex;
            align-items: center;
            gap: 13px;
            padding: 5px;
            border: 1px solid var(--caramel);
            border-radius: 12px;
            background: var(--cream);
        }

        .quantity-control a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 34px;
            height: 34px;
            border-radius: 9px;
            background: var(--chocolate);
            color: var(--cream);
            font-size: 21px;
            font-weight: 700;
            transition: background .2s, transform .2s;
        }

        .quantity-control a:hover {
            background: var(--caramel);
            color: var(--cocoa);
            transform: translateY(-1px);
        }

        .quantity-number {
            min-width: 18px;
            color: var(--cocoa);
            text-align: center;
            font-size: 15px;
            font-weight: 800;
        }

        .remove-link {
            display: inline-block;
            margin-top: 12px;
            color: var(--chocolate);
            font-size: 12px;
            font-weight: 800;
            text-decoration: underline;
            text-decoration-color: var(--caramel);
            text-underline-offset: 4px;
        }

        .remove-link:hover { color: var(--caramel); }

        .cart-actions {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 14px;
            padding: 22px 0;
            border-top: 1px solid var(--caramel);
        }

        .continue-link {
            color: var(--chocolate);
            font-size: 13px;
            font-weight: 800;
        }

        .continue-link:hover { color: var(--caramel); }

        .clear-form { margin: 0; }

        .clear-button {
            padding: 11px 17px;
            border: 1px solid var(--caramel);
            border-radius: 10px;
            background: var(--cream);
            color: var(--chocolate);
            font-size: 12px;
            font-weight: 800;
            cursor: pointer;
        }

        .clear-button:hover {
            background: var(--caramel);
            color: var(--cocoa);
        }

        .summary-card {
            position: sticky;
            top: 24px;
            padding: 26px;
        }

        .summary-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 25px;
        }

        .summary-top h3 {
            margin: 0;
            color: var(--cocoa);
            font-family: "Playfair Display", Georgia, serif;
            font-size: 25px;
        }

        .summary-bag {
            display: grid;
            place-items: center;
            width: 44px;
            height: 44px;
            border-radius: 13px;
            background: var(--chocolate);
            color: var(--cream);
            font-size: 21px;
        }

        .summary-line {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin: 19px 0;
            color: var(--chocolate);
            font-size: 13px;
        }

        .summary-line strong {
            color: var(--cocoa);
            text-align: right;
            white-space: nowrap;
        }

        .discount-value { color: var(--caramel) !important; }

        .coupon-box {
            margin: 22px 0;
            padding: 17px;
            background: var(--cream);
            border: 1px solid var(--caramel);
            border-radius: 13px;
        }

        .coupon-box h4 {
            margin: 0 0 12px;
            color: var(--cocoa);
            font-size: 14px;
        }

        .coupon-form { display: flex; gap: 8px; }

        .coupon-form input {
            width: 100%;
            min-width: 0;
            padding: 11px 9px;
            border: 1px solid var(--caramel);
            border-radius: 8px;
            background: var(--cream);
            color: var(--cocoa);
            text-transform: uppercase;
        }

        .coupon-form input:focus {
            outline: 2px solid var(--caramel);
            outline-offset: 1px;
        }

        .coupon-form button {
            padding: 10px 13px;
            border: 1px solid var(--caramel);
            border-radius: 8px;
            background: var(--chocolate);
            color: var(--cream);
            font-weight: 700;
            cursor: pointer;
        }

        .coupon-form button:hover {
            background: var(--caramel);
            color: var(--cocoa);
        }

        .coupon-success, .coupon-hint {
            margin: 10px 0 0;
            color: var(--chocolate);
            font-size: 12px;
            line-height: 1.6;
        }

        .coupon-hint { font-size: 11px; }

        .savings-box {
            margin: 23px 0;
            padding: 16px;
            border: 1px solid var(--caramel);
            border-radius: 13px;
            background: var(--cream);
        }

        .savings-heading {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 9px;
            color: var(--cocoa);
            font-size: 13px;
            font-weight: 800;
            line-height: 1.5;
        }

        .savings-heading span {
            color: var(--caramel);
            font-size: 19px;
        }

        .savings-message {
            margin: 0;
            color: var(--chocolate);
            font-size: 12px;
            line-height: 1.7;
        }

        .progress-track {
            height: 7px;
            margin-top: 14px;
            overflow: hidden;
            border: 1px solid var(--caramel);
            border-radius: 20px;
            background: var(--cream);
        }

        .progress-fill {
            height: 100%;
            width: <%= progress %>%;
            border-radius: inherit;
            background: var(--caramel);
            transition: width .4s ease;
        }

        .summary-divider {
            border: 0;
            border-top: 1px dashed var(--caramel);
            margin: 24px 0;
        }

        .grand-total {
            align-items: center;
            margin: 20px 0 5px;
            color: var(--cocoa);
            font-size: 15px;
            font-weight: 800;
        }

        .grand-total strong {
            color: var(--chocolate);
            font-size: 25px;
            letter-spacing: -.5px;
        }

        .checkout-button, .browse-button {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
            min-height: 54px;
            margin-top: 23px;
            padding: 14px 18px;
            border: 1px solid var(--caramel);
            border-radius: 12px;
            background: var(--chocolate);
            color: var(--cream);
            text-align: center;
            font-size: 14px;
            font-weight: 800;
            transition: background .2s, color .2s, transform .2s;
        }

        .checkout-button:hover, .browse-button:hover {
            background: var(--caramel);
            color: var(--cocoa);
            transform: translateY(-2px);
        }

        .secure-note {
            margin: 16px 0 0;
            color: var(--chocolate);
            font-size: 11px;
            line-height: 1.7;
            text-align: center;
        }

        .secure-note span {
            color: var(--caramel);
            font-weight: 800;
        }

        .brand-note {
            margin: 15px 0 0;
            color: var(--chocolate);
            font-family: "Playfair Display", Georgia, serif;
            font-size: 12px;
            font-style: italic;
            line-height: 1.7;
            text-align: center;
        }

        .empty-cart {
            padding: 65px 24px;
            text-align: center;
        }

        .empty-illustration {
            display: grid;
            place-items: center;
            width: 100px;
            height: 100px;
            margin: 0 auto 23px;
            border: 1px solid var(--caramel);
            border-radius: 28px;
            background: var(--chocolate);
            color: var(--cream);
            font-size: 43px;
        }

        .empty-cart h2 {
            margin: 0 0 12px;
            color: var(--cocoa);
            font-family: "Playfair Display", Georgia, serif;
            font-size: clamp(25px, 4vw, 32px);
        }

        .empty-cart p {
            max-width: 430px;
            margin: 0 auto;
            color: var(--chocolate);
            font-size: 14px;
            line-height: 1.8;
        }

        .browse-button {
            display: inline-flex;
            width: auto;
            margin-top: 25px;
        }

        @media (max-width: 900px) {
            .cart-layout { grid-template-columns: minmax(0, 1fr); }
            .summary-card { position: static; }
        }

        @media (max-width: 560px) {
            .cart-container {
                width: calc(100% - 26px);
                margin: 28px auto 45px;
            }

            .section-heading h2 { font-size: 24px; }
            .items-panel { padding: 3px 14px; border-radius: 16px; }

            .cart-item {
                grid-template-columns: 91px minmax(0, 1fr);
                align-items: start;
                gap: 12px;
                padding: 19px 0;
            }

            .food-image-wrap {
                width: 91px;
                height: 96px;
                border-radius: 12px;
            }

            .item-title { font-size: 15px; }
            .item-unit-price { font-size: 12px; }
            .item-total { display: none; }
            .item-total-mobile { display: block; font-size: 14px; }
            .item-bottom { margin-top: 12px; }
            .quantity-control { gap: 9px; }

            .quantity-control a {
                width: 29px;
                height: 29px;
            }

            .remove-link { margin-top: 9px; font-size: 11px; }
            .cart-actions { align-items: flex-start; }
            .summary-card { padding: 21px; border-radius: 16px; }
            .summary-top h3 { font-size: 23px; }
            .grand-total strong { font-size: 22px; }
            .empty-cart { padding: 46px 18px; }
        }

        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation: none !important;
                transition: none !important;
                scroll-behavior: auto !important;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/navbar.jsp" />

<main class="cart-container">

    <div class="section-heading">
        <h2>Your selection</h2>
        <div class="cart-count">
            <strong><%= itemCount %></strong>
            item<%= itemCount == 1 ? "" : "s" %>
        </div>
    </div>

    <% if (cart.isEmpty() || itemCount == 0) { %>

        <section class="empty-cart">
            <div class="empty-illustration" aria-hidden="true">🛍️</div>
            <h2>Your cart is waiting for a treat</h2>
            <p>
                You haven't picked your favourites yet.
                Explore our restaurants and discover something delicious.
            </p>
            <a class="browse-button" href="<%= contextPath %>/restaurant">
                Explore Restaurants <span aria-hidden="true">→</span>
            </a>
        </section>

    <% } else { %>

        <div class="cart-layout">

            <section class="items-panel">

                <% for (Map.Entry<Integer, List<CartItem>> restaurantEntry
                        : restaurantGroups.entrySet()) {

                    int groupRestaurantId = restaurantEntry.getKey();
                    List<CartItem> restaurantItems = restaurantEntry.getValue();
                    BigDecimal restaurantSubtotal = BigDecimal.ZERO;

                    for (CartItem groupItem : restaurantItems) {
                        if (groupItem.getPrice() != null) {
                            restaurantSubtotal = restaurantSubtotal.add(
                                groupItem.getPrice().multiply(
                                    BigDecimal.valueOf(groupItem.getQuantity())
                                )
                            );
                        }
                    }
                %>

                    <div class="restaurant-cart-group">

                        <div class="restaurant-cart-heading">
                            <span>
                                🍽️ <%= esc(restaurantNames.get(groupRestaurantId)) %>
                            </span>
                            <small>Separate bill</small>
                        </div>

                        <% for (CartItem item : restaurantItems) {
                            if (item == null || item.getQuantity() <= 0) continue;

                            BigDecimal price = item.getPrice() == null
                                    ? BigDecimal.ZERO : item.getPrice();

                            BigDecimal itemTotal = price.multiply(
                                    BigDecimal.valueOf(item.getQuantity())
                            );

                            String itemName = item.getItemName();
                            String imagePath = safeImage(
                                    item.getImagePath(), contextPath
                            );
                        %>

                            <article class="cart-item">

                                <div class="food-image-wrap">
                                    <img
                                        class="food-image"
                                        src="<%= esc(imagePath) %>"
                                        alt="<%= esc(itemName) %>"
                                        loading="eager"
                                        onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=700&q=80';"
                                    >
                                </div>

                                <div class="item-content">

                                    <div class="item-title-row">
                                        <div>
                                            <h3 class="item-title">
                                                <%= esc(itemName) %>
                                            </h3>

                                            <div class="item-unit-price">
                                                ₹<%= price.setScale(2, RoundingMode.HALF_UP) %>
                                                per item
                                            </div>

                                            <div class="item-total-mobile">
                                                ₹<%= itemTotal.setScale(2, RoundingMode.HALF_UP) %>
                                            </div>
                                        </div>

                                        <div class="item-total">
                                            ₹<%= itemTotal.setScale(2, RoundingMode.HALF_UP) %>
                                        </div>
                                    </div>

                                    <div class="item-bottom">
                                        <div class="quantity-control">
                                            <a
                                                href="<%= contextPath %>/cart?action=decrease&amp;menuId=<%= item.getMenuId() %>"
                                                aria-label="Decrease quantity"
                                                title="Decrease quantity"
                                            >−</a>

                                            <span class="quantity-number">
                                                <%= item.getQuantity() %>
                                            </span>

                                            <a
                                                href="<%= contextPath %>/cart?action=increase&amp;menuId=<%= item.getMenuId() %>"
                                                aria-label="Increase quantity"
                                                title="Increase quantity"
                                            >+</a>
                                        </div>
                                    </div>

                                    <a
                                        class="remove-link"
                                        href="<%= contextPath %>/cart?action=remove&amp;menuId=<%= item.getMenuId() %>"
                                        onclick="return confirm('Remove this item from your cart?');"
                                    >Remove item</a>

                                </div>
                            </article>

                        <% } %>

                        <div class="restaurant-cart-bill">
                            <span>Restaurant subtotal</span>
                            <strong>
                                ₹<%= restaurantSubtotal.setScale(2, RoundingMode.HALF_UP) %>
                            </strong>
                        </div>

                        <div class="restaurant-cart-bill">
                            <span>Delivery fee</span>
                            <strong>₹40.00</strong>
                        </div>

                    </div>

                <% } %>

                <div class="cart-actions">
                    <a class="continue-link" href="<%= contextPath %>/restaurant">
                        ← Continue shopping
                    </a>

                    <form
                        class="clear-form"
                        action="<%= contextPath %>/cart"
                        method="get"
                        onsubmit="return confirm('Are you sure you want to clear your entire cart?');"
                    >
                        <input type="hidden" name="action" value="clear">
                        <button class="clear-button" type="submit">Clear All</button>
                    </form>
                </div>

            </section>

            <aside class="summary-card">

                <div class="summary-top">
                    <h3>Order Summary</h3>
                    <div class="summary-bag" aria-hidden="true">🛍️</div>
                </div>

                <div class="summary-line">
                    <span>
                        Items (<%= itemCount %>) ·
                        <%= restaurantGroups.size() %> restaurant(s)
                    </span>
                    <strong>
                        ₹<%= subtotal.setScale(2, RoundingMode.HALF_UP) %>
                    </strong>
                </div>

                <div class="summary-line">
                    <span>Delivery fee</span>
                    <strong>
                        ₹<%= deliveryFee.setScale(2, RoundingMode.HALF_UP) %>
                    </strong>
                </div>

                <div class="coupon-box">
                    <h4>Have a coupon code?</h4>

                    <form
                        action="<%= contextPath %>/cart"
                        method="get"
                        class="coupon-form"
                    >
                        <input type="hidden" name="action" value="applyCoupon">

                        <input
                            type="text"
                            name="couponCode"
                            placeholder="Enter coupon code"
                            value="<%= couponCode == null ? "" : esc(couponCode) %>"
                            maxlength="30"
                            autocomplete="off"
                            aria-label="Coupon code"
                            required
                        >

                        <button type="submit">Apply</button>
                    </form>

                    <% if (couponMessage != null && !couponMessage.isEmpty()) { %>
                        <p class="coupon-success" role="status">
                            <%= esc(couponMessage) %>
                        </p>
                    <% } %>

                    <p class="coupon-hint">
                        Try YUM10, FEAST100 or YUMLOVE15.
                    </p>
                </div>

                <% if (couponDiscount.compareTo(BigDecimal.ZERO) > 0) { %>
                    <div class="summary-line">
                        <span>Coupon discount (<%= esc(couponCode) %>)</span>
                        <strong class="discount-value">
                            − ₹<%= couponDiscount.setScale(2, RoundingMode.HALF_UP) %>
                        </strong>
                    </div>
                <% } %>

                <div class="summary-line">
                    <span>Your discount</span>
                    <strong class="discount-value">
                        − ₹<%= discount.setScale(2, RoundingMode.HALF_UP) %>
                    </strong>
                </div>

                <div class="savings-box">
                    <div class="savings-heading">
                        <span aria-hidden="true">✦</span>
                        <% if (discount.compareTo(BigDecimal.ZERO) > 0) { %>
                            You've unlocked ₹40 off!
                        <% } else { %>
                            Unlock ₹40 off your order
                        <% } %>
                    </div>

                    <p class="savings-message">
                        <% if (discount.compareTo(BigDecimal.ZERO) > 0) { %>
                            Great choice! Your existing cart discount has been applied.
                        <% } else { %>
                            Add ₹<%= remaining.setScale(2, RoundingMode.HALF_UP) %>
                            more to unlock ₹40 off.
                        <% } %>
                    </p>

                    <div
                        class="progress-track"
                        role="progressbar"
                        aria-label="Progress towards discount"
                        aria-valuemin="0"
                        aria-valuemax="499"
                        aria-valuenow="<%= subtotal.compareTo(targetAmount) >= 0 ? 499 : subtotal.intValue() %>"
                    >
                        <div class="progress-fill"></div>
                    </div>
                </div>

                <hr class="summary-divider">

                <div class="summary-line grand-total">
                    <span>Total</span>
                    <strong>
                        ₹<%= grandTotal.setScale(2, RoundingMode.HALF_UP) %>
                    </strong>
                </div>

                <a
                    href="<%= contextPath %>/checkout"
                    class="checkout-button"
                >
                    Proceed to Checkout <span aria-hidden="true">→</span>
                </a>

                <p class="secure-note">
                    <span aria-hidden="true">✓</span>
                    Fresh food. Easy ordering.
                </p>

                <p class="brand-note">
                    Fresh cravings. Happy moments. That's Yumlet.
                </p>

            </aside>

        </div>

    <% } %>

</main>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
