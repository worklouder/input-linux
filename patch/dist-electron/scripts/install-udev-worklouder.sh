#!/bin/bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-worklouder.rules"
TEMP_FILE="$(mktemp)"

# Vendor IDs
VENDOR_WORKLOUDER="303a"
VENDOR_NOMAD="574c"

# Bluetooth PIDs (confirmed from uhid path: 0005:303A:8294.xxxx)
# Add more here as needed if Work Louder expands BT firmware.
BT_PRODUCT_WORKLOUDER="8294"

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
#  Generate udev rules
# ---------------------------
sudo tee "$TEMP_FILE" >/dev/null <<EOF
# Work Louder / Nomad – Udev rules
# Generated on $(date)
# Supports USB HID, Bluetooth HID (via uhid → hidraw), serial interfaces

# =======================
# HIDRAW (USB + Bluetooth)
# =======================
# USB wired & Bluetooth HID devices expose a hidraw node.
# These rules match BOTH.
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="$VENDOR_WORKLOUDER", MODE="0660", GROUP="$UDEV_GROUP", TAG+="uaccess"
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="$VENDOR_NOMAD",     MODE="0660", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Bluetooth-specific Work Louder device (303A:8294)
# Only matches BT HID, not USB
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", \
  ATTRS{idVendor}=="$VENDOR_WORKLOUDER", ATTRS{idProduct}=="$BT_PRODUCT_WORKLOUDER", \
  MODE="0660", GROUP="$UDEV_GROUP", TAG+="uaccess"


# =======================
# USB DEVICES (leave existing rules intact)
# =======================
SUBSYSTEM=="usb", ATTR{idVendor}=="$VENDOR_WORKLOUDER", MODE="0660", GROUP="$UDEV_GROUP"
SUBSYSTEM=="usb", ATTR{idVendor}=="$VENDOR_NOMAD",     MODE="0660", GROUP="$UDEV_GROUP"


# =======================
# SERIAL DEVICES (ESP32-S3, DFU, debug)
# =======================
SUBSYSTEM=="tty", ATTRS{idVendor}=="$VENDOR_WORKLOUDER", MODE="0660", GROUP="$UDEV_GROUP", TAG+="uaccess"
SUBSYSTEM=="tty", ATTRS{idVendor}=="$VENDOR_NOMAD",     MODE="0660", GROUP="$UDEV_GROUP", TAG+="uaccess"


# =======================
# FALLBACK MATCHES
# =======================
# Catch devices that expose VID but not PID
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="$VENDOR_WORKLOUDER", MODE="0660", GROUP="$UDEV_GROUP", TAG+="uaccess"

# Work Louder name-based fallback (older firmware)
ATTRS{name}=="Work Louder*", MODE="0660", GROUP="$UDEV_GROUP", TAG+="uaccess"

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

echo "Done! Unplug/replug (USB) or disconnect/reconnect (Bluetooth), then restart the Input app."
