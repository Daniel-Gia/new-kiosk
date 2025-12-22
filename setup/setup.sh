#!/bin/bash
# chmod +x setup.sh
# setup/setup.sh - Installation & System Config

echo "Installing Raspberry Pi OS Lite Kiosk (2025)..."

# 1. Install packages
sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends labwc chromium wlrctl curl grep -y

# 2. Configure Labwc as Wayland Compositor
sudo raspi-config nonint do_wayland W2

# 3. Enable Console Autologin (User: pi/current user)
# This allows the Pi to boot to the command line without a password
sudo raspi-config nonint do_boot_behaviour B2

# 4. Configure Tiny Cursor (for invisibility)
mkdir -p ~/.config/labwc
cat <<EOF > ~/.config/labwc/rc.xml
<core>
  <cursor>
    <size>1</size>
  </cursor>
</core>
EOF

# 5. Ensure scripts are executable
chmod +x start_browser.sh go.sh

# 6. Set up Start-on-Boot
# We append a check to .bash_profile to run the browser ONLY on the primary physical console (tty1)
PROFILE_FILE="$HOME/.bash_profile"
START_CMD="/new-kiosk/setup/start_browser.sh"

# Avoid double-entry if script is run twice
if ! grep -q "$START_CMD" "$PROFILE_FILE" 2>/dev/null; then
    echo "" >> "$PROFILE_FILE"
    echo "# Start Kiosk automatically on login" >> "$PROFILE_FILE"
    echo "if [ -z \"\$DISPLAY\" ] && [ \"\$(tty)\" = \"/dev/tty1\" ]; then" >> "$PROFILE_FILE"
    echo "  $START_CMD" >> "$PROFILE_FILE"
    echo "fi" >> "$PROFILE_FILE"
    echo "Autostart added to $PROFILE_FILE"
fi

echo "-------------------------------------------------------"
echo "Setup complete! The Pi is now configured to:"
echo "1. Login automatically"
echo "2. Start the browser from /new-kiosk/setup/ on boot"
echo ""
echo "Please run 'sudo reboot' now."
echo "-------------------------------------------------------"
