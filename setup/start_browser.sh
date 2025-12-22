#!/bin/bash
# setup/start_browser.sh - Launch Engine

# Force software cursor rendering
export WLR_NO_HARDWARE_CURSORS=1

# Start Labwc and Chromium
labwc -s "chromium \
  --no-sandbox \
  --remote-debugging-port=9222 \
  --remote-allow-origins=* \
  --start-maximized \
  --no-first-run \
  --noerrdialogs \
  --disable-infobars" &

# Wait for UI to load
sleep 3

# Park the tiny cursor in the bottom-right corner
wlrctl pointer move 2000 2000

echo "Browser started. Control it via ./go.sh [URL]"
