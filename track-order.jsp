
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.sql.Timestamp,java.math.BigDecimal,java.text.SimpleDateFormat,java.util.Locale" %>

<%
    String contextPath = request.getContextPath();

    Object orderIdObj = request.getAttribute("orderId");
    Object orderDateObj = request.getAttribute("orderDate");
    Object totalAmountObj = request.getAttribute("totalAmount");
    Object orderStatusObj = request.getAttribute("orderStatus");
    Object paymentModeObj = request.getAttribute("paymentMode");
    Object restaurantIdObj = request.getAttribute("restaurantId");

    if (orderIdObj == null) {
        response.sendRedirect(contextPath + "/orders");
        return;
    }

    int orderId = ((Number) orderIdObj).intValue();

    String status = orderStatusObj == null
            ? "Pending"
            : orderStatusObj.toString().trim();

    String normalizedStatus = status.toLowerCase(Locale.ROOT)
            .replace("_", " ")
            .replace("-", " ");

    String formattedDate = "Not available";

    if (orderDateObj instanceof Timestamp) {
        formattedDate = new SimpleDateFormat("dd MMM yyyy, hh:mm a")
                .format((Timestamp) orderDateObj);
    }

    String formattedAmount = "0.00";

    if (totalAmountObj instanceof BigDecimal) {
        formattedAmount = String.format(
                Locale.US, "%.2f",
                ((BigDecimal) totalAmountObj).doubleValue()
        );
    } else if (totalAmountObj instanceof Number) {
        formattedAmount = String.format(
                Locale.US, "%.2f",
                ((Number) totalAmountObj).doubleValue()
        );
    }

    String paymentMode = paymentModeObj == null
            ? "Not specified"
            : paymentModeObj.toString();

    boolean cancelled = normalizedStatus.contains("cancel")
            || normalizedStatus.contains("fail")
            || normalizedStatus.contains("reject");

    int currentStep = 0;

    if (normalizedStatus.contains("confirm")) {
        currentStep = 1;
    }

    if (normalizedStatus.contains("prepar")) {
        currentStep = 2;
    }

    if (normalizedStatus.contains("out for delivery")
            || normalizedStatus.contains("on the way")
            || normalizedStatus.contains("picked up")) {
        currentStep = 3;
    }

    if ((normalizedStatus.contains("deliver")
            && !normalizedStatus.contains("out for delivery"))
            || normalizedStatus.equals("completed")) {
        currentStep = 4;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Track Order | Yumlet</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #4B2E22;
            color: #4B2E22;
        }

        .tracking-container {
            max-width: 900px;
            margin: 45px auto;
            padding: 0 20px;
        }

        .tracking-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .tracking-header h1 {
            color: #FFF1DF;
            font-size: 32px;
            margin: 0 0 12px;
        }

        .tracking-header p {
            color: #E9D1B7;
            margin: 0;
            line-height: 1.7;
        }

        .tracking-card {
            background: #F5E6D3;
            border: 1px solid #E3CFB8;
            border-radius: 18px;
            padding: 28px;
            margin-bottom: 24px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
        }

        .order-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
            padding-bottom: 22px;
            border-bottom: 1px solid #DDC5AB;
        }

        .order-top h2 {
            margin: 0 0 8px;
            color: #4B2E22;
            font-size: 22px;
        }

        .order-top p {
            margin: 0;
            color: #806653;
            font-size: 14px;
        }

        .status-pill {
            display: inline-block;
            background: #4B2E22;
            color: #FFF1DF;
            padding: 10px 16px;
            border-radius: 30px;
            font-size: 13px;
            font-weight: bold;
            text-transform: capitalize;
        }

        .progress-title,
        .details-title {
            color: #4B2E22;
            font-size: 21px;
            margin: 26px 0;
        }

        .tracking-step {
            display: flex;
            gap: 16px;
            position: relative;
            min-height: 85px;
        }

        .step-icon {
            width: 38px;
            height: 38px;
            min-width: 38px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #DDC5AB;
            color: #4B2E22;
            font-weight: bold;
            z-index: 1;
        }

        .tracking-step:not(:last-child)::after {
            content: "";
            position: absolute;
            left: 18px;
            top: 38px;
            width: 2px;
            height: 47px;
            background: #DDC5AB;
        }

        .tracking-step.completed .step-icon {
            background: #4B2E22;
            color: #FFF1DF;
        }

        .tracking-step.completed:not(:last-child)::after {
            background: #4B2E22;
        }

        .step-content {
            padding-top: 3px;
        }

        .step-content h3 {
            margin: 0 0 7px;
            color: #4B2E22;
            font-size: 16px;
        }

        .step-content p {
            margin: 0;
            color: #806653;
            font-size: 13px;
            line-height: 1.6;
        }

        .cancelled-message {
            background: #F7DCD4;
            color: #762C20;
            padding: 18px;
            border-radius: 12px;
            margin-top: 22px;
            line-height: 1.7;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 18px;
            padding: 15px 0;
            border-bottom: 1px solid #DDC5AB;
        }

        .detail-row:last-of-type {
            border-bottom: none;
        }

        .detail-label {
            color: #806653;
            font-size: 14px;
        }

        .detail-value {
            color: #4B2E22;
            font-size: 14px;
            font-weight: 600;
            text-align: right;
            overflow-wrap: anywhere;
        }

        .tracking-actions {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 13px;
            margin-top: 28px;
        }

        .tracking-btn {
            display: inline-block;
            text-decoration: none;
            border-radius: 9px;
            padding: 13px 22px;
            font-size: 14px;
            font-weight: bold;
            transition: background 0.2s ease;
        }

        .primary-btn {
            background: #4B2E22;
            color: #FFF1DF;
        }

        .primary-btn:hover {
            background: #654431;
        }

        .secondary-btn {
            border: 1px solid #4B2E22;
            color: #4B2E22;
            background: transparent;
        }

        .secondary-btn:hover {
            background: #E9D1B7;
        }

        @media (max-width: 600px) {
            .tracking-container {
                margin: 28px auto;
                padding: 0 14px;
            }

            .tracking-header h1 {
                font-size: 26px;
            }

            .tracking-card {
                padding: 21px 17px;
            }

            .order-top h2 {
                font-size: 19px;
            }

            .detail-row {
                gap: 12px;
            }

            .detail-label,
            .detail-value {
                font-size: 13px;
            }

            .tracking-btn {
                text-align: center;
                padding: 12px 16px;
            }
        }
    </style>
