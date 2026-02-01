#!/system/bin/sh
# uninstall.sh - cleanup for App Redirector

REDIRECTLIST="/data/adb/app_redirect_list.txt"

echo "Uninstalling App Redirector..."

# Remove redirect list
if [ -f "$REDIRECTLIST" ]; then
  rm -f "$REDIRECTLIST"
  echo "Redirect list removed"
fi

# Kill any running watcher
pkill -f "app.started.watcher/service.sh" 2>/dev/null

echo "Done!"
exit 0
