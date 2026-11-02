
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.DeliveryAddress" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<DeliveryAddress> addresses =
        (List<DeliveryAddress>) request.getAttribute("addresses");

    DeliveryAddress editAddress =
        (DeliveryAddress) request.getAttribute("editAddress");

    String message = request.getParameter("message");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Delivery Addresses | Eatero</title>

<style>
:root {
    --chocolate: #48230F;
    --dark-cocoa: #30170D;
    --cream: #F5E9D8;
    --caramel: #B87545;
    --beige: #E8D3B9;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: var(--cream);
    color: var(--dark-cocoa);
}

.container {
    max-width: 1100px;
    margin: 40px auto;
    padding: 20px;
}

h1 {
    color: var(--chocolate);
    margin-bottom: 8px;
}

.subtitle {
    color: #725846;
    margin-bottom: 28px;
}

.layout {
    display: grid;
    grid-template-columns: 1fr 1.2fr;
    gap: 25px;
    align-items: start;
}

.panel, .address-card {
    background: #fffdf9;
    border: 1px solid var(--beige);
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 5px 18px rgba(48, 23, 13, 0.06);
}

h2 {
    font-size: 21px;
    margin-top: 0;
    color: var(--chocolate);
}

label {
    display: block;
    font-weight: 600;
    font-size: 14px;
    margin: 15px 0 7px;
}

input, select, textarea {
    width: 100%;
    padding: 12px;
    border: 1px solid #d8c5b2;
    border-radius: 8px;
    background: white;
    font-size: 14px;
}

textarea {
    resize: vertical;
    min-height: 85px;
}

button, .button {
    display: inline-block;
    padding: 10px 15px;
    border: 0;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    text-decoration: none;
}

.primary {
    background: var(--chocolate);
    color: white;
    margin-top: 18px;
}

.secondary {
    background: var(--beige);
    color: var(--dark-cocoa);
    margin-top: 18px;
}

.danger {
    background: #f9e3df;
    color: #9d2e20;
}

.default-btn {
    background: #e9f3e7;
    color: #28632b;
}

.address-list {
    display: grid;
    gap: 16px;
}

.address-type {
    display: inline-block;
    padding: 5px 10px;
    background: var(--cream);
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.default-label {
    color: #28713a;
    font-size: 13px;
    font-weight: bold;
    margin-left: 8px;
}

.address-details {
    color: #665447;
    line-height: 1.7;
    overflow-wrap: anywhere;
}

.actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 15px;
}

.notice {
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 8px;
}

.success {
    background: #e8f5e9;
    color: #246b2a;
}

.error {
    background: #fdecea;
    color: #a3261c;
}

.empty {
    padding: 30px;
    text-align: center;
    background: #fffdf9;
    border: 1px dashed var(--beige);
    border-radius: 12px;
    color: #725846;
}

@media (max-width: 760px) {
    .container {
        margin: 15px auto;
        padding: 14px;
    }

    .layout {
        grid-template-columns: 1fr;
    }

    .panel, .address-card {
        padding: 18px;
    }
}
</style>
</head>

<body>

<jsp:include page="includes/navbar.jsp" />

