
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,java.util.ArrayList,com.tap.model.Menu,com.tap.daoImpl.MenuDaoImpl" %>

<%!
    private String rouletteHtmlEscape(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("'", "&#39;");
    }

    private String rouletteJsonEscape(String value) {
        if (value == null) return "";

        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\r", "\\r")
                    .replace("\n", "\\n")
                    .replace("\t", "\\t")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\u2028", "\\u2028")
                    .replace("\u2029", "\\u2029")
                    .replace("</", "<\\/");
    }
%>

<%
    List<Menu> rouletteMenus = new MenuDaoImpl().getAllMenus();

    if (rouletteMenus == null) {
        rouletteMenus = new ArrayList<Menu>();
    }

    List<Menu> availableRouletteMenus = new ArrayList<Menu>();

    for (Menu rouletteMenu : rouletteMenus) {
        if (rouletteMenu.isAvailable()) {
            availableRouletteMenus.add(rouletteMenu);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Food Roulette | Yumlet</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/navbar.css">
<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/footer.css">

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'Segoe UI', Arial, sans-serif;
    color: #352116;
    background: #fffaf4;
}

.roulette-page {
    min-height: 78vh;
    padding: 55px 22px 75px;
    background:
        radial-gradient(circle at 10% 10%, #ffe4c3, transparent 32%),
        radial-gradient(circle at 95% 85%, #ffe9d4, transparent 30%),
        linear-gradient(135deg, #fffaf4, #fff3e5);
}

.roulette-container {
    max-width: 1150px;
    margin: auto;
    display: grid;
    grid-template-columns: 0.9fr 1.1fr;
    align-items: center;
    gap: 55px;
}

.eyebrow {
    display: inline-block;
    padding: 9px 15px;
    border-radius: 30px;
    background: #ffead7;
    color: #a64e20;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 1.5px;
}

.roulette-info h1 {
    margin: 22px 0 18px;
    font-size: clamp(38px, 5vw, 61px);
    line-height: 1.08;
    letter-spacing: -1.8px;
}

.roulette-info h1 span {
    color: #df6d2e;
}

.roulette-info p {
    max-width: 450px;
    color: #806a5b;
    font-size: 16px;
    line-height: 1.85;
}

.info-points {
    display: grid;
    gap: 13px;
    margin-top: 28px;
}

.info-point {
    display: flex;
    align-items: center;
    gap: 12px;
    color: #604636;
    font-size: 14px;
}

.point-icon {
    display: grid;
    place-items: center;
    flex-shrink: 0;
    width: 38px;
    height: 38px;
    border-radius: 12px;
    background: white;
    box-shadow: 0 4px 15px #7c472014;
}

.wheel-section {
    text-align: center;
    min-width: 0;
}

.wheel-heading {
    margin-bottom: 25px;
}

.wheel-heading h2 {
    margin: 0 0 8px;
    font-size: 25px;
}

.wheel-heading p {
    margin: 0;
    color: #8b7464;
    font-size: 14px;
}

.wheel-wrapper {
    position: relative;
    width: min(100%, 410px);
    margin: 0 auto 28px;
    padding: 19px;
}

.wheel-pointer {
    position: absolute;
    z-index: 5;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 0;
    border-left: 18px solid transparent;
    border-right: 18px solid transparent;
    border-top: 35px solid #482719;
    filter: drop-shadow(0 4px 3px #0002);
}

.wheel {
    position: relative;
    width: 100%;
    aspect-ratio: 1;
    border-radius: 50%;
    border: 8px solid white;
    outline: 4px solid #efc9a7;
    box-shadow: 0 18px 45px #75401c24;
    overflow: hidden;
    background: #f8d5a7;
    transition: transform 5s cubic-bezier(.12,.72,.12,1);
}

/* Spinner contains emojis only; no food names. */
.wheel-item {
    position: absolute;
    left: 50%;
    top: 50%;
    width: 44%;
    transform-origin: 0 0;
    text-align: center;
    pointer-events: none;
}

.wheel-item .food-emoji {
    display: block;
    font-size: 25px;
    line-height: 1;
}

.wheel-center {
    position: absolute;
    z-index: 3;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 76px;
    height: 76px;
    border: 5px solid white;
    border-radius: 50%;
    background: linear-gradient(135deg, #f18a45, #cf5425);
    color: white;
    display: grid;
    place-items: center;
    font-size: 29px;
    box-shadow: 0 5px 16px #6d321c35;
}

.spin-button {
    border: 0;
    border-radius: 40px;
    padding: 16px 34px;
    background: linear-gradient(135deg, #ef8c48, #ce5424);
    color: white;
    font-size: 15px;
    font-weight: 800;
    cursor: pointer;
    box-shadow: 0 9px 22px #ce642c35;
    transition: transform .2s, box-shadow .2s;
}

.spin-button:hover {
    transform: translateY(-2px);
    box-shadow: 0 13px 25px #ce642c40;
}

.spin-button:disabled {
    opacity: .7;
    cursor: not-allowed;
}

.result-box {
    max-width: 440px;
    margin: 24px auto 0;
    padding: 22px;
    border: 1px solid #f1dfcf;
    border-radius: 22px;
    background: #ffffffd9;
    box-shadow: 0 10px 32px #75401c0c;
    text-align: left;
}

.result-label {
    color: #a77b60;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1.5px;
}

.result-content {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-top: 12px;
}

.result-image,
.result-placeholder {
    width: 92px;
    height: 92px;
    flex-shrink: 0;
    border-radius: 16px;
}

.result-image {
    object-fit: cover;
    background: #ffead7;
}

.result-placeholder {
    display: grid;
    place-items: center;
    background: #ffead7;
    font-size: 37px;
}

.result-details {
    min-width: 0;
}

.result-food {
    margin: 0 0 6px;
    color: #a74720;
    font-size: 21px;
    font-weight: 800;
    overflow-wrap: anywhere;
}

.result-description {
    color: #816b5d;
    font-size: 13px;
    line-height: 1.5;
}

.result-price {
    margin-top: 7px;
    font-weight: 800;
    color: #392418;
}

.order-link {
    display: inline-block;
    margin-top: 18px;
    color: #bf5426;
    font-size: 14px;
    font-weight: 800;
    text-decoration: none;
}

.order-link:hover {
    text-decoration: underline;
}

.empty-message {
    margin: 20px auto;
    max-width: 460px;
    padding: 25px;
    border-radius: 18px;
    background: white;
    color: #806a5b;
    line-height: 1.7;
}

@media (max-width: 800px) {
    .roulette-page {
        padding: 35px 17px 50px;
    }

    .roulette-container {
        grid-template-columns: 1fr;
        gap: 35px;
    }

    .roulette-info {
        text-align: center;
    }

    .roulette-info p {
        margin-left: auto;
        margin-right: auto;
    }

    .info-points {
        max-width: 330px;
        margin: 25px auto 0;
        text-align: left;
    }

    .wheel-wrapper {
        max-width: 370px;
    }
}

@media (max-width: 420px) {
    .wheel-wrapper {
        padding: 15px;
    }

    .wheel-item .food-emoji {
        font-size: 20px;
    }

    .wheel-center {
        width: 61px;
        height: 61px;
        font-size: 24px;
    }

    .result-box {
        padding: 16px;
    }

    .result-image,
    .result-placeholder {
        width: 72px;
        height: 72px;
    }
}
</style>
</head>

<body>

<%@ include file="/includes/navbar.jsp" %>

<main class="roulette-page">
    <div class="roulette-container">

        <section class="roulette-info">
            <span class="eyebrow">YOUR FOOD, YOUR LUCK</span>

            <h1>Let the wheel<br>choose your <span>craving.</span></h1>

            <p>
                Too many delicious choices? Let Yumlet make the decision.
                Spin the wheel and discover something tasty from the menu
                available in your restaurants.
            </p>

            <div class="info-points">
                <div class="info-point">
                    <span class="point-icon">🎯</span>
                    <span>One spin, one delicious surprise</span>
                </div>

                <div class="info-point">
                    <span class="point-icon">🍽️</span>
                    <span>Suggestions from your real menu</span>
                </div>

                <div class="info-point">
                    <span class="point-icon">❤️</span>
                    <span>Find your next favourite meal</span>
                </div>
            </div>
        </section>

        <section class="wheel-section">
            <div class="wheel-heading">
                <h2>What are we eating today?</h2>
                <p>Take a chance. Find your next favourite.</p>
            </div>

            <% if (availableRouletteMenus.isEmpty()) { %>

                <div class="empty-message">
                    <strong>No available menu items found.</strong><br>
                    Please add menu items or mark existing items as available
                    in your database, then refresh this page.
                </div>

            <% } else { %>

                <div class="wheel-wrapper">
                    <div class="wheel-pointer"></div>

                    <div class="wheel" id="foodWheel">

                        <% for (int rouletteIndex = 0;
                                rouletteIndex < availableRouletteMenus.size();
                                rouletteIndex++) {
                        %>

                            <div class="wheel-item"
                                 data-index="<%= rouletteIndex %>">
                                <span class="food-emoji">🍽️</span>
                            </div>

                        <% } %>

                    </div>

                    <div class="wheel-center">🍴</div>
                </div>

                <button type="button"
                        class="spin-button"
                        id="spinButton"
                        onclick="spinWheel()">
                    🎯 Spin the Wheel
                </button>

                <div class="result-box" aria-live="polite">
                    <div class="result-label">YOUR FOOD PICK</div>

                    <div class="result-content">
                        <div class="result-placeholder"
                             id="resultPlaceholder">🍲</div>

                        <img class="result-image"
                             id="resultImage"
                             alt="Selected menu item"
                             hidden>

                        <div class="result-details">
                            <h3 class="result-food" id="resultFood">
                                Your craving awaits!
                            </h3>

                            <div class="result-description"
                                 id="resultDescription">
                                Spin the wheel to reveal a menu item.
                            </div>

                            <div class="result-price" id="resultPrice"></div>
                        </div>
                    </div>

                    <a class="order-link"
                       href="<%= request.getContextPath() %>/restaurant">
                        Explore Restaurants →
                    </a>
                </div>

                <script>
                const rouletteItems = [
                    <%
                    for (int rouletteIndex = 0;
                         rouletteIndex < availableRouletteMenus.size();
                         rouletteIndex++) {

                        Menu rouletteItem =
                            availableRouletteMenus.get(rouletteIndex);

                        String rouletteName =
                            rouletteItem.getItemName() == null
                                ? ""
                                : rouletteItem.getItemName();

                        String rouletteDescription =
                            rouletteItem.getDescription() == null
                                ? ""
                                : rouletteItem.getDescription();

                        String rouletteImage =
                            rouletteItem.getImagePath() == null
                                ? ""
                                : rouletteItem.getImagePath();

                        Object priceObject = rouletteItem.getPrice();

                        String roulettePrice =
                            priceObject == null
                                ? ""
                                : String.valueOf(priceObject);
                    %>
                    {
                        name: "<%= rouletteJsonEscape(rouletteName) %>",
                        description: "<%= rouletteJsonEscape(rouletteDescription) %>",
                        image: "<%= rouletteJsonEscape(rouletteImage) %>",
                        price: "<%= rouletteJsonEscape(roulettePrice) %>"
                    }<%= rouletteIndex < availableRouletteMenus.size() - 1 ? "," : "" %>
                    <% } %>
                ];

                const rouletteColors = [
                    "#f7bd76", "#fff0d9", "#e88750", "#fce0b5",
                    "#d8a46e", "#fff0d9", "#edaa68", "#fce0b5",
                    "#f2c29a", "#f7d9b8", "#e9a06d", "#ffe8ca"
                ];

                const rouletteWheel =
                    document.getElementById("foodWheel");

                const rouletteSlices =
                    rouletteWheel.querySelectorAll(".wheel-item");

                const rouletteCount = rouletteItems.length;

                const rouletteSliceAngle = 360 / rouletteCount;

                let rouletteRotation = 0;
                let rouletteSpinning = false;

                rouletteWheel.style.background = "conic-gradient(" +
                    rouletteItems.map(function(item, index) {
                        const start = index * rouletteSliceAngle;
                        const end = (index + 1) * rouletteSliceAngle;

                        return rouletteColors[index % rouletteColors.length] +
                            " " + start + "deg " + end + "deg";
                    }).join(",") + ")";

                function positionRouletteSlices() {
                    rouletteSlices.forEach(function(slice, index) {
                        const angle =
                            index * rouletteSliceAngle +
                            rouletteSliceAngle / 2;

                        slice.style.transform =
                            "rotate(" + angle + "deg) translateY(-" +
                            (rouletteWheel.clientWidth * 0.34) + "px)";

                        slice.style.marginLeft = "0";
                        slice.style.marginTop = "0";
                        slice.style.width = "44%";
                        slice.style.transformOrigin = "0 0";
                        slice.style.textAlign = "center";
                    });
                }

                positionRouletteSlices();

                function spinWheel() {
                    if (rouletteSpinning || rouletteCount === 0) {
                        return;
                    }

                    rouletteSpinning = true;

                    const rouletteButton =
                        document.getElementById("spinButton");

                    rouletteButton.disabled = true;
                    rouletteButton.textContent = "✨ Spinning...";

                    const selectedIndex =
                        Math.floor(Math.random() * rouletteCount);

                    const targetAngle =
                        360 -
                        (selectedIndex * rouletteSliceAngle +
                        rouletteSliceAngle / 2);

                    const extraSpins =
                        360 * (5 + Math.floor(Math.random() * 3));

                    rouletteRotation += extraSpins + targetAngle;

                    rouletteWheel.style.transform =
                        "rotate(" + rouletteRotation + "deg)";

                    window.setTimeout(function() {
                        const picked = rouletteItems[selectedIndex];

                        document.getElementById("resultFood").textContent =
                            picked.name || "Menu item";

                        document.getElementById("resultDescription")
                            .textContent =
                                picked.description ||
                                "A tasty choice from the Yumlet menu.";

                        document.getElementById("resultPrice")
                            .textContent =
                                picked.price ? "₹" + picked.price : "";

                        const image =
                            document.getElementById("resultImage");

                        const placeholder =
                            document.getElementById("resultPlaceholder");

                        image.hidden = true;
                        placeholder.hidden = false;
                        image.onload = null;

                        if (picked.image) {
                            image.onload = function() {
                                image.hidden = false;
                                placeholder.hidden = true;
                            };

                            image.onerror = function() {
                                image.hidden = true;
                                placeholder.hidden = false;
                            };

                            image.src = picked.image;
                        }

                        rouletteButton.disabled = false;
                        rouletteButton.textContent = "🔄 Spin Again";

                        rouletteSpinning = false;

                    }, 5100);
                }

                window.addEventListener("resize", function() {
                    positionRouletteSlices();
                });
                </script>

            <% } %>
        </section>
    </div>
</main>

<%@ include file="/includes/footer.jsp" %>

</body>
</html>
