#!/bin/bash
# setup/setup.sh - Clean Installation for 2025 (No LightDM Errors)

echo "Installing Raspberry Pi OS Lite Kiosk (2025)..."

# 1. Install packages
sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends labwc chromium wlrctl curl grep -y

# 2. Configure Labwc as Wayland Compositor (This works fine in raspi-config)
sudo raspi-config nonint do_wayland W2

# 3. MANUAL AUTOLOGIN FIX (Replaces buggy raspi-config command)
# This creates the autologin service for the console without looking for LightDM
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo bash -c "cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \\\$TERM
EOF"

# 4. Configure Tiny Cursor
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
    echo "Autostart logic added to $PROFILE_FILE"
fi

echo "-------------------------------------------------------"
echo "Setup complete! No LightDM errors occurred."
echo "Please run 'sudo reboot' now."
echo "-------------------------------------------------------"
