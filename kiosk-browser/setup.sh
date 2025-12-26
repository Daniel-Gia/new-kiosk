#!/bin/bash
# chmod +x setup.sh

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
TEMPLATE_PATH="$SCRIPT_DIR/new-kiosk.service"

if [ ! -f "$TEMPLATE_PATH" ]; then
	echo "Missing unit template: $TEMPLATE_PATH"
	exit 1
fi

sudo sed \
	-e "s|@KIOSK_USER@|$KIOSK_USER|g" \
	-e "s|@SCRIPT_DIR@|$SCRIPT_DIR|g" \
	"$TEMPLATE_PATH" | sudo tee "$SERVICE_PATH" > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable new-kiosk.service

echo "-------------------------------------------------------"
echo "Done! Please run 'sudo reboot' now."
echo "After reboot, the kiosk will start automatically."
echo "To check status: sudo systemctl status new-kiosk.service"
echo "-------------------------------------------------------"
