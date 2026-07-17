#!/bin/bash
# Cleanup script for CamPhish
# Usage: bash cleanup.sh [--session <dir>] [--secure]

target_dir="."
secure_delete=false
cam_count=0
loc_count=0
audio_count=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --session)
      if [[ -z "$2" ]]; then
        echo "Error: --session requires a directory argument."
        exit 1
      fi
      target_dir="$2"
      shift 2
      ;;
    --secure)
      secure_delete=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: bash cleanup.sh [--session <dir>] [--secure]"
      exit 1
      ;;
  esac
done

# Helper: remove a file, optionally with shred
remove_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    if [[ "$secure_delete" == true ]] && command -v shred > /dev/null 2>&1; then
      shred -u "$f" 2>/dev/null
    else
      rm -f "$f"
    fi
  fi
}

echo "Starting cleanup in: $target_dir"
[[ "$secure_delete" == true ]] && echo "Secure delete (shred) enabled."

# Remove log files
echo "Removing log files..."
for f in "$target_dir"/*.log "$target_dir"/.cloudflared.log "$target_dir"/session_dir.txt; do
  remove_file "$f"
done

# Remove temporary location files
echo "Removing temporary location files..."
for f in "$target_dir"/location_*.txt "$target_dir"/current_location.bak; do
  remove_file "$f"
  [[ -f "$f" ]] || loc_count=$((loc_count + 1))
done
loc_count=$(find "$target_dir" -maxdepth 1 -name "location_*.txt" 2>/dev/null | wc -l)
for f in "$target_dir"/location_*.txt; do
  remove_file "$f"
done

# Remove captured images
echo "Removing captured images..."
cam_count=$(find "$target_dir" -maxdepth 1 -name "cam*.png" 2>/dev/null | wc -l)
for f in "$target_dir"/cam*.png; do
  remove_file "$f"
done

# Remove captured audio
echo "Removing captured audio..."
audio_count=$(find "$target_dir" -maxdepth 1 -name "audio*.webm" 2>/dev/null | wc -l)
for f in "$target_dir"/audio*.webm; do
  remove_file "$f"
done

# Remove fingerprint data
echo "Removing fingerprint data..."
remove_file "$target_dir/fingerprint.txt"

# Remove temporary HTML/PHP files
echo "Removing temporary HTML files..."
remove_file "$target_dir/index.php"
remove_file "$target_dir/index2.html"
remove_file "$target_dir/index3.html"

# Clean saved locations directory
echo "Cleaning saved locations directory..."
if [[ -d "$target_dir/saved_locations" ]]; then
  for f in "$target_dir/saved_locations/"*; do
    remove_file "$f"
  done
fi

# Clean sessions directory (only if not targeting a specific session)
if [[ "$target_dir" == "." ]]; then
  echo "Cleaning all session data..."
  if [[ -d "sessions" ]]; then
    for f in sessions/*/cam*.png; do remove_file "$f"; done
    for f in sessions/*/audio*.webm; do remove_file "$f"; done
    for f in sessions/*/location_*.txt; do remove_file "$f"; done
    for f in sessions/*/*.log; do remove_file "$f"; done
    for f in sessions/*/fingerprint.txt; do remove_file "$f"; done
    for f in sessions/*/current_location.bak; do remove_file "$f"; done
    for f in sessions/*/saved.locations.txt; do remove_file "$f"; done
    for f in sessions/*/saved.ip.txt; do remove_file "$f"; done
  fi
fi

echo ""
echo "Cleanup completed successfully!"
echo "Summary:"
echo "  Camera images removed : $cam_count"
echo "  Location files removed: $loc_count"
echo "  Audio files removed   : $audio_count"