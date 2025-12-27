#!/bin/bash

set -euo pipefail

DEFAULT_URL_FILE="$(cd "$(dirname "$0")" && pwd)/../settings/default_url.txt"
START_URL=""
if [ -f "$DEFAULT_URL_FILE" ]; then
  # Read first line
  START_URL="$(head -n 1 "$DEFAULT_URL_FILE" | tr -d '\r' | xargs)"
fi

# if START_URL is empty, set to default
if [ -z "$START_URL" ]; then
  START_URL="https://www.google.com"
fi

# Wait for local server if needed
if [[ "$START_URL" == *"localhost"* ]] || [[ "$START_URL" == *"127.0.0.1"* ]]; then
  echo "Waiting for local server..."
  for i in {1..30}; do
    if curl -s --head "$START_URL" >/dev/null || wget -q --spider "$START_URL"; then
      break
    fi
    sleep 1
  done
fi

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

(sleep 3; wlrctl pointer move 2000 2000) &
exec labwc -s "$CHROMIUM_CMD $START_URL"
