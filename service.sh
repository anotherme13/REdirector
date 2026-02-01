#!/system/bin/sh
# service.sh - runs in late_start service mode
# Redirect blocked apps to specified replacement apps

MODDIR=${0%/*}
LOG_TAG="MagiskAppWatcher"
LOGFILE="$MODDIR/app_started.log"
REDIRECTLIST="/data/adb/app_redirect_list.txt"

log_msg() {
  msg="$1"
  timestamp="$(date '+%F %T')"
  log -t "$LOG_TAG" -p i "$msg" 2>/dev/null
  echo "$timestamp $msg" >> "$LOGFILE" 2>/dev/null
}

# Get current foreground app
get_foreground() {
  # Try multiple patterns (varies by Android version)
  result=$(dumpsys activity activities 2>/dev/null | grep -E "topResumedActivity|mResumedActivity|ResumedActivity:" | head -1)
  # Extract the package/activity part
  echo "$result" | grep -oE '[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+/[^\s\}]+' | head -1
}

# Extract package name from activity string
extract_package() {
  echo "$1" | grep -oE '[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+' | head -n1
}

# Get redirect target for a package
get_redirect() {
  pkg="$1"
  [ ! -f "$REDIRECTLIST" ] && return 1
  
  while IFS= read -r line; do
    case "$line" in \#*|"") continue ;; esac
    # Parse: blocked_package=redirect_package
    blocked=$(echo "$line" | cut -d'=' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    redirect=$(echo "$line" | cut -d'=' -f2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ "$blocked" = "$pkg" ] && [ -n "$redirect" ]; then
      echo "$redirect"
      return 0
    fi
  done < "$REDIRECTLIST"
  return 1
}

# Launch an app
launch_app() {
  pkg="$1"
  log_msg "LAUNCHING: $pkg"
  am start -n "$(pm dump "$pkg" 2>/dev/null | grep -m1 'android.intent.action.MAIN' -A5 | grep -m1 "$pkg/" | awk '{print $2}')" >/dev/null 2>&1 \
    || am start "$(pm resolve-activity --brief "$pkg" 2>/dev/null | tail -1)" >/dev/null 2>&1 \
    || monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
}

log_msg "=== App Redirector Started ==="

# Wait for system boot
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done
sleep 3
log_msg "System ready"

# Create redirect list if doesn't exist
if [ ! -f "$REDIRECTLIST" ]; then
  cat > "$REDIRECTLIST" << 'EOF'
# App Redirect List
# Format: blocked_package=redirect_package
EOF
  log_msg "Created redirect list at $REDIRECTLIST"
fi

# Show current redirects
log_msg "--- Redirect rules ---"
while IFS= read -r line; do
  case "$line" in \#*|"") continue ;; esac
  log_msg "  $line"
done < "$REDIRECTLIST"
log_msg "--- End rules ---"

# Main monitoring loop
log_msg "Monitoring started..."
prev=""

while true; do
  fg=$(get_foreground)
  pkg=$(extract_package "$fg")
  
  if [ -n "$pkg" ] && [ "$pkg" != "$prev" ]; then
    log_msg "DETECTED: $pkg (from: $fg)"
    prev="$pkg"
    
    redirect_to=$(get_redirect "$pkg")
    if [ -n "$redirect_to" ]; then
      log_msg "REDIRECT: $pkg -> $redirect_to"
      launch_app "$redirect_to"
      prev="$redirect_to"
    fi
  fi
  
  sleep 1
done
