#!/bin/bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-worklouder.rules"
TEMP_FILE="$(mktemp)"
VENDOR_WORKLOUDER="303a"
VENDOR_NOMAD="574c"

# ---------------------------
#  Detect platform / group
# ---------------------------
detect_group() {
  local osr="/etc/os-release"
  local group="plugdev"

  if [[ -f $osr ]]; then
    if grep -qiE 'fedora|rhel|centos|rocky|almalinux' "$osr"; then
      group="input"
    elif grep -qiE 'arch|manjaro|endeavouros' "$osr"; then
      group="input"
    elif grep -qiE 'debian|ubuntu|linuxmint|pop' "$osr"; then
      group="plugdev"
    else
      group="plugdev"
    fi
  fi

  echo "$group"
}

UDEV_GROUP="$(detect_group)"
echo "Using group: $UDEV_GROUP"

# Warn users about missing groups
if ! getent group "$UDEV_GROUP" >/dev/null; then
  echo "Warning: group '$UDEV_GROUP' does not exist. Creating it..."
  sudo groupadd "$UDEV_GROUP"
fi

# ---------------------------
#  Uninstall mode
# ---------------------------
if [[ "${1:-}" == "uninstall" ]]; then
  echo "Uninstalling Work Louder udev rules…"
  if [[ -f "$RULE_FILE" ]]; then
    sudo rm "$RULE_FILE"
    echo "Removed $RULE_FILE"
  else
    echo "No rules found at $RULE_FILE"
  fi

  echo "Reloading udev..."
  sudo udevadm control --reload
  sudo udevadm trigger
  sudo udevadm settle
  echo "Done."
  exit 0
fi


# ---------------------------
#  Generate new rules
# ---------------------------
sudo tee "$TEMP_FILE" >/dev/null <<EOF
# Work Louder / Nomad – Udev rules
# Generated on $(date)

# Vendor IDs:
#   Work Louder: $VENDOR_WORKLOUDER
#   Nomad legacy: $VENDOR_NOMAD

# HID (hidraw) devices – keyboards, macropads, BLE HID, USB HID
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="$VENDOR_WORKLOUDER", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="$VENDOR_NOMAD",     MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

# USB generic access for current and future devices (matches interface-level)
SUBSYSTEM=="usb", ATTR{idVendor}=="$VENDOR_WORKLOUDER", MODE="0666", GROUP="$UDEV_GROUP"
SUBSYSTEM=="usb", ATTR{idVendor}=="$VENDOR_NOMAD",     MODE="0666", GROUP="$UDEV_GROUP"

# Serial devices (ESP32-S3, debug interfaces, DFU firmware)
SUBSYSTEM=="tty", ATTRS{idVendor}=="$VENDOR_WORKLOUDER", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"
SUBSYSTEM=="tty", ATTRS{idVendor}=="$VENDOR_NOMAD",       MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Catch all HID types that expose vendor but not product
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="$VENDOR_WORKLOUDER", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Optional fallback – match by device name (sometimes useful on older firmware)
ATTRS{name}=="Work Louder*", MODE="0666", GROUP="$UDEV_GROUP", TAG+="uaccess"

EOF


# ---------------------------
#  Install the rule
# ---------------------------
echo "Installing udev rules to $RULE_FILE…"
sudo mv "$TEMP_FILE" "$RULE_FILE"
sudo chmod 644 "$RULE_FILE"


# ---------------------------
#  Reload udev
# ---------------------------
echo "Reloading udev rules..."
sudo udevadm control --reload
sudo udevadm trigger
sudo udevadm settle

echo "Done! Please unplug/replug your device or restart the Input app."