</head>

<body>

    <%@ include file="includes/navbar.jsp" %>

    <main class="tracking-container">

        <header class="tracking-header">
            <h1>Track Your Order</h1>
            <p>
                Follow your food's journey from the kitchen
                to your doorstep.
            </p>
        </header>

        <section class="tracking-card">

            <div class="order-top">
                <div>
                    <h2>Order #<%= orderId %></h2>
                    <p>Placed on <%= formattedDate %></p>
                </div>

                <span class="status-pill">
                    <%= status %>
                </span>
            </div>

            <% if (cancelled) { %>

                <div class="cancelled-message">
                    <strong>Order update</strong><br>
                    Your order status is <%= status %>.
                    Please visit My Orders for more information.
                </div>

            <% } else { %>

                <h2 class="progress-title">Delivery Progress</h2>

                <div class="tracking-step completed">
                    <div class="step-icon">&#10003;</div>
                    <div class="step-content">
                        <h3>Order Placed</h3>
                        <p>Your order has been recorded successfully.</p>
                    </div>
                </div>

                <div class="tracking-step <%= currentStep >= 1 ? "completed" : "" %>">
                    <div class="step-icon">&#10003;</div>
                    <div class="step-content">
                        <h3>Order Confirmed</h3>
                        <p>The restaurant has confirmed your order.</p>
                    </div>
                </div>

                <div class="tracking-step <%= currentStep >= 2 ? "completed" : "" %>">
                    <div class="step-icon">&#10003;</div>
                    <div class="step-content">
                        <h3>Preparing Your Food</h3>
                        <p>Your meal is being prepared by the restaurant.</p>
                    </div>
                </div>

                <div class="tracking-step <%= currentStep >= 3 ? "completed" : "" %>">
                    <div class="step-icon">&#10003;</div>
                    <div class="step-content">
                        <h3>Out for Delivery</h3>
                        <p>Your order is on its way to you.</p>
                    </div>
                </div>

                <div class="tracking-step <%= currentStep >= 4 ? "completed" : "" %>">
                    <div class="step-icon">&#10003;</div>
                    <div class="step-content">
                        <h3>Delivered</h3>
                        <p>Enjoy your meal!</p>
                    </div>
                </div>

            <% } %>

        </section>

        <section class="tracking-card">

            <h2 class="details-title">Order Details</h2>

            <div class="detail-row">
                <span class="detail-label">Order ID</span>
                <span class="detail-value">#<%= orderId %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Restaurant ID</span>
                <span class="detail-value">
                    <%= restaurantIdObj == null
                        ? "Not available"
                        : restaurantIdObj %>
                </span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Order Date</span>
                <span class="detail-value"><%= formattedDate %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Payment Method</span>
                <span class="detail-value"><%= paymentMode %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Total Amount</span>
                <span class="detail-value">
                    &#8377;<%= formattedAmount %>
                </span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Order Status</span>
                <span class="detail-value"><%= status %></span>
            </div>

            <div class="tracking-actions">
                <a href="<%= contextPath %>/orders"
                   class="tracking-btn primary-btn">
                    My Orders
                </a>

                <a href="<%= contextPath %>/restaurant"
                   class="tracking-btn secondary-btn">
                    Order More Food
                </a>
            </div>

        </section>

    </main>

  

</body>
</html>
