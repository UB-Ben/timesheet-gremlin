#!/bin/zsh
# Installs or upgrades to the latest Timesheet Gremlin in ~/Applications and opens it.
# Settings and your Productive token are kept.
# No admin password needed. Safe to run again at any time.
set -e
REPO="UB-Ben/timesheet-gremlin"
APP="$HOME/Applications/Timesheet Gremlin.app"
FIRST_INSTALL=1; [ -d "$APP" ] && FIRST_INSTALL=0

if [ "$(uname -m)" != "arm64" ]; then
  echo "Sorry, the Timesheet Gremlin only runs on Apple Silicon Macs (M1 or newer)."; exit 1
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
echo "Downloading the latest gremlin..."
curl -fsSL "https://github.com/$REPO/releases/latest/download/TimesheetGremlin.zip" -o "$TMP/gremlin.zip"
ditto -x -k "$TMP/gremlin.zip" "$TMP/x"
[ -d "$TMP/x/Timesheet Gremlin.app" ] || { echo "The download didn't contain the app."; exit 1; }

# Stop any running gremlin, then swap in the new one.
pkill -f "Timesheet Gremlin.app/Contents/MacOS" 2>/dev/null || true
sleep 1
mkdir -p "$HOME/Applications"
rm -rf "$APP"
mv "$TMP/x/Timesheet Gremlin.app" "$APP"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

open "$APP"
VERSION=$(defaults read "$APP/Contents/Info" CFBundleVersion 2>/dev/null || echo "?")
if [ "$FIRST_INSTALL" = 1 ]; then
  open "https://github.com/$REPO#readme"
  echo "Done! Installed v$VERSION. The gremlin should say hello in a moment. Follow the README to add your Productive token."
else
  echo "Done! The gremlin is now on v$VERSION. Your settings and token are unchanged."
fi
