
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Food Mood | Eatero</title>

<style>
:root {
    --chocolate: #3B2118;
    --card: #4A2A1E;
    --cream: #FFF3E8;
    --muted: #D2B8A5;
    --accent: #E3A16E;
    --border: #674333;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: "Segoe UI", Arial, sans-serif;
    background: var(--chocolate);
    color: var(--cream);
    min-height: 100vh;
}

a {
    text-decoration: none;
    color: inherit;
}

/* Main page */
.mood-page {
    width: 100%;
    max-width: 1250px;
    margin: 0 auto;
    padding: 48px 24px 60px;
}

/* Hero section */
.mood-hero {
    text-align: center;
    margin-bottom: 42px;
}

.eyebrow {
    display: inline-block;
    padding: 8px 16px;
    border-radius: 30px;
    background: #573627;
    color: #F0C39D;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    margin-bottom: 18px;
}

.mood-hero h1 {
    font-size: clamp(32px, 5vw, 50px);
    line-height: 1.2;
    color: var(--cream);
    font-weight: 800;
    margin-bottom: 15px;
}

.mood-hero h1 span {
    color: var(--accent);
}

.mood-hero p {
    max-width: 650px;
    margin: 0 auto;
    color: var(--muted);
    font-size: 16px;
    line-height: 1.8;
}

/* Section heading */
.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: end;
    gap: 15px;
    margin-bottom: 22px;
}

.section-heading h2 {
    color: var(--cream);
    font-size: 23px;
    margin-bottom: 6px;
}

.section-heading p {
    color: var(--muted);
    font-size: 14px;
}

/* Mood cards grid */
.mood-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 22px;
}

.mood-card {
    position: relative;
    display: block;
    height: 275px;
    overflow: hidden;
    border-radius: 19px;
    background: var(--card);
    border: 1px solid rgba(255, 243, 232, 0.10);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.18);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    isolation: isolate;
}

.mood-card:hover {
    transform: translateY(-7px);
    box-shadow: 0 18px 35px rgba(0, 0, 0, 0.32);
}

.mood-card img {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    z-index: -2;
    transition: transform 0.5s ease;
}

.mood-card:hover img {
    transform: scale(1.08);
}

.mood-card::after {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -1;
    background: linear-gradient(
        to top,
        rgba(28, 12, 7, 0.96) 0%,
        rgba(28, 12, 7, 0.65) 40%,
        rgba(28, 12, 7, 0.05) 100%
    );
}

.mood-content {
    position: absolute;
    left: 19px;
    right: 19px;
    bottom: 19px;
}

.mood-emoji {
    display: inline-flex;
    width: 43px;
    height: 43px;
    align-items: center;
    justify-content: center;
    border-radius: 13px;
    background: rgba(255, 243, 232, 0.15);
    border: 1px solid rgba(255, 243, 232, 0.22);
    backdrop-filter: blur(8px);
    font-size: 23px;
    margin-bottom: 12px;
}

.mood-content h3 {
    color: #FFFFFF;
    font-size: 21px;
    margin-bottom: 7px;
    font-weight: 750;
}

.mood-content p {
    color: #F0DFD2;
    font-size: 13px;
    line-height: 1.5;
    margin-bottom: 15px;
}

.mood-action {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: #F2B783;
    font-size: 13px;
    font-weight: 700;
}

.mood-action span {
    transition: transform 0.2s ease;
}

.mood-card:hover .mood-action span {
    transform: translateX(5px);
}

/* Bottom note */
.bottom-note {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-top: 32px;
    padding: 19px 22px;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 15px;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.7;
}

.bottom-note .note-icon {
    font-size: 25px;
    flex-shrink: 0;
}

.bottom-note strong {
    color: var(--cream);
}

/* Responsive design */
@media (max-width: 1000px) {
    .mood-grid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 18px;
    }

    .mood-card {
        height: 260px;
    }
}

@media (max-width: 700px) {
    .mood-page {
        padding: 35px 16px 45px;
    }

    .mood-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 14px;
    }

    .mood-card {
        height: 245px;
        border-radius: 15px;
    }

    .mood-content {
        left: 13px;
        right: 13px;
        bottom: 14px;
    }

    .mood-content h3 {
        font-size: 18px;
    }

    .mood-content p {
        font-size: 12px;
    }

    .mood-emoji {
        width: 38px;
        height: 38px;
        font-size: 20px;
    }

    .section-heading {
        align-items: start;
        flex-direction: column;
    }
}

