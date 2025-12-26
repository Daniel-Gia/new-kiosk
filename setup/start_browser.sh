#!/bin/bash

set -euo pipefail

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
exec labwc -s "$CHROMIUM_CMD"
