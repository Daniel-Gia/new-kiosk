#!/bin/bash
# chmod +x setup/setup.sh

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SETUP_DIR/.." && pwd)"

echo "== New Kiosk: root setup =="

echo "1) Installing Docker using the official Docker installation script..."
curl -sSL https://get.docker.com | sh

echo "2) Enabling Docker daemon..."
sudo systemctl enable --now docker

echo "3) Running kiosk-browser setup..."
chmod +x "$REPO_DIR/kiosk-browser/setup.sh"
"$REPO_DIR/kiosk-browser/setup.sh"

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
