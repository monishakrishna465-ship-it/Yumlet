
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    String contextPath = request.getContextPath();

    HttpSession userSession = request.getSession(false);

    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect(contextPath + "/login.jsp");
        return;
    }

    Object sessionName = userSession.getAttribute("name");
    if (sessionName == null) {
        sessionName = userSession.getAttribute("username");
    }

    String displayName = sessionName == null
            ? "Eatero User" : sessionName.toString();

    Object sessionEmail = userSession.getAttribute("email");
    String email = sessionEmail == null ? "" : sessionEmail.toString();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Settings | Eatero</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/navbar.css">
    <link rel="stylesheet" href="<%= contextPath %>/css/footer.css">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #3B2419;
            color: #F5E8D5;
        }

        .settings-container {
            max-width: 1100px;
            margin: auto;
            padding: 38px 22px 60px;
            min-height: 75vh;
        }

        .settings-heading {
            margin: 0 0 8px;
            font-size: 34px;
            color: #F5E8D5;
        }

        .settings-subtitle {
            color: #E4D2BE;
            margin: 0 0 30px;
            line-height: 1.6;
        }

        .settings-layout {
            display: grid;
            grid-template-columns: 245px minmax(0, 1fr);
            gap: 24px;
            align-items: start;
        }

        .settings-menu,
        .settings-panel {
            background: #F5E8D5;
            color: #3B2419;
            border: 1px solid #D9BEA0;
            border-radius: 16px;
            padding: 22px;
            box-shadow: 0 12px 28px rgba(25, 12, 7, .16);
        }

        .settings-menu h3 {
            margin: 0 0 17px;
            color: #3B2419;
            font-size: 17px;
        }

        .settings-menu button {
            display: block;
            width: 100%;
            padding: 13px;
            margin-bottom: 8px;
            border: 1px solid transparent;
            border-radius: 9px;
            text-align: left;
            background: transparent;
            color: #513426;
            cursor: pointer;
            font-size: 14px;
            transition: background .2s ease, color .2s ease;
        }

        .settings-menu button.active,
        .settings-menu button:hover {
            background: #D9BEA0;
            color: #30170D;
            border-color: #C9A783;
        }

        .settings-menu button:focus-visible,
        .primary-button:focus-visible,
        .secondary-button:focus-visible,
        .danger-button:focus-visible {
            outline: 3px solid #B87545;
            outline-offset: 3px;
        }

        .settings-section {
            display: none;
        }

        .settings-section.active {
            display: block;
        }

        .settings-section h2 {
            margin: 0 0 8px;
            font-size: 23px;
            color: #3B2419;
        }

        .section-description {
            color: #80634D;
            font-size: 14px;
            line-height: 1.7;
            margin: 0 0 24px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: bold;
            color: #513426;
            margin-bottom: 8px;
        }

        .form-group input {
            width: 100%;
            padding: 13px;
            border: 1px solid #D9BEA0;
            border-radius: 9px;
            font-size: 14px;
            background: #FFF9F0;
            color: #3B2419;
        }

        .form-group input:disabled {
            background: #E9D5BB;
            color: #70533F;
            opacity: 1;
        }

        .primary-button,
        .secondary-button,
        .danger-button {
            display: inline-block;
            padding: 12px 19px;
            border-radius: 9px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 700;
            transition: background .2s ease, transform .2s ease;
        }

        .primary-button {
            border: 1px solid #513426;
            background: #513426;
            color: #FFF8EE;
        }

        .primary-button:hover {
            background: #805333;
            border-color: #805333;
            transform: translateY(-1px);
        }

        .secondary-button {
            border: 1px solid #C9A783;
            background: #E9D5BB;
            color: #3B2419;
        }

        .secondary-button:hover {
            background: #D9BEA0;
        }

        .setting-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            padding: 18px 0;
            border-bottom: 1px solid #E4D2BE;
        }

        .setting-row:last-of-type {
            border-bottom: none;
        }

        .setting-row h3 {
            font-size: 15px;
            color: #3B2419;
            margin: 0 0 6px;
        }

        .setting-row p {
            font-size: 13px;
            color: #80634D;
            margin: 0;
            line-height: 1.6;
        }

        .toggle {
            width: 44px;
            height: 24px;
            flex-shrink: 0;
            accent-color: #805333;
            cursor: pointer;
        }

        .danger-button {
            background: #F5E8D5;
            border: 1px solid #A63D32;
            color: #8B3529;
        }

        .danger-button:hover {
            background: #F0D6C9;
        }

        .message {
            display: none;
            margin-top: 16px;
            padding: 13px;
            border-radius: 9px;
            background: #E2EAD8;
            border: 1px solid #C3D2B3;
            color: #31552A;
            font-size: 14px;
            line-height: 1.5;
        }

        .account-note {
            color: #80634D;
            font-size: 13px;
            line-height: 1.7;
            margin-top: 18px;
        }

        @media (max-width: 700px) {
            .settings-container {
                padding: 28px 15px 42px;
            }

            .settings-heading {
                font-size: 28px;
            }

            .settings-layout {
                grid-template-columns: 1fr;
                gap: 16px;
            }

            .settings-menu {
                padding: 15px;
            }

            .settings-menu h3 {
                margin-bottom: 10px;
            }

            .settings-menu button {
                display: inline-block;
                width: auto;
                margin: 3px;
                padding: 11px 13px;
            }

            .settings-panel {
                padding: 18px;
            }
        }

        @media (max-width: 420px) {
            .setting-row {
                align-items: flex-start;
                gap: 12px;
            }

            .setting-row p {
                max-width: 240px;
            }

            .primary-button,
            .danger-button {
                padding: 11px 14px;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="/includes/navbar.jsp" />

    <main class="settings-container">

        <h1 class="settings-heading">Settings</h1>

        <p class="settings-subtitle">
            Manage your account and preferences.
        </p>

        <div class="settings-layout">

            <aside class="settings-menu">
                <h3>Preferences</h3>

                <button type="button" class="active"
                        data-section="profile">
                    My Profile
                </button>

                <button type="button" data-section="notifications">
                    Notifications
                </button>

                <button type="button" data-section="privacy">
                    Privacy
                </button>

                <button type="button" data-section="account">
                    Account
                </button>
            </aside>

            <div class="settings-panel">

                <!-- PROFILE SETTINGS -->
                <section class="settings-section active" id="profile">

                    <h2>My Profile</h2>

                    <p class="section-description">
                        View your account information.
                    </p>

                    <div class="form-group">
                        <label for="displayName">Name</label>
                        <input id="displayName"
                               type="text"
                               value="<%= escapeSettings(displayName) %>"
                               disabled>
                    </div>

                    <div class="form-group">
                        <label for="email">Email address</label>
                        <input id="email"
                               type="email"
                               value="<%= escapeSettings(email) %>"
                               disabled>
                    </div>

                    <p class="account-note">
                        Your account details are displayed here.
                        Profile editing is not connected to the database
                        on this page yet.
                    </p>

                    <a class="primary-button"
                       href="<%= contextPath %>/profile"
                       style="text-decoration:none;">
                        View My Profile
                    </a>

                </section>

                <!-- NOTIFICATION SETTINGS -->
                <section class="settings-section" id="notifications">

                    <h2>Notifications</h2>

                    <p class="section-description">
                        Choose which notifications you prefer on this device.
                    </p>

                    <div class="setting-row">
                        <div>
                            <h3>Order updates</h3>
                            <p>Updates about your food orders.</p>
                        </div>

                        <input class="toggle"
                               type="checkbox"
                               id="orderNotifications">
                    </div>

                    <div class="setting-row">
                        <div>
                            <h3>Offers and promotions</h3>
                            <p>Hear about deals and special offers.</p>
                        </div>

                        <input class="toggle"
                               type="checkbox"
                               id="offerNotifications">
                    </div>

                    <br>

                    <button type="button" class="primary-button"
                            id="saveNotifications">
                        Save Preferences
                    </button>

                    <div class="message" id="notificationMessage"
                         role="status" aria-live="polite">
                        Notification preferences saved on this device.
                    </div>

                </section>

                <!-- PRIVACY SETTINGS -->
                <section class="settings-section" id="privacy">

                    <h2>Privacy</h2>

                    <p class="section-description">
                        Review your privacy preferences.
                    </p>

                    <div class="setting-row">
                        <div>
                            <h3>Personalized offers</h3>
                            <p>
                                Allow your preferences to be used for
                                tailored offers on this device.
                            </p>
                        </div>

                        <input class="toggle"
                               type="checkbox"
                               id="personalizedOffers">
                    </div>

                    <p class="account-note">
                        These are local interface preferences. They do not
                        change server-side privacy settings.
                    </p>

                    <button type="button" class="primary-button"
                            id="savePrivacy">
                        Save Preferences
                    </button>

                    <div class="message" id="privacyMessage"
                         role="status" aria-live="polite">
                        Privacy preferences saved on this device.
                    </div>

                </section>

                <!-- ACCOUNT SETTINGS -->
                <section class="settings-section" id="account">

                    <h2>Account</h2>

                    <p class="section-description">
                        Manage your current Eatero session.
                    </p>

                    <div class="setting-row">
                        <div>
                            <h3>Log out</h3>
                            <p>End your current session on this device.</p>
                        </div>

                        <button type="button" class="danger-button"
                                id="logoutButton">
                            Log Out
                        </button>
                    </div>

                </section>

            </div>
        </div>
    </main>

   

    <script>
        (function () {
            "use strict";

            var menuButtons =
                document.querySelectorAll(".settings-menu button");

            var sections =
                document.querySelectorAll(".settings-section");

            menuButtons.forEach(function (button) {
                button.addEventListener("click", function () {
                    menuButtons.forEach(function (item) {
                        item.classList.remove("active");
                    });

                    sections.forEach(function (section) {
                        section.classList.remove("active");
                    });

                    button.classList.add("active");

                    var target =
                        document.getElementById(button.dataset.section);

                    if (target) {
                        target.classList.add("active");
                    }
                });
            });

            function loadPreference(id, defaultValue) {
                var saved = localStorage.getItem("eatero_" + id);
                var checkbox = document.getElementById(id);

                checkbox.checked =
                    saved === null ? defaultValue : saved === "true";
            }

            function savePreference(id) {
                localStorage.setItem(
                    "eatero_" + id,
                    document.getElementById(id).checked
                );
            }

            loadPreference("orderNotifications", true);
            loadPreference("offerNotifications", true);
            loadPreference("personalizedOffers", false);

            document.getElementById("saveNotifications")
                .addEventListener("click", function () {
                    savePreference("orderNotifications");
                    savePreference("offerNotifications");

                    document.getElementById("notificationMessage")
                        .style.display = "block";
                });

            document.getElementById("savePrivacy")
                .addEventListener("click", function () {
                    savePreference("personalizedOffers");

                    document.getElementById("privacyMessage")
                        .style.display = "block";
                });

            document.getElementById("logoutButton")
                .addEventListener("click", function () {
                    if (confirm("Are you sure you want to log out?")) {
                        window.location.href =
                            "<%= contextPath %>/logout";
                    }
                });
        })();
    </script>

</body>
</html>

<%!
    private String escapeSettings(String value) {
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
