#!/bin/bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-worklouder.rules"

# Handle uninstall mode
if [[ "${1:-}" == "uninstall" ]]; then
  echo "Uninstalling Work Louder udev rules..."
  if [[ -f "$RULE_FILE" ]]; then
    sudo rm "$RULE_FILE"
    echo "Removed $RULE_FILE"
    echo "Reloading udev rules..."
    sudo udevadm control --reload
    sudo udevadm trigger
    sudo udevadm settle
    echo "Done. Please replug your device or restart the app if needed."
  else
    echo "No udev rules to remove at $RULE_FILE"
  fi
  exit 0
fi

# Detect appropriate group for udev device access
if grep -qi 'ID_LIKE=.*fedora' /etc/os-release || grep -qi 'fedora' /etc/os-release; then
  UDEV_GROUP="input"
elif grep -qi 'ID_LIKE=.*arch' /etc/os-release || grep -qi 'arch' /etc/os-release; then
  UDEV_GROUP="input"
elif grep -qi 'ID_LIKE=.*debian' /etc/os-release || grep -qi 'ubuntu' /etc/os-release; then
  UDEV_GROUP="plugdev"
else
  UDEV_GROUP="plugdev"  # Fallback
fi

TEMP_FILE="$(mktemp)"
echo "Using GROUP=\"$UDEV_GROUP\" for udev permissions"
echo "Writing static Work Louder udev rules to \"$RULE_FILE\"..."

# Create static rules
sudo tee "$TEMP_FILE" > /dev/null <<EOF
# udev rules for Work Louder and Nomad devices (USB and Bluetooth)

# USB HID devices (Nomad/Work Louder)
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="8294", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Serial for ESP32-S3 or similar
SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Legacy Nomad firmware (serial-based)
SUBSYSTEM=="tty", ATTRS{idVendor}=="574c", ATTRS{idProduct}=="6e63", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Generic match for future Work Louder USB devices
SUBSYSTEM=="usb", ATTR{idVendor}=="303a", MODE="0666", GROUP="$UDEV_GROUP"

# Generic match for any hidraw device by vendor (Bluetooth HID or USB)
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="303a", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Optional: match device name (not always reliable)
ATTRS{name}=="Work Louder*", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"
EOF


# Install rules
sudo mv "$TEMP_FILE" "$RULE_FILE"
sudo chmod 644 "$RULE_FILE"

# Reload and settle
echo "Reloading udev rules..."
sudo udevadm control --reload
sudo udevadm trigger
sudo udevadm settle

echo "Done. Please replug your device or restart the app if needed."
