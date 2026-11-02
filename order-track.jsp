
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Order" %>

<%
    String contextPath = request.getContextPath();
    List<Order> orders = (List<Order>) request.getAttribute("orders");
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
        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #4B2E1F;
            color: #FFF8ED;
        }

        .orders-page {
            min-height: 70vh;
            padding: 45px 20px 65px;
        }

        .orders-container {
            width: 100%;
            max-width: 1050px;
            margin: auto;
        }

        .orders-heading {
            margin-bottom: 30px;
        }

        .orders-eyebrow {
            margin: 0 0 8px;
            color: #D8AD78;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 2px;
        }

        .orders-heading h1 {
            margin: 0 0 10px;
            color: #FFF8ED;
            font-size: clamp(28px, 4vw, 38px);
            font-weight: 900;
        }

        .orders-heading p {
            margin: 0;
            color: #E3D0BB;
            font-size: 14px;
            line-height: 1.7;
        }

        .orders-list {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
        }

        .order-card {
            padding: 24px;
            color: #4B2E1F;
            background: #FFF8ED;
            border: 1px solid #E7D5BD;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, .18);
            transition: transform .2s ease, box-shadow .2s ease;
        }

        .order-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 28px rgba(0, 0, 0, .25);
        }

        .order-card-top {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            padding-bottom: 18px;
            border-bottom: 1px solid #E9DED2;
        }

        .order-label {
            display: block;
            margin-bottom: 7px;
            color: #8C7564;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1px;
        }

        .order-id {
            color: #4B2E1F;
            font-size: 17px;
            font-weight: 900;
            overflow-wrap: anywhere;
        }

        .order-status {
            display: inline-block;
            padding: 8px 11px;
            color: #4B2E1F;
            background: #F0E1CC;
            border-radius: 25px;
            font-size: 11px;
            font-weight: 800;
            text-align: center;
            overflow-wrap: anywhere;
        }

        .order-info {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px 12px;
            padding: 20px 0;
        }

        .info-label {
            display: block;
            margin-bottom: 7px;
            color: #8C7564;
            font-size: 11px;
        }

        .info-value {
            display: block;
            color: #4B2E1F;
            font-size: 14px;
            font-weight: 800;
            overflow-wrap: anywhere;
        }

        .info-value.amount {
            color: #9A572D;
            font-size: 19px;
        }

        .order-actions {
            display: flex;
            gap: 10px;
            padding-top: 17px;
            border-top: 1px solid #E9DED2;
        }

        .order-btn {
            display: inline-flex;
            flex: 1;
            align-items: center;
            justify-content: center;
            min-height: 43px;
            padding: 11px 14px;
            border: 1px solid #4B2E1F;
            border-radius: 9px;
            font-size: 12px;
            font-weight: 800;
            text-decoration: none;
            text-align: center;
            transition: .2s ease;
        }

        .track-btn {
            color: #FFF8ED;
            background: #4B2E1F;
        }

        .track-btn:hover {
            background: #301B12;
        }

        .browse-btn {
            color: #4B2E1F;
            background: transparent;
        }

        .browse-btn:hover {
            background: #F3E3CA;
        }

        .empty-orders {
            padding: 55px 22px;
            color: #4B2E1F;
            background: #FFF8ED;
            border: 1px solid #E7D5BD;
            border-radius: 20px;
            text-align: center;
            box-shadow: 0 8px 24px rgba(0, 0, 0, .18);
        }

        .empty-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 75px;
            height: 75px;
            margin: 0 auto 20px;
            color: #FFF8ED;
            background: #4B2E1F;
            border-radius: 50%;
            font-size: 30px;
        }

        .empty-orders h2 {
            margin: 0 0 10px;
            color: #4B2E1F;
            font-size: 24px;
        }

        .empty-orders p {
            max-width: 390px;
            margin: 0 auto 23px;
            color: #8C7564;
            font-size: 14px;
            line-height: 1.7;
        }

        .empty-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 13px 22px;
            color: #FFF8ED;
            background: #4B2E1F;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 800;
            text-decoration: none;
        }

        .empty-btn:hover { background: #301B12; }

        @media (max-width: 720px) {
            .orders-list { grid-template-columns: 1fr; }
            .orders-page { padding: 30px 14px 45px; }
        }

        @media (max-width: 420px) {
            .order-card { padding: 18px; }
            .order-actions { flex-direction: column; }
            .order-btn { width: 100%; }
            .order-status { max-width: 120px; }
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
            </header>

            <% if (orders == null || orders.isEmpty()) { %>

                <section class="empty-orders">
                    <div class="empty-icon" aria-hidden="true">🍽</div>
                    <h2>No orders yet</h2>
                    <p>
                        Looks like you haven't placed an order yet.
                        Explore restaurants and find something delicious!
                    </p>
                    <a class="empty-btn"
                       href="<%= contextPath %>/restaurant">
                        Explore Restaurants →
                    </a>
                </section>

            <% } else { %>

                <section class="orders-list">

                    <% for (Order order : orders) { %>

                        <article class="order-card">

                            <div class="order-card-top">
                                <div>
                                    <span class="order-label">ORDER NUMBER</span>
                                    <div class="order-id">
                                        #<%= order.getOrderId() %>
                                    </div>
                                </div>

                                <span class="order-status">
                                    <%= order.getStatus() == null
                                        ? "Placed" : order.getStatus() %>
                                </span>
                            </div>

                            <div class="order-info">

                                <div>
                                    <span class="info-label">Order Date</span>
                                    <span class="info-value">
                                        <%= order.getOrderDate() == null
                                            ? "Not available"
                                            : order.getOrderDate() %>
                                    </span>
                                </div>

                                <div>
                                    <span class="info-label">Total Amount</span>
                                    <span class="info-value amount">
                                        ₹<%= order.getTotalAmount() %>
                                    </span>
                                </div>

                                <div>
                                    <span class="info-label">Payment Method</span>
                                    <span class="info-value">
                                        <%= order.getPaymentMode() == null
                                            ? "Not specified"
                                            : order.getPaymentMode() %>
                                    </span>
                                </div>

                                <div>
                                    <span class="info-label">Restaurant ID</span>
                                    <span class="info-value">
                                        #<%= order.getRestaurantId() %>
                                    </span>
                                </div>

                            </div>

                            <div class="order-actions">
                                <a class="order-btn track-btn"
                                   href="<%= contextPath %>/track-order?orderId=<%= order.getOrderId() %>">
                                    Track Order →
                                </a>

                                <a class="order-btn browse-btn"
                                   href="<%= contextPath %>/restaurant">
                                    Order Again
                                </a>
                            </div>

                        </article>

                    <% } %>

                </section>

            <% } %>

        </div>
    </main>

    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
