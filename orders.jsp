
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>

<%!
    private String escapeOrderHtml(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private BigDecimal orderAmount(Object value) {
        if (value == null) return BigDecimal.ZERO;
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }
%>

<%
    String contextPath = request.getContextPath();

    List<Map<String, Object>> orders =
        (List<Map<String, Object>>) request.getAttribute("orders");

    if (orders == null) {
        orders = new ArrayList<Map<String, Object>>();
    }

    String error = (String) request.getAttribute("error");

    Boolean loginStatus = (Boolean) request.getAttribute("isLoggedIn");
    boolean isLoggedIn = loginStatus != null
            ? loginStatus.booleanValue()
            : session.getAttribute("userId") != null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders | Yumlet</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/common.css">
    <link rel="stylesheet" href="<%= contextPath %>/css/navbar.css">
    <link rel="stylesheet" href="<%= contextPath %>/css/footer.css">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #3B2115;
            color: #FFF5E7;
        }

        .orders-page {
            min-height: 70vh;
            padding: 38px 20px 55px;
            background:
                radial-gradient(ellipse at top left, #57321F 0%, transparent 55%),
                linear-gradient(135deg, #492817, #351C11);
        }

        .orders-container {
            width: 100%;
            max-width: 1040px;
            margin: 0 auto;
        }

        .orders-heading {
            margin-bottom: 28px;
        }

        .orders-eyebrow {
            margin: 0 0 9px;
            color: #EAB77A;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 2px;
        }

        .orders-heading h1 {
            margin: 0 0 10px;
            color: #FFF5E7;
            font-size: clamp(30px, 4vw, 42px);
            font-weight: 900;
        }

        .orders-heading p {
            margin: 0;
            color: #E5CEB7;
            font-size: 14px;
            line-height: 1.7;
        }

        .favourites-link {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            margin-top: 15px;
            color: #EAB77A;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            transition: color .2s ease;
        }

        .favourites-link:hover {
            color: #FFD6A6;
        }

        .favourites-link svg {
            width: 17px;
            height: 17px;
            fill: none;
            stroke: currentColor;
            stroke-width: 1.8;
        }

        .error-message {
            margin-bottom: 22px;
            padding: 14px 16px;
            color: #8E2B22;
            background: #FBE7E3;
            border: 1px solid #EBC7BA;
            border-radius: 9px;
            font-size: 13px;
        }

        .orders-list {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .order-card {
            min-width: 0;
            overflow: hidden;
            color: #432719;
            background: linear-gradient(135deg, #FFF5E5, #F8E7CE);
            border: 1px solid #E7D1B3;
            border-radius: 13px;
            box-shadow: 0 7px 22px rgba(0, 0, 0, .18);
            transition: transform .2s ease, box-shadow .2s ease;
        }

        .order-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 28px rgba(0, 0, 0, .26);
        }

        .order-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            padding: 19px 20px;
            background: #F1DEC4;
            border-bottom: 1px solid #E3CDB1;
        }

        .order-number {
            margin-bottom: 7px;
            color: #492817;
            font-size: 17px;
            font-weight: 900;
            overflow-wrap: anywhere;
        }

        .order-date {
            color: #806B58;
            font-size: 12px;
            line-height: 1.5;
        }

        .status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            max-width: 145px;
            padding: 8px 11px;
            color: #70421F;
            background: #F0D3B2;
            border-radius: 30px;
            font-size: 10px;
            font-weight: 800;
            text-align: center;
            overflow-wrap: anywhere;
        }

        .status::before {
            content: "";
            width: 7px;
            height: 7px;
            flex: 0 0 7px;
            background: currentColor;
            border-radius: 50%;
        }

        .status.delivered {
            color: #31652E;
            background: #D7E7C6;
        }

        .status.preparing {
            color: #A85F22;
            background: #F3D4B6;
        }

        .status.out-for-delivery {
            color: #57592A;
            background: #E5E3C6;
        }

        .status.cancelled,
        .status.failed {
            color: #A42F27;
            background: #F6D0C8;
        }

        .status.pending {
            color: #85520A;
            background: #FFF0D6;
        }

        .order-body {
            padding: 20px;
        }

        .restaurant-name {
            margin-bottom: 16px;
            color: #492817;
            font-size: 19px;
            font-weight: 900;
            overflow-wrap: anywhere;
        }

        .order-items {
            border-top: 1px solid #E8D7C0;
        }

        .order-item {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px solid #E8D7C0;
        }

        .item-name {
            color: #59483C;
            font-size: 13px;
            line-height: 1.5;
            overflow-wrap: anywhere;
        }

        .item-price {
            color: #482B1B;
            font-size: 13px;
            font-weight: 800;
            white-space: nowrap;
        }

        .no-items {
            padding: 12px 0;
            color: #806B58;
            font-size: 12px;
            line-height: 1.6;
        }

        .order-summary {
            margin-top: 17px;
            padding-top: 5px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            margin: 12px 0;
            font-size: 12px;
        }

        .summary-label {
            color: #806B58;
        }

        .summary-value {
            color: #432719;
            font-weight: 700;
            text-align: right;
            overflow-wrap: anywhere;
        }

        .total-row {
            margin-top: 17px;
            padding-top: 15px;
            border-top: 1px dashed #D9C4AD;
        }

        .total-row .summary-label {
            color: #492817;
            font-size: 14px;
            font-weight: 800;
        }

        .total-row .summary-value {
            color: #96532D;
            font-size: 19px;
            font-weight: 900;
        }

        .order-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            padding-top: 16px;
            border-top: 1px solid #E3D1BB;
        }

        .order-btn {
            display: inline-flex;
            flex: 1;
            align-items: center;
            justify-content: center;
            min-width: 0;
            min-height: 42px;
            padding: 10px 9px;
            border: 1px solid #61351F;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 800;
            text-align: center;
            text-decoration: none;
            transition: background .2s ease, color .2s ease;
        }

        .track-link {
            color: #FFF5E7;
            background: #542D19;
        }

        .track-link:hover {
            background: #351B10;
        }

        .browse-link {
            color: #542D19;
            background: transparent;
        }

        .browse-link:hover {
            background: #EED8BC;
        }

        .message-box {
            max-width: 600px;
            margin: 15px auto;
            padding: 42px 24px;
            color: #492817;
            background: linear-gradient(135deg, #FFF5E5, #F8E7CE);
            border: 1px solid #E7D1B3;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 8px 25px rgba(0, 0, 0, .2);
        }

        .empty-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 72px;
            height: 72px;
            margin: 0 auto 19px;
            color: #FFF5E7;
            background: #542D19;
            border-radius: 50%;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: .5px;
        }

        .message-box h2 {
            margin: 0 0 11px;
            color: #492817;
            font-size: 23px;
        }

        .message-box p {
            max-width: 400px;
            margin: 0 auto 23px;
            color: #806B58;
            font-size: 13px;
            line-height: 1.8;
        }

        .action-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin: 5px;
            padding: 12px 19px;
            color: #FFF5E7;
            background: #542D19;
            border: 1px solid #542D19;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 800;
            text-decoration: none;
            transition: background .2s ease;
        }

        .action-link:hover {
            background: #351B10;
        }

        .secondary-link {
            color: #542D19;
            background: transparent;
        }

        .secondary-link:hover {
            color: #351B10;
            background: #EED8BC;
        }

        .food-prompt {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 245px;
            padding: 24px 17px;
            border: 1px solid rgba(255, 245, 231, .17);
            border-radius: 13px;
            text-align: center;
            background: rgba(255, 255, 255, .015);
        }

        .food-art {
            margin-bottom: 14px;
            color: #EAB77A;
            font-size: 43px;
        }

        .food-prompt h2 {
            margin: 0 0 9px;
            color: #FFF1DF;
            font-size: 20px;
        }

        .food-prompt p {
            margin: 0 0 18px;
            color: #E2CBB3;
            font-size: 12px;
            line-height: 1.7;
        }

        .food-prompt a {
            display: inline-block;
            padding: 12px 17px;
            color: #462716;
            background: #EFC18C;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 800;
            text-decoration: none;
        }

        .food-prompt a:hover {
            background: #FFD6A6;
        }

        @media (max-width: 760px) {
            .orders-page {
                padding: 29px 14px 42px;
            }

            .orders-list {
                grid-template-columns: 1fr;
            }

            .food-prompt {
                min-height: 190px;
            }
        }

        @media (max-width: 420px) {
            .order-header,
            .order-body {
                padding: 16px;
            }

            .order-number {
                font-size: 15px;
            }

            .order-actions {
                flex-direction: column;
            }

            .order-btn {
                width: 100%;
            }

            .message-box {
                padding: 32px 17px;
            }

            .message-box h2 {
                font-size: 21px;
            }

            .action-link {
                margin: 5px 0;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="/includes/navbar.jsp" />

    <main class="orders-page">
        <div class="orders-container">

            <header class="orders-heading">
                <p class="orders-eyebrow">YOUR YUMLET JOURNEY</p>
                <h1>My Orders</h1>
                <p>All your delicious moments, together in one place.</p>

                <a class="favourites-link"
                   href="<%= contextPath %>/favourites.jsp"
                   aria-label="View favourites">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8z"/>
                    </svg>
                    <span>Favourites</span>
                </a>
            </header>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="error-message">
                    <%= escapeOrderHtml(error) %>
                </div>
            <% } %>

            <% if (!isLoggedIn) { %>

                <section class="message-box">
                    <div class="empty-icon">ORDERS</div>
                    <h2>Please log in to view your orders</h2>
                    <p>
                        Your order history will be available here after you log in.
                    </p>

                    <a class="action-link"
                       href="<%= contextPath %>/login.jsp?from=orders">
                        Log In
                    </a>

                    <a class="action-link secondary-link"
                       href="<%= contextPath %>/restaurant">
                        Explore Restaurants
                    </a>
                </section>

            <% } else if (orders.isEmpty()) { %>

                <section class="message-box">
                    <div class="empty-icon">ORDERS</div>
                    <h2>No orders yet</h2>
                    <p>
                        You haven't placed any orders yet.
                        Explore restaurants and find something delicious!
                    </p>

                    <a class="action-link"
                       href="<%= contextPath %>/restaurant">
                        Explore Restaurants →
                    </a>
                </section>

            <% } else { %>

                <section class="orders-list">

                    <% for (Map<String, Object> order : orders) {

                        String orderId = escapeOrderHtml(order.get("orderId"));

                        String restaurantName = order.get("restaurantName") == null
                                ? "Restaurant"
                                : escapeOrderHtml(order.get("restaurantName"));

                        String orderDate = order.get("orderDate") == null
                                ? "Date unavailable"
                                : escapeOrderHtml(order.get("orderDate"));

                        String status = order.get("status") == null
                                ? "PLACED"
                                : String.valueOf(order.get("status"));

                        String safeStatus = escapeOrderHtml(status);
                        String normalizedStatus = status.trim().toLowerCase();

                        String statusClass =
                                normalizedStatus.contains("deliver") ? "delivered" :
                                normalizedStatus.contains("prepar") ||
                                normalizedStatus.contains("confirm") ? "preparing" :
                                normalizedStatus.contains("out for delivery") ||
                                normalizedStatus.contains("on the way") ? "out-for-delivery" :
                                normalizedStatus.contains("cancel") ? "cancelled" :
                                normalizedStatus.contains("fail") ? "failed" :
                                normalizedStatus.contains("pending") ||
                                normalizedStatus.contains("placed") ? "pending" : "";

                        String paymentMode = order.get("paymentMode") == null
                                ? "Not specified"
                                : escapeOrderHtml(order.get("paymentMode"));

                        BigDecimal total = orderAmount(order.get("totalAmount"));

                        List<Map<String, Object>> items =
                                (List<Map<String, Object>>) order.get("items");

                        if (items == null) {
                            items = new ArrayList<Map<String, Object>>();
                        }

                        String rawOrderId = String.valueOf(
                                order.get("orderId") == null
                                ? "" : order.get("orderId"));
                    %>

                        <article class="order-card">

                            <div class="order-header">
                                <div>
                                    <div class="order-number">
                                        Order #<%= orderId %>
                                    </div>
                                    <div class="order-date">
                                        <%= orderDate %>
                                    </div>
                                </div>

                                <span class="status <%= statusClass %>">
                                    <%= safeStatus.replace("_", " ") %>
                                </span>
                            </div>

                            <div class="order-body">

                                <div class="restaurant-name">
                                    <%= restaurantName %>
                                </div>

                                <div class="order-items">
                                    <% if (items.isEmpty()) { %>

                                        <div class="no-items">
                                            Item details are not available for this order.
                                        </div>

                                    <% } else { %>

                                        <% for (Map<String, Object> item : items) {

                                            String itemName = item.get("itemName") == null
                                                    ? "Food item"
                                                    : escapeOrderHtml(item.get("itemName"));

                                            BigDecimal itemTotal =
                                                    orderAmount(item.get("totalAmount"));
                                        %>

                                            <div class="order-item">
                                                <span class="item-name">
                                                    <%= itemName %>
                                                </span>

                                                <span class="item-price">
                                                    ₹<%= itemTotal.toPlainString() %>
                                                </span>
                                            </div>

                                        <% } %>

                                    <% } %>
                                </div>

                                <div class="order-summary">

                                    <div class="summary-row total-row">
                                        <span class="summary-label">
                                            Total Amount
                                        </span>

                                        <span class="summary-value">
                                            ₹<%= total.toPlainString() %>
                                        </span>
                                    </div>

                                    <div class="summary-row">
                                        <span class="summary-label">
                                            Payment method
                                        </span>

                                        <span class="summary-value">
                                            <%= paymentMode %>
                                        </span>
                                    </div>

                                </div>

                                <div class="order-actions">

                                    <a class="order-btn track-link"
                                       href="<%= contextPath %>/track-order?orderId=<%= java.net.URLEncoder.encode(rawOrderId, "UTF-8") %>">
                                        Track Order →
                                    </a>

                                    <a class="order-btn browse-link"
                                       href="<%= contextPath %>/restaurant">
                                        Order Again
                                    </a>

                                </div>

                            </div>
                        </article>

                    <% } %>

                    <section class="food-prompt">
                        <div class="food-art" aria-hidden="true">♨</div>
                        <h2>Enjoy great food!</h2>
                        <p>Your next delicious order is just a click away.</p>

                        <a href="<%= contextPath %>/restaurant">
                            Explore Restaurants →
                        </a>
                    </section>

                </section>

            <% } %>

        </div>
    </main>

    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
