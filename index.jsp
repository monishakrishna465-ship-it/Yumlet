
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.tap.util.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
    public String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    public String restaurantImage(String image) {
        if (image == null || image.trim().isEmpty()) {
            return "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=85";
        }
        return image.trim();
    }
%>

<%
    String contextPath = request.getContextPath();
    List<Map<String, String>> restaurants = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        String sql = "SELECT restaurantId, name, cuisineType, deliveryTime, "
                   + "address, rating, imagePath "
                   + "FROM restaurant WHERE isActive = 1 LIMIT 4";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            ResultSetMetaData meta = rs.getMetaData();
            Set<String> columns = new HashSet<>();

            for (int i = 1; i <= meta.getColumnCount(); i++) {
                columns.add(meta.getColumnLabel(i).toLowerCase(Locale.ROOT));
            }

            while (rs.next()) {
                Map<String, String> restaurant = new HashMap<>();

                restaurant.put("id",
                    columns.contains("restaurantid") ? rs.getString("restaurantId") :
                    columns.contains("restaurant_id") ? rs.getString("restaurant_id") : "");

                restaurant.put("name",
                    columns.contains("restaurantname") ? rs.getString("restaurantName") :
                    columns.contains("name") ? rs.getString("name") : "Restaurant");

                restaurant.put("cuisine",
                    columns.contains("cuisinetype") ? rs.getString("cuisineType") :
                    columns.contains("cuisine") ? rs.getString("cuisine") : "Delicious food");

                restaurant.put("image",
                    columns.contains("imagepath") ? rs.getString("imagePath") :
                    columns.contains("image") ? rs.getString("image") :
                    columns.contains("imageurl") ? rs.getString("imageUrl") : "");

                restaurant.put("rating",
                    columns.contains("rating") ? rs.getString("rating") : "4.2");

                restaurant.put("deliveryTime",
                    columns.contains("deliverytime") ? rs.getString("deliveryTime") : "30–40 min");

                restaurants.add(restaurant);
            }
        }
    } catch (Exception e) {
        application.log("Unable to load restaurants on homepage.", e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#28150f">
    <title>Yumlet | Your Little World of Yum</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/navbar.css">
    <link rel="stylesheet" href="<%= contextPath %>/css/footer.css">

    <link rel="preconnect" href="https://images.unsplash.com">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --brown: #28150f;
            --brown-2: #3b2117;
            --brown-3: #563421;
            --beige: #f4e5cd;
            --beige-2: #fff8ec;
            --beige-3: #ead2b0;
            --caramel: #e9a15b;
            --caramel-dark: #bd7136;
            --ink: #382014;
            --muted-ink: #795b43;
            --muted-light: #d8c3a5;
            --line: rgba(82, 49, 29, .16);
            --shadow: 0 18px 45px rgba(40, 21, 15, .13);
            --radius: 22px;
        }

        * { box-sizing: border-box; }

        html {
            scroll-behavior: smooth;
            scroll-padding-top: 90px;
            background: var(--brown);
        }

        body {
            margin: 0;
            color: var(--beige);
            background: var(--brown);
            font-family: "DM Sans", Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
        }

        body, button, input {
            font-family: "DM Sans", Arial, sans-serif;
        }

        a { text-decoration: none; }
        button, input { font: inherit; }
        img { max-width: 100%; }

        .page-container {
            width: min(1180px, 92%);
            margin-inline: auto;
        }

        .serif {
            font-family: "Playfair Display", Georgia, serif;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            color: var(--caramel-dark);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 2.2px;
            text-transform: uppercase;
        }

        .eyebrow::before {
            content: "";
            display: inline-block;
            width: 24px;
            height: 2px;
            background: currentColor;
        }

        .section { padding: 82px 0; }

        .section-heading { margin-bottom: 30px; }

        .section-heading h2 {
            margin: 12px 0 10px;
            color: var(--beige);
            font: 700 clamp(30px, 4vw, 43px)/1.13 "Playfair Display", Georgia, serif;
            letter-spacing: -.7px;
        }

        .section-heading p {
            margin: 0;
            color: var(--muted-light);
            line-height: 1.8;
            font-size: 15px;
        }

        .section-topline {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 27px;
        }

        .section-topline .section-heading { margin: 0; }

        .view-link {
            color: var(--ink);
            font-size: 13px;
            font-weight: 800;
            white-space: nowrap;
            transition: color .2s ease;
        }

        .view-link:hover { color: var(--caramel-dark); }

        .primary-btn, .secondary-btn {
            min-height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 13px 22px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            transition: transform .25s ease, box-shadow .25s ease, background .25s ease;
        }

        .primary-btn {
            color: var(--brown);
            background: var(--caramel);
            border: 1px solid var(--caramel);
            box-shadow: 0 8px 20px rgba(233,161,91,.18);
        }

        .primary-btn:hover {
            background: #f4b875;
            transform: translateY(-3px);
            box-shadow: 0 12px 24px rgba(233,161,91,.25);
        }

        .secondary-btn {
            color: var(--beige-2);
            border: 1px solid rgba(255,248,236,.62);
            background: rgba(40,21,15,.42);
        }

        .secondary-btn:hover {
            background: rgba(40,21,15,.72);
            transform: translateY(-2px);
        }

        .surprise-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 13px 22px;
            min-height: 48px;
            border: 1px solid var(--caramel);
            border-radius: 12px;
            background: var(--caramel);
            color: var(--brown) !important;
            font-size: 13px;
            font-weight: 800;
            text-decoration: none !important;
            box-shadow: 0 8px 20px rgba(233, 161, 91, .18);
            transition: transform .25s ease, box-shadow .25s ease, background .25s ease;
            cursor: pointer;
        }

        .surprise-btn:hover {
            background: #f4b875;
            transform: translateY(-3px);
            box-shadow: 0 12px 24px rgba(233, 161, 91, .25);
        }

        .surprise-btn:active { transform: translateY(0); }

        .surprise-btn:focus-visible {
            outline: 3px solid var(--caramel);
            outline-offset: 4px;
        }

        /* HERO */

        .hero {
            position: relative;
            isolation: isolate;
            display: flex;
            align-items: center;
            min-height: clamp(570px, 78vh, 740px);
            overflow: hidden;
            background-color: var(--brown);
            background-image:
                linear-gradient(90deg, rgba(40,21,15,.94) 0%, rgba(40,21,15,.78) 42%, rgba(40,21,15,.24) 100%),
                url("<%= contextPath %>/images/yumlet-hero.png.png");
            background-size: cover;
            background-position: center;
        }

        .hero::after {
            content: "";
            position: absolute;
            inset: auto 0 0;
            height: 130px;
            z-index: 0;
            background: linear-gradient(transparent, var(--brown));
            pointer-events: none;
        }

        .hero-video {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0;
            z-index: -1;
            pointer-events: none;
            transition: opacity .6s ease;
        }

        .hero.video-playing .hero-video { opacity: 1; }

        .hero-content {
            position: relative;
            z-index: 1;
            width: min(1180px, 92%);
            margin: 0 auto;
            padding: 85px 0 115px;
            animation: heroIn .9s cubic-bezier(.2,.7,.2,1) both;
        }

        @keyframes heroIn {
            from { opacity: 0; transform: translateY(22px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            padding: 9px 13px;
            margin-bottom: 24px;
            border: 1px solid rgba(233,161,91,.35);
            border-radius: 999px;
            color: #f5bc7e;
            background: rgba(40,21,15,.38);
            backdrop-filter: blur(8px);
            font-size: 10px;
            letter-spacing: 2px;
            font-weight: 800;
        }

        .hero-badge::before {
            content: "✦";
            color: var(--caramel);
            font-size: 13px;
        }

        .hero h1 {
            max-width: 700px;
            margin: 0 0 22px;
            color: var(--beige-2);
            font: 800 clamp(48px, 7vw, 88px)/1.01 "Playfair Display", Georgia, serif;
            letter-spacing: -2.4px;
        }

        .hero h1 span {
            color: var(--caramel);
            font-style: italic;
        }

        .hero-description {
            max-width: 510px;
            margin: 0 0 31px;
            color: #f1dfc6;
            font-size: clamp(15px, 1.7vw, 17px);
            line-height: 1.9;
        }

        .hero-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 13px;
        }

        .hero-note {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 37px;
            color: #e0c8a8;
            font-size: 12px;
        }

        .hero-note strong { color: var(--beige-2); }

        .hero-note-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #a8c57c;
            box-shadow: 0 0 0 5px rgba(168,197,124,.12);
        }
        

        /* FLOATING FOOD ILLUSTRATIONS */

        .food-playground {
            position: relative;
            overflow: hidden;
            padding: 66px 0 72px;
            color: var(--ink);
            background: radial-gradient(ellipse at 50% 110%, rgba(233,161,91,.24), transparent 48%), linear-gradient(130deg, #fff8ec, #f4e5cd 60%, #f0d9b8);
        }

        .food-playground::before,
        .food-playground::after {
            content: "";
            position: absolute;
            border: 1px solid rgba(86,52,33,.12);
            border-radius: 50%;
            pointer-events: none;
        }

        .food-playground::before {
            width: 430px;
            height: 430px;
            left: -250px;
            top: -250px;
        }

        .food-playground::after {
            width: 310px;
            height: 310px;
            right: -170px;
            bottom: -205px;
        }

        .food-playground-inner {
            position: relative;
            z-index: 1;
            display: grid;
            grid-template-columns: 1fr 1fr;
            align-items: center;
            gap: 40px;
        }

        .food-playground-copy { max-width: 520px; }

        .food-playground-copy .eyebrow { color: #a45f30; }

        .food-playground-copy h2 {
            margin: 15px 0;
            color: var(--ink);
            font: 700 clamp(34px, 4.3vw, 54px)/1.12 "Playfair Display", Georgia, serif;
            letter-spacing: -1.2px;
        }

        .food-playground-copy h2 span {
            color: #b86e37;
            font-style: italic;
        }

        .food-playground-copy p {
            max-width: 465px;
            margin: 0;
            color: var(--muted-ink);
            font-size: 15px;
            line-height: 1.9;
        }

        .food-playground-copy .primary-btn { margin-top: 24px; }

        .food-stage {
            min-height: 330px;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            isolation: isolate;
        }

        .food-stage-halo {
            position: absolute;
            width: 260px;
            height: 260px;
            border-radius: 50%;
            background: rgba(233,161,91,.25);
            filter: blur(12px);
            z-index: -1;
        }

        .food-stage-ring {
            position: absolute;
            width: 300px;
            height: 300px;
            border: 1px dashed rgba(86,52,33,.22);
            border-radius: 50%;
            animation: ringTurn 34s linear infinite;
        }

        .food-stage-ring::before,
        .food-stage-ring::after {
            content: "✦";
            position: absolute;
            color: #c47b40;
            font-size: 20px;
        }

        .food-stage-ring::before { top: 22px; left: 45px; }
        .food-stage-ring::after { bottom: 30px; right: 28px; }

        @keyframes ringTurn {
            to { transform: rotate(360deg); }
        }

        .food-emoji {
            position: absolute;
            display: grid;
            place-items: center;
            user-select: none;
            filter: drop-shadow(0 15px 12px rgba(67,39,22,.16));
            transform-origin: center;
        }

        .food-emoji-main {
            width: 190px;
            height: 190px;
            border-radius: 42% 58% 52% 48% / 50% 43% 57% 50%;
            background: rgba(255,248,236,.74);
            border: 1px solid rgba(255,255,255,.8);
            box-shadow: 0 25px 55px rgba(86,52,33,.12), inset 0 0 0 9px rgba(255,255,255,.3);
            font-size: 105px;
            animation: mainBob 4.5s ease-in-out infinite;
        }

        .food-emoji-burger {
            top: 12px;
            right: 7%;
            width: 100px;
            height: 100px;
            border-radius: 30px;
            background: #fff9ed;
            font-size: 59px;
            animation: bobOne 4.7s ease-in-out infinite;
        }

        .food-emoji-pizza {
            bottom: 12px;
            left: 5%;
            width: 92px;
            height: 92px;
            border-radius: 28px;
            background: #fff9ed;
            font-size: 55px;
            animation: bobTwo 5.1s ease-in-out infinite;
        }

        .food-emoji-drink {
            bottom: 18px;
            right: 8%;
            width: 83px;
            height: 83px;
            border-radius: 26px;
            background: #fff9ed;
            font-size: 49px;
            animation: bobThree 5.6s ease-in-out infinite;
        }

        .food-sparkle {
            position: absolute;
            color: #bb733c;
            font-size: 22px;
            animation: sparkle 2.6s ease-in-out infinite;
        }

        .sparkle-a { top: 25px; left: 17%; }
        .sparkle-b { top: 42%; right: 2%; animation-delay: .8s; }
        .sparkle-c { bottom: 5px; left: 45%; animation-delay: 1.3s; }

        @keyframes mainBob {
            0%,100% { transform: translateY(0) rotate(-4deg); }
            50% { transform: translateY(-12px) rotate(3deg); }
        }

        @keyframes bobOne {
            0%,100% { transform: translate(0,0) rotate(6deg); }
            50% { transform: translate(-7px,-13px) rotate(-2deg); }
        }

        @keyframes bobTwo {
            0%,100% { transform: translate(0,0) rotate(-8deg); }
            50% { transform: translate(8px,-11px) rotate(3deg); }
        }

        @keyframes bobThree {
            0%,100% { transform: translate(0,0) rotate(5deg); }
            50% { transform: translate(-6px,-9px) rotate(-5deg); }
        }

        @keyframes sparkle {
            0%,100% { opacity: .45; transform: scale(.8) rotate(0); }
            50% { opacity: 1; transform: scale(1.15) rotate(18deg); }
        }

        /* SCROLL REVEAL */

        .scroll-reveal,
        .reveal-left,
        .reveal-right {
            opacity: 0;
            transition: opacity .75s ease, transform .75s cubic-bezier(.22,1,.36,1);
            transition-delay: var(--reveal-delay, 0ms);
            will-change: opacity, transform;
        }

        .scroll-reveal { transform: translateY(28px); }
        .reveal-left { transform: translateX(-32px); }
        .reveal-right { transform: translateX(32px); }

        .scroll-reveal.revealed,
        .reveal-left.revealed,
        .reveal-right.revealed {
            opacity: 1;
            transform: translate(0,0);
        }
        
/* ===== CREATIVE YUMLET MOOD FINDER ===== */

.mood-section {
    position: relative;
    overflow: hidden;
    padding: 75px 22px;
    color: #f8ead7;
    background:
        radial-gradient(circle at 15% 20%, rgba(190, 126, 76, .17), transparent 32%),
        radial-gradient(circle at 85% 85%, rgba(233, 161, 91, .12), transparent 30%),
        linear-gradient(135deg, #28150f, #3b2117 55%, #563421);
}

.mood-container {
    max-width: 1080px;
    min-height: 300px;
    margin: auto;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 75px;
}

.mood-orbit {
    position: relative;
    width: 245px;
    height: 245px;
    flex-shrink: 0;
    display: grid;
    place-items: center;
    border: 1px solid rgba(233, 161, 91, .35);
    border-radius: 50%;
    box-shadow:
        0 0 0 18px rgba(233, 161, 91, .035),
        0 0 0 38px rgba(233, 161, 91, .025);
    animation: moodFloat 4s ease-in-out infinite;
}

.mood-orbit::before,
.mood-orbit::after {
    content: "";
    position: absolute;
    border: 1px dashed rgba(233, 161, 91, .25);
    border-radius: 50%;
}

.mood-orbit::before {
    inset: 20px;
}

.mood-orbit::after {
    inset: 42px;
    border-style: solid;
    border-color: rgba(233, 161, 91, .15);
}

.mood-center {
    position: relative;
    width: 125px;
    height: 125px;
    display: grid;
    place-items: center;
    border: 1px solid rgba(255, 240, 218, .3);
    border-radius: 38% 62% 55% 45% / 45% 42% 58% 55%;
    color: #3b2117;
    background: linear-gradient(145deg, #f4d5ad, #e9a15b);
    box-shadow: 0 15px 40px rgba(0, 0, 0, .25);
    transform: rotate(-8deg);
}

.mood-face {
    font-family: Georgia, serif;
    font-size: 68px;
    line-height: 1;
    transform: rotate(8deg);
}

.mood-spark {
    position: absolute;
    top: 5px;
    right: 4px;
    color: #fff7e9;
    font-size: 27px;
}

.mood-heart {
    position: absolute;
    bottom: 1px;
    left: 2px;
    color: #7d3827;
    font-size: 32px;
}

.orbit-dot {
    position: absolute;
    z-index: 2;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: #e9a15b;
    box-shadow: 0 0 16px rgba(233, 161, 91, .65);
}

.dot-one {
    top: 28px;
    right: 35px;
}

.dot-two {
    bottom: 35px;
    left: 18px;
    width: 8px;
    height: 8px;
    background: #f4d5ad;
}

.dot-three {
    bottom: 22px;
    right: 55px;
    width: 6px;
    height: 6px;
}

.mood-content {
    max-width: 550px;
}

.mood-label {
    display: inline-block;
    margin-bottom: 15px;
    color: #e9a15b;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 3px;
}

.mood-content h2 {
    margin: 0 0 18px;
    color: #fff3e2;
    font-family: "Playfair Display", Georgia, serif;
    font-size: clamp(34px, 4vw, 49px);
    font-weight: 700;
    line-height: 1.15;
}

.mood-content p {
    max-width: 490px;
    margin: 0 0 25px;
    color: #d7c0a8;
    font-size: 14px;
    line-height: 1.9;
}

.check-mood-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 22px;
    padding: 15px 23px;
    border: 1px solid #f4d5ad;
    border-radius: 10px;
    color: #321b12;
    background: linear-gradient(135deg, #f4d5ad, #e9a15b);
    font-size: 13px;
    font-weight: 800;
    text-decoration: none;
    box-shadow: 0 8px 22px rgba(0, 0, 0, .2);
    transition: transform .25s ease, box-shadow .25s ease;
}

.check-mood-btn span {
    font-size: 20px;
    transition: transform .25s ease;
}

.check-mood-btn:hover {
    color: #321b12;
    transform: translateY(-3px);
    box-shadow: 0 13px 28px rgba(0, 0, 0, .3);
}

.check-mood-btn:hover span {
    transform: translate(3px, -3px);
}

.mood-note {
    margin-top: 22px;
    color: #c9ad91;
    font-size: 11px;
    letter-spacing: .4px;
}

.mood-note span {
    margin-right: 7px;
    color: #e9a15b;
}

@keyframes moodFloat {
    0%, 100% {
        transform: translateY(0) rotate(0);
    }
    50% {
        transform: translateY(-8px) rotate(2deg);
    }
}

@media (max-width: 700px) {
    .mood-section {
        padding: 55px 20px;
    }

    .mood-container {
        flex-direction: column;
        gap: 38px;
        text-align: center;
    }

    .mood-orbit {
        width: 190px;
        height: 190px;
    }

    .mood-center {
        width: 105px;
        height: 105px;
    }

    .mood-face {
        font-size: 57px;
    }

    .mood-content p {
        margin-right: auto;
        margin-left: auto;
    }
}

@media (prefers-reduced-motion: reduce) {
    .mood-orbit {
        animation: none;
    }

    .check-mood-btn,
    .check-mood-btn span {
        transition: none;
    }
}
        

        /* SEARCH */

        .search-section {
            position: relative;
            z-index: 3;
            margin-top: -28px;
        }

        .search-box {
            max-width: 850px;
            margin: 0 auto;
            padding: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
            border: 1px solid rgba(255,255,255,.7);
            border-radius: 18px;
            background: var(--beige-2);
            box-shadow: 0 18px 45px rgba(24,12,8,.22);
        }

        .search-icon {
            display: grid;
            place-items: center;
            width: 44px;
            height: 44px;
            flex: 0 0 44px;
            border-radius: 13px;
            color: #86542f;
            background: #f3e1c7;
            font-size: 19px;
        }

        .search-box input {
            min-width: 0;
            flex: 1;
            padding: 12px 5px;
            outline: none;
            border: 0;
            color: var(--ink);
            background: transparent;
            font-size: 14px;
        }

        .search-box input::placeholder { color: #94765d; }

        .search-box button {
            padding: 13px 22px;
            border: 0;
            border-radius: 12px;
            color: var(--beige-2);
            background: var(--brown-2);
            cursor: pointer;
            font-size: 13px;
            font-weight: 800;
            transition: background .2s ease, transform .2s ease;
        }

        .search-box button:hover {
            background: var(--caramel-dark);
            transform: translateY(-1px);
        }

        /* CUISINES */

        #cuisines, #restaurants {
            background: var(--beige);
            color: var(--ink);
        }

        #cuisines .section-heading h2,
        #restaurants .section-heading h2 { color: var(--ink); }

        #cuisines .section-heading p,
        #restaurants .section-heading p { color: var(--muted-ink); }

        .cuisine-grid {
            display: grid;
            grid-template-columns: repeat(6, minmax(0,1fr));
            gap: 15px;
        }

        .cuisine-card {
            position: relative;
            display: block;
            height: 178px;
            overflow: hidden;
            isolation: isolate;
            border-radius: 17px;
            background: #d7b894;
            box-shadow: 0 7px 18px rgba(40,21,15,.1);
            transform: translateZ(0);
        }

        .cuisine-card img {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform .55s cubic-bezier(.2,.7,.2,1);
        }

        .cuisine-card::after {
            content: "";
            position: absolute;
            inset: 0;
            z-index: 0;
            background: linear-gradient(180deg, transparent 24%, rgba(30,16,10,.82));
        }

        .cuisine-card span {
            position: absolute;
            z-index: 1;
            bottom: 16px;
            left: 8px;
            right: 8px;
            color: #fff8ec;
            text-align: center;
            font-size: 13px;
            font-weight: 800;
        }

        .cuisine-card:hover img { transform: scale(1.09); }

        .cuisine-card:hover {
            box-shadow: 0 13px 25px rgba(40,21,15,.2);
        }

        /* RESTAURANTS */

        .restaurant-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0,1fr));
            gap: 20px;
        }

        .restaurant-card {
            overflow: hidden;
            border: 1px solid #e7d3b8;
            border-radius: 19px;
            color: var(--ink);
            background: var(--beige-2);
            box-shadow: 0 7px 22px rgba(40,21,15,.08);
            transition: transform .3s ease, box-shadow .3s ease;
        }

        .restaurant-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 17px 32px rgba(40,21,15,.15);
        }

        .restaurant-image-wrap {
            position: relative;
            height: 180px;
            overflow: hidden;
            background: #e7d3b8;
        }

        .restaurant-image-wrap::after {
            content: "";
            position: absolute;
            inset: 55% 0 0;
            background: linear-gradient(transparent, rgba(40,21,15,.16));
            pointer-events: none;
        }

        .restaurant-image {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform .55s ease;
        }

        .restaurant-card:hover .restaurant-image { transform: scale(1.06); }

        .restaurant-info { padding: 18px; }

        .restaurant-info h3 {
            margin: 0 0 8px;
            color: var(--ink);
            font-size: 17px;
            font-weight: 800;
        }

        .restaurant-cuisine {
            min-height: 20px;
            margin-bottom: 15px;
            color: #806149;
            font-size: 12px;
        }

        .restaurant-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            margin-bottom: 17px;
            color: #795b43;
            font-size: 11px;
        }

        .restaurant-rating {
            padding: 5px 8px;
            border-radius: 7px;
            color: #315a2b;
            background: #e5efdc;
            font-size: 12px;
            font-weight: 800;
        }

        .restaurant-link {
            display: block;
            padding: 12px;
            border: 1px solid var(--caramel);
            border-radius: 11px;
            color: var(--ink);
            background: var(--caramel);
            text-align: center;
            font-size: 12px;
            font-weight: 800;
            transition: background .2s ease, color .2s ease;
        }

        .restaurant-link:hover {
            color: var(--beige-2);
            background: var(--brown-2);
            border-color: var(--brown-2);
        }

        .empty-restaurants {
            grid-column: 1/-1;
            padding: 35px;
            border: 1px dashed #c9a984;
            border-radius: 17px;
            color: var(--muted-ink);
            background: var(--beige-2);
            text-align: center;
            line-height: 1.7;
        }

        .empty-restaurants h3 { color: var(--ink); }
        .view-all { margin-top: 30px; text-align: center; }

        /* FEATURES */

        .features-section {
            color: var(--ink);
            background: var(--brown);
        }

        .features-section .section-heading {
            margin-bottom: 34px;
            text-align: center;
        }

        .features-section .section-heading .eyebrow { color: var(--caramel); }

        .features-section .section-heading h2 { color: var(--beige-2); }

        .features-section .section-heading p {
            max-width: 620px;
            margin: 0 auto;
            color: var(--muted-light);
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(3,minmax(0,1fr));
            gap: 22px;
        }

        .feature-card {
            position: relative;
            overflow: hidden;
            padding: 31px 25px 30px;
            border: 1px solid rgba(255,255,255,.6);
            border-radius: 21px;
            color: var(--ink);
            background: linear-gradient(145deg, #fff8ec, #f0dfc4);
            box-shadow: 0 12px 28px rgba(0,0,0,.13);
            text-align: center;
            transition: transform .3s ease, box-shadow .3s ease;
        }

        .feature-card::before {
            content: "";
            position: absolute;
            top: -45px;
            right: -45px;
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: rgba(233,161,91,.13);
        }

        .feature-card:hover {
            transform: translateY(-7px);
            box-shadow: 0 19px 35px rgba(0,0,0,.2);
        }

        .feature-symbol {
            position: relative;
            display: grid;
            place-items: center;
            width: 66px;
            height: 66px;
            margin: 0 auto 19px;
            border: 1px solid rgba(180,111,57,.17);
            border-radius: 21px;
            color: var(--ink);
            background: #f1d9b6;
            font-size: 30px;
            box-shadow: inset 0 1px 0 rgba(255,255,255,.7);
        }

        .feature-card h3 {
            position: relative;
            margin: 0 0 11px;
            color: var(--ink);
            font-size: 18px;
            font-weight: 800;
        }

        .feature-card p {
            position: relative;
            margin: 0;
            color: #76573e;
            font-size: 13px;
            line-height: 1.85;
        }

        /* ROULETTE */

        .roulette-section {
            padding-top: 24px;
            background: var(--brown);
        }

        .roulette-card {
            display: grid;
            grid-template-columns: 1fr .9fr;
            align-items: center;
            gap: 34px;
            max-width: 1060px;
            margin: 0 auto;
            padding: 42px;
            overflow: hidden;
            border: 1px solid rgba(255,255,255,.7);
            border-radius: 26px;
            color: var(--ink);
            background: linear-gradient(135deg, #fff8ec 0%, #f4e5cd 60%, #ead2b0 100%);
            box-shadow: 0 20px 45px rgba(0,0,0,.15);
        }

        .roulette-copy .eyebrow { color: #a45f30; }

        .roulette-copy h2 {
            margin: 13px 0 14px;
            color: var(--ink);
            font: 700 clamp(30px,4vw,43px)/1.13 "Playfair Display", Georgia, serif;
            letter-spacing: -.7px;
        }

        .roulette-copy p {
            max-width: 460px;
            margin: 0 0 23px;
            color: var(--muted-ink);
            font-size: 14px;
            line-height: 1.9;
        }

        .roulette-wheel-wrap { text-align: center; }

        .roulette-pointer {
            position: relative;
            z-index: 2;
            width: 0;
            height: 0;
            margin: 0 auto -7px;
            border-left: 13px solid transparent;
            border-right: 13px solid transparent;
            border-top: 25px solid var(--brown);
            filter: drop-shadow(0 3px 2px rgba(40,21,15,.18));
        }

        .roulette-wheel {
            position: relative;
            display: grid;
            place-items: center;
            width: 225px;
            height: 225px;
            margin: 0 auto 18px;
            border: 8px solid #fff8ec;
            border-radius: 50%;
            background: conic-gradient(
                #e9a15b 0deg 60deg,
                #f7e6c9 60deg 120deg,
                #b86e37 120deg 180deg,
                #d8c3a5 180deg 240deg,
                #cb8548 240deg 300deg,
                #f4e5cd 300deg 360deg
            );
            box-shadow: 0 12px 28px rgba(40,21,15,.18), inset 0 0 0 1px rgba(40,21,15,.12);
            transition: transform 2.6s cubic-bezier(.12,.75,.2,1);
        }

        .roulette-wheel::after {
            content: "Y";
            display: grid;
            place-items: center;
            width: 57px;
            height: 57px;
            border: 5px solid var(--caramel);
            border-radius: 50%;
            color: var(--beige-2);
            background: var(--brown);
            font: 800 24px "Playfair Display", Georgia, serif;
            box-shadow: 0 4px 10px rgba(40,21,15,.2);
        }

        .roulette-wheel.spinning { transform: rotate(1440deg); }

        .roulette-result {
            min-height: 24px;
            margin-bottom: 15px;
            color: #86502b;
            font-size: 13px;
            font-weight: 800;
        }

        .roulette-wheel-wrap .secondary-btn {
            min-height: 43px;
            color: var(--ink);
            border-color: rgba(56,32,20,.25);
            background: rgba(255,255,255,.3);
        }

        .roulette-wheel-wrap .secondary-btn:hover {
            background: rgba(255,255,255,.65);
        }

        #spinRouletteButton:disabled {
            cursor: wait;
            opacity: .75;
            transform: none;
        }

        /* FINAL CTA */

        .cta-section {
            padding: 10px 0 85px;
            background: var(--brown);
        }

        .cta-card {
            position: relative;
            isolation: isolate;
            overflow: hidden;
            padding: 62px 25px;
            border: 1px solid rgba(233,161,91,.3);
            border-radius: 25px;
            background:
                linear-gradient(100deg, rgba(40,21,15,.97), rgba(59,33,23,.78)),
                url("https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1400&q=85") center/cover;
            text-align: center;
        }

        .cta-card::before {
            content: "✦";
            position: absolute;
            z-index: -1;
            top: 5px;
            right: 7%;
            color: rgba(233,161,91,.28);
            font-size: 100px;
            transform: rotate(15deg);
        }

        .cta-card h2 {
            margin: 0 0 14px;
            color: var(--beige-2);
            font: 700 clamp(30px,4vw,44px)/1.15 "Playfair Display", Georgia, serif;
        }

        .cta-card p {
            max-width: 610px;
            margin: 0 auto 25px;
            color: var(--muted-light);
            font-size: 14px;
            line-height: 1.9;
        }

        /* MOOD FOOD FINDER — CHOCOLATE BROWN THEME */

        .mood-section {
            position: relative;
            overflow: hidden;
            padding: 82px 0;
            color: var(--beige-2);
            background:
                radial-gradient(ellipse at 15% 0%, rgba(233,161,91,.12), transparent 42%),
                radial-gradient(ellipse at 90% 100%, rgba(189,113,54,.15), transparent 40%),
                linear-gradient(135deg, #28150f, #3b2117 55%, #28150f);
        }

        .mood-heading {
            margin-bottom: 34px;
            text-align: center;
        }

        .mood-heading .eyebrow {
            color: var(--caramel);
        }

        .mood-heading h2 {
            margin: 13px 0 12px;
            color: var(--beige-2);
            font: 700 clamp(30px, 4vw, 43px)/1.15 "Playfair Display", Georgia, serif;
            letter-spacing: -.6px;
        }

        .mood-heading p {
            max-width: 600px;
            margin: 0 auto;
            color: var(--muted-light);
            font-size: 14px;
            line-height: 1.8;
        }

        .mood-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 17px;
        }

        .mood-card {
            position: relative;
            isolation: isolate;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: flex-end;
            min-width: 0;
            min-height: 230px;
            padding: 20px;
            overflow: hidden;
            border: 1px solid rgba(255,248,236,.16);
            border-radius: 18px;
            color: #fff8ec;
            background: #563421;
            cursor: pointer;
            text-align: left;
            box-shadow: 0 10px 25px rgba(0,0,0,.22);
            transition: transform .3s ease, box-shadow .3s ease, border-color .3s ease;
        }

        .mood-card img {
            position: absolute;
            inset: 0;
            z-index: -2;
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform .55s cubic-bezier(.2,.7,.2,1);
        }

        .mood-card::before {
            content: "";
            position: absolute;
            inset: 0;
            z-index: -1;
            background: linear-gradient(
                180deg,
                rgba(40,21,15,.02) 0%,
                rgba(40,21,15,.20) 35%,
                rgba(40,21,15,.94) 100%
            );
            transition: background .3s ease;
        }

        .mood-card:hover,
        .mood-card.active {
            transform: translateY(-5px);
            border-color: var(--caramel);
            box-shadow: 0 18px 34px rgba(0,0,0,.32);
        }

        .mood-card:hover img,
        .mood-card.active img {
            transform: scale(1.08);
        }

        .mood-card.active::before {
            background: linear-gradient(
                180deg,
                rgba(40,21,15,.08) 0%,
                rgba(40,21,15,.34) 34%,
                rgba(40,21,15,.97) 100%
            );
        }

        .mood-emoji {
            display: grid;
            place-items: center;
            width: 43px;
            height: 43px;
            margin-bottom: 12px;
            border: 1px solid rgba(255,248,236,.28);
            border-radius: 13px;
            background: rgba(40,21,15,.62);
            backdrop-filter: blur(8px);
            font-size: 23px;
        }

        .mood-card strong {
            display: block;
            color: #fff8ec;
            font-size: 15px;
            font-weight: 800;
            line-height: 1.4;
        }

        .mood-card small {
            display: block;
            margin-top: 6px;
            color: #f0dfc9;
            font-size: 11px;
            line-height: 1.55;
        }

        .mood-card:focus-visible {
            outline: 3px solid var(--caramel);
            outline-offset: 4px;
        }

        .mood-results {
            display: none;
            margin-top: 26px;
            padding: 27px;
            border: 1px solid rgba(233,161,91,.4);
            border-radius: 18px;
            color: var(--beige-2);
            background: linear-gradient(135deg, #3b2117, #4a2b1c);
            box-shadow: 0 12px 30px rgba(0,0,0,.2);
            animation: moodAppear .3s ease;
        }

        .mood-results.show { display: block; }

        .mood-results h3 {
            margin: 0 0 10px;
            color: var(--caramel);
            font: 700 24px "Playfair Display", Georgia, serif;
        }

        .mood-results p {
            margin: 0;
            color: var(--muted-light);
            font-size: 14px;
            line-height: 1.8;
        }

        .mood-results a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 18px;
            padding: 12px 18px;
            border: 1px solid var(--caramel);
            border-radius: 10px;
            color: var(--brown);
            background: var(--caramel);
            font-size: 12px;
            font-weight: 800;
            transition: background .2s ease, transform .2s ease;
        }

        .mood-results a:hover {
            background: #f4b875;
            transform: translateY(-2px);
        }

        @keyframes moodAppear {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        ::selection {
            color: var(--brown);
            background: var(--caramel);
        }

        /* RESPONSIVE */

        @media (max-width: 1000px) {
            .cuisine-grid {
                grid-template-columns: repeat(3,minmax(0,1fr));
            }

            .restaurant-grid {
                grid-template-columns: repeat(2,minmax(0,1fr));
            }

            .food-playground-inner { gap: 20px; }
            .food-stage { min-height: 300px; }

            .food-stage-ring {
                width: 260px;
                height: 260px;
            }

            .food-emoji-main {
                width: 165px;
                height: 165px;
                font-size: 90px;
            }

            .food-emoji-burger {
                width: 84px;
                height: 84px;
                font-size: 49px;
            }

            .food-emoji-pizza {
                width: 80px;
                height: 80px;
                font-size: 47px;
            }

            .food-emoji-drink {
                width: 74px;
                height: 74px;
                font-size: 43px;
            }

            .mood-grid { grid-template-columns: repeat(2,minmax(0,1fr)); }
            .mood-card { min-height: 220px; }
        }

        @media (max-width: 700px) {
            .section { padding: 62px 0; }

            .hero {
                min-height: 590px;
                background-position: 61% center;
            }

            .hero-content { padding: 75px 0 100px; }

            .hero h1 {
                font-size: clamp(46px, 11vw, 66px);
                letter-spacing: -1.5px;
            }

            .hero-description {
                max-width: 430px;
                font-size: 15px;
            }

            .food-playground { padding: 63px 0 60px; }

            .food-playground-inner {
                grid-template-columns: 1fr;
                gap: 10px;
            }

            .food-playground-copy {
                text-align: center;
                margin: 0 auto;
            }

            .food-playground-copy .eyebrow { justify-content: center; }

            .food-playground-copy p { margin: 0 auto; }

            .food-stage {
                min-height: 310px;
                margin-top: 3px;
            }

            .search-box {
                align-items: stretch;
                border-radius: 16px;
            }

            .search-box button { padding-inline: 16px; }

            .section-topline { align-items: start; }

            .features-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }

            .feature-card { padding: 26px 22px; }

            .roulette-card {
                grid-template-columns: 1fr;
                gap: 26px;
                padding: 30px 22px;
                text-align: center;
            }

            .roulette-copy p { margin-inline: auto; }

            .roulette-wheel {
                width: 205px;
                height: 205px;
            }

            .restaurant-image-wrap { height: 160px; }
            .cta-card { padding: 48px 22px; }
            .mood-section { padding: 64px 0; }
            .mood-card { min-height: 195px; padding: 16px; }
        }

        @media (max-width: 480px) {
            .page-container { width: min(100% - 30px, 1180px); }

            .hero {
                min-height: 560px;
                background-position: 64% center;
            }

            .hero h1 { font-size: 45px; }

            .hero-actions {
                align-items: stretch;
                flex-direction: column;
                max-width: 280px;
            }

            .hero-actions a { width: 100%; }

            .hero-note {
                align-items: flex-start;
                line-height: 1.6;
            }

            .food-playground-copy h2 { font-size: 36px; }
            .food-stage { min-height: 275px; }

            .food-stage-ring {
                width: 235px;
                height: 235px;
            }

            .food-emoji-main {
                width: 145px;
                height: 145px;
                font-size: 78px;
            }

            .food-emoji-burger {
                top: 5px;
                right: 2%;
                width: 72px;
                height: 72px;
                font-size: 42px;
                border-radius: 23px;
            }

            .food-emoji-pizza {
                bottom: 5px;
                left: 1%;
                width: 70px;
                height: 70px;
                font-size: 40px;
                border-radius: 22px;
            }

            .food-emoji-drink {
                bottom: 7px;
                right: 3%;
                width: 64px;
                height: 64px;
                font-size: 36px;
                border-radius: 20px;
            }

            .search-section { margin-top: -20px; }

            .search-box {
                flex-wrap: wrap;
                gap: 7px;
                padding: 9px;
            }

            .search-icon {
                width: 39px;
                height: 39px;
                flex-basis: 39px;
            }

            .search-box input {
                width: calc(100% - 50px);
                flex: 1;
            }

            .search-box button { width: 100%; }

            .cuisine-grid {
                grid-template-columns: repeat(2,minmax(0,1fr));
                gap: 11px;
            }

            .cuisine-card {
                height: 150px;
                border-radius: 14px;
            }

            .restaurant-grid { grid-template-columns: 1fr; }
            .restaurant-image-wrap { height: 205px; }

            .section-heading h2 { font-size: 31px; }

            .section-topline { gap: 10px; }

            .view-link {
                padding-top: 4px;
                font-size: 11px;
            }

            .roulette-wheel {
                width: 190px;
                height: 190px;
            }

            .mood-grid { gap: 10px; }

            .mood-card {
                min-height: 175px;
                padding: 13px;
                border-radius: 15px;
            }

            .mood-emoji {
                width: 37px;
                height: 37px;
                margin-bottom: 9px;
                font-size: 20px;
            }

            .mood-card strong { font-size: 13px; }
            .mood-card small { font-size: 10px; }
            .mood-results { padding: 20px; }
            .mood-results h3 { font-size: 21px; }
        }

        @media (prefers-reduced-motion: reduce) {
            html { scroll-behavior: auto; }

            *, *::before, *::after {
                animation-duration: .01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: .01ms !important;
                scroll-behavior: auto !important;
            }

            .scroll-reveal,
            .reveal-left,
            .reveal-right {
                opacity: 1;
                transform: none;
                will-change: auto;
            }

            .mood-results { animation: none; }
        }
    </style>
</head>

<body>

    <!-- SHARED NAVBAR -->
    <jsp:include page="/includes/navbar.jsp" />

    <!-- HERO -->
    <section class="hero" id="homeHero">
        <video class="hero-video" id="homeHeroVideo" muted playsinline loop preload="metadata" aria-hidden="true">
            <source src="<%= contextPath %>/videos/video.mp4.mp4" type="video/mp4">
        </video>

        <div class="hero-content">
            <div class="hero-badge">MORE THAN JUST FOOD</div>

            <h1>A Taste<br>of <span>Happiness</span></h1>

            <p class="hero-description">
                Fresh ingredients. Authentic flavours. Delivered to your doorstep.
            </p>

            <div class="hero-actions">
                <a href="<%= contextPath %>/restaurant" class="primary-btn">
                    Explore Restaurants <span aria-hidden="true">↗</span>
                </a>

                <a href="<%= contextPath %>/food-roulette.jsp" class="surprise-btn">
                    🎲 Surprise Me
                </a>
            </div>

            <div class="hero-note">
                <span class="hero-note-dot"></span>
                <span><strong>Your cravings, your way.</strong> Discover something delicious today.</span>
            </div>
        </div>
    </section>

    <!-- FOOD PLAYGROUND -->
    <section class="food-playground" id="yumletStory">
        <div class="page-container food-playground-inner">

            <div class="food-playground-copy reveal-left">
                <span class="eyebrow">Welcome to Yumlet</span>

                <h2>Your cravings.<br>Your kind of <span>happiness.</span></h2>

                <p>
                    From comforting classics to something new, your next favourite meal is only a few clicks away.
                    Explore local restaurants, discover exciting menus, and make every craving count.
                </p>

                <a href="<%= contextPath %>/restaurant" class="primary-btn">
                    Find your next craving <span aria-hidden="true">→</span>
                </a>
            </div>

            <div class="food-stage reveal-right" aria-label="Floating pizza, burger and hot chocolate illustrations">
                <div class="food-stage-halo"></div>
                <div class="food-stage-ring"></div>

                <span class="food-sparkle sparkle-a" aria-hidden="true">✦</span>
                <span class="food-sparkle sparkle-b" aria-hidden="true">✧</span>
                <span class="food-sparkle sparkle-c" aria-hidden="true">✦</span>

                <div class="food-emoji food-emoji-main" role="img" aria-label="Hot meal">🍜</div>
                <div class="food-emoji food-emoji-burger" role="img" aria-label="Burger">🍔</div>
                <div class="food-emoji food-emoji-pizza" role="img" aria-label="Pizza">🍕</div>
                <div class="food-emoji food-emoji-drink" role="img" aria-label="Hot chocolate">☕</div>
            </div>

        </div>
    </section>

    <!-- MOOD FOOD FINDER WITH FOOD IMAGES -->
  
<!-- CREATIVE MOOD FINDER SECTION -->
<section class="mood-section">
    <div class="mood-container">

        <div class="mood-orbit">
            <span class="orbit-dot dot-one"></span>
            <span class="orbit-dot dot-two"></span>
            <span class="orbit-dot dot-three"></span>

            <div class="mood-center">
                <span class="mood-spark">✦</span>
                <span class="mood-face">☺</span>
                <span class="mood-heart">♡</span>
            </div>
        </div>

        <div class="mood-content">
            <span class="mood-label">A LITTLE TASTE OF HAPPINESS</span>

            <h2>What's Your Mood<br>Craving Today?</h2>

            <p>
                Feeling happy, tired, stressed or just hungry?
                Let Yumlet help you discover food that matches
                the way you feel.
            </p>

            <a href="<%= contextPath %>/mood.jsp"
               class="check-mood-btn">
                Check My Mood
                <span aria-hidden="true">↗</span>
            </a>

            <div class="mood-note">
                <span>✦</span>
                Your mood. Your cravings. Your Yumlet.
            </div>
        </div>

    </div>
</section>
  

    <!-- SEARCH -->
    <section class="search-section">
        <div class="page-container">
            <form class="search-box" id="restaurantSearchForm" role="search">
                <div class="search-icon" aria-hidden="true">⌕</div>

                <input
                    type="search"
                    id="restaurantSearch"
                    placeholder="Search restaurants or cuisines..."
                    aria-label="Search restaurants or cuisines">

                <button type="submit">Search <span aria-hidden="true">→</span></button>
            </form>
        </div>
    </section>

    <!-- CUISINES -->
    <section class="section" id="cuisines">
        <div class="page-container">

            <div class="section-topline scroll-reveal">
                <div class="section-heading">
                    <span class="eyebrow">Discover your favourites</span>
                    <h2>Explore Our Cuisines</h2>
                    <p>Different flavours. One destination.</p>
                </div>

                <a href="<%= contextPath %>/restaurant" class="view-link">View all →</a>
            </div>

            <div class="cuisine-grid">

                <a class="cuisine-card scroll-reveal" style="--reveal-delay:0ms" href="<%= contextPath %>/restaurant">
                    <img src="https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=500&q=80" alt="North Indian food" loading="lazy" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=500&q=80';">
                    <span>North Indian</span>
                </a>

                <a class="cuisine-card scroll-reveal" style="--reveal-delay:70ms" href="<%= contextPath %>/restaurant">
                    <img src="https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=500&q=80" alt="South Indian food" loading="lazy" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1630383249896-424e482df921?auto=format&fit=crop&w=500&q=80';">
                    <span>South Indian</span>
                </a>

                <a class="cuisine-card scroll-reveal" style="--reveal-delay:140ms" href="<%= contextPath %>/restaurant">
                    <img src="https://images.unsplash.com/photo-1563379091339-03246963d96a?auto=format&fit=crop&w=500&q=80" alt="Biryani" loading="lazy" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=500&q=80';">
                    <span>Biryani</span>
                </a>

                <a class="cuisine-card scroll-reveal" style="--reveal-delay:210ms" href="<%= contextPath %>/restaurant">
                    <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80" alt="Burgers and fast food" loading="lazy" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=500&q=80';">
                    <span>Fast Food</span>
                </a>

                <a class="cuisine-card scroll-reveal" style="--reveal-delay:280ms" href="<%= contextPath %>/restaurant">
                    <img src="https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=500&q=80" alt="Chocolate desserts" loading="lazy" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=500&q=80';">
                    <span>Desserts</span>
                </a>

                <a class="cuisine-card scroll-reveal" style="--reveal-delay:350ms" href="<%= contextPath %>/restaurant">
                    <img src="https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=500&q=80" alt="Indian snacks" loading="lazy" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&w=500&q=80';">
                    <span>Snacks</span>
                </a>

            </div>
        </div>
    </section>

    <!-- RESTAURANTS: DATABASE QUERY AND DISPLAY LOGIC PRESERVED -->
    <section class="section" id="restaurants">
        <div class="page-container">

            <div class="section-topline scroll-reveal">
                <div class="section-heading">
                    <span class="eyebrow">Made for your cravings</span>
                    <h2>Top Restaurants Near You</h2>
                    <p>Loved by foodies. Ready for your next meal.</p>
                </div>

                <a href="<%= contextPath %>/restaurant" class="view-link">View all →</a>
            </div>

            <div class="restaurant-grid" id="restaurantGrid">

                <% if (restaurants.isEmpty()) { %>

                    <div class="empty-restaurants">
                        <h3>Restaurants are getting ready!</h3>
                        <p>We couldn't load restaurant details right now. Please visit the restaurants page to explore.</p>
                        <a href="<%= contextPath %>/restaurant" class="primary-btn">Explore Restaurants</a>
                    </div>

                <% } else {
                    for (Map<String, String> restaurant : restaurants) {
                        String name = restaurant.get("name");
                        String cuisine = restaurant.get("cuisine");
                        String image = restaurantImage(restaurant.get("image"));
                        String rating = restaurant.get("rating");
                        String deliveryTime = restaurant.get("deliveryTime");
                %>

                    <article class="restaurant-card scroll-reveal" data-search="<%= esc((name + " " + cuisine).toLowerCase(Locale.ROOT)) %>">

                        <div class="restaurant-image-wrap">
                            <img
                                class="restaurant-image"
                                src="<%= esc(image) %>"
                                alt="<%= esc(name) %>"
                                loading="lazy"
                                onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=85';">
                        </div>

                        <div class="restaurant-info">
                            <h3><%= esc(name) %></h3>

                            <div class="restaurant-cuisine"><%= esc(cuisine) %></div>

                            <div class="restaurant-meta">
                                <span class="restaurant-rating">★ <%= esc(rating) %></span>
                                <span>◷ <%= esc(deliveryTime) %></span>
                            </div>

                            <a class="restaurant-link" href="<%= contextPath %>/restaurant">
                                Explore Restaurant <span aria-hidden="true">→</span>
                            </a>
                        </div>

                    </article>

                <%  }
                   }
                %>

            </div>

            <div class="view-all scroll-reveal">
                <a href="<%= contextPath %>/restaurant" class="primary-btn">
                    View All Restaurants <span aria-hidden="true">→</span>
                </a>
            </div>

        </div>
    </section>

    <!-- FEATURES -->
    <section class="section features-section" id="features">
        <div class="page-container">

            <div class="section-heading scroll-reveal">
                <span class="eyebrow">Why Yumlet?</span>
                <h2>A Little More Delicious</h2>
                <p>Finding something tasty should be simple, fun, and made around you.</p>
            </div>

            <div class="features-grid">

                <div class="feature-card scroll-reveal" style="--reveal-delay:0ms">
                    <div class="feature-symbol" aria-hidden="true">🍽️</div>
                    <h3>Explore Restaurants</h3>
                    <p>Discover restaurants and explore menus filled with meals for every craving.</p>
                </div>

                <div class="feature-card scroll-reveal" style="--reveal-delay:100ms">
                    <div class="feature-symbol" aria-hidden="true">🛒</div>
                    <h3>Easy Ordering</h3>
                    <p>Add your favourite dishes to your cart and manage your order in one convenient place.</p>
                </div>

                <div class="feature-card scroll-reveal" style="--reveal-delay:200ms">
                    <div class="feature-symbol" aria-hidden="true">🎯</div>
                    <h3>Food Roulette</h3>
                    <p>Not sure what to eat? Let the roulette pick a tasty idea for your next meal.</p>
                </div>

            </div>
        </div>
    </section>

    <!-- FOOD ROULETTE -->
    <section class="section roulette-section" id="roulette">
        <div class="page-container">

            <div class="roulette-card scroll-reveal">

                <div class="roulette-copy">
                    <span class="eyebrow">Feeling indecisive?</span>
                    <h2>Let the Cravings Decide!</h2>
                    <p>Too many choices? Give Food Roulette a spin and discover what you might want to eat today.</p>

                    <button type="button" class="primary-btn" id="spinRouletteButton">
                        Spin the Roulette <span aria-hidden="true">↻</span>
                    </button>
                </div>

                <div class="roulette-wheel-wrap">
                    <div class="roulette-pointer" aria-hidden="true"></div>
                    <div class="roulette-wheel" id="rouletteWheel" aria-label="Food roulette wheel"></div>
                    <div class="roulette-result" id="rouletteResult" aria-live="polite">Ready to discover something delicious?</div>

                    <a href="<%= contextPath %>/restaurant" class="secondary-btn">
                        Find Your Food <span aria-hidden="true">→</span>
                    </a>
                </div>

            </div>
        </div>
    </section>

    <!-- FINAL CALL TO ACTION -->
    <section class="cta-section">
        <div class="page-container">

            <div class="cta-card scroll-reveal">
                <h2>Your Next Favourite Meal Awaits</h2>
                <p>Explore menus, discover restaurants, and find something delicious for your next craving.</p>

                <a href="<%= contextPath %>/restaurant" class="primary-btn">
                    Start Exploring <span aria-hidden="true">↗</span>
                </a>
            </div>

        </div>
    </section>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const reducedMotion = window.matchMedia &&
                window.matchMedia("(prefers-reduced-motion: reduce)").matches;

            /* SCROLL REVEALS */

            const revealElements = document.querySelectorAll(
                ".scroll-reveal, .reveal-left, .reveal-right"
            );

            if (reducedMotion || !("IntersectionObserver" in window)) {
                revealElements.forEach(function (element) {
                    element.classList.add("revealed");
                });
            } else {
                const revealObserver = new IntersectionObserver(function (entries, observer) {
                    entries.forEach(function (entry) {
                        if (entry.isIntersecting) {
                            entry.target.classList.add("revealed");
                            observer.unobserve(entry.target);
                        }
                    });
                }, {
                    threshold: 0.08,
                    rootMargin: "0px 0px -35px 0px"
                });

                revealElements.forEach(function (element) {
                    revealObserver.observe(element);
                });
            }

            /* RESTAURANT SEARCH */

            const searchForm = document.getElementById("restaurantSearchForm");
            const searchInput = document.getElementById("restaurantSearch");
            const restaurantCards = document.querySelectorAll(".restaurant-card");

            function filterRestaurants() {
                const value = searchInput.value.trim().toLowerCase();

                restaurantCards.forEach(function (card) {
                    card.hidden = !(card.dataset.search || "").includes(value);
                });
            }

            if (searchForm && searchInput) {
                searchForm.addEventListener("submit", function (event) {
                    event.preventDefault();
                    filterRestaurants();

                    const section = document.getElementById("restaurants");

                    if (section) {
                        section.scrollIntoView({
                            behavior: reducedMotion ? "auto" : "smooth"
                        });
                    }
                });

                searchInput.addEventListener("input", filterRestaurants);
            }

            /* FOOD ROULETTE */

            const rouletteFoods = [
                "Masala Dosa",
                "Paneer Butter Masala",
                "Veg Biryani",
                "Chicken Biryani",
                "Pizza",
                "Burger",
                "Masala Puri",
                "Chole Bhature",
                "Idli Vada",
                "Pav Bhaji",
                "Gobi Manchurian",
                "Kesari Bath"
            ];

            const spinButton = document.getElementById("spinRouletteButton");
            const rouletteWheel = document.getElementById("rouletteWheel");
            const rouletteResult = document.getElementById("rouletteResult");

            let rouletteSpinning = false;

            if (spinButton && rouletteWheel && rouletteResult) {
                spinButton.addEventListener("click", function () {
                    if (rouletteSpinning) return;

                    rouletteSpinning = true;
                    spinButton.disabled = true;
                    rouletteResult.textContent = "Finding your next craving...";

                    rouletteWheel.classList.remove("spinning");
                    void rouletteWheel.offsetWidth;
                    rouletteWheel.classList.add("spinning");

                    const chosenFood =
                        rouletteFoods[Math.floor(Math.random() * rouletteFoods.length)];

                    window.setTimeout(function () {
                        rouletteResult.textContent = "Today's pick: " + chosenFood + "!";
                        rouletteSpinning = false;
                        spinButton.disabled = false;
                        rouletteWheel.classList.remove("spinning");
                    }, reducedMotion ? 50 : 2600);
                });
            }

            /* HERO VIDEO */

            const hero = document.getElementById("homeHero");
            const video = document.getElementById("homeHeroVideo");

            if (hero && video && !reducedMotion) {
                let videoStarted = false;
                let heroTimer;

                function stopVideoWhenHeroLeaves() {
                    if (hero.getBoundingClientRect().bottom <= 0) {
                        video.pause();

                        try {
                            video.currentTime = 0;
                        } catch (ignore) {}

                        hero.classList.remove("video-playing");
                        window.removeEventListener("scroll", stopVideoWhenHeroLeaves);
                    }
                }

                function startHeroVideo() {
                    if (videoStarted || hero.getBoundingClientRect().bottom <= 0) {
                        return;
                    }

                    const playAttempt = video.play();

                    if (playAttempt && typeof playAttempt.then === "function") {
                        playAttempt.then(function () {
                            videoStarted = true;
                            hero.classList.add("video-playing");

                            window.addEventListener(
                                "scroll",
                                stopVideoWhenHeroLeaves,
                                { passive: true }
                            );

                            stopVideoWhenHeroLeaves();
                        }).catch(function () {
                            hero.classList.remove("video-playing");
                        });
                    }
                }

                video.addEventListener("error", function () {
                    hero.classList.remove("video-playing");
                });

                heroTimer = window.setTimeout(startHeroVideo, 3000);

                window.addEventListener("scroll", function () {
                    if (!videoStarted && hero.getBoundingClientRect().bottom <= 0) {
                        window.clearTimeout(heroTimer);
                    }
                }, { passive: true });
            }

            /* MOOD FOOD FINDER */

            const moodOptions = {
                period: {
                    title: "A Little Extra Comfort 🌸",
                    description: "Try warm meals such as khichdi, idli, soup or a comforting home-style meal. Choose what feels good for you."
                },

                sick: {
                    title: "Take It Easy Today 🤒",
                    description: "Consider gentle options like idli, clear soup, soft rice or khichdi. Stay hydrated and choose foods you can comfortably tolerate."
                },

                happy: {
                    title: "Celebrate Your Happiness 🥳",
                    description: "Make your day more delicious with pizza, biryani, burgers or your favourite dessert. Pick a treat that makes you smile."
                },

                sad: {
                    title: "Comfort Food Time 😢",
                    description: "Feeling low? Consider a warm bowl of noodles, your favourite biryani, a comforting dosa or a little chocolate dessert."
                },

                diet: {
                    title: "Fresh Choices, Your Way 🥗",
                    description: "Explore vegetable-rich meals, dal, grilled dishes, salads or balanced rice bowls. Choose portions and ingredients that suit your needs."
                },

                stress: {
                    title: "Take a Delicious Break 😮‍💨",
                    description: "Pause for a moment and enjoy something you love, whether that's a warm meal, a sandwich, a bowl of noodles or a refreshing drink."
                },

                rainy: {
                    title: "Rainy Day Cravings 🌧️",
                    description: "Rain calls for hot chai, pakoras, samosas, masala puri or a warm bowl of soup. Find your favourite rainy-day snack."
                },

                night: {
                    title: "Midnight Munchies 🌙",
                    description: "Craving something late at night? Explore sandwiches, noodles, dosa or a small dessert. Check restaurant availability before ordering."
                }
            };

            const moodCards = document.querySelectorAll(".mood-card");
            const moodResults = document.getElementById("moodResults");
            const moodResultTitle = document.getElementById("moodResultTitle");
            const moodResultDescription =
                document.getElementById("moodResultDescription");

            moodCards.forEach(function (card) {
                card.addEventListener("click", function () {
                    const mood = moodOptions[card.dataset.mood];

                    if (!mood) return;

                    moodCards.forEach(function (item) {
                        item.classList.remove("active");
                        item.setAttribute("aria-pressed", "false");
                    });

                    card.classList.add("active");
                    card.setAttribute("aria-pressed", "true");

                    moodResultTitle.textContent = mood.title;
                    moodResultDescription.textContent = mood.description;

                    moodResults.classList.add("show");

                    moodResults.scrollIntoView({
                        behavior: reducedMotion ? "auto" : "smooth",
                        block: "nearest"
                    });
                });
            });
        });
    </script>

    <!-- SHARED FOOTER -->
    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
