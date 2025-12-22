#!/bin/bash
# chmod +x setup.sh
# setup/setup.sh - Installation & System Config

echo "Installing Raspberry Pi OS Lite Kiosk (2025)..."

# 1. Install packages
sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends labwc chromium wlrctl curl grep -y

# 2. Configure Labwc as Wayland Compositor
sudo raspi-config nonint do_wayland W2

# 3. Configure Tiny Cursor (for invisibility)
mkdir -p ~/.config/labwc
cat <<EOF > ~/.config/labwc/rc.xml
<core>
  <cursor>
    <size>1</size>
  </cursor>
</core>
EOF

# 4. Ensure scripts are executable
chmod +x start_browser.sh go.sh

echo "-------------------------------------------------------"
echo "Done! Please run 'sudo reboot' now."
echo "After reboot, enter this folder and run ./start_browser.sh"
echo "-------------------------------------------------------"
