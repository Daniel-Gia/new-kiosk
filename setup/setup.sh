#!/bin/bash
# chmod +x setup.sh
# setup/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KIOSK_USER="${SUDO_USER:-pi}"

echo "Kiosk will be set up for user: $KIOSK_USER"

# KIOSK_HOME="$(eval echo "~$KIOSK_USER")"

echo "Setting up the project..."

# 1. Install packages
sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends labwc chromium wlrctl curl grep -y

sudo raspi-config nonint do_boot_behaviour B2

# 2. Configure Labwc as Wayland Compositor
sudo raspi-config nonint do_wayland W2

# 3. Configure Tiny Cursor (for invisibility)
# sudo -u "$KIOSK_USER" mkdir -p "$KIOSK_HOME/.config/labwc"
# sudo -u "$KIOSK_USER" tee "$KIOSK_HOME/.config/labwc/rc.xml" > /dev/null <<EOF
# <core>
#   <cursor>
#     <size>1</size>
#   </cursor>
# </core>
# EOF

# 4. Ensure scripts are executable
chmod +x "$SCRIPT_DIR/start_browser.sh" "$SCRIPT_DIR/go.sh"

# 5. Run kiosk on boot via systemd (runs labwc + chromium on tty1)
SERVICE_PATH="/etc/systemd/system/new-kiosk.service"
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=New Kiosk (Labwc + Chromium)
After=systemd-logind.service network-online.target
Wants=network-online.target
Conflicts=getty@tty1.service

[Service]
Type=simple
User=$KIOSK_USER
WorkingDirectory=$SCRIPT_DIR
Environment=XDG_RUNTIME_DIR=/run/user/%U
Environment=WLR_NO_HARDWARE_CURSORS=1
PAMName=login
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
StandardInput=tty
StandardOutput=journal
StandardError=journal
ExecStart=$SCRIPT_DIR/start_browser.sh --systemd
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable new-kiosk.service

echo "-------------------------------------------------------"
echo "Done! Please run 'sudo reboot' now."
echo "After reboot, the kiosk will start automatically."
echo "To check status: sudo systemctl status new-kiosk.service"
echo "-------------------------------------------------------"
