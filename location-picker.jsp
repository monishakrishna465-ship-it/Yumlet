
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Choose delivery location | Yumlet</title>

<link rel="stylesheet"
 href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">

<style>
*{box-sizing:border-box}
body{margin:0;background:#fbf7f0;color:#30170d;
 font-family:Arial,sans-serif}
header{padding:20px;background:white;border-bottom:1px solid #eadfd2}
h1{font-size:23px;margin:0 0 7px}
header p{margin:0;color:#806b5a;font-size:13px}
main{max-width:900px;margin:22px auto;padding:0 16px}
.search-area{position:relative;display:flex;gap:8px;margin-bottom:12px}
input,button{font:inherit}
#search{flex:1;min-width:0;padding:13px;border:1px solid #ddcdbd;
 border-radius:10px}
button{border:0;border-radius:10px;padding:12px 15px;
 cursor:pointer;font-weight:700}
.primary{background:#48230f;color:white}
.secondary{background:#f0e5d8;color:#48230f}
#suggestions{position:absolute;z-index:1000;top:50px;left:0;right:0;
 background:white;border-radius:10px;box-shadow:0 8px 24px #0002}
.suggestion{display:block;width:100%;text-align:left;background:white;
 border-radius:0;padding:12px;border-bottom:1px solid #eee}
.suggestion:hover{background:#fbf3e9}
#map{height:390px;border-radius:14px;border:1px solid #ddcdbd}
.note{font-size:12px;color:#806b5a;line-height:1.6}
.address-card{margin-top:14px;background:white;padding:16px;
 border:1px solid #eadfd2;border-radius:12px}
#selectedAddress{font-size:14px;line-height:1.6}
.actions{display:flex;gap:10px;margin-top:14px}
.actions button{flex:1}
#message{font-size:13px;color:#9a3828;margin:10px 0}
@media(max-width:520px){
 .search-area{flex-wrap:wrap}
 #search{flex-basis:100%}
 #suggestions{top:50px}
 #map{height:340px}
 .actions{flex-direction:column}
}
</style>
</head>
<body>

<header>
  <h1>Choose your delivery location</h1>
  <p>Search your address or move the pin to your exact location.</p>
</header>

<main>
  <div class="search-area">
    <input id="search" type="search"
      placeholder="Search area, street, apartment or landmark"
      autocomplete="off">
    <button class="secondary" id="searchButton" type="button">
      Search
    </button>
    <div id="suggestions"></div>
  </div>

  <button class="secondary" id="currentLocation" type="button"
    style="width:100%;margin-bottom:12px">
    ◎ Use my current location
  </button>

  <div id="map"></div>

  <p class="note">
    Move the map pin to adjust the delivery point. Address suggestions
    depend on available map data. Please verify the address before saving.
  </p>

  <div class="address-card">
    <strong>Selected address</strong>
    <p id="selectedAddress">Search for an address or select a point on the map.</p>
    <div id="message" role="status"></div>

    <div class="actions">
      <button class="secondary" type="button"
        onclick="window.close()">Cancel</button>
      <button class="primary" id="confirmLocation" type="button">
        Confirm location
      </button>
    </div>
  </div>
</main>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(function () {
  "use strict";

  const map = L.map("map").setView([12.9716, 77.5946], 12);

  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: "&copy; OpenStreetMap contributors"
  }).addTo(map);

  let marker = L.marker([12.9716, 77.5946], {
    draggable: true
  }).addTo(map);

  let selected = null;
  let lookupTimer = null;
  let requestNumber = 0;

  const search = document.getElementById("search");
  const suggestions = document.getElementById("suggestions");
  const addressText = document.getElementById("selectedAddress");
  const message = document.getElementById("message");

  function showMessage(text) {
    message.textContent = text || "";
  }

  async function reverseGeocode(lat, lon) {
    const requestId = ++requestNumber;
    selected = { lat, lon };
    addressText.textContent = "Finding address…";
    showMessage("");

    try {
      const url = new URL("https://nominatim.openstreetmap.org/reverse");
      url.searchParams.set("format", "jsonv2");
      url.searchParams.set("lat", lat);
      url.searchParams.set("lon", lon);
      url.searchParams.set("addressdetails", "1");

      const response = await fetch(url.toString(), {
        headers: { "Accept": "application/json" }
      });

      if (!response.ok) throw new Error("Address lookup failed");

      const data = await response.json();
      if (requestId !== requestNumber) return;

      selected = {
        lat, lon,
        displayName: data.display_name || "",
        address: data.address || {}
      };

      addressText.textContent = selected.displayName ||
        "Address unavailable. Please search for your address.";
    } catch (error) {
      if (requestId !== requestNumber) return;
      addressText.textContent = "Could not find this address automatically.";
      showMessage("Try searching for your street or apartment.");
    }
  }

  function choosePoint(lat, lon, zoom) {
    marker.setLatLng([lat, lon]);
    map.setView([lat, lon], zoom || 16);
    reverseGeocode(lat, lon);
  }

  marker.on("dragend", function () {
    const point = marker.getLatLng();
    reverseGeocode(point.lat, point.lng);
  });

  map.on("click", function (event) {
    choosePoint(event.latlng.lat, event.latlng.lng);
  });

  async function searchAddresses() {
    const query = search.value.trim();
    if (query.length < 3) {
      showMessage("Enter at least 3 characters to search.");
      return;
    }

    suggestions.replaceChildren();
    showMessage("Searching…");

    try {
      const url = new URL("https://nominatim.openstreetmap.org/search");
      url.searchParams.set("format", "jsonv2");
      url.searchParams.set("q", query);
      url.searchParams.set("limit", "5");
      url.searchParams.set("addressdetails", "1");
      url.searchParams.set("countrycodes", "in");

      const response = await fetch(url.toString(), {
        headers: { "Accept": "application/json" }
      });

      if (!response.ok) throw new Error("Search failed");
      const results = await response.json();

      suggestions.replaceChildren();
      showMessage(results.length ? "" : "No matching address found.");

      results.forEach(function (place) {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "suggestion";
        button.textContent = place.display_name;

        button.addEventListener("click", function () {
          suggestions.replaceChildren();
          search.value = place.display_name;
          choosePoint(Number(place.lat), Number(place.lon), 17);
        });

        suggestions.appendChild(button);
      });
    } catch (error) {
      showMessage("Address search is unavailable. Please try again later.");
    }
  }

  document.getElementById("searchButton")
    .addEventListener("click", searchAddresses);

  search.addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
      event.preventDefault();
      searchAddresses();
    }
  });

  search.addEventListener("input", function () {
    clearTimeout(lookupTimer);
    lookupTimer = setTimeout(function () {
      if (search.value.trim().length >= 4) searchAddresses();
    }, 700);
  });

  document.getElementById("currentLocation")
    .addEventListener("click", function () {
      if (!navigator.geolocation) {
        showMessage("Your browser does not support location access.");
        return;
      }

      showMessage("Requesting location permission…");

      navigator.geolocation.getCurrentPosition(
        function (position) {
          choosePoint(
            position.coords.latitude,
            position.coords.longitude,
            17
          );
        },
        function (error) {
          showMessage(error.code === 1
            ? "Location permission was denied. Search for your address instead."
            : "Could not get your location. Check GPS and browser permissions.");
        },
        { enableHighAccuracy: true, timeout: 12000, maximumAge: 60000 }
      );
    });

  document.getElementById("confirmLocation")
    .addEventListener("click", function () {
      if (!selected || !selected.displayName) {
        showMessage("Please select a location with a resolved address first.");
        return;
      }

      if (!window.opener || window.opener.closed) {
        showMessage("Open this page from checkout to send the address back.");
        return;
      }

      window.opener.postMessage({
        type: "yumlet-location-selected",
        displayName: selected.displayName,
        lat: selected.lat,
        lon: selected.lon,
        address: selected.address
      }, window.location.origin);

      window.close();
    });

  setTimeout(function () { map.invalidateSize(); }, 200);
})();
</script>
</body>
</html>