@media (max-width: 380px) {
    .mood-grid {
        grid-template-columns: 1fr;
    }

    .mood-card {
        height: 270px;
    }
}
</style>
</head>

<body>

<jsp:include page="/includes/navbar.jsp" />

<main class="mood-page">

    <section class="mood-hero">
        <div class="eyebrow">Your cravings, your way</div>

        <h1>What's your <span>food mood?</span></h1>

        <p>
            Feeling happy, tired, stressed, or just craving something delicious?
            Choose your mood and let Eatero find food that feels right for you.
        </p>
    </section>

    <section class="mood-section">
        <div class="section-heading">
            <div>
                <h2>Choose your mood</h2>
                <p>There's something delicious for every kind of day.</p>
            </div>
        </div>

        <div class="mood-grid">

            <!-- Period mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=period">
                <img
                    src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Freshly baked cheesy pizza"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">🍫</div>
                    <h3>Period Cravings</h3>
                    <p>Chocolate, comfort food, and little treats.</p>
                    <span class="mood-action">Find comfort food <span>→</span></span>
                </div>
            </a>

            <!-- Sick mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=sick">
                <img
                    src="https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Warm bowl of comforting soup"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">🥣</div>
                    <h3>Feeling Sick</h3>
                    <p>Warm soups and gentle, comforting meals.</p>
                    <span class="mood-action">Find comfort food <span>→</span></span>
                </div>
            </a>

            <!-- Happy mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=happy">
                <img
                    src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Juicy burger with fresh toppings"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">🥳</div>
                    <h3>Happy Mood</h3>
                    <p>Celebrate the good vibes with tasty favourites.</p>
                    <span class="mood-action">Celebrate with food <span>→</span></span>
                </div>
            </a>

            <!-- Sad mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=sad">
                <img
                    src="https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Rich chocolate cake"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">🍰</div>
                    <h3>Feeling Sad</h3>
                    <p>A little sweetness for a better-feeling day.</p>
                    <span class="mood-action">Get a sweet treat <span>→</span></span>
                </div>
            </a>

            <!-- Diet mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=diet">
                <img
                    src="https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Colourful fresh vegetable salad"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">🥗</div>
                    <h3>Healthy Mood</h3>
                    <p>Fresh salads and balanced meal options.</p>
                    <span class="mood-action">Explore fresh food <span>→</span></span>
                </div>
            </a>

            <!-- Late night mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=late-night">
                <img
                    src="https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Delicious bowl of noodles"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">🌙</div>
                    <h3>Late-Night Cravings</h3>
                    <p>Noodles, quick bites, and midnight favourites.</p>
                    <span class="mood-action">Find a late-night bite <span>→</span></span>
                </div>
            </a>

            <!-- Stress mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=stress">
                <img
                    src="https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Delicious grilled food ready to enjoy"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">😌</div>
                    <h3>Stressed Out</h3>
                    <p>Take a break and enjoy a satisfying meal.</p>
                    <span class="mood-action">Take a tasty break <span>→</span></span>
                </div>
            </a>

            <!-- Rainy mood -->
            <a class="mood-card"
               href="<%= request.getContextPath() %>/mood-recommendations.jsp?mood=rainy">
                <img
                    src="https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Golden crispy Indian snacks"
                    loading="lazy"
                    onerror="this.style.display='none'">

                <div class="mood-content">
                    <div class="mood-emoji">🌧️</div>
                    <h3>Rainy Day</h3>
                    <p>Crispy snacks and warm food for rainy weather.</p>
                    <span class="mood-action">Find rainy-day food <span>→</span></span>
                </div>
            </a>

        </div>
    </section>

    <div class="bottom-note">
        <div class="note-icon">🍽️</div>
        <div>
            <strong>Your mood, your menu.</strong>
            <br>
            Pick a mood to explore food recommendations and discover your next favourite meal with Eatero.
        </div>
    </div>

</main>



</body>
</html>
