#!/bin/zsh
# Installs or upgrades to the latest Timesheet Gremlin in ~/Applications and opens it.
# Settings and your Productive token are kept.
# No admin password needed. Safe to run again at any time.
#
# Everything runs inside main(), called on the very last line, so a partly
# downloaded copy of this script can't run half its commands.

main() {
  set -e
  local REPO="UB-Ben/timesheet-gremlin"
  local APP="$HOME/Applications/Timesheet Gremlin.app"
  local FIRST_INSTALL=1
  [ -d "$APP" ] && FIRST_INSTALL=0

  if [ "$(uname -m)" != "arm64" ]; then
    echo "Sorry, the Timesheet Gremlin only runs on Apple Silicon Macs (M1 or newer)."; return 1
  fi

  local TMP
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  echo "Downloading the latest gremlin..."
  curl -fsSL "https://github.com/$REPO/releases/latest/download/TimesheetGremlin.zip" -o "$TMP/gremlin.zip"
  ditto -x -k "$TMP/gremlin.zip" "$TMP/x"
  [ -d "$TMP/x/Timesheet Gremlin.app" ] || { echo "The download didn't contain the app."; return 1; }

  # Stop any running gremlin, then swap in the new one.
  pkill -f "Timesheet Gremlin.app/Contents/MacOS" 2>/dev/null || true
  sleep 1
  mkdir -p "$HOME/Applications"
  rm -rf "$APP"
  mv "$TMP/x/Timesheet Gremlin.app" "$APP"
  xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

  open "$APP"
  local VERSION
  VERSION=$(defaults read "$APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "?")
  if [ "$FIRST_INSTALL" = 1 ]; then
    open "https://github.com/$REPO#readme"
    echo "Done! Installed v$VERSION. The gremlin should say hello in a moment. Follow the README to add your Productive token."
  else
    echo "Done! The gremlin is now on v$VERSION. Your settings and token are unchanged."
  fi
}

main "$@"