<main class="container">

    <h1>My Delivery Addresses</h1>
    <p class="subtitle">
        Save your favourite delivery locations for a faster checkout.
    </p>

    <% if ("success".equals(message)) { %>
        <div class="notice success">Your address action was completed successfully.</div>
    <% } else if ("failed".equals(message)) { %>
        <div class="notice error">Unable to complete that action. Please try again.</div>
    <% } %>

    <div class="layout">

        <section class="panel">
            <h2>
                <%= editAddress == null ? "Add a New Address" : "Edit Address" %>
            </h2>

            <form action="<%= request.getContextPath() %>/delivery-address"
                  method="post">

                <input type="hidden" name="action" value="save">

                <% if (editAddress != null) { %>
                    <input type="hidden" name="addressId"
                           value="<%= editAddress.getAddressId() %>">
                <% } %>

                <label for="fullName">Full Name</label>
                <input id="fullName" type="text" name="fullName"
                       maxlength="100" required
                       value="<%= editAddress != null && editAddress.getFullName() != null
                           ? editAddress.getFullName() : "" %>">

                <label for="phone">Phone Number</label>
                <input id="phone" type="tel" name="phone"
                       pattern="[0-9]{10}" maxlength="10"
                       inputmode="numeric" required
                       value="<%= editAddress != null && editAddress.getPhone() != null
                           ? editAddress.getPhone() : "" %>">

                <label for="address">House No. / Street / Area</label>
                <textarea id="address" name="address"
                          maxlength="500" required><%= editAddress != null && editAddress.getAddress() != null
                              ? editAddress.getAddress() : "" %></textarea>

                <label for="landmark">Landmark (Optional)</label>
                <input id="landmark" type="text" name="landmark"
                       maxlength="150"
                       value="<%= editAddress != null && editAddress.getLandmark() != null
                           ? editAddress.getLandmark() : "" %>">

                <label for="city">City</label>
                <input id="city" type="text" name="city"
                       maxlength="100" required
                       value="<%= editAddress != null && editAddress.getCity() != null
                           ? editAddress.getCity() : "" %>">

                <label for="pincode">PIN Code</label>
                <input id="pincode" type="text" name="pincode"
                       pattern="[0-9]{6}" maxlength="6"
                       inputmode="numeric" required
                       value="<%= editAddress != null && editAddress.getPincode() != null
                           ? editAddress.getPincode() : "" %>">

                <label for="addressType">Address Type</label>
                <select id="addressType" name="addressType" required>
                    <option value="HOME"
                        <%= editAddress != null && "HOME".equals(editAddress.getAddressType())
                            ? "selected" : "" %>>Home</option>
                    <option value="WORK"
                        <%= editAddress != null && "WORK".equals(editAddress.getAddressType())
                            ? "selected" : "" %>>Work</option>
                    <option value="OTHER"
                        <%= editAddress != null && "OTHER".equals(editAddress.getAddressType())
                            ? "selected" : "" %>>Other</option>
                </select>

                <button class="primary" type="submit">
                    <%= editAddress == null ? "Save Address" : "Update Address" %>
                </button>

                <% if (editAddress != null) { %>
                    <a class="button secondary"
                       href="<%= request.getContextPath() %>/delivery-address">
                       Cancel
                    </a>
                <% } %>
            </form>
        </section>

        <section>
            <h2>Saved Addresses</h2>

            <div class="address-list">

                <% if (addresses == null || addresses.isEmpty()) { %>
                    <div class="empty">
                        <h3>No saved addresses yet</h3>
                        <p>Add your first delivery address using the form.</p>
                    </div>
                <% } else {
                    for (DeliveryAddress a : addresses) {
                %>

                    <article class="address-card">

                        <div>
                            <span class="address-type">
                                <%= a.getAddressType() %>
                            </span>

                            <% if (a.isDefault()) { %>
                                <span class="default-label">✓ Default</span>
                            <% } %>
                        </div>

                        <h3><%= a.getFullName() %></h3>

                        <div class="address-details">
                            <%= a.getAddress() %><br>

                            <% if (a.getLandmark() != null
                                  && !a.getLandmark().trim().isEmpty()) { %>
                                Near <%= a.getLandmark() %><br>
                            <% } %>

                            <%= a.getCity() %> - <%= a.getPincode() %><br>
                            Phone: <%= a.getPhone() %>
                        </div>

                        <div class="actions">

                            <a class="button secondary"
                               href="<%= request.getContextPath() %>/delivery-address?action=edit&addressId=<%= a.getAddressId() %>">
                               Edit
                            </a>

                            <% if (!a.isDefault()) { %>
                                <form action="<%= request.getContextPath() %>/delivery-address"
                                      method="post">
                                    <input type="hidden" name="action" value="default">
                                    <input type="hidden" name="addressId"
                                           value="<%= a.getAddressId() %>">
                                    <button class="default-btn" type="submit">
                                        Set as Default
                                    </button>
                                </form>
                            <% } %>

                            <form action="<%= request.getContextPath() %>/delivery-address"
                                  method="post"
                                  onsubmit="return confirm('Delete this saved address?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="addressId"
                                       value="<%= a.getAddressId() %>">
                                <button class="danger" type="submit">
                                    Delete
                                </button>
                            </form>

                        </div>
                    </article>

                <%  }
                   }
                %>

            </div>
        </section>

    </div>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>
