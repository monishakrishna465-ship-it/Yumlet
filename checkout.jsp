
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.util.CouponUtil" %>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String money(BigDecimal value) {
        if (value == null) value = BigDecimal.ZERO;
        return String.format(Locale.US, "%.2f", value);
    }

    private String foodImage(CartItem item, String contextPath) {
        String fallback =
            "https://placehold.co/160x160/F5E9D8/48230F?text=Food";

        if (item == null || item.getImagePath() == null
                || item.getImagePath().trim().isEmpty()) {
            return fallback;
        }

        String path = item.getImagePath().trim();

        if (path.startsWith("https://") || path.startsWith("http://")) {
            return path;
        }

        if (path.startsWith("/")) return contextPath + path;

        return contextPath + "/" + path;
    }
%>

<%
    String cp = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");

    if (cart == null || cart.isEmpty()) {
        response.sendRedirect(cp + "/cart");
        return;
    }

    BigDecimal subtotal = BigDecimal.ZERO;
    int cartCount = 0;
    Map<Integer, List<CartItem>> restaurantGroups = new LinkedHashMap<Integer, List<CartItem>>();
    Map<Integer, String> restaurantNames = new LinkedHashMap<Integer, String>();

    for (CartItem item : cart) {
        if (item != null && item.getPrice() != null && item.getQuantity() > 0) {
            subtotal = subtotal.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            cartCount += item.getQuantity();
            int restaurantId = item.getRestaurantId() > 0 ? item.getRestaurantId() : -1;
            restaurantGroups.computeIfAbsent(restaurantId, key -> new ArrayList<CartItem>()).add(item);
            String restaurantName = item.getRestaurantName();
            if (restaurantName == null || restaurantName.trim().isEmpty()) {
                restaurantName = restaurantId > 0 ? "Restaurant " + restaurantId : "Restaurant";
            }
            restaurantNames.put(restaurantId, restaurantName);
        }
    }

    if (cartCount == 0) {
        response.sendRedirect(cp + "/cart");
        return;
    }

    BigDecimal deliveryFeePerRestaurant = new BigDecimal("40.00");
    BigDecimal deliveryFee = deliveryFeePerRestaurant.multiply(BigDecimal.valueOf(restaurantGroups.size()));
    BigDecimal discount = subtotal.compareTo(new BigDecimal("499.00")) >= 0
        ? new BigDecimal("40.00") : BigDecimal.ZERO;
    String checkoutCoupon = (String) session.getAttribute("couponCode");
    BigDecimal couponDiscount = BigDecimal.ZERO;
    if (checkoutCoupon != null && !checkoutCoupon.trim().isEmpty()) {
        couponDiscount = CouponUtil.calculateDiscount(checkoutCoupon, subtotal);
    }
    BigDecimal totalDiscount = discount.add(couponDiscount);
    BigDecimal total = subtotal.add(deliveryFee).subtract(totalDiscount);
    if (total.compareTo(BigDecimal.ZERO) < 0) total = BigDecimal.ZERO;

    String username = session.getAttribute("username") == null
        ? "" : session.getAttribute("username").toString();
    String phone = session.getAttribute("phone") == null
        ? "" : session.getAttribute("phone").toString();
    String address = session.getAttribute("address") == null
        ? "" : session.getAttribute("address").toString();
    String error = request.getAttribute("error") == null
        ? "" : request.getAttribute("error").toString();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Checkout | Eatero</title>

<link rel="stylesheet" href="<%= cp %>/css/common.css">
<link rel="stylesheet" href="<%= cp %>/css/navbar.css">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&display=swap" rel="stylesheet">

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<style>
:root {
    --chocolate:#35190E;
    --chocolate-dark:#281208;
    --accent:#B87545;
    --cream:#F5E9D8;
    --cream-light:#FFFAF2;
    --border:#DDA16E;
    --muted:#806652;
    --ink:#35190E;
    --green:#47764B;
}
* { box-sizing:border-box; }

body {
    margin:0;
    background:var(--chocolate);
    color:var(--ink);
    font-family:"DM Sans",sans-serif;
}
button,input,select,textarea { font:inherit; }
a { color:inherit; text-decoration:none; }

