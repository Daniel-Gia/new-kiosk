#!/bin/bash
# chmod +x setup.sh
# setup/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KIOSK_USER="${SUDO_USER:-pi}"

echo -e "\e[33m Setting up the project... \e[0m"

echo "1. Installing required packages..."

sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends labwc chromium wlrctl curl grep -y

echo "2. Configuring Raspberry Pi settings..."
# Set up auto login
sudo raspi-config nonint do_boot_behaviour B2

# Set up Labwc as Wayland Compositor
sudo raspi-config nonint do_wayland W2

# Ensure scripts are executable
chmod +x "$SCRIPT_DIR/start_browser.sh" "$SCRIPT_DIR/go.sh"

# Run kiosk on boot
SERVICE_PATH="/etc/systemd/system/new-kiosk.service"

sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Kiosk Browser Service
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
ExecStart=$SCRIPT_DIR/start_browser.sh
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
