
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Offers | Yumlet</title>

<link rel="stylesheet"
    href="${pageContext.request.contextPath}/css/common.css">
<link rel="stylesheet"
    href="${pageContext.request.contextPath}/css/navbar.css">
<link rel="stylesheet"
    href="${pageContext.request.contextPath}/css/footer.css">

<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&display=swap"
    rel="stylesheet">

<style>
:root {
    --chocolate: #48230F;
    --dark-cocoa: #30170D;
    --cream: #F5E9D8;
    --beige: #E8D3B9;
    --beige-dark: #D7BFA3;
    --caramel: #B87545;
    --muted-brown: #76533B;
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    margin: 0;
    font-family: 'DM Sans', sans-serif;
    background: var(--dark-cocoa);
    color: var(--cream);
}

button {
    font-family: inherit;
}

.offers-page {
    min-height: 100vh;
    padding: 45px 7% 75px;
    background:
        radial-gradient(ellipse at 15% 5%, rgba(184,117,69,.19), transparent 35%),
        radial-gradient(ellipse at 90% 30%, rgba(72,35,15,.65), transparent 38%),
        var(--dark-cocoa);
}

.offers-container {
    max-width: 1250px;
    margin: 0 auto;
}

/* HERO BANNER */

.offers-hero {
    position: relative;
    overflow: hidden;
    padding: 60px 55px;
    border: 1px solid rgba(245,233,216,.15);
    border-radius: 28px;
    background: linear-gradient(125deg, var(--chocolate), var(--dark-cocoa) 75%);
    box-shadow: 0 25px 65px rgba(0,0,0,.22);
}

.offers-hero::after {
    content: "%";
    position: absolute;
    right: 8%;
    top: 50%;
    transform: translateY(-50%) rotate(12deg);
    font-family: 'Playfair Display', serif;
    font-size: clamp(150px, 24vw, 300px);
    font-weight: 800;
    line-height: 1;
    color: rgba(245,233,216,.055);
    pointer-events: none;
}

.hero-content {
    position: relative;
    z-index: 1;
    max-width: 650px;
}

.hero-tag {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 9px 15px;
    border: 1px solid rgba(245,233,216,.22);
    border-radius: 30px;
    background: var(--beige);
    color: var(--chocolate);
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 1.4px;
    text-transform: uppercase;
}

.offers-hero h1 {
    margin: 24px 0 16px;
    font-family: 'Playfair Display', serif;
    font-size: clamp(38px, 5vw, 65px);
    line-height: 1.12;
    letter-spacing: -1.5px;
    color: var(--cream);
}

.offers-hero h1 span {
    color: var(--caramel);
}

.offers-hero p {
    max-width: 520px;
    margin: 0;
    color: #D7C2A8;
    font-size: 16px;
    line-height: 1.8;
}

.hero-note {
    display: inline-block;
    margin-top: 25px;
    padding: 12px 17px;
    border: 1px solid var(--beige-dark);
    border-radius: 10px;
    background: var(--beige);
    color: var(--chocolate);
    font-size: 13px;
    font-weight: 700;
}

/* SECTION HEADINGS */

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: end;
    gap: 20px;
    margin: 55px 0 25px;
}

.section-heading h2 {
    margin: 0 0 8px;
    font-family: 'Playfair Display', serif;
    font-size: clamp(28px, 3vw, 38px);
    color: var(--cream);
}

.section-heading p {
    margin: 0;
    color: #D7C2A8;
    font-size: 14px;
    line-height: 1.7;
}

.offer-count {
    flex-shrink: 0;
    padding: 10px 15px;
    border: 1px solid var(--beige-dark);
    border-radius: 30px;
    background: var(--cream);
    color: var(--chocolate);
    font-size: 12px;
    font-weight: 800;
}

/* OFFER GRID */

.offers-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 22px;
}

/* LARGE BEIGE OFFER BOXES */

.offer-card {
    position: relative;
    display: flex;
    flex-direction: column;
    min-width: 0;
    padding: 27px;
    overflow: hidden;
    border: 1px solid var(--beige-dark);
    border-radius: 22px;
    background: var(--cream);
    color: var(--chocolate);
    box-shadow: 0 12px 30px rgba(0,0,0,.18);
    transition: transform .25s ease, box-shadow .25s ease;
}

