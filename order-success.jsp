
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.text.SimpleDateFormat,java.util.Calendar,java.util.Date,java.util.List,java.util.Map,java.net.URLEncoder" %>

<%!
    private String escapeSuccessHtml(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private BigDecimal successAmount(Object value) {
        if (value == null) return BigDecimal.ZERO;
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private String successMoney(Object value) {
        return successAmount(value).toPlainString();
    }
%>

<%
    Object orderIdObj = session.getAttribute("lastOrderId");
    Object totalObj = session.getAttribute("lastOrderTotal");
    Object paymentObj = session.getAttribute("lastPaymentMode");
    Object addressObj = session.getAttribute("lastOrderAddress");

    List<Map<String, Object>> restaurantBills = null;

    Object billsObject = session.getAttribute("lastRestaurantBills");

    if (billsObject instanceof List<?>) {
        try {
            restaurantBills =
                (List<Map<String, Object>>) billsObject;
        } catch (ClassCastException ignored) {
            restaurantBills = null;
        }
    }

    boolean hasRestaurantBills =
            restaurantBills != null && !restaurantBills.isEmpty();

    if (orderIdObj == null && !hasRestaurantBills) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String orderId = escapeSuccessHtml(orderIdObj);

    String paymentMode = paymentObj == null
            ? "Not specified"
            : escapeSuccessHtml(paymentObj);

    String deliveryAddress = addressObj == null
            ? "Address saved with your order"
            : escapeSuccessHtml(addressObj);

    BigDecimal orderTotal = successAmount(totalObj);

    if (hasRestaurantBills) {
        BigDecimal calculatedTotal = BigDecimal.ZERO;

        for (Map<String, Object> bill : restaurantBills) {
            calculatedTotal = calculatedTotal.add(
                successAmount(bill.get("total"))
            );
        }

        // Use the combined bill when it is present.
        if (totalObj == null) {
            orderTotal = calculatedTotal;
        }
    }

    Calendar deliveryCalendar = Calendar.getInstance();
    deliveryCalendar.add(Calendar.MINUTE, 40);

    Date estimatedDelivery = deliveryCalendar.getTime();

    String deliveryTime =
            new SimpleDateFormat("hh:mm a").format(estimatedDelivery);

    String deliveryDate =
            new SimpleDateFormat("dd MMM yyyy").format(estimatedDelivery);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Order Confirmed | Yumlet</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/common.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/footer.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/order-success.css">

    <style>
        :root {
            --yumlet-chocolate: #60391f;
            --yumlet-dark: #3d2518;
            --yumlet-brown: #805537;
            --yumlet-medium: #a77b50;
            --yumlet-beige: #f3e3ca;
            --yumlet-cream: #fff8ed;
            --yumlet-light: #fffcf6;
            --yumlet-border: #e7d5bd;
            --yumlet-muted: #867665;
            --yumlet-green: #4d8b46;
        }

        body.success-page {
            background: var(--yumlet-cream);
            color: var(--yumlet-dark);
        }

        /* DELIVERY RIDER INTRO */

        .delivery-intro {
            position: fixed;
            inset: 0;
            z-index: 999999;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            background: radial-gradient(
                ellipse at 50% 40%,
                #fffaf0 0%,
                #f8ead4 52%,
                #ead3b1 100%
            );
            opacity: 1;
            visibility: visible;
            transition: opacity .7s ease, visibility .7s ease;
        }

        .delivery-intro.intro-finished {
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
        }

        .intro-content {
            position: relative;
            z-index: 2;
            width: min(92%, 650px);
            text-align: center;
            animation: introContentAppear .9s ease both;
        }

        .intro-logo {
            margin-bottom: 10px;
            color: var(--yumlet-chocolate);
            font-size: clamp(30px, 5vw, 45px);
            font-weight: 900;
            letter-spacing: -1.5px;
        }

        .intro-logo span {
            color: var(--yumlet-medium);
        }

        .intro-title {
            margin: 0 0 10px;
            color: var(--yumlet-dark);
            font-size: clamp(23px, 4vw, 36px);
            font-weight: 800;
            letter-spacing: -.7px;
        }

        .intro-description {
            margin: 0;
            color: #796957;
            font-size: 15px;
            line-height: 1.7;
        }

        .intro-road-scene {
            position: relative;
            width: 100%;
            height: 210px;
            margin: 20px auto 10px;
            overflow: hidden;
        }

        .intro-city {
            position: absolute;
            right: 0;
            bottom: 31px;
            left: 0;
            height: 105px;
            opacity: .65;
            background: linear-gradient(
                to top,
                #dec7a6 0 45%,
                transparent 45%
            );
        }

        .intro-building {
            position: absolute;
            bottom: 31px;
            width: 40px;
            background: #e6d2b5;
            border-radius: 3px 3px 0 0;
        }

        .intro-building::after {
            position: absolute;
            inset: 10px 8px;
            content: "";
            background: repeating-linear-gradient(
                to bottom,
                #fff4df 0 5px,
                transparent 5px 15px
            );
            opacity: .8;
        }

        .building-one {
            left: 5%;
            height: 70px;
        }

        .building-two {
            left: 19%;
            height: 50px;
            width: 52px;
        }

        .building-three {
            right: 17%;
            height: 80px;
            width: 45px;
        }

        .building-four {
            right: 4%;
            height: 57px;
            width: 52px;
        }

        .intro-cloud {
            position: absolute;
            width: 65px;
            height: 17px;
            background: rgba(255, 251, 242, .8);
            border-radius: 30px;
        }

        .intro-cloud::before,
        .intro-cloud::after {
            position: absolute;
            bottom: 4px;
            content: "";
            background: inherit;
            border-radius: 50%;
        }

        .intro-cloud::before {
            left: 12px;
            width: 25px;
            height: 25px;
        }

        .intro-cloud::after {
            right: 10px;
            width: 20px;
            height: 20px;
        }

        .cloud-one {
            top: 18px;
            left: 13%;
        }

        .cloud-two {
            top: 34px;
            right: 12%;
            transform: scale(.8);
        }

        .intro-road {
            position: absolute;
            bottom: 23px;
            left: -5%;
            width: 110%;
            height: 9px;
            border-radius: 20px;
            background: #bca181;
        }

        .intro-road::after {
            position: absolute;
            top: 3px;
            left: 0;
            width: 100%;
            height: 3px;
            content: "";
            background: repeating-linear-gradient(
                to right,
                #fff5e5 0 30px,
                transparent 30px 55px
            );
            animation: roadMove .4s linear infinite;
        }

        .intro-rider {
            position: absolute;
            bottom: 22px;
            left: -280px;
            z-index: 3;
            width: 260px;
            height: 155px;
            animation: riderPass 4.1s cubic-bezier(.45, 0, .35, 1) forwards;
            will-change: left, transform;
        }

        .rider-scooter {
            display: block;
            width: 100%;
            height: 100%;
            overflow: visible;
            filter: drop-shadow(0 7px 4px rgba(75, 48, 25, .16));
        }

        .intro-sparkle {
            position: absolute;
            z-index: 1;
            color: #9b774d;
            font-size: 23px;
            animation: sparkleFloat 1.3s ease-in-out infinite alternate;
        }

        .intro-sparkle.one {
            top: 30px;
            left: 23%;
        }

        .intro-sparkle.two {
            top: 45px;
            right: 19%;
            animation-delay: .4s;
        }

        .intro-sparkle.three {
            bottom: 55px;
            right: 29%;
            animation-delay: .7s;
        }

        .intro-status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            padding: 11px 18px;
            color: var(--yumlet-chocolate);
            background: rgba(255, 250, 240, .94);
            border: 1px solid #e4ceb0;
            border-radius: 30px;
            box-shadow: 0 5px 16px rgba(80, 48, 20, .08);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .6px;
        }

        .intro-status-dot {
            width: 8px;
            height: 8px;
            flex-shrink: 0;
            border-radius: 50%;
            background: #598b49;
            box-shadow: 0 0 0 4px rgba(89, 139, 73, .13);
            animation: statusPulse .8s ease-in-out infinite alternate;
        }

        @keyframes riderPass {
            0% {
                left: -280px;
                transform: translateY(0);
            }
            12% {
                transform: translateY(-3px);
            }
            25% {
                transform: translateY(0);
            }
            70% {
                transform: translateY(-2px);
            }
            100% {
                left: calc(100% + 280px);
                transform: translateY(0);
            }
        }

        @keyframes roadMove {
            from { transform: translateX(0); }
            to { transform: translateX(-55px); }
        }

        @keyframes sparkleFloat {
            from {
                transform: translateY(4px) scale(.85);
                opacity: .5;
            }
            to {
                transform: translateY(-7px) scale(1.1);
                opacity: 1;
            }
        }

        @keyframes statusPulse {
            from { opacity: .55; }
            to { opacity: 1; }
        }

        @keyframes introContentAppear {
            from {
                opacity: 0;
                transform: translateY(12px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* MAIN CONFIRMATION PAGE */

        .success-main {
            position: relative;
            min-height: 75vh;
            overflow: hidden;
            padding: 48px 20px 60px;
            background:
                radial-gradient(
                    circle at 5% 20%,
                    rgba(226, 203, 171, .27),
                    transparent 25%
                ),
                radial-gradient(
                    circle at 95% 75%,
                    rgba(226, 203, 171, .28),
                    transparent 23%
                ),
                var(--yumlet-cream);
        }

        .success-background-shape {
            position: absolute;
            width: 180px;
            height: 180px;
            border-radius: 50%;
            background: rgba(228, 207, 177, .24);
            pointer-events: none;
        }

        .shape-one {
            top: 5%;
            left: -115px;
        }

        .shape-two {
            right: -120px;
            bottom: 8%;
            width: 230px;
            height: 230px;
        }

        .success-hero {
            position: relative;
            z-index: 1;
            text-align: center;
            animation: successFadeIn .8s ease both;
        }

        .success-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 16px;
            color: #fffaf1;
            background: var(--yumlet-chocolate);
            border: 1px solid var(--yumlet-chocolate);
            border-radius: 30px;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1px;
        }

        .live-dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #e5d0ad;
            box-shadow: 0 0 0 4px rgba(255, 250, 240, .15);
        }

        .success-animation {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 200px;
            height: 160px;
            margin: 14px auto 8px;
        }

        .success-ring {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 112px;
            height: 112px;
            border-radius: 50%;
            background: #efe0c9;
            box-shadow: 0 10px 25px rgba(75, 48, 25, .08);
            animation: successPulse 2s ease-in-out infinite;
        }

        .success-check {
            width: 85px;
            height: 85px;
        }

        .check-circle {
            fill: var(--yumlet-chocolate);
            stroke: #d9c1a0;
            stroke-width: 2;
        }

        .check-tick {
            fill: none;
            stroke: #fffaf0;
            stroke-width: 7;
            stroke-linecap: round;
            stroke-linejoin: round;
            stroke-dasharray: 70;
            stroke-dashoffset: 70;
            animation: drawCheck .7s ease .3s forwards;
        }

        .floating-food {
            position: absolute;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: #f5e8d5;
            font-size: 24px;
            box-shadow: 0 5px 15px rgba(75, 48, 25, .05);
            animation: foodFloat 2.8s ease-in-out infinite;
        }

        .food-one { top: 8px; left: 12px; }
        .food-two { top: 13px; right: 10px; animation-delay: .5s; }
        .food-three { right: 3px; bottom: 8px; animation-delay: 1s; }
        .food-four { bottom: 6px; left: 6px; animation-delay: .7s; }

        .delivery-scooter {
            position: absolute;
            right: 0;
            bottom: -1px;
            left: 0;
            height: 27px;
            overflow: hidden;
        }

        .scooter-motion {
            position: absolute;
            left: -55px;
            bottom: 0;
            display: flex;
            align-items: center;
            animation: miniScooterPass 4.5s ease-in-out infinite;
        }

        .scooter-emoji {
            font-size: 25px;
            filter: grayscale(.4) sepia(.2);
        }

        .delivery-box {
            display: inline-block;
            width: 15px;
            height: 13px;
            margin-left: -4px;
            border: 1px solid #4c2c18;
            border-radius: 2px;
            background: #805537;
        }

        .scooter-road {
            position: absolute;
            right: 0;
            bottom: 0;
            left: 0;
            height: 2px;
            background: #d9c6aa;
        }

        .success-eyebrow {
            margin: 0 0 7px;
            color: var(--yumlet-brown);
            font-size: 12px;
            font-weight: 850;
            letter-spacing: 1.4px;
        }

        .success-hero h1 {
            margin: 0 0 12px;
            color: var(--yumlet-dark);
            font-size: clamp(30px, 5vw, 43px);
            font-weight: 900;
            line-height: 1.1;
            letter-spacing: -1.4px;
        }

        .success-hero h1 span {
            color: var(--yumlet-brown);
        }

        .success-description {
            max-width: 470px;
            margin: 0 auto 25px;
            color: var(--yumlet-muted);
            font-size: 14px;
            line-height: 1.8;
        }

        /* ORDER CARD */

        .order-details-card {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 680px;
            margin: 0 auto;
            padding: 25px;
            overflow: hidden;
            background: rgba(255, 252, 246, .95);
            border: 1px solid var(--yumlet-border);
            border-radius: 19px;
            box-shadow: 0 14px 40px rgba(75, 48, 25, .07);
            animation: cardRise .8s ease .15s both;
        }

        .order-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .card-eyebrow {
            display: block;
            margin-bottom: 3px;
            color: var(--yumlet-brown);
            font-size: 11px;
            font-weight: 850;
            letter-spacing: 1.2px;
        }

        .order-card-header h2 {
            margin: 0;
            color: var(--yumlet-dark);
            font-size: 22px;
            font-weight: 900;
        }

        .confirmed-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 38px;
            height: 38px;
            color: #fffaf0;
            background: var(--yumlet-chocolate);
            border-radius: 50%;
            font-size: 21px;
            font-weight: 900;
        }

        .order-id-panel {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
            padding: 14px;
            background: #f7ecd9;
            border: 1px solid #efe0c8;
            border-radius: 13px;
        }

        .order-id-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            flex: 0 0 40px;
            width: 40px;
            height: 40px;
            color: #fff8ed;
            background: var(--yumlet-brown);
            border-radius: 50%;
            font-size: 19px;
            font-weight: 900;
        }

        .order-id-text {
            display: flex;
            flex: 1;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
        }

        .order-id-text span {
            color: var(--yumlet-muted);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: .9px;
        }

        .order-id-text strong {
            color: var(--yumlet-dark);
            font-size: 14px;
            overflow-wrap: anywhere;
        }

        .placed-status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 10px;
            color: var(--yumlet-chocolate);
            background: #eee0ca;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 800;
            white-space: nowrap;
        }

        .placed-status span {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--yumlet-brown);
        }

        .order-detail-row {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            padding: 13px 3px;
            border-bottom: 1px solid #eee4d6;
        }

        .detail-label {
            color: #786957;
            font-size: 13px;
        }

        .detail-value {
            max-width: 60%;
            color: var(--yumlet-dark);
            font-size: 13px;
            font-weight: 750;
            text-align: right;
            overflow-wrap: anywhere;
        }

        .detail-value.amount {
            color: var(--yumlet-chocolate);
            font-size: 16px;
            font-weight: 900;
        }

        .address-value {
            line-height: 1.6;
        }

        /* MULTI-RESTAURANT BILLS */

        .restaurant-bills {
            margin: 22px 0 8px;
        }

        .restaurant-bills-heading {
            margin: 0 0 13px;
            color: var(--yumlet-dark);
            font-size: 16px;
            font-weight: 900;
        }

        .restaurant-bill {
            margin-bottom: 13px;
            padding: 16px;
            background: #fffaf1;
            border: 1px solid var(--yumlet-border);
            border-radius: 13px;
        }

        .restaurant-bill-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 10px;
            padding-bottom: 10px;
            border-bottom: 1px dashed #dfc9aa;
        }

        .restaurant-bill-name {
            color: var(--yumlet-dark);
            font-size: 14px;
            font-weight: 900;
            overflow-wrap: anywhere;
        }

        .restaurant-bill-order-id {
            display: block;
            margin-top: 4px;
            color: var(--yumlet-muted);
            font-size: 11px;
        }

        .restaurant-bill-status {
            flex-shrink: 0;
            padding: 6px 9px;
            color: var(--yumlet-chocolate);
            background: #f1e3ce;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 800;
        }

        .restaurant-bill-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            padding: 6px 0;
            color: #786957;
            font-size: 12px;
        }

        .restaurant-bill-row strong {
            color: var(--yumlet-dark);
            text-align: right;
            overflow-wrap: anywhere;
        }

        .restaurant-total {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-top: 8px;
            padding-top: 11px;
            border-top: 1px solid #eadbc5;
            color: var(--yumlet-chocolate);
            font-size: 13px;
            font-weight: 900;
        }

        .restaurant-total strong {
            text-align: right;
        }

        .combined-order-total {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-top: 14px;
            padding: 16px;
            color: #fffaf0;
            background: var(--yumlet-chocolate);
            border-radius: 12px;
        }

        .combined-order-total span {
            font-size: 13px;
            font-weight: 800;
        }

        .combined-order-total strong {
            font-size: 20px;
            font-weight: 900;
            overflow-wrap: anywhere;
        }

        .delivery-estimate {
            display: flex;
            align-items: center;
            gap: 13px;
            margin-top: 18px;
            padding: 15px;
            background: #f6ead7;
            border: 1px solid #edddc5;
            border-radius: 14px;
        }

        .delivery-estimate-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            flex: 0 0 43px;
            width: 43px;
            height: 43px;
            color: #fffaf0;
            background: var(--yumlet-chocolate);
            border-radius: 50%;
            font-size: 23px;
        }

        .delivery-estimate-text {
            display: flex;
            flex: 1;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
        }

        .delivery-estimate-text span {
            color: #796957;
            font-size: 10px;
            font-weight: 850;
            letter-spacing: .8px;
        }

        .delivery-estimate-text strong {
            color: var(--yumlet-dark);
            font-size: 16px;
        }

        .delivery-estimate-text small {
            color: #817261;
            font-size: 11px;
        }

        .delivery-estimate-arrow {
            color: var(--yumlet-chocolate);
            font-size: 25px;
            font-weight: 800;
        }

        .success-actions {
            display: flex;
            gap: 12px;
            margin-top: 18px;
        }

        .track-order-btn,
        .continue-shopping-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            flex: 1;
            min-height: 46px;
            padding: 12px 17px;
            border: 1px solid var(--yumlet-chocolate);
            border-radius: 30px;
            font-size: 12px;
            font-weight: 850;
            text-align: center;
            text-decoration: none;
            transition: background .2s ease, color .2s ease,
                        transform .2s ease, box-shadow .2s ease;
        }

        .track-order-btn {
            color: #fff9ef;
            background: var(--yumlet-chocolate);
            box-shadow: 0 5px 13px rgba(75, 48, 25, .13);
        }

        .track-order-btn:hover {
            color: white;
            background: var(--yumlet-dark);
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(75, 48, 25, .18);
        }

        .continue-shopping-btn {
            color: var(--yumlet-chocolate);
            background: transparent;
        }

        .continue-shopping-btn:hover {
            color: var(--yumlet-dark);
            background: #f6ead7;
            transform: translateY(-2px);
        }

        .thank-you-note {
            margin: 19px 0 0;
            color: #817261;
            font-size: 12px;
            text-align: center;
        }

        .thank-you-note span {
            color: var(--yumlet-brown);
        }

        .success-bottom-note {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: center;
            gap: 16px;
            width: 100%;
            max-width: 680px;
            margin: 17px auto 0;
            padding: 17px 20px;
            background: #f4e5cf;
            border: 1px solid #ead7ba;
            border-radius: 14px;
            animation: cardRise .8s ease .3s both;
        }

        .bottom-note-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 44px;
            height: 44px;
            flex-shrink: 0;
            color: var(--yumlet-chocolate);
            border-right: 1px solid #d9c2a1;
            font-size: 25px;
        }

        .success-bottom-note strong {
            color: var(--yumlet-dark);
            font-size: 13px;
        }

        .success-bottom-note p {
            margin: 4px 0 0;
            color: #817261;
            font-size: 12px;
        }

        @keyframes successPulse {
            0%, 100% {
                transform: scale(1);
                box-shadow: 0 0 0 0 rgba(96, 57, 31, .08);
            }
            50% {
                transform: scale(1.045);
                box-shadow: 0 0 0 9px rgba(96, 57, 31, 0);
            }
        }

        @keyframes drawCheck {
            to { stroke-dashoffset: 0; }
        }

        @keyframes foodFloat {
            0%, 100% { transform: translateY(0) rotate(0); }
            50% { transform: translateY(-7px) rotate(5deg); }
        }

        @keyframes miniScooterPass {
            0% { left: -55px; opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { left: calc(100% + 55px); opacity: 0; }
        }

        @keyframes successFadeIn {
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes cardRise {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 480px) {
            .intro-road-scene {
                height: 175px;
            }

            .intro-rider {
                width: 220px;
                height: 132px;
                left: -240px;
            }

            @keyframes riderPass {
                0% {
                    left: -240px;
                    transform: translateY(0);
                }
                100% {
                    left: calc(100% + 240px);
                    transform: translateY(0);
                }
            }

            .intro-description {
                font-size: 14px;
            }

            .success-main {
                padding: 35px 14px 45px;
            }

            .order-details-card {
                padding: 18px;
                border-radius: 16px;
            }

            .success-actions {
                flex-direction: column;
            }

            .track-order-btn,
            .continue-shopping-btn {
                width: 100%;
                min-height: 46px;
            }

            .order-detail-row {
                gap: 12px;
            }

            .detail-label,
            .detail-value {
                font-size: 12px;
            }

            .delivery-estimate {
                gap: 10px;
                padding: 12px;
            }

            .success-bottom-note {
                padding: 14px;
            }

            .restaurant-bill {
                padding: 12px;
            }

            .restaurant-bill-header {
                gap: 8px;
            }

            .restaurant-bill-name {
                font-size: 13px;
            }

            .combined-order-total strong {
                font-size: 17px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .intro-road::after,
            .intro-sparkle,
            .intro-status-dot,
            .floating-food,
            .success-ring,
            .scooter-motion {
                animation: none !important;
            }

            .intro-rider {
                animation-duration: 1.5s;
            }
        }
    </style>
</head>

<body class="success-page">

    <!-- DELIVERY RIDER INTRO SCREEN -->
    <div class="delivery-intro" id="deliveryIntro"
         role="status"
         aria-label="Your order is confirmed. Delivery rider is on the way.">

        <div class="intro-content">

            <div class="intro-logo">Yumlet<span>.</span></div>

            <h1 class="intro-title">Your food is on its way!</h1>

            <p class="intro-description">
                Our delivery partner is bringing happiness to your doorstep.
            </p>

            <div class="intro-road-scene">

                <div class="intro-cloud cloud-one"></div>
                <div class="intro-cloud cloud-two"></div>

                <div class="intro-city">
                    <div class="intro-building building-one"></div>
                    <div class="intro-building building-two"></div>
                    <div class="intro-building building-three"></div>
                    <div class="intro-building building-four"></div>
                </div>

                <span class="intro-sparkle one" aria-hidden="true">✦</span>
                <span class="intro-sparkle two" aria-hidden="true">✧</span>
                <span class="intro-sparkle three" aria-hidden="true">✦</span>

                <div class="intro-road"></div>

                <div class="intro-rider">
                    <svg class="rider-scooter"
                         viewBox="0 0 260 150"
                         xmlns="http://www.w3.org/2000/svg"
                         role="img"
                         aria-label="Delivery rider riding a scooter">

                        <path d="M27 31 L79 31 L82 72 L24 72 Z" fill="#805537"/>
                        <path d="M27 31 L40 24 L87 24 L79 31 Z" fill="#A77B50"/>
                        <path d="M79 31 L87 24 L87 65 L82 72 Z" fill="#684226"/>
                        <path d="M27 44 H80" stroke="#B58A60" stroke-width="2.5"/>

                        <circle cx="69" cy="115" r="20" fill="#34271F"/>
                        <circle cx="69" cy="115" r="11" fill="#E8D8BE"/>
                        <circle cx="69" cy="115" r="5" fill="#9C8060"/>
                        <circle cx="69" cy="115" r="2" fill="#34271F"/>

                        <circle cx="204" cy="115" r="20" fill="#34271F"/>
                        <circle cx="204" cy="115" r="11" fill="#E8D8BE"/>
                        <circle cx="204" cy="115" r="5" fill="#9C8060"/>
                        <circle cx="204" cy="115" r="2" fill="#34271F"/>

                        <path d="M48 91 Q50 83 62 84 L99 87 L122 98 L175 99 Q185 98 193 85 L203 86 L213 99 L206 106 L117 108 L94 100 L68 102 L52 103 Z"
                              fill="#805537" stroke="#5B3924" stroke-width="2"/>

                        <path d="M61 91 L91 91 L101 99 L69 99 Z" fill="#A77B50"/>
                        <path d="M73 92 L84 92" stroke="#E8D8BE" stroke-width="2" stroke-linecap="round"/>

                        <path d="M169 87 L179 66 Q182 61 189 64 L202 77 L211 94 L197 99 L179 96 Z"
                              fill="#805537" stroke="#5B3924" stroke-width="2"/>

                        <path d="M187 80 L198 111" stroke="#443126" stroke-width="6" stroke-linecap="round"/>
                        <path d="M190 68 L201 73 L197 80 L188 75 Z" fill="#F7E6C4"/>
                        <path d="M76 81 Q88 74 104 80 L127 86 L122 93 L94 91 L79 89 Z" fill="#34271F"/>

                        <path d="M120 72 L135 88 L160 94 L174 94"
                              fill="none" stroke="#293B40" stroke-width="12" stroke-linecap="round" stroke-linejoin="round"/>

                        <path d="M136 75 L153 87 L174 91"
                              fill="none" stroke="#31484B" stroke-width="10" stroke-linecap="round" stroke-linejoin="round"/>

                        <path d="M160 91 L178 91 L183 97 L159 98 Z" fill="#34271F"/>

                        <path d="M105 39 Q117 34 130 43 L146 65 L143 79 L117 83 L101 61 L96 49 Z"
                              fill="#4D9347" stroke="#3D7838" stroke-width="1.5"/>

                        <path d="M119 43 L127 54 L126 70"
                              fill="none" stroke="#76B76A" stroke-width="3" stroke-linecap="round"/>

                        <path d="M106 31 L107 43 L118 46 L121 34 Z" fill="#C98961"/>
                        <circle cx="108" cy="27" r="15" fill="#C98961"/>

                        <path d="M92 28 Q90 9 107 8 Q125 8 126 25 L119 29 L98 25 L96 33 Z"
                              fill="#347D38"/>

                        <path d="M108 25 L125 27"
                              stroke="#347D38" stroke-width="5" stroke-linecap="round"/>

                        <circle cx="114" cy="28" r="1.5" fill="#3C291F"/>
                        <path d="M111 34 Q115 37 119 34"
                              fill="none" stroke="#80513A" stroke-width="1.5" stroke-linecap="round"/>

                        <path d="M133 47 L151 62 L186 65"
                              fill="none" stroke="#4D9347" stroke-width="10" stroke-linecap="round" stroke-linejoin="round"/>

                        <path d="M166 63 L188 65"
                              fill="none" stroke="#C98961" stroke-width="7" stroke-linecap="round"/>

                        <circle cx="189" cy="65" r="4" fill="#C98961"/>

                        <path d="M184 62 L199 59"
                              fill="none" stroke="#34271F" stroke-width="4" stroke-linecap="round"/>

                        <path d="M113 48 L135 60 L151 63"
                              fill="none" stroke="#4D9347" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>

                        <circle cx="152" cy="63" r="4" fill="#C98961"/>

                        <path d="M5 61 H19 M11 72 H22"
                              stroke="#B99A72" stroke-width="2.5" stroke-linecap="round" opacity=".8"/>
                    </svg>
                </div>

            </div>

            <div class="intro-status">
                <span class="intro-status-dot"></span>
                ORDER CONFIRMED · GETTING READY
            </div>

        </div>
    </div>

    <jsp:include page="/includes/navbar.jsp" />

    <main class="success-main">

        <div class="success-background-shape shape-one"></div>
        <div class="success-background-shape shape-two"></div>

        <section class="success-hero">

            <div class="success-badge">
                <span class="live-dot"></span>
                ORDER CONFIRMED
            </div>

            <div class="success-animation" aria-label="Order successfully placed">

                <div class="success-ring">
                    <svg class="success-check"
                         viewBox="0 0 100 100"
                         role="img"
                         aria-label="Success">

                        <circle class="check-circle" cx="50" cy="50" r="43"></circle>
                        <path class="check-tick" d="M28 51 L43 66 L73 35"></path>
                    </svg>
                </div>

                <div class="floating-food food-one">🍕</div>
                <div class="floating-food food-two">🍔</div>
                <div class="floating-food food-three">🍜</div>
                <div class="floating-food food-four">🥗</div>

                <div class="delivery-scooter">
                    <div class="scooter-motion">
                        <span class="scooter-emoji">🛵</span>
                        <span class="delivery-box"></span>
                    </div>
                    <div class="scooter-road"></div>
                </div>

            </div>

            <p class="success-eyebrow">GOOD FOOD IS ON ITS WAY</p>

            <h1>Your order is<br><span>on its way!</span></h1>

            <p class="success-description">
                Great choice! Your order has been placed successfully.
                Our team is getting everything ready for you.
            </p>

        </section>

        <section class="order-details-card">

            <div class="order-card-header">
                <div>
                    <span class="card-eyebrow">YOUR ORDER</span>
                    <h2>Order summary</h2>
                </div>
                <div class="confirmed-icon">✓</div>
            </div>

            <% if (hasRestaurantBills) { %>

                <p class="detail-label" style="margin:0 0 12px;">
                    You have placed orders from
                    <strong><%= restaurantBills.size() %></strong>
                    restaurant(s).
                </p>

                <div class="restaurant-bills">

                    <h3 class="restaurant-bills-heading">
                        Restaurant-wise bill
                    </h3>

                    <% for (Map<String, Object> bill : restaurantBills) {

                        Object billRestaurantName = bill.get("restaurantName");
                        if (billRestaurantName == null) {
                            billRestaurantName = bill.get("restaurant");
                        }

                        Object billOrderId = bill.get("orderId");
                        Object billSubtotal = bill.get("subtotal");
                        Object billDelivery = bill.get("deliveryFee");
                        Object billDiscount = bill.get("discount");
                        Object billTotal = bill.get("total");
                    %>

                        <div class="restaurant-bill">

                            <div class="restaurant-bill-header">
                                <div>
                                    <div class="restaurant-bill-name">
                                        <%= escapeSuccessHtml(
                                            billRestaurantName == null
                                                ? "Restaurant"
                                                : billRestaurantName
                                        ) %>
                                    </div>

                                    <span class="restaurant-bill-order-id">
                                        Order ID:
                                        #<%= escapeSuccessHtml(billOrderId == null ? "N/A" : billOrderId) %>
                                    </span>
                                </div>

                                <span class="restaurant-bill-status">
                                    Placed
                                </span>
                            </div>

                            <div class="restaurant-bill-row">
                                <span>Food subtotal</span>
                                <strong>₹<%= successMoney(billSubtotal) %></strong>
                            </div>

                            <div class="restaurant-bill-row">
                                <span>Delivery fee</span>
                                <strong>₹<%= successMoney(billDelivery) %></strong>
                            </div>

                            <% if (successAmount(billDiscount).compareTo(BigDecimal.ZERO) > 0) { %>
                                <div class="restaurant-bill-row">
                                    <span>Discount</span>
                                    <strong>- ₹<%= successMoney(billDiscount) %></strong>
                                </div>
                            <% } %>

                            <div class="restaurant-total">
                                <span>Restaurant total</span>
                                <strong>₹<%= successMoney(billTotal) %></strong>
                            </div>

                        </div>

                    <% } %>

                    <div class="combined-order-total">
                        <span>Combined total</span>
                        <strong>₹<%= orderTotal.toPlainString() %></strong>
                    </div>

                </div>

            <% } else { %>

                <div class="order-id-panel">
                    <div class="order-id-icon">#</div>

                    <div class="order-id-text">
                        <span>ORDER ID</span>
                        <strong>#<%= orderId %></strong>
                    </div>

                    <span class="placed-status">
                        <span></span> Placed
                    </span>
                </div>

                <div class="order-detail-row">
                    <span class="detail-label">Total paid / payable</span>
                    <strong class="detail-value amount">
                        ₹<%= orderTotal.toPlainString() %>
                    </strong>
                </div>

            <% } %>

            <div class="order-detail-row">
                <span class="detail-label">Payment method</span>
                <strong class="detail-value"><%= paymentMode %></strong>
            </div>

            <div class="order-detail-row address-row">
                <span class="detail-label">Delivery address</span>
                <strong class="detail-value address-value">
                    <%= deliveryAddress %>
                </strong>
            </div>

            <div class="delivery-estimate">

                <div class="delivery-estimate-icon">🛵</div>

                <div class="delivery-estimate-text">
                    <span>ESTIMATED DELIVERY</span>
                    <strong><%= deliveryTime %></strong>
                    <small><%= deliveryDate %> · Approx. 40 minutes</small>
                </div>

                <div class="delivery-estimate-arrow">→</div>

            </div>

            <div class="success-actions">

                <% if (!hasRestaurantBills && orderIdObj != null) { %>
                    <a class="track-order-btn"
                       href="<%= request.getContextPath() %>/track-order?orderId=<%= URLEncoder.encode(String.valueOf(orderIdObj), "UTF-8") %>">
                        Track My Order <span>→</span>
                    </a>
                <% } else if (hasRestaurantBills) { %>
                    <a class="track-order-btn"
                       href="<%= request.getContextPath() %>/orders">
                        View My Orders <span>→</span>
                    </a>
                <% } %>

                <a class="continue-shopping-btn"
                   href="<%= request.getContextPath() %>/restaurant">
                    Continue Shopping
                </a>

            </div>

            <p class="thank-you-note">
                Made with care by Yumlet. <span>♥</span>
            </p>

        </section>

        <section class="success-bottom-note">
            <div class="bottom-note-icon">✦</div>
            <div>
                <strong>Something delicious is coming!</strong>
                <p>Keep an eye on your order status for updates.</p>
            </div>
        </section>

    </main>

    <jsp:include page="/includes/footer.jsp" />

    <script>
        document.addEventListener("DOMContentLoaded", function () {

            const intro = document.getElementById("deliveryIntro");

            window.setTimeout(function () {
                if (intro) {
                    intro.classList.add("intro-finished");
                }
            }, 4300);

            window.setTimeout(function () {
                if (intro) {
                    intro.style.display = "none";
                }
            }, 5050);

        });
    </script>

</body>
</html>
