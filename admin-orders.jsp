
<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.tap.controllers.AdminOrderController.OrderData" %>

<%!
    private String esc(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String safeImage(String image) {
        if (image == null || image.trim().isEmpty()) {
            return "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=500&q=80";
        }

        String trimmed = image.trim();

        if (trimmed.startsWith("https://") || trimmed.startsWith("http://")) {
            return esc(trimmed);
        }

        return "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=500&q=80";
    }

    private String statusClass(String status) {
        if (status == null) return "placed";

        switch (status) {
            case "PREPARING":
                return "preparing";
            case "OUT_FOR_DELIVERY":
                return "delivery";
            case "DELIVERED":
                return "delivered";
            case "CANCELLED":
                return "cancelled";
            default:
                return "placed";
        }
    }

    private String statusLabel(String status) {
        if (status == null || status.trim().isEmpty()) {
            return "Unknown";
        }

        return status.replace("_", " ");
    }
%>

<%
    String contextPath = request.getContextPath();

    List<OrderData> orders =
        (List<OrderData>) request.getAttribute("adminOrders");

    if (orders == null) {
        response.sendRedirect(contextPath + "/admin-orders");
        return;
    }

    SimpleDateFormat dateFormat =
        new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Manage Orders | Yumlet</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/common.css">

    <link rel="stylesheet"
          href="<%= contextPath %>/css/navbar.css">

    <link rel="stylesheet"
          href="<%= contextPath %>/css/footer.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&display=swap"
          rel="stylesheet">

    <style>
        :root {
            --brown: #48230F;
            --brown-dark: #30170D;
            --cream: #F5E9D8;
            --cream-dark: #D9C4AD;
            --caramel: #B87545;
            --muted: #8C7564;
            --border: #E9DACA;
            --white: #FFFFFF;
            --green: #28764B;
            --green-bg: #EAF5EC;
            --orange: #A96522;
            --orange-bg: #FFF1DE;
            --blue: #4268A8;
            --blue-bg: #EAF0FC;
            --red: #B53E36;
            --red-bg: #FFF0EE;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #FBF6EF;
            color: var(--brown-dark);
            font-family: "DM Sans", sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        button,
        select {
            font: inherit;
        }

        .page {
            width: min(1200px, 92%);
            min-height: 60vh;
            margin: 0 auto;
            padding: 46px 0 76px;
        }

        /* Header */

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 22px;
            margin-bottom: 30px;
        }

        .eyebrow {
            margin: 0 0 9px;
            color: var(--caramel);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        .page-header h1 {
            margin: 0;
            color: var(--brown);
            font: 800 clamp(30px, 4vw, 42px)/1.15 "Playfair Display", serif;
        }

        .page-header p {
            max-width: 600px;
            margin: 11px 0 0;
            color: var(--muted);
            font-size: 14px;
            line-height: 1.7;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .admin-badge,
        .order-count {
            display: inline-flex;
            min-height: 39px;
            align-items: center;
            justify-content: center;
            padding: 9px 15px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .admin-badge {
            border: 1px solid var(--border);
            background: var(--white);
            color: var(--brown);
        }

        .order-count {
            background: var(--brown);
            color: var(--white);
        }

        /* Update message */

        .updated {
            margin-bottom: 22px;
            padding: 14px 17px;
            border: 1px solid #CDE4D3;
            border-radius: 12px;
            background: var(--green-bg);
            color: var(--green);
            font-size: 13px;
            font-weight: 700;
        }

        /* Order card */

        .order-card {
            margin-bottom: 20px;
            overflow: hidden;
            border: 1px solid var(--border);
            border-radius: 18px;
            background: var(--white);
            box-shadow: 0 8px 25px rgba(72, 35, 15, .045);
        }

        .order-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            padding: 22px 24px;
            border-bottom: 1px solid var(--border);
        }

        .restaurant-info {
            display: flex;
            align-items: center;
            gap: 15px;
            min-width: 0;
        }

        .restaurant-img {
            width: 64px;
            height: 64px;
            flex: 0 0 64px;
            border-radius: 13px;
            object-fit: cover;
            background: var(--cream);
        }

        .restaurant-info h2 {
            margin: 0 0 6px;
            color: var(--brown);
            font-size: 17px;
            font-weight: 800;
            overflow-wrap: anywhere;
        }

        .restaurant-info p {
            margin: 0;
            color: var(--muted);
            font-size: 12px;
        }

        /* Status */

        .status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 12px;
            border-radius: 999px;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: .3px;
            text-align: center;
            white-space: nowrap;
        }

        .status-placed {
            background: #F8EBDD;
            color: var(--brown);
        }

        .status-preparing {
            background: var(--orange-bg);
            color: var(--orange);
        }

        .status-delivery {
            background: var(--blue-bg);
            color: var(--blue);
        }

        .status-delivered {
            background: var(--green-bg);
            color: var(--green);
        }

        .status-cancelled {
            background: var(--red-bg);
            color: var(--red);
        }

        /* Order details */

        .order-body {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 25px 22px;
            padding: 25px 24px;
        }

        .detail {
            min-width: 0;
        }

        .detail-label {
            margin-bottom: 8px;
            color: var(--muted);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: .8px;
            text-transform: uppercase;
        }

        .detail-value {
            color: var(--brown-dark);
            font-size: 13px;
            font-weight: 700;
            line-height: 1.7;
            overflow-wrap: anywhere;
            white-space: normal;
        }

        .amount {
            color: var(--brown);
            font-size: 18px;
            font-weight: 800;
        }

        /* Update status */

        .order-action {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            padding: 18px 24px;
            border-top: 1px solid var(--border);
            background: #FCF8F2;
        }

        .action-title {
            color: var(--brown);
            font-size: 13px;
            font-weight: 800;
        }

        .action-subtitle {
            margin-top: 5px;
            color: var(--muted);
            font-size: 11px;
            line-height: 1.5;
        }

        .status-form {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-select {
            min-width: 185px;
            min-height: 42px;
            padding: 10px 12px;
            border: 1px solid var(--cream-dark);
            border-radius: 9px;
            outline: none;
            background: var(--white);
            color: var(--brown);
            font-size: 12px;
            font-weight: 700;
        }

        .status-select:focus {
            border-color: var(--caramel);
            box-shadow: 0 0 0 3px rgba(184, 117, 69, .12);
        }

        .update-btn {
            min-height: 42px;
            padding: 11px 16px;
            border: 0;
            border-radius: 9px;
            background: var(--brown);
            color: var(--white);
            cursor: pointer;
            font-size: 12px;
            font-weight: 800;
            transition: background .2s, transform .2s;
        }

        .update-btn:hover {
            transform: translateY(-1px);
            background: var(--caramel);
        }

        .update-btn:focus-visible,
        .status-select:focus-visible {
            outline: 3px solid rgba(184, 117, 69, .3);
            outline-offset: 2px;
        }

        /* Empty state */

        .empty {
            padding: 70px 24px;
            border: 1px solid var(--border);
            border-radius: 18px;
            background: var(--white);
            text-align: center;
        }

        .empty-mark {
            display: grid;
            width: 68px;
            height: 68px;
            margin: 0 auto 20px;
            place-items: center;
            border-radius: 50%;
            background: var(--cream);
            color: var(--brown);
            font-size: 25px;
            font-weight: 800;
        }

        .empty h2 {
            margin: 0 0 10px;
            color: var(--brown);
            font: 700 25px "Playfair Display", serif;
        }

        .empty p {
            margin: 0;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.7;
        }

        /* Responsive */

        @media (max-width: 850px) {
            .order-body {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .order-action {
                align-items: flex-start;
                flex-direction: column;
            }

            .status-form {
                width: 100%;
            }

            .status-select {
                flex: 1;
                min-width: 0;
            }
        }

        @media (max-width: 600px) {
            .page {
                width: 92%;
                padding: 32px 0 55px;
            }

            .page-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .page-header h1 {
                font-size: 32px;
            }

            .header-right {
                width: 100%;
            }

            .order-top {
                align-items: flex-start;
                flex-direction: column;
                padding: 18px;
            }

            .restaurant-img {
                width: 54px;
                height: 54px;
                flex-basis: 54px;
            }

            .order-body {
                grid-template-columns: 1fr;
                gap: 18px;
                padding: 21px 18px;
            }

            .order-action {
                padding: 18px;
            }

            .status-form {
                align-items: stretch;
                flex-direction: column;
            }

            .status-select,
            .update-btn {
                width: 100%;
                min-height: 44px;
            }

            .status {
                white-space: normal;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="/includes/navbar.jsp" />

    <main class="page">

        <header class="page-header">
            <div>
                <p class="eyebrow">YUMLET ADMIN</p>
                <h1>Manage Orders</h1>
                <p>
                    Monitor customer orders and keep delivery progress up to date.
                </p>
            </div>

            <div class="header-right">
                <span class="admin-badge">Admin Dashboard</span>
                <span class="order-count">
                    <%= orders.size() %> Orders
                </span>
            </div>
        </header>

        <% if ("true".equals(request.getParameter("updated"))) { %>
            <div class="updated" role="status">
                Order status updated successfully.
            </div>
        <% } %>

        <% if (orders.isEmpty()) { %>

            <section class="empty">
                <div class="empty-mark" aria-hidden="true">0</div>
                <h2>No orders yet</h2>
                <p>New customer orders will appear here when they are placed.</p>
            </section>

        <% } else { %>

            <% for (OrderData order : orders) {
                if (order == null) continue;

                String currentStatus = order.status == null
                    ? "PLACED" : order.status;

                String currentPayment = order.paymentMode == null
                    ? "Not available" : order.paymentMode;
            %>

                <article class="order-card">

                    <header class="order-top">
                        <div class="restaurant-info">

                            <img
                                src="<%= safeImage(order.restaurantImage) %>"
                                class="restaurant-img"
                                alt="<%= esc(order.restaurantName) %>"
                                loading="lazy"
                                onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=500&q=80';">

                            <div>
                                <h2>
                                    <%= esc(order.restaurantName == null
                                        ? "Restaurant" : order.restaurantName) %>
                                </h2>

                                <p>
                                    Order #<%= order.orderId %>
                                </p>
                            </div>
                        </div>

                        <span class="status status-<%= statusClass(currentStatus) %>">
                            <%= esc(statusLabel(currentStatus)) %>
                        </span>
                    </header>

                    <section class="order-body">

                        <div class="detail">
                            <div class="detail-label">Customer</div>
                            <div class="detail-value">
                                <%= esc(order.username == null
                                    ? "Not available" : order.username) %>
                            </div>
                        </div>

                        <div class="detail">
                            <div class="detail-label">Phone</div>
                            <div class="detail-value">
                                <%= esc(order.phone == null || order.phone.trim().isEmpty()
                                    ? "Not available" : order.phone) %>
                            </div>
                        </div>

                        <div class="detail">
                            <div class="detail-label">Order Date</div>
                            <div class="detail-value">
                                <%= order.orderDate != null
                                    ? dateFormat.format(order.orderDate)
                                    : "Not available" %>
                            </div>
                        </div>

                        <div class="detail">
                            <div class="detail-label">Delivery Address</div>
                            <div class="detail-value">
                                <%= esc(order.address == null || order.address.trim().isEmpty()
                                    ? "Not available" : order.address) %>
                            </div>
                        </div>

                        <div class="detail">
                            <div class="detail-label">Payment Method</div>
                            <div class="detail-value">
                                <%= esc(currentPayment) %>
                            </div>
                        </div>

                        <div class="detail">
                            <div class="detail-label">Order Total</div>
                            <div class="detail-value amount">
                                ₹<%= order.totalAmount == null
                                    ? "0.00" : order.totalAmount.toString() %>
                            </div>
                        </div>

                    </section>

                    <footer class="order-action">
                        <div>
                            <div class="action-title">Update order progress</div>
                            <div class="action-subtitle">
                                Select the latest status and save your change.
                            </div>
                        </div>

                        <form
                            action="<%= contextPath %>/admin-orders"
                            method="post"
                            class="status-form">

                            <input type="hidden" name="action" value="updateStatus">

                            <input type="hidden"
                                   name="orderId"
                                   value="<%= order.orderId %>">

                            <select
                                name="status"
                                class="status-select"
                                aria-label="Status for order <%= order.orderId %>"
                                required>

                                <option value="PLACED"
                                    <%= "PLACED".equals(currentStatus)
                                        ? "selected" : "" %>>
                                    Placed
                                </option>

                                <option value="PREPARING"
                                    <%= "PREPARING".equals(currentStatus)
                                        ? "selected" : "" %>>
                                    Preparing
                                </option>

                                <option value="OUT_FOR_DELIVERY"
                                    <%= "OUT_FOR_DELIVERY".equals(currentStatus)
                                        ? "selected" : "" %>>
                                    Out for Delivery
                                </option>

                                <option value="DELIVERED"
                                    <%= "DELIVERED".equals(currentStatus)
                                        ? "selected" : "" %>>
                                    Delivered
                                </option>

                                <option value="CANCELLED"
                                    <%= "CANCELLED".equals(currentStatus)
                                        ? "selected" : "" %>>
                                    Cancelled
                                </option>

                            </select>

                            <button type="submit" class="update-btn">
                                Update Status
                            </button>

                        </form>
                    </footer>

                </article>

            <% } %>

        <% } %>

    </main>

    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