.offer-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 20px 35px rgba(0,0,0,.25);
}

/* SMALL ICON BOXES */

.offer-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 24px;
}

.offer-icon {
    display: grid;
    place-items: center;
    width: 52px;
    height: 52px;
    flex-shrink: 0;
    border: 1px solid var(--beige-dark);
    border-radius: 16px;
    background: var(--beige);
    font-size: 25px;
}

/* BADGE BOXES */

.offer-badge {
    padding: 8px 11px;
    border: 1px solid var(--beige-dark);
    border-radius: 30px;
    background: var(--beige);
    color: var(--chocolate);
    font-size: 10px;
    font-weight: 800;
    letter-spacing: .7px;
    text-transform: uppercase;
}

/* DISCOUNT TEXT */

.discount {
    margin: 0 0 9px;
    color: var(--caramel);
    font-size: clamp(30px, 3vw, 43px);
    font-weight: 800;
    letter-spacing: -1.5px;
}

.offer-card h3 {
    margin: 0 0 10px;
    color: var(--chocolate);
    font-size: 19px;
    font-weight: 800;
}

.offer-description {
    min-height: 48px;
    margin: 0;
    color: var(--muted-brown);
    font-size: 13px;
    line-height: 1.8;
}

.offer-divider {
    margin: 23px 0 17px;
    border: 0;
    border-top: 1px dashed var(--beige-dark);
}

/* OFFER CONDITIONS */

.offer-terms {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-bottom: 22px;
}

.term-row {
    display: flex;
    align-items: center;
    gap: 9px;
    color: var(--muted-brown);
    font-size: 12px;
}

.term-check {
    color: var(--caramel);
    font-weight: 800;
}

/* SMALL COUPON BOXES */

.coupon-label {
    margin-bottom: 8px;
    color: var(--muted-brown);
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1.2px;
    text-transform: uppercase;
}

.coupon-box {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    padding: 10px;
    border: 1px dashed var(--caramel);
    border-radius: 12px;
    background: var(--beige);
}

.coupon-code {
    overflow-wrap: anywhere;
    color: var(--chocolate);
    font-size: 13px;
    font-weight: 800;
    letter-spacing: 1.1px;
}

/* CARAMEL BUTTONS */

.copy-btn {
    flex-shrink: 0;
    padding: 10px 12px;
    border: 1px solid var(--caramel);
    border-radius: 8px;
    background: var(--caramel);
    color: var(--dark-cocoa);
    cursor: pointer;
    font-size: 11px;
    font-weight: 800;
    transition: background .2s ease, color .2s ease, transform .2s ease;
}

.copy-btn:hover {
    transform: translateY(-2px);
    background: var(--chocolate);
    border-color: var(--chocolate);
    color: var(--cream);
}

.copy-btn:focus-visible {
    outline: 2px solid var(--chocolate);
    outline-offset: 3px;
}

.copy-message {
    min-height: 17px;
    margin-top: 8px;
    color: var(--muted-brown);
    font-size: 11px;
}

/* HOW TO USE SECTION */

.how-section {
    margin-top: 65px;
}

.how-section > h2 {
    margin: 0 0 25px;
    font-family: 'Playfair Display', serif;
    font-size: 32px;
    color: var(--cream);
}

.how-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 20px;
}

/* ALL HOW-TO CARDS BEIGE */

.how-card {
    padding: 25px;
    border: 1px solid var(--beige-dark);
    border-radius: 18px;
    background: var(--cream);
    color: var(--chocolate);
    box-shadow: 0 10px 25px rgba(0,0,0,.15);
    transition: transform .25s ease, box-shadow .25s ease;
}

.how-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 18px 30px rgba(0,0,0,.22);
}

/* NUMBER BOXES */

.how-number {
    display: grid;
    place-items: center;
    width: 42px;
    height: 42px;
    margin-bottom: 17px;
    border: 1px solid var(--caramel);
    border-radius: 12px;
    background: var(--caramel);
    color: var(--dark-cocoa);
    font-weight: 800;
}

