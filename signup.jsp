
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    String contextPath = request.getContextPath();
    String errorMessage = request.getAttribute("errorMessage") == null
        ? "" : request.getAttribute("errorMessage").toString();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sign Up | Yumlet</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700;800&display=swap" rel="stylesheet">

<style>
*{box-sizing:border-box}
:root{
 --brown:#512817;
 --dark:#30170d;
 --cream:#f8e8d0;
 --border:#e4cbae;
 --muted:#856c57;
}
html,body{margin:0;min-height:100%;font-family:"DM Sans",Arial,sans-serif}
body{color:var(--brown)}
a{color:inherit;text-decoration:none}
button,input{font:inherit}

.auth-page{
 min-height:100vh;display:flex;align-items:center;justify-content:center;
 padding:28px 5%;
 background:
  linear-gradient(90deg,rgba(32,13,5,.34),rgba(32,13,5,.12)),
  url("<%= contextPath %>/images/Yumlet_ Good Food, Good Mood.png")
  center/cover no-repeat;
}
.auth-layout{
 width:100%;max-width:1250px;margin:auto;
 display:grid;
 grid-template-columns:minmax(370px,500px) minmax(280px,1fr);
 align-items:center;gap:45px;
}
.auth-card{
 grid-column:1;grid-row:1;position:relative;isolation:isolate;
 width:100%;padding:30px 38px;
 background:var(--cream);
 border-radius:60px 32px 58px 35px / 42px 34px 48px 42px;
 box-shadow:0 24px 65px rgba(24,9,2,.38);overflow:hidden;
}
.auth-card:before{
 content:"❧";position:absolute;z-index:-1;top:0;right:14px;
 color:#986c4c;font-size:45px;transform:rotate(-25deg);
 opacity:.65;pointer-events:none;
}
.auth-card:after{
 content:"❧";position:absolute;z-index:-1;bottom:-8px;left:12px;
 color:#986c4c;font-size:40px;transform:rotate(30deg);
 opacity:.65;pointer-events:none;
}
.tabs{display:flex;gap:5px;padding:5px;margin-bottom:20px;border-radius:40px;background:#ead7bd}
.tabs a{flex:1;display:block;padding:12px 8px;text-align:center;border-radius:35px;font-size:13px;font-weight:700}
.tabs a.active{background:var(--brown);color:#fff}
h2{margin:0;color:var(--brown);font:700 32px/1.2 "Playfair Display",Georgia,serif}
.subtitle{margin:8px 0 17px;color:var(--muted);font-size:13px;line-height:1.7}
.error-message{margin-bottom:13px;padding:10px 13px;border:1px solid #e9b9b0;border-radius:10px;background:#fff0ec;color:#8d2e22;font-size:12px;overflow-wrap:anywhere}
.field{margin-bottom:12px}
.field label{display:block;margin-bottom:6px;font-size:12px;font-weight:700}
.field input{display:block;width:100%;height:44px;padding:0 14px;border:1px solid var(--border);border-radius:12px;outline:none;background:rgba(255,248,239,.92);color:var(--dark);font-size:13px}
.field input::placeholder{color:#a28c77}
.field input:focus{border-color:var(--brown);box-shadow:0 0 0 3px rgba(81,40,23,.09)}
.password-wrap{position:relative}
.password-wrap input{padding-right:65px}
.password-toggle{position:absolute;top:50%;right:12px;transform:translateY(-50%);padding:5px;border:0;background:transparent;color:var(--brown);font-size:12px;font-weight:700;cursor:pointer}
.submit-button{width:100%;min-height:47px;padding:12px 16px;border:0;border-radius:35px;background:var(--brown);color:#fff;font-size:14px;font-weight:800;cursor:pointer;transition:background .2s,transform .2s;margin-top:4px}
.submit-button:hover{background:var(--dark);transform:translateY(-1px)}
.bottom{margin:16px 0 0;color:var(--muted);text-align:center;font-size:12px;line-height:1.8}
.bottom a{margin-left:4px;color:var(--brown);font-weight:800}
.bottom a:hover{text-decoration:underline}

/* Yumlet branding on the right */
.brand{grid-column:2;grid-row:1;padding:28px 12px;color:#fff2df;text-shadow:0 2px 12px rgba(0,0,0,.3)}
.brand-icon{font-size:48px;margin-bottom:5px}
.brand h1{margin:0;font:800 clamp(48px,6vw,78px)/1 "Playfair Display",Georgia,serif;letter-spacing:-2px}
.brand h1 span{color:#edc99f}
.tagline{margin:14px 0 0;font-size:10px;letter-spacing:4px}
.slogan{margin:43px 0 12px;font:italic clamp(28px,3vw,39px)/1.4 "Playfair Display",Georgia,serif}
.brand-note{max-width:350px;font-size:14px;line-height:1.9;color:#f5dfc5}

@media(max-width:850px){
 .auth-page{padding:22px 15px;background-position:center}
 .auth-layout{max-width:470px;grid-template-columns:1fr;gap:12px}
 .brand{grid-column:1;grid-row:1;text-align:center;padding:8px 0}
 .brand-icon{font-size:28px}
 .brand h1{font-size:44px}
 .tagline{font-size:9px;letter-spacing:3px}
 .slogan{font-size:24px;margin:14px 0 4px}
 .brand-note{display:none}
 .auth-card{grid-column:1;grid-row:2;padding:25px 23px;border-radius:45px 25px 40px 25px}
 h2{font-size:28px}
}
@media(max-width:380px){.auth-card{padding:22px 17px}}
</style>
</head>

<body>
<main class="auth-page">
 <div class="auth-layout">

  <section class="auth-card">
   <nav class="tabs" aria-label="Account pages">
    <a href="<%= contextPath %>/login.jsp">Login</a>
    <a class="active" aria-current="page" href="<%= contextPath %>/signup.jsp">Sign Up</a>
   </nav>

   <h2>Create Account</h2>
   <p class="subtitle">Your little world of yum starts here.</p>

   <% if (!errorMessage.trim().isEmpty()) { %>
    <div class="error-message" role="alert"><%= escapeHtml(errorMessage) %></div>
   <% } %>

   <form action="<%= contextPath %>/signup" method="post">
    <div class="field">
     <label for="name">Full Name</label>
     <input type="text" id="name" name="username"
       placeholder="Enter your full name"
       autocomplete="name" required>
    </div>

    <div class="field">
     <label for="email">Email Address</label>
     <input type="email" id="email" name="email"
            placeholder="Enter your email address" autocomplete="email" required>
    </div>

    <div class="field">
     <label for="phone">Mobile Number</label>
     <input type="tel" id="phone" name="phone"
            placeholder="Enter your mobile number" autocomplete="tel" required>
    </div>
    
    <div class="field">
    <label for="address">Delivery Address</label>
    <input type="text" id="address" name="address"
           placeholder="Enter your delivery address"
           autocomplete="street-address" required>
</div>

    <div class="field">
     <label for="password">Password</label>
     <div class="password-wrap">
      <input type="password" id="password" name="password"
             placeholder="Create a password" autocomplete="new-password"
             minlength="6" required>
      <button type="button" class="password-toggle" id="passwordToggle">Show</button>
     </div>
    </div>

    <button type="submit" class="submit-button">Create Account &nbsp; →</button>
   </form>

   <p class="bottom">Already have an account?
    <a href="<%= contextPath %>/login.jsp">Log In</a>
   </p>
  </section>

  <section class="brand">
   <div class="brand-icon">♨</div>
   <h1>Yum<span>let</span></h1>
   <p class="tagline">YOUR LITTLE WORLD OF YUM.</p>
   <div class="slogan">Good Food<br>Good Mood ♡</div>
   <p class="brand-note">Join Yumlet, discover delicious food, and find your next favourite meal.</p>
  </section>

 </div>
</main>

<script>
const passwordInput = document.getElementById("password");
const passwordToggle = document.getElementById("passwordToggle");

passwordToggle.addEventListener("click", function () {
    const showPassword = passwordInput.type === "password";
    passwordInput.type = showPassword ? "text" : "password";
    passwordToggle.textContent = showPassword ? "Hide" : "Show";
    passwordToggle.setAttribute("aria-label", showPassword ? "Hide password" : "Show password");
});
</script>
</body>
</html>
