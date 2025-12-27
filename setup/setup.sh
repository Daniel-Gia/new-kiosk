#!/bin/bash
# chmod +x setup/setup.sh

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SETUP_DIR/.." && pwd)"

echo "== New Kiosk: root setup =="

echo "0) Installing required packages (openssl, htpasswd)..."
sudo apt-get update
sudo apt-get install -y openssl apache2-utils

if ! command -v docker &> /dev/null; then
    echo "1) Installing Docker using the official Docker installation script..."
    curl -sSL https://get.docker.com | sh
else
    echo "1) Docker is already installed. Skipping installation."
fi

echo "2) Enabling Docker..."
sudo systemctl enable --now docker

echo "3) Running kiosk-browser setup..."
chmod +x "$REPO_DIR/kiosk-browser/setup.sh"
"$REPO_DIR/kiosk-browser/setup.sh"

echo "3b) Making generate-admin-login.sh executable..."
chmod +x "$REPO_DIR/setup/generate-admin-login.sh"

echo "4) Installing admin-panel docker compose systemd service..."
SERVICE_PATH="/etc/systemd/system/new-kiosk-admin.service"
TEMPLATE_PATH="$REPO_DIR/setup/new-kiosk-admin.service"

if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "Missing unit template: $TEMPLATE_PATH"
  exit 1
fi

sudo sed -e "s|@REPO_DIR@|$REPO_DIR|g" "$TEMPLATE_PATH" | sudo tee "$SERVICE_PATH" > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable new-kiosk-admin.service

echo "-------------------------------------------------------"
echo "Installed services:"
echo " - new-kiosk.service (kiosk browser)"
echo " - new-kiosk-admin.service (docker compose pull + up -d)"
echo ""
echo "To start admin now: sudo systemctl start new-kiosk-admin.service"
echo "To view logs: sudo journalctl -u new-kiosk-admin.service -f"
echo "Reboot to start kiosk: sudo reboot"
echo "-------------------------------------------------------"