.how-card h3 {
    margin: 0 0 9px;
    color: var(--chocolate);
    font-size: 16px;
}

.how-card p {
    margin: 0;
    color: var(--muted-brown);
    font-size: 13px;
    line-height: 1.8;
}

/* BEIGE INFORMATION BOX */

.offers-note {
    margin-top: 35px;
    padding: 20px 22px;
    border: 1px solid var(--beige-dark);
    border-left: 4px solid var(--caramel);
    border-radius: 12px;
    background: var(--cream);
    color: var(--muted-brown);
    font-size: 12px;
    line-height: 1.8;
}

.offers-note strong {
    color: var(--chocolate);
}

/* RESPONSIVE DESIGN */

@media (max-width: 950px) {
    .offers-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .offers-hero {
        padding: 45px 35px;
    }
}

@media (max-width: 620px) {
    .offers-page {
        padding: 25px 16px 50px;
    }

    .offers-hero {
        padding: 35px 23px;
        border-radius: 21px;
    }

    .offers-hero::after {
        right: -10px;
        top: 25%;
        font-size: 160px;
    }

    .offers-hero p {
        font-size: 14px;
    }

    .section-heading {
        align-items: start;
        flex-direction: column;
        margin-top: 40px;
    }

    .offers-grid,
    .how-grid {
        grid-template-columns: 1fr;
    }

    .offer-card {
        padding: 23px;
    }

    .offer-description {
        min-height: auto;
    }

    .how-section {
        margin-top: 45px;
    }

    .coupon-box {
        flex-wrap: wrap;
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

<main class="offers-page">
<div class="offers-container">

    <!-- HERO BANNER -->
    <section class="offers-hero">
        <div class="hero-content">

            <span class="hero-tag">✦ THE YUMLET SPECIALS</span>

            <h1>
                Good food.<br>
                <span>Better deals.</span>
            </h1>

            <p>
                Your favourite cravings deserve something extra.
                Explore our special coupon offers and make every
                Yumlet order a little more rewarding.
            </p>

            <div class="hero-note">
                🍽️ Choose an offer and copy its coupon code
            </div>

        </div>
    </section>

    <!-- AVAILABLE OFFERS -->
    <section>
        <div class="section-heading">
            <div>
                <h2>Offers made for you</h2>
                <p>Pick your favourite deal and keep the code handy.</p>
            </div>

            <span class="offer-count">3 SPECIAL DEALS</span>
        </div>

        <div class="offers-grid">

            <!-- OFFER ONE -->
            <article class="offer-card">

                <div class="offer-top">
                    <div class="offer-icon">🍔</div>
                    <span class="offer-badge">Popular</span>
                </div>

                <div class="discount">10% OFF</div>

                <h3>A delicious first step</h3>

                <p class="offer-description">
                    Enjoy a little saving on an eligible food order.
                    Perfect for your next craving.
                </p>

                <hr class="offer-divider">

                <div class="offer-terms">
                    <div class="term-row">
                        <span class="term-check">✓</span>
                        Minimum order: ₹299
                    </div>

                    <div class="term-row">
                        <span class="term-check">✓</span>
                        Maximum discount: ₹100
                    </div>
                </div>

                <div class="coupon-label">Your coupon code</div>

                <div class="coupon-box">
                    <span class="coupon-code">YUM10</span>

                    <button class="copy-btn" type="button"
                        data-code="YUM10" onclick="copyCoupon(this)">
                        Copy Code
                    </button>
                </div>

                <div class="copy-message" aria-live="polite"></div>

            </article>

            <!-- OFFER TWO -->
            <article class="offer-card">

                <div class="offer-top">
                    <div class="offer-icon">🍕</div>
                    <span class="offer-badge">Big Savings</span>
                </div>

                <div class="discount">₹100 OFF</div>

                <h3>More food, more joy</h3>

                <p class="offer-description">
                    Planning a bigger meal? Save more when your
                    eligible order reaches the minimum amount.
                </p>

                <hr class="offer-divider">

                <div class="offer-terms">
                    <div class="term-row">
                        <span class="term-check">✓</span>
                        Minimum order: ₹699
                    </div>

                    <div class="term-row">
                        <span class="term-check">✓</span>
                        Flat ₹100 discount
                    </div>
                </div>

                <div class="coupon-label">Your coupon code</div>

                <div class="coupon-box">
                    <span class="coupon-code">FEAST100</span>

                    <button class="copy-btn" type="button"
                        data-code="FEAST100" onclick="copyCoupon(this)">
                        Copy Code
                    </button>
                </div>

                <div class="copy-message" aria-live="polite"></div>

            </article>

            <!-- OFFER THREE -->
            <article class="offer-card">

                <div class="offer-top">
                    <div class="offer-icon">🍰</div>
                    <span class="offer-badge">For Foodies</span>
                </div>

                <div class="discount">15% OFF</div>

                <h3>A little extra happiness</h3>

                <p class="offer-description">
                    Turn your next meal into a treat with this
                    percentage-off coupon.
                </p>

                <hr class="offer-divider">

                <div class="offer-terms">
                    <div class="term-row">
                        <span class="term-check">✓</span>
                        Minimum order: ₹499
                    </div>

                    <div class="term-row">
                        <span class="term-check">✓</span>
                        Maximum discount: ₹150
                    </div>
                </div>

                <div class="coupon-label">Your coupon code</div>

                <div class="coupon-box">
                    <span class="coupon-code">YUMLOVE15</span>

                    <button class="copy-btn" type="button"
                        data-code="YUMLOVE15" onclick="copyCoupon(this)">
                        Copy Code
                    </button>
                </div>

                <div class="copy-message" aria-live="polite"></div>

            </article>

        </div>
    </section>

    <!-- HOW TO USE COUPONS -->
    <section class="how-section">

        <h2>How to use a coupon</h2>

        <div class="how-grid">

            <article class="how-card">
                <div class="how-number">01</div>

                <h3>Choose your deal</h3>

                <p>
                    Pick the offer that suits your order and check
                    its minimum order requirement.
                </p>
            </article>

            <article class="how-card">
                <div class="how-number">02</div>

                <h3>Copy the code</h3>

                <p>
                    Use the Copy Code button to copy the coupon
                    to your clipboard.
                </p>
            </article>

            <article class="how-card">
                <div class="how-number">03</div>

                <h3>Apply at checkout</h3>

                <p>
                    Enter the code during checkout once coupon
                    redemption is connected to your application.
                </p>
            </article>

        </div>

        <!-- INFORMATION BOX -->
        <div class="offers-note">
            <strong>Good to know:</strong>
            These coupon codes are currently sample promotional offers.
            Copying a code works, but the discount will not change your
            order total until we connect coupon validation to your Java
            checkout controller.
        </div>

    </section>

</div>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
function copyCoupon(button) {
    const code = button.getAttribute("data-code");
    const card = button.closest(".offer-card");
    const message = card.querySelector(".copy-message");
    const originalText = "Copy Code";

    function showCopied() {
        message.textContent = "✓ " + code + " copied!";
        button.textContent = "Copied!";

        window.setTimeout(function () {
            button.textContent = originalText;
        }, 1800);
    }

    function showError() {
        message.textContent =
            "Copy unavailable. Please copy: " + code;
    }

    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(code)
            .then(showCopied)
            .catch(function () {
                fallbackCopy(code, showCopied, showError);
            });
    } else {
        fallbackCopy(code, showCopied, showError);
    }
}

function fallbackCopy(code, onSuccess, onError) {
    const textArea = document.createElement("textarea");

    textArea.value = code;
    textArea.setAttribute("readonly", "");
    textArea.style.position = "fixed";
    textArea.style.left = "-9999px";

    document.body.appendChild(textArea);
    textArea.select();

    try {
        const copied = document.execCommand("copy");

        if (copied) {
            onSuccess();
        } else {
            onError();
        }
    } catch (error) {
        onError();
    } finally {
        document.body.removeChild(textArea);
    }
}
</script>

</body>
</html>