.page {
    width:min(1320px,94%);
    margin:auto;
    padding:38px 0 70px;
}
.heading { margin-bottom:26px; }
.eyebrow {
    color:#DDA16E;
    font-size:11px;
    font-weight:800;
    letter-spacing:2px;
}
h1,h2 { font-family:"Playfair Display",serif; color:var(--chocolate); }
h1 {
    color:var(--cream-light);
    font-size:clamp(30px,4vw,44px);
    margin:8px 0;
}
.heading p { color:#E2C8B5; font-size:14px; line-height:1.7; }

.steps { display:flex; align-items:center; gap:10px; margin-bottom:25px; }
.step {
    display:flex; align-items:center; gap:7px;
    color:#E2C8B5; font-size:12px; font-weight:700; white-space:nowrap;
}
.circle {
    width:34px; height:34px; display:grid; place-items:center;
    border:1px solid #A77B60; border-radius:50%;
    background:var(--cream); color:var(--chocolate);
}
.step.active,.step.completed { color:white; }
.step.active .circle,.step.completed .circle {
    background:var(--accent); border-color:var(--accent); color:white;
}
.step-line { height:2px; flex:1; background:#80513A; }
.step-line.completed { background:#DDA16E; }

.layout {
    display:grid;
    grid-template-columns:minmax(0,1.45fr) minmax(300px,.75fr);
    gap:24px;
    align-items:start;
}
.card {
    background:var(--cream);
    border:1px solid var(--border);
    border-radius:24px;
    padding:27px;
    box-shadow:0 8px 28px #16090030;
}
.checkout-step { display:none; }
.checkout-step.active { display:block; }
.card-title {
    display:flex; justify-content:space-between; align-items:center;
    gap:12px; margin-bottom:22px;
}
h2 { font-size:25px; margin:0; }

.card-title span { color:var(--muted); font-size:11px; font-weight:700; }

.note {
    padding:13px; margin-bottom:20px;
    background:#EFE0CD; border:1px solid var(--border);
    border-radius:11px; color:#725A48; font-size:12px; line-height:1.7;
}

.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
.group { min-width:0; }
.group.full { grid-column:1/-1; }
.group label {
    display:block; margin-bottom:7px;
    color:var(--chocolate); font-size:12px; font-weight:800;
}
.group input,.group textarea,.group select {
    width:100%; padding:12px; border:1px solid #D9C5AF;
    border-radius:10px; background:#FFFCF8; outline:none;
    color:var(--ink); font-size:13px;
}
.group input { min-height:44px; }
.group textarea { min-height:85px; resize:vertical; }
.group input:focus,.group textarea:focus,.group select:focus {
    border-color:var(--accent); box-shadow:0 0 0 2px #B8754520;
}
.address-types { display:flex; gap:12px; margin-top:18px; flex-wrap:wrap; }
.address-types label {
    border:1px solid #D9C5AF; padding:10px 13px;
    border-radius:9px; font-size:12px; cursor:pointer;
}
.address-types input { accent-color:var(--chocolate); }

.payment-options { display:grid; gap:12px; }
.payment-option { position:relative; }
.payment-option input { position:absolute; opacity:0; }
.payment-label {
    display:flex; align-items:center; gap:13px; padding:16px;
    border:1px solid #D9C5AF; border-radius:13px; cursor:pointer;
}
.payment-option input:checked + .payment-label {
    border-color:var(--accent); background:#EFE0CD;
}
.payment-code {
    min-width:48px; height:44px; display:grid; place-items:center;
    background:#E9D6C0; border-radius:10px;
    color:var(--chocolate); font-size:11px; font-weight:800;
}
.payment-info { flex:1; }
.payment-info strong { display:block; font-size:13px; margin-bottom:4px; }
.payment-info small { color:var(--muted); line-height:1.5; font-size:11px; }
.radio {
    width:18px; height:18px; border:2px solid #D9C4AD;
    border-radius:50%; flex-shrink:0;
}
.payment-option input:checked + .payment-label .radio {
    border:5px solid var(--chocolate);
}
.status {
    margin-top:14px; padding:12px; border-radius:9px;
    background:#F2F8EF; color:#35653B; font-size:12px; line-height:1.6;
}

.location-btn {
    border:1px solid var(--accent); background:var(--chocolate);
    color:white; padding:12px 16px; border-radius:10px;
    font-size:12px; font-weight:800; cursor:pointer;
}
.location-status { font-size:12px; line-height:1.6; color:var(--muted); margin:12px 0; }
#locationMap {
    height:390px; width:100%; border-radius:14px;
    border:1px solid var(--border); overflow:hidden;
    background:#E7DFD0; z-index:1;
}
.map-caption { color:var(--muted); font-size:11px; line-height:1.6; margin:9px 0 15px; }
.review-box {
    padding:15px; border:1px solid #D9C5AF; border-radius:12px;
    background:#FFFCF8; margin-bottom:13px;
}
.review-title {
    color:var(--accent); font-size:10px; font-weight:800;
    letter-spacing:1px; margin-bottom:8px;
}
.review-value { font-size:13px; line-height:1.8; overflow-wrap:anywhere; }
.map-link { display:none; color:#70401F; font-size:12px; font-weight:800; margin-top:8px; }

.actions {
    display:flex; justify-content:space-between; gap:12px;
    margin-top:24px; flex-wrap:wrap;
}
.btn {
    border:1px solid transparent; border-radius:10px;
    min-height:45px; padding:12px 17px;
    cursor:pointer; font-size:12px; font-weight:800;
}
.primary { background:var(--chocolate); color:white; }
.primary:hover { background:var(--chocolate-dark); }
.secondary { background:transparent; border-color:var(--accent); color:var(--chocolate); }
.btn:disabled { opacity:.65; cursor:not-allowed; }
.error {
    margin-bottom:18px; padding:12px; border:1px solid #E8BDB7;
    border-radius:9px; background:#FFF4F1; color:#A33425; font-size:12px;
}

/* Right-hand order summary */
.summary { position:sticky; top:20px; }
.restaurant-bill-group { border:1px solid #ead8c1; border-radius:12px; padding:12px; margin:0 0 12px; background:#fffaf3; }
.restaurant-bill-heading { font-size:13px; font-weight:800; color:#48230F; margin-bottom:10px; padding-bottom:8px; border-bottom:1px dashed #dfc7aa; }
.restaurant-bill-subtotal { display:flex; justify-content:space-between; gap:12px; font-size:13px; color:#684b37; margin-top:8px; }
.summary h2 { margin-bottom:22px; }
.items {
    display:grid; gap:15px; padding-bottom:18px;
    border-bottom:1px solid #D9C5AF;
}
.item {
    display:grid; grid-template-columns:70px minmax(0,1fr) auto;
    gap:12px; align-items:center;
}
.food-image {
    width:70px; height:70px; display:block; object-fit:cover;
    border-radius:13px; background:#EFE0CD; border:1px solid var(--border);
}
.item-name { font-size:13px; font-weight:800; overflow-wrap:anywhere; }
.item-qty { display:block; margin-top:5px; color:var(--muted); font-size:11px; }
.item-price { font-size:12px; font-weight:800; white-space:nowrap; }
.price-row,.total-row {
    display:flex; justify-content:space-between; gap:10px;
    margin:14px 0; font-size:13px;
}
.price-row { color:#684B37; }
.price-row strong,.total-row strong { color:var(--ink); white-space:nowrap; }
.discount,.discount strong { color:var(--green); }
.total-row {
    border-top:1px solid #D9C5AF; padding-top:18px;
    font-size:14px; font-weight:800;
}
.total-amount { color:var(--chocolate)!important; font-size:23px; }
.secure {
    margin-top:18px; padding:14px; background:#EFE0CD;
    border-radius:11px; font-size:11px; line-height:1.7; color:#604832;
}

/* Payment dialog */
.modal-backdrop,.success-overlay {
    display:none; position:fixed; inset:0; z-index:9999;
    padding:20px; background:#170D08C9;
    align-items:center; justify-content:center;
}
.modal-backdrop.show,.success-overlay.show { display:flex; }
.modal {
    width:min(470px,100%); max-height:90vh; overflow:auto;
    background:var(--cream); border-radius:18px; box-shadow:0 20px 70px #0004;
}
.modal-head {
    padding:20px 22px; background:#EFE0CD; border-bottom:1px solid #D9C5AF;
}
.modal-head-top { display:flex; justify-content:space-between; align-items:center; }
.modal-head h2 { font-size:22px; }
.modal-head p { color:var(--muted); font-size:12px; margin-bottom:0; }
.close-modal { border:0; background:transparent; font-size:24px; cursor:pointer; }
.modal-body { padding:20px 22px; }
.payment-total {
    padding:14px; background:#EFE0CD; border-radius:10px;
    display:flex; justify-content:space-between; font-size:13px;
    font-weight:800; margin-bottom:17px;
}
.pay-tabs { display:flex; gap:6px; margin-bottom:17px; }
.pay-tab {
    flex:1; padding:10px 5px; border:1px solid #D9C5AF;
    background:var(--cream-light); border-radius:8px;
    cursor:pointer; font-size:11px; font-weight:800;
}
.pay-tab.active { background:var(--chocolate); color:white; border-color:var(--chocolate); }
.pay-panel { display:none; }
.pay-panel.active { display:block; }
.pay-field {
    display:block; width:100%; padding:12px; margin:8px 0 13px;
    border:1px solid #D9C5AF; border-radius:8px;
    font-size:13px; background:#FFFCF8;
}
.pay-hint { color:var(--muted); font-size:11px; line-height:1.6; margin-bottom:13px; }
.pay-message {
    display:none; padding:11px; border-radius:8px;
    font-size:12px; margin:12px 0; line-height:1.5;
}
.pay-message.show { display:block; }
.pay-message.bad { background:#FFF0ED; color:#A33425; }
.pay-message.good { background:#EDF8ED; color:#286536; }
.pay-submit {
    width:100%; padding:13px; border:0; border-radius:9px;
    background:var(--chocolate); color:white; font-weight:800; cursor:pointer;
}
.pay-submit:disabled { opacity:.65; cursor:wait; }
.disclaimer { color:var(--muted); font-size:10px; text-align:center; line-height:1.6; margin-top:12px; }
.processing { display:none; text-align:center; padding:18px 8px; }
.processing.show { display:block; }
.coin {
    width:54px; height:54px; border-radius:50%;
    border:5px solid #EFE0CD; border-top-color:var(--accent);
    margin:0 auto 12px; animation:spin .8s linear infinite;
}
.processing p { font-size:13px; font-weight:800; color:var(--chocolate); }
@keyframes spin { to { transform:rotate(360deg); } }

.success-card {
    position:relative; background:var(--cream); border-radius:20px;
    padding:32px 24px; text-align:center; width:min(420px,100%); overflow:hidden;
}
.success-check {
    width:66px; height:66px; display:grid; place-items:center;
    margin:0 auto 15px; border-radius:50%;
    background:#EAF8E9; color:#2F8B43; font-size:34px;
}
.success-card h2 { margin-bottom:8px; }
.success-card p { font-size:13px; line-height:1.7; color:var(--muted); }
.confetti {
    position:absolute; top:-15px; width:8px; height:13px;
    animation:fall 2.2s linear infinite;
}
.confetti:nth-child(1) { left:8%; background:#E7A54A; }
.confetti:nth-child(2) { left:22%; background:#4A9B5B; animation-delay:.3s; }
.confetti:nth-child(3) { left:38%; background:#B87545; animation-delay:.7s; }
.confetti:nth-child(4) { left:62%; background:#4776B5; animation-delay:.2s; }
.confetti:nth-child(5) { left:78%; background:#D45D79; animation-delay:.9s; }
.confetti:nth-child(6) { left:92%; background:#E7A54A; animation-delay:.5s; }
@keyframes fall { to { transform:translateY(430px) rotate(480deg); opacity:0; } }

@media(max-width:900px) {
    .layout { grid-template-columns:1fr; }
    .summary { position:static; }
}
@media(max-width:600px) {
    .page { padding-top:25px; }
    .card { padding:18px; border-radius:18px; }
    .form-grid { grid-template-columns:1fr; }
    .group.full { grid-column:auto; }
    .step { gap:5px; }
    .step-label { display:none; }
    .steps { gap:6px; }
    .actions .btn { padding:10px; }
    .modal-body { padding:16px; }
    #locationMap { height:320px; }
    .item { grid-template-columns:60px minmax(0,1fr) auto; gap:9px; }
    .food-image { width:60px; height:60px; }
}
</style>
</head>

<body>

<jsp:include page="/includes/navbar.jsp" />

<main class="page">
    <header class="heading">
        <div class="eyebrow">ALMOST THERE</div>
        <h1>Complete your order</h1>
        <p>Just a few more steps to get your favourite food delivered.</p>
    </header>

    <% if (!error.isEmpty()) { %>
        <div class="error" role="alert"><%= esc(error) %></div>
    <% } %>

    <div class="steps">
        <div class="step active" id="indicator1"><span class="circle">1</span><span class="step-label">Delivery</span></div>
        <div class="step-line" id="line1"></div>
        <div class="step" id="indicator2"><span class="circle">2</span><span class="step-label">Payment</span></div>
        <div class="step-line" id="line2"></div>
        <div class="step" id="indicator3"><span class="circle">3</span><span class="step-label">Location</span></div>
        <div class="step-line" id="line3"></div>
        <div class="step" id="indicator4"><span class="circle">4</span><span class="step-label">Review</span></div>
    </div>

    <div class="layout">
        <div>
            <form action="<%= cp %>/checkout" method="post" id="checkoutForm">
                <input type="hidden" name="action" value="placeOrder">
                <input type="hidden" name="demoPaymentMethod" id="demoPaymentMethod" value="">
                <input type="hidden" name="demoPaymentReference" id="demoPaymentReference" value="">
                <input type="hidden" name="deliveryLatitude" id="deliveryLatitude" value="">
                <input type="hidden" name="deliveryLongitude" id="deliveryLongitude" value="">
                <input type="hidden" name="deliveryLocationText" id="deliveryLocationText" value="">

                <!-- STEP 1 -->
                <section class="card checkout-step active" id="step1">
                    <div class="card-title"><h2>Delivery details</h2><span>STEP 1 OF 4</span></div>

                    <div class="note">Enter the details where you want your order delivered. Select your exact location in Step 3.</div>

                    <div class="form-grid">
                        <div class="group">
                            <label for="fullName">Full name *</label>
                            <input id="fullName" name="fullName" value="<%= esc(username) %>" maxlength="100" autocomplete="name" required>
                        </div>
                        <div class="group">
                            <label for="phone">Phone number *</label>
                            <input id="phone" name="phone" type="tel" value="<%= esc(phone) %>"
                                   pattern="[0-9]{10}" maxlength="10" inputmode="numeric" autocomplete="tel" required>
                        </div>
                        <div class="group full">
                            <label for="address">Delivery address *</label>
                            <textarea id="address" name="address" maxlength="500" autocomplete="street-address" required><%= esc(address) %></textarea>
                        </div>
                        <div class="group">
                            <label for="landmark">Landmark (optional)</label>
                            <input id="landmark" name="landmark" maxlength="150" placeholder="Nearby landmark">
                        </div>
                        <div class="group">
                            <label for="city">City *</label>
                            <input id="city" name="city" value="Bengaluru" maxlength="100" required>
                        </div>
                        <div class="group">
                            <label for="pincode">Pincode *</label>
                            <input id="pincode" name="pincode" pattern="[0-9]{6}" maxlength="6" inputmode="numeric" placeholder="6-digit pincode" required>
                        </div>
                    </div>

                    <div class="address-types">
                        <label><input type="radio" name="addressType" value="HOME" checked> Home</label>
                        <label><input type="radio" name="addressType" value="WORK"> Work</label>
                        <label><input type="radio" name="addressType" value="OTHER"> Other</label>
                    </div>

                    <div class="actions">
                        <a class="btn secondary" href="<%= cp %>/cart">Back to cart</a>
                        <button class="btn primary" type="button" onclick="goToStep(2)">Continue to payment →</button>
                    </div>
                </section>

                <!-- STEP 2 -->
                <section class="card checkout-step" id="step2">
                    <div class="card-title"><h2>Choose payment</h2><span>STEP 2 OF 4</span></div>

                    <div class="note">Choose how you would like to pay. Online payment is simulated for this project; no real payment is taken.</div>

                    <div class="payment-options">
                        <div class="payment-option">
                            <input type="radio" id="cod" name="paymentMode" value="COD" checked>
                            <label class="payment-label" for="cod">
                                <span class="payment-code">COD</span>
                                <span class="payment-info"><strong>Cash on Delivery</strong><small>Pay when your order arrives.</small></span>
                                <span class="radio"></span>
                            </label>
                        </div>
                        <div class="payment-option">
                            <input type="radio" id="online" name="paymentMode" value="DEMO_ONLINE">
                            <label class="payment-label" for="online">
                                <span class="payment-code">UPI</span>
                                <span class="payment-info"><strong>UPI / Online Payment</strong><small>UPI, card, or net-banking simulation.</small></span>
                                <span class="radio"></span>
                            </label>
                        </div>
                    </div>

                    <div class="status" id="paymentStatus" role="status">Cash on Delivery is selected.</div>
                    <div class="actions">
                        <button class="btn secondary" type="button" onclick="goToStep(1)">← Back</button>
                        <button class="btn primary" type="button" onclick="goToStep(3)">Continue to location →</button>
                    </div>
                </section>

                <!-- STEP 3 -->
                <section class="card checkout-step" id="step3">
                    <div class="card-title"><h2>Delivery location</h2><span>STEP 3 OF 4</span></div>

                    <div class="note">Select your delivery point on the map or use GPS. Choosing a map location is optional; your written delivery address is still required.</div>
                    <button type="button" class="location-btn" id="getLocationBtn">⌖ Use my current location</button>
                    <div class="location-status" id="locationStatus" role="status">The map is centred on Bengaluru. Click the map to choose your delivery location.</div>
                    <div id="locationMap" aria-label="Interactive delivery location map"></div>
                    <div class="map-caption">Map data © OpenStreetMap contributors. Click anywhere on the map to move the delivery marker.</div>

                    <div class="review-box">
                        <div class="review-title">SELECTED LOCATION</div>
                        <div class="review-value" id="locationCoordinates">No location selected yet.</div>
                        <a class="map-link" id="mapLink" href="#" target="_blank" rel="noopener">Open location in Google Maps ↗</a>
                    </div>

                    <div class="actions">
                        <button class="btn secondary" type="button" onclick="goToStep(2)">← Back</button>
                        <button class="btn primary" type="button" onclick="goToStep(4)">Review your order →</button>
                    </div>
                </section>

                <!-- STEP 4 -->
                <section class="card checkout-step" id="step4">
                    <div class="card-title"><h2>Review your order</h2><span>STEP 4 OF 4</span></div>

                    <div class="review-box">
                        <div class="review-title">DELIVERY DETAILS</div>
                        <div class="review-value" id="reviewAddress">Your address will appear here.</div>
                    </div>
                    <div class="review-box">
                        <div class="review-title">DELIVERY LOCATION</div>
                        <div class="review-value" id="reviewLocation">No map location selected. Your written address will be used.</div>
                        <a class="map-link" id="reviewMapLink" href="#" target="_blank" rel="noopener">View delivery location ↗</a>
                    </div>
                    <div class="review-box">
                        <div class="review-title">PAYMENT METHOD</div>
                        <div class="review-value" id="reviewPayment">Cash on Delivery</div>
                    </div>

                    <div class="actions">
                        <button class="btn secondary" type="button" onclick="goToStep(3)">← Back</button>
                        <button class="btn primary" type="submit" id="placeOrderButton">Place Order · ₹<%= money(total) %></button>
                    </div>
                </section>
            </form>
        </div>

        <!-- RIGHT-SIDE ORDER SUMMARY: FOOD IMAGES, NAMES, QUANTITIES AND PRICES REMAIN HERE -->
        <aside class="card summary">
            <h2>Your order</h2>
            <div class="items">
                <% for (Map.Entry<Integer, List<CartItem>> restaurantEntry : restaurantGroups.entrySet()) {
                    int groupRestaurantId = restaurantEntry.getKey();
                    BigDecimal restaurantSubtotal = BigDecimal.ZERO;
                %>
                    <div class="restaurant-bill-group">
                        <div class="restaurant-bill-heading">🍽️ <%= esc(restaurantNames.get(groupRestaurantId)) %></div>
                        <% for (CartItem item : restaurantEntry.getValue()) {
                            if (item == null || item.getPrice() == null || item.getQuantity() <= 0) continue;
                            String dishName = item.getItemName();
                            String imageUrl = foodImage(item, cp);
                            restaurantSubtotal = restaurantSubtotal.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                        %>
                            <div class="item">
                                <img class="food-image" src="<%= esc(imageUrl) %>" alt="<%= esc(dishName) %>" loading="eager"
                                     onerror="this.onerror=null;this.src='https://placehold.co/120x120/F5E9D8/48230F?text=Food';">
                                <div>
                                    <div class="item-name"><%= esc(dishName) %></div>
                                    <span class="item-qty">Qty: <%= item.getQuantity() %></span>
                                </div>
                                <div class="item-price">₹<%= money(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()))) %></div>
                            </div>
                        <% } %>
                        <div class="restaurant-bill-subtotal"><span>Restaurant subtotal</span><strong>₹<%= money(restaurantSubtotal) %></strong></div>
                        <div class="restaurant-bill-subtotal"><span>Delivery fee</span><strong>₹<%= money(deliveryFeePerRestaurant) %></strong></div>
                    </div>
                <% } %>
            </div>

            <div style="padding-top:12px">
                <div class="price-row"><span>Subtotal (<%= cartCount %> items)</span><strong>₹<%= money(subtotal) %></strong></div>
                <div class="price-row"><span>Delivery fee (<%= restaurantGroups.size() %> restaurant(s))</span><strong>₹<%= money(deliveryFee) %></strong></div>
                <% if (discount.compareTo(BigDecimal.ZERO) > 0) { %>
                    <div class="price-row discount"><span>Yumlet discount</span><strong>− ₹<%= money(discount) %></strong></div>
                <% } %>
                <% if (couponDiscount.compareTo(BigDecimal.ZERO) > 0) { %>
                    <div class="price-row discount"><span>Coupon (<%= esc(checkoutCoupon) %>)</span><strong>− ₹<%= money(couponDiscount) %></strong></div>
                <% } %>
            </div>
            <div class="total-row"><span>Total</span><strong class="total-amount">₹<%= money(total) %></strong></div>
            <div class="secure"><strong>Secure checkout</strong><br>Online payment is simulated only. No real money will be charged.</div>
        </aside>
    </div>
</main>

<!-- PAYMENT MODAL -->
<div class="modal-backdrop" id="paymentModal" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="modal">
        <div class="modal-head">
            <div class="modal-head-top">
                <h2 id="modalTitle">Eatero Payments</h2>
                <button type="button" class="close-modal" onclick="closePaymentModal()" aria-label="Close">&times;</button>
            </div>
            <p>Choose a simulated payment method.</p>
        </div>
        <div class="modal-body">
            <div class="payment-total"><span>Total amount</span><span>₹<%= money(total) %></span></div>
            <div class="pay-tabs">
                <button class="pay-tab active" type="button" data-panel="upiPanel">UPI</button>
                <button class="pay-tab" type="button" data-panel="cardPanel">Card</button>
                <button class="pay-tab" type="button" data-panel="bankPanel">Net Banking</button>
            </div>

            <div class="pay-panel active" id="upiPanel">
                <label for="upiApp" style="font-size:12px;font-weight:800">Choose UPI app</label>
                <select class="pay-field" id="upiApp">
                    <option value="PhonePe">PhonePe</option>
                    <option value="Google Pay">Google Pay</option>
                    <option value="Paytm">Paytm</option>
                    <option value="BHIM">BHIM</option>
                    <option value="Other UPI">Other UPI app</option>
                </select>
                <label for="upiId" style="font-size:12px;font-weight:800">Test UPI ID</label>
                <input class="pay-field" id="upiId" placeholder="demo@upi" autocomplete="off">
                <div class="pay-hint">Simulation only. No real UPI app is contacted.</div>
            </div>

            <div class="pay-panel" id="cardPanel">
                <label for="cardName" style="font-size:12px;font-weight:800">Name on test card</label>
                <input class="pay-field" id="cardName" placeholder="Cardholder name" autocomplete="off">
                <label for="cardNumber" style="font-size:12px;font-weight:800">Test card number</label>
                <input class="pay-field" id="cardNumber" placeholder="4242 4242 4242 4242" inputmode="numeric" maxlength="19" autocomplete="off">
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                    <div>
                        <label for="expiry" style="font-size:12px;font-weight:800">Expiry</label>
                        <input class="pay-field" id="expiry" placeholder="MM/YY" maxlength="5" autocomplete="off">
                    </div>
                    <div>
                        <label for="cvv" style="font-size:12px;font-weight:800">CVV</label>
                        <input class="pay-field" id="cvv" placeholder="123" inputmode="numeric" maxlength="4" autocomplete="off">
                    </div>
                </div>
                <div class="pay-hint">Use fictional test details only. Do not enter real card details.</div>
            </div>

            <div class="pay-panel" id="bankPanel">
                <label for="bankName" style="font-size:12px;font-weight:800">Choose test bank</label>
                <select class="pay-field" id="bankName">
                    <option value="">Select bank</option>
                    <option value="BANK_1">Bank One</option>
                    <option value="BANK_2">Bank Two</option>
                    <option value="BANK_3">Bank Three</option>
                </select>
                <div class="pay-hint">This simulates the net-banking flow.</div>
            </div>

            <div class="processing" id="processing">
                <div class="coin"></div><p>Processing your payment…</p><div class="pay-hint">Please wait.</div>
            </div>
            <div class="pay-message" id="paymentMessage" role="status"></div>
            <button class="pay-submit" type="button" id="simulatePaymentButton" onclick="simulatePayment()">Pay ₹<%= money(total) %></button>
            <div class="disclaimer">Simulated payment only. No real transaction occurs.</div>
        </div>
    </div>
</div>

<!-- PAYMENT SUCCESS -->
<div class="success-overlay" id="successOverlay" role="dialog" aria-modal="true" aria-labelledby="successTitle">
    <div class="success-card">
        <span class="confetti"></span><span class="confetti"></span><span class="confetti"></span>
        <span class="confetti"></span><span class="confetti"></span><span class="confetti"></span>
        <div class="success-check">✓</div>
        <h2 id="successTitle">Payment Successful!</h2>
        <p id="successText">Your simulated payment was successful.</p>
        <button class="btn primary" type="button" onclick="finishPaymentSuccess()">Continue to location</button>
    </div>
</div>

<script>
let currentStep = 1;
let paymentCompleted = false;
let paymentReference = "";
let activeMethod = "UPI";
let selectedUpiApp = "PhonePe";
let locationMap = null;
let locationMarker = null;

function initLocationMap() {
    if (locationMap || !window.L) return;

    locationMap = L.map("locationMap").setView([12.9716, 77.5946], 12);
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom:19,
        attribution:'&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener">OpenStreetMap</a> contributors'
    }).addTo(locationMap);

    locationMap.on("click", function(event) {
        setSelectedLocation(event.latlng.lat, event.latlng.lng, "Map location selected");
    });

    const lat = document.getElementById("deliveryLatitude").value;
    const lon = document.getElementById("deliveryLongitude").value;
    if (lat && lon) setSelectedLocation(Number(lat), Number(lon), "Saved location");

    setTimeout(function() { locationMap.invalidateSize(); }, 150);
}

function setSelectedLocation(lat, lon, label) {
    lat = Number(lat);
    lon = Number(lon);
    if (!Number.isFinite(lat) || !Number.isFinite(lon)) return;

    const latitude = lat.toFixed(6);
    const longitude = lon.toFixed(6);

    document.getElementById("deliveryLatitude").value = latitude;
    document.getElementById("deliveryLongitude").value = longitude;
    document.getElementById("deliveryLocationText").value = label;

    if (locationMap && window.L) {
        const point = [lat, lon];
        if (locationMarker) locationMarker.setLatLng(point);
        else locationMarker = L.marker(point).addTo(locationMap);

        locationMarker.bindPopup("<strong>Delivery location</strong><br>" +
            latitude + ", " + longitude).openPopup();

        locationMap.setView(point, Math.max(locationMap.getZoom(), 15));
    }

    document.getElementById("locationCoordinates").textContent =
        "Latitude: " + latitude + " · Longitude: " + longitude;
    document.getElementById("locationStatus").textContent =
        label + ". Click another point to change your delivery location.";

    document.getElementById("mapLink").href =
        "https://www.google.com/maps?q=" + encodeURIComponent(latitude + "," + longitude);
    document.getElementById("mapLink").style.display = "inline-block";
}

function validateStep(step) {
    const section = document.getElementById("step" + step);
    if (!section) return false;

    for (const input of section.querySelectorAll(
        "input[required],textarea[required],select[required]"
    )) {
        if (!input.checkValidity()) {
            input.reportValidity();
            input.focus();
            return false;
        }
    }

    if (step === 2) {
        const selected = document.querySelector('input[name="paymentMode"]:checked');
        if (!selected) {
            alert("Please choose a payment method.");
            return false;
        }
        if (selected.value === "DEMO_ONLINE" && !paymentCompleted) {
            openPaymentModal();
            return false;
        }
    }
    return true;
}

function safeText(value) {
    return String(value || "").replace(/[&<>"']/g, function(ch) {
        return {"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[ch];
    });
}

function updateReview() {
    const name = document.getElementById("fullName").value.trim();
    const phoneValue = document.getElementById("phone").value.trim();
    const addressValue = document.getElementById("address").value.trim();
    const landmark = document.getElementById("landmark").value.trim();
    const city = document.getElementById("city").value.trim();
    const pin = document.getElementById("pincode").value.trim();

    let html = "<strong>" + safeText(name) + "</strong><br>" +
        safeText(phoneValue) + "<br>" + safeText(addressValue);
    if (landmark) html += "<br>Near " + safeText(landmark);
    html += "<br>" + safeText(city) + " - " + safeText(pin);
    document.getElementById("reviewAddress").innerHTML = html;

    const lat = document.getElementById("deliveryLatitude").value;
    const lon = document.getElementById("deliveryLongitude").value;
    const locationText = document.getElementById("deliveryLocationText").value;
    const reviewLocation = document.getElementById("reviewLocation");
    const reviewMapLink = document.getElementById("reviewMapLink");

    if (lat && lon) {
        reviewLocation.textContent = (locationText ? locationText + " · " : "") +
            "Latitude: " + lat + ", Longitude: " + lon;
        reviewMapLink.href = "https://www.google.com/maps?q=" +
            encodeURIComponent(lat + "," + lon);
        reviewMapLink.style.display = "inline-block";
    } else {
        reviewLocation.textContent =
            "No map location selected. Your written address will be used.";
        reviewMapLink.style.display = "none";
    }

    const selected = document.querySelector('input[name="paymentMode"]:checked');
    let paymentText = "Cash on Delivery";

    if (selected && selected.value === "DEMO_ONLINE") {
        paymentText = paymentCompleted
            ? "Online payment successful (" + activeMethod + "). Reference: " + paymentReference
            : "Online payment not completed";
    }
    document.getElementById("reviewPayment").textContent = paymentText;
}

function goToStep(step) {
    if (step < 1 || step > 4) return;
    if (step > currentStep && !validateStep(currentStep)) return;

    document.querySelectorAll(".checkout-step").forEach(function(section) {
        section.classList.remove("active");
    });
    document.getElementById("step" + step).classList.add("active");

    for (let i = 1; i <= 4; i++) {
        const indicator = document.getElementById("indicator" + i);
        indicator.classList.toggle("active", i === step);
        indicator.classList.toggle("completed", i < step);
    }

    document.getElementById("line1").classList.toggle("completed", step >= 2);
    document.getElementById("line2").classList.toggle("completed", step >= 3);
    document.getElementById("line3").classList.toggle("completed", step >= 4);

    currentStep = step;

    if (step === 3) {
        initLocationMap();
        setTimeout(function() {
            if (locationMap) locationMap.invalidateSize();
        }, 200);
    }
    if (step === 4) updateReview();

    window.scrollTo({top:0, behavior:"smooth"});
}

function openPaymentModal() {
    document.getElementById("paymentModal").classList.add("show");
    showPaymentMessage("", "");
}

function closePaymentModal() {
    document.getElementById("paymentModal").classList.remove("show");
}

function showPaymentMessage(message, type) {
    const element = document.getElementById("paymentMessage");
    element.textContent = message;
    element.className = "pay-message" + (message ? " show " + type : "");
}

document.querySelectorAll(".pay-tab").forEach(function(tab) {
    tab.addEventListener("click", function() {
        document.querySelectorAll(".pay-tab").forEach(function(item) {
            item.classList.remove("active");
        });
        document.querySelectorAll(".pay-panel").forEach(function(panel) {
            panel.classList.remove("active");
        });

        tab.classList.add("active");
        document.getElementById(tab.dataset.panel).classList.add("active");

        activeMethod = tab.dataset.panel === "upiPanel" ? "UPI" :
            tab.dataset.panel === "cardPanel" ? "CARD" : "NETBANKING";
        showPaymentMessage("", "");
    });
});

document.getElementById("upiApp").addEventListener("change", function() {
    selectedUpiApp = this.value;
    activeMethod = "UPI";
});

document.querySelectorAll('input[name="paymentMode"]').forEach(function(radio) {
    radio.addEventListener("change", function() {
        if (radio.value === "COD") {
            paymentCompleted = false;
            paymentReference = "";
            document.getElementById("demoPaymentMethod").value = "";
            document.getElementById("demoPaymentReference").value = "";
            document.getElementById("paymentStatus").textContent = "Cash on Delivery is selected.";
        } else {
            document.getElementById("paymentStatus").textContent = paymentCompleted
                ? "Payment completed successfully."
                : "Complete the online payment before placing the order.";
        }
    });
});

async function simulatePayment() {
    const button = document.getElementById("simulatePaymentButton");
    const method = activeMethod;

    if (method === "UPI") {
        const upi = document.getElementById("upiId").value.trim();
        if (!/^[a-zA-Z0-9._-]{2,256}@[a-zA-Z0-9.-]{2,64}$/.test(upi)) {
            showPaymentMessage("Enter a valid test UPI ID, such as demo@upi.", "bad");
            return;
        }
    } else if (method === "CARD") {
        const name = document.getElementById("cardName").value.trim();
        const number = document.getElementById("cardNumber").value.replace(/\s/g, "");
        const expiry = document.getElementById("expiry").value.trim();
        const cvv = document.getElementById("cvv").value.trim();

        if (!name || !/^\d{16}$/.test(number) ||
            !/^(0[1-9]|1[0-2])\/\d{2}$/.test(expiry) ||
            !/^\d{3,4}$/.test(cvv)) {
            showPaymentMessage("Enter valid fictional test card details.", "bad");
            return;
        }
    } else if (method === "NETBANKING" && !document.getElementById("bankName").value) {
        showPaymentMessage("Choose a bank first.", "bad");
        return;
    }

    button.disabled = true;
    button.style.display = "none";
    document.querySelectorAll(".pay-tabs,.pay-panel,.disclaimer").forEach(function(element) {
        element.style.display = "none";
    });
    document.getElementById("paymentMessage").style.display = "none";
    document.getElementById("processing").classList.add("show");

    const processingStart = Date.now();

    try {
        const startResponse = await fetch("<%= cp %>/demo-payment", {
            method:"POST",
            headers:{"Content-Type":"application/x-www-form-urlencoded"},
            body:new URLSearchParams({action:"start"})
        });
        const startResult = await startResponse.json();

        if (!startResponse.ok || !startResult.success || !startResult.reference) {
            throw new Error(startResult.message || "Could not start payment. Please try again.");
        }

        const reference = startResult.reference;
        const response = await fetch("<%= cp %>/demo-payment", {
            method:"POST",
            headers:{"Content-Type":"application/x-www-form-urlencoded"},
            body:new URLSearchParams({
                action:"confirm",
                reference:reference,
                method:method,
                result:"SUCCESS"
            })
        });
        const result = await response.json();

        if (!response.ok || !result.success || result.status !== "SUCCESS") {
            throw new Error(result.message || "Payment could not be completed. Please try again.");
        }

        const remaining = 3000 - (Date.now() - processingStart);
        if (remaining > 0) await new Promise(resolve => setTimeout(resolve, remaining));

        paymentReference = result.reference || reference;
        paymentCompleted = true;
        document.getElementById("demoPaymentMethod").value = method;
        document.getElementById("demoPaymentReference").value = paymentReference;
        document.getElementById("paymentStatus").textContent = "Payment successful. Reference: " + paymentReference;
        document.getElementById("online").checked = true;

        document.getElementById("processing").classList.remove("show");
        closePaymentModal();

        document.getElementById("successText").textContent =
            "Your " + (method === "UPI" ? selectedUpiApp : method) +
            " simulated payment is successful. Reference: " + paymentReference +
            ". No money was charged.";

        updateReview();
        document.getElementById("successOverlay").classList.add("show");

    } catch (error) {
        document.getElementById("processing").classList.remove("show");
        document.querySelectorAll(".pay-tabs,.pay-panel,.disclaimer").forEach(function(element) {
            element.style.display = "";
        });
        button.style.display = "block";
        button.disabled = false;
        showPaymentMessage(error.message || "Could not reach the payment service.", "bad");
    }
}

function finishPaymentSuccess() {
    document.getElementById("successOverlay").classList.remove("show");
    goToStep(3);
}

document.getElementById("checkoutForm").addEventListener("submit", function(event) {
    if (currentStep !== 4) {
        event.preventDefault();
        alert("Please complete the checkout steps first.");
        return;
    }

    if (!validateStep(1)) {
        event.preventDefault();
        goToStep(1);
        return;
    }

    const selected = document.querySelector('input[name="paymentMode"]:checked');
    if (selected && selected.value === "DEMO_ONLINE" && !paymentCompleted) {
        event.preventDefault();
        goToStep(2);
        openPaymentModal();
        return;
    }

    const button = document.getElementById("placeOrderButton");
    button.disabled = true;
    button.textContent = "Placing order...";
});

document.getElementById("paymentModal").addEventListener("click", function(event) {
    if (event.target === this) closePaymentModal();
});

document.getElementById("getLocationBtn").addEventListener("click", function() {
    const status = document.getElementById("locationStatus");

    if (!navigator.geolocation) {
        status.textContent = "Geolocation is not supported. Click the map to select a location.";
        return;
    }

    status.textContent = "Getting your current location…";

    navigator.geolocation.getCurrentPosition(function(position) {
        setSelectedLocation(
            position.coords.latitude,
            position.coords.longitude,
            "Current GPS location selected"
        );

        if (locationMap) {
            locationMap.setView([
                position.coords.latitude,
                position.coords.longitude
            ], 16);
        }
    }, function(error) {
        status.textContent = error.code === 1
            ? "Location permission denied. You can click the map to select a location."
            : "Could not get GPS location. Try clicking the map instead.";
    }, {
        enableHighAccuracy:true,
        timeout:12000,
        maximumAge:60000
    });
});
</script>

<jsp:include page="/includes/footer.jsp" />

</body>
</html>
