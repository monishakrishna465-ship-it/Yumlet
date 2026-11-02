
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String cp = request.getContextPath();

    Object usernameObject = session.getAttribute("username");
    String username = usernameObject == null
            ? "Eatero User" : usernameObject.toString();

    Object emailObject = session.getAttribute("email");
    String email = emailObject == null ? "" : emailObject.toString();

    Object phoneObject = session.getAttribute("phone");
    String phone = phoneObject == null ? "" : phoneObject.toString();

    Object addressObject = session.getAttribute("address");
    String address = addressObject == null ? "" : addressObject.toString();

    String initial = username.trim().isEmpty()
            ? "U" : username.trim().substring(0, 1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | Eatero</title>

    <link rel="stylesheet" href="<%= cp %>/css/navbar.css">
    <link rel="stylesheet" href="<%= cp %>/css/profile.css">
    <link rel="stylesheet" href="<%= cp %>/css/footer.css">

    <style>
        body.profile-page {
            margin: 0;
            background: #3B2419;
            color: #F5E8D5;
            font-family: Arial, sans-serif;
        }

        .profile-page .profile-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 24px 60px;
            min-height: 70vh;
            background: transparent;
        }

        .profile-page-heading {
            margin-bottom: 30px;
        }

        .profile-page-heading .profile-eyebrow {
            color: #D4A373;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 2px;
        }

        .profile-page-heading h1 {
            margin: 8px 0;
            color: #F5E8D5;
            font-size: 34px;
        }

        .profile-page-heading > p:last-child {
            color: #E4D2BE;
            line-height: 1.6;
        }

        .profile-layout {
            display: grid;
            grid-template-columns: 260px minmax(0, 1fr);
            gap: 25px;
            align-items: start;
        }

        .profile-sidebar {
            background: #F5E8D5;
            border: 1px solid #D9BEA0;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 12px 28px rgba(25, 12, 7, .18);
        }

        .profile-user-card {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 22px 17px;
            background: #E9D5BB;
            border-bottom: 1px solid #D9BEA0;
        }

        .profile-avatar {
            width: 48px;
            height: 48px;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: #513426;
            color: #FFF8EE;
            border: 2px solid #D4A373;
            font-size: 21px;
            font-weight: 700;
        }

        .profile-user-info {
            min-width: 0;
        }

        .profile-user-info h2 {
            margin: 0 0 5px;
            color: #3B2419;
            font-size: 16px;
            overflow-wrap: anywhere;
        }

        .profile-user-info p {
            margin: 0;
            color: #80634D;
            font-size: 12px;
        }

        .profile-menu {
            display: flex;
            flex-direction: column;
            gap: 5px;
            padding: 13px;
            background: #F5E8D5;
        }

        .profile-menu-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-radius: 10px;
            color: #513426;
            font-size: 14px;
            text-decoration: none;
            transition: background .2s ease, color .2s ease;
        }

        .profile-menu-item:hover,
        .profile-menu-item.active {
            background: #D9BEA0;
            color: #30170D;
        }

        .profile-menu-icon {
            width: 22px;
            text-align: center;
            color: #805333;
            font-size: 17px;
        }

        .profile-menu-divider {
            height: 1px;
            margin: 8px 0;
            background: #D9BEA0;
        }

        .profile-menu-item.profile-logout {
            color: #8B3529;
        }

        .profile-menu-item.profile-logout:hover {
            background: #F0D6C9;
        }

        .profile-content {
            min-width: 0;
        }

        .profile-card {
            overflow: hidden;
            background: #F5E8D5;
            color: #3B2419;
            border: 1px solid #D9BEA0;
            border-radius: 18px;
            box-shadow: 0 12px 30px rgba(25, 12, 7, .18);
        }

        .profile-card-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            padding: 23px;
            background: #E9D5BB;
            border-bottom: 1px solid #D9BEA0;
        }

        .profile-card-heading h2 {
            margin: 0 0 7px;
            color: #3B2419;
            font-size: 21px;
        }

        .profile-card-heading p {
            margin: 0;
            color: #80634D;
            font-size: 13px;
            line-height: 1.5;
        }

        .profile-status {
            padding: 8px 12px;
            border-radius: 20px;
            background: #D9BEA0;
            color: #3B2419;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .profile-details {
            padding: 8px 23px;
            background: #F5E8D5;
        }

        .profile-detail-item {
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding: 17px 0;
            border-bottom: 1px solid #E4D2BE;
        }

        .profile-detail-item:last-child {
            border-bottom: none;
        }

        .detail-label {
            color: #80634D;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .6px;
        }

        .detail-value {
            color: #30170D;
            font-size: 15px;
            overflow-wrap: anywhere;
            line-height: 1.5;
        }

        .profile-card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 15px;
            padding: 20px 23px;
            background: #E9D5BB;
            border-top: 1px solid #D9BEA0;
        }

        .profile-card-footer p {
            margin: 0;
            color: #70533F;
            font-size: 13px;
            line-height: 1.6;
        }

        .profile-primary-button {
            display: inline-block;
            padding: 12px 18px;
            background: #513426;
            color: #FFF8EE;
            border: 1px solid #513426;
            border-radius: 9px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            transition: background .2s ease, transform .2s ease;
        }

        .profile-primary-button:hover {
            background: #805333;
            border-color: #805333;
            transform: translateY(-2px);
        }

        .profile-quick-links {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
            margin-top: 22px;
        }

        .profile-quick-card {
            display: flex;
            align-items: center;
            gap: 11px;
            min-width: 0;
            padding: 17px 14px;
            background: #F5E8D5;
            color: #3B2419;
            border: 1px solid #D9BEA0;
            border-radius: 14px;
            text-decoration: none;
            box-shadow: 0 6px 18px rgba(25, 12, 7, .12);
            transition: transform .2s ease, background .2s ease;
        }

        .profile-quick-card:hover {
            background: #E9D5BB;
            transform: translateY(-3px);
        }

        .quick-card-icon {
            color: #805333;
            font-size: 21px;
        }

        .profile-quick-card > span:nth-child(2) {
            display: flex;
            flex: 1;
            flex-direction: column;
            gap: 5px;
            min-width: 0;
        }

        .profile-quick-card strong {
            color: #3B2419;
            font-size: 13px;
        }

        .profile-quick-card small {
            color: #80634D;
            font-size: 11px;
            line-height: 1.5;
        }

        .quick-arrow {
            color: #805333;
            font-size: 18px;
        }

        .profile-page a:focus-visible {
            outline: 3px solid #D4A373;
            outline-offset: 3px;
        }

        @media (max-width: 900px) {
            .profile-layout {
                grid-template-columns: 1fr;
            }

            .profile-quick-links {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 600px) {
            .profile-page .profile-container {
                padding: 28px 15px 40px;
            }

            .profile-page-heading h1 {
                font-size: 28px;
            }

            .profile-card-heading {
                align-items: flex-start;
                flex-direction: column;
                padding: 18px;
            }

            .profile-details {
                padding: 8px 18px;
            }

            .profile-card-footer {
                align-items: flex-start;
                flex-direction: column;
                padding: 18px;
            }
        }
    </style>
</head>

<body class="profile-page">

    <jsp:include page="/includes/navbar.jsp" />

    <main class="profile-container">

        <section class="profile-page-heading">
            <p class="profile-eyebrow">YOUR EATERO ACCOUNT</p>
            <h1>My Profile</h1>
            <p>Manage your account and your food journey.</p>
        </section>

        <div class="profile-layout">

            <!-- SIDEBAR -->
            <aside class="profile-sidebar">

                <div class="profile-user-card">
                    <div class="profile-avatar"><%= initial %></div>

                    <div class="profile-user-info">
                        <h2><%= escProfile(username) %></h2>
                        <p>Food lover at Eatero</p>
                    </div>
                </div>

                <nav class="profile-menu" aria-label="Profile navigation">

                    <a class="profile-menu-item active"
                       href="<%= cp %>/profile">
                        <span class="profile-menu-icon">👤</span>
                        <span>My Profile</span>
                    </a>

                    <a class="profile-menu-item" href="<%= cp %>/orders">
                        <span class="profile-menu-icon">🛍️</span>
                        <span>My Orders</span>
                    </a>

                    <a class="profile-menu-item" href="<%= cp %>/favourites">
                        <span class="profile-menu-icon">♡</span>
                        <span>Favourites</span>
                    </a>

                    <a class="profile-menu-item" href="<%= cp %>/settings.jsp">
                        <span class="profile-menu-icon">⚙</span>
                        <span>Settings</span>
                    </a>

                    <div class="profile-menu-divider"></div>

                    <a class="profile-menu-item profile-logout"
                       href="<%= cp %>/logout">
                        <span class="profile-menu-icon">↪</span>
                        <span>Logout</span>
                    </a>

                </nav>
            </aside>

            <!-- PROFILE CONTENT -->
            <section class="profile-content">

                <div class="profile-card">

                    <div class="profile-card-heading">
                        <div>
                            <h2>Personal Information</h2>
                            <p>View your account details below.</p>
                        </div>
                        <span class="profile-status">My Account</span>
                    </div>

                    <div class="profile-details">

                        <div class="profile-detail-item">
                            <span class="detail-label">Full Name</span>
                            <span class="detail-value"><%= escProfile(username) %></span>
                        </div>

                        <div class="profile-detail-item">
                            <span class="detail-label">Email Address</span>
                            <span class="detail-value"><%= email.trim().isEmpty()
                                ? "Not available" : escProfile(email) %></span>
                        </div>

                        <div class="profile-detail-item">
                            <span class="detail-label">Phone Number</span>
                            <span class="detail-value"><%= phone.trim().isEmpty()
                                ? "Not available" : escProfile(phone) %></span>
                        </div>

                        <div class="profile-detail-item">
                            <span class="detail-label">Address</span>
                            <span class="detail-value"><%= address.trim().isEmpty()
                                ? "Not available" : escProfile(address) %></span>
                        </div>

                    </div>

                    <div class="profile-card-footer">
                        <p>
                            Want to change your account details?
                            Visit Settings.
                        </p>

                        <a class="profile-primary-button"
                           href="<%= cp %>/settings.jsp">
                            Account Settings
                        </a>
                    </div>

                </div>

                <!-- QUICK ACCESS -->
                <div class="profile-quick-links">

                    <a href="<%= cp %>/orders" class="profile-quick-card">
                        <span class="quick-card-icon">🛍️</span>
                        <span>
                            <strong>My Orders</strong>
                            <small>Check your food orders</small>
                        </span>
                        <span class="quick-arrow">→</span>
                    </a>

                    <a href="<%= cp %>/favourites" class="profile-quick-card">
                        <span class="quick-card-icon">♡</span>
                        <span>
                            <strong>Favourites</strong>
                            <small>Find your saved favourites</small>
                        </span>
                        <span class="quick-arrow">→</span>
                    </a>

                    <a href="<%= cp %>/settings.jsp" class="profile-quick-card">
                        <span class="quick-card-icon">⚙</span>
                        <span>
                            <strong>Settings</strong>
                            <small>Manage your account</small>
                        </span>
                        <span class="quick-arrow">→</span>
                    </a>

                </div>

            </section>
        </div>
    </main>

    <jsp:include page="/includes/footer.jsp" />

</body>
</html>

<%!
    private String escProfile(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>
