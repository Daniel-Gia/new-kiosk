#!/bin/bash
# setup/start_browser.sh - Launch Engine

set -euo pipefail

FOREGROUND=0
if [ "${1:-}" = "--systemd" ] || [ "${1:-}" = "--foreground" ]; then
  FOREGROUND=1
  shift
fi

# Force software cursor rendering
export WLR_NO_HARDWARE_CURSORS=1

CHROMIUM_CMD="chromium \
  --ozone-platform=wayland \
  --enable-features=UseOzonePlatform \
  --kiosk \
  --no-sandbox \
  --remote-debugging-port=9222 \
  --remote-allow-origins=* \
  --no-first-run \
  --noerrdialogs \
  --disable-infobars"

# Start Labwc and Chromium
if [ "$FOREGROUND" -eq 1 ]; then
  (sleep 3; wlrctl pointer move 2000 2000) &
  exec labwc -s "$CHROMIUM_CMD"
else
  labwc -s "$CHROMIUM_CMD" &
  sleep 3
  wlrctl pointer move 2000 2000
  echo "Browser started. Control it via ./go.sh [URL]"
fi
