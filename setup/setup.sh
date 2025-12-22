#!/bin/bash
# chmod +x setup.sh
# setup/setup.sh - Installation & System Config

echo "Installing Raspberry Pi OS Lite Kiosk (2025)..."

# 1. Install packages
sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends labwc chromium wlrctl curl grep -y

# 2. Configure Labwc as Wayland Compositor
sudo raspi-config nonint do_wayland W2

# 3. Enable Console Autologin (Manual fix for Lite)
# This replaces the raspi-config command that causes lightdm errors
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo bash -c "cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \\\$TERM
EOF"

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

# 6. Set up Start-on-Boot in .bash_profile
PROFILE_FILE="$HOME/.bash_profile"
START_CMD="/new-kiosk/setup/start_browser.sh"

if ! grep -q "$START_CMD" "$PROFILE_FILE" 2>/dev/null; then
    echo -e "\n# Start Kiosk automatically on login\nif [ -z \"\$DISPLAY\" ] && [ \"\$(tty)\" = \"/dev/tty1\" ]; then\n  $START_CMD\nfi" >> "$PROFILE_FILE"
    echo "Autostart added to $PROFILE_FILE"
fi

echo "-------------------------------------------------------"
echo "Setup complete! Please run 'sudo reboot' now."
echo "-------------------------------------------------------"
