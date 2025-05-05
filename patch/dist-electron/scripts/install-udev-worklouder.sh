#!/bin/bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-worklouder.rules"
TEMP_FILE="$(mktemp)"
MATCH_NAME="Work Louder"

# Add header
echo "# udev rules for Work Louder devices" | sudo tee "$TEMP_FILE" > /dev/null

# Find matching devices and extract vendor/product IDs
mapfile -t DEVICES < <(lsusb | grep "$MATCH_NAME")

if [[ ${#DEVICES[@]} -eq 0 ]]; then
    echo "No USB devices found with manufacturer \"$MATCH_NAME\""
else
    echo "Found matching devices:"
    printf '%s\n' "${DEVICES[@]}"

    for DEVICE in "${DEVICES[@]}"; do
        ID_VENDOR=$(echo "$DEVICE" | awk '{print $6}' | cut -d: -f1)
        ID_PRODUCT=$(echo "$DEVICE" | awk '{print $6}' | cut -d: -f2)

        echo "Adding rules for device $ID_VENDOR:$ID_PRODUCT"

        # USB rule
        echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$ID_VENDOR\", ATTR{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\", SYMLINK+=\"worklouder\"" | sudo tee -a "$TEMP_FILE" > /dev/null

        # HIDRAW rule
        echo "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"$ID_VENDOR\", ATTRS{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\", TAG+=\"uaccess\"" | sudo tee -a "$TEMP_FILE" > /dev/null
    done
fi

# Add generic HIDRAW rule with TAG+="uaccess"
echo 'SUBSYSTEM=="hidraw", KERNEL=="hidraw*", MODE="0666", GROUP="plugdev", TAG+="uaccess"' | sudo tee -a "$TEMP_FILE" > /dev/null

# Replace the old rule file
sudo mv "$TEMP_FILE" "$RULE_FILE"
sudo chmod 644 "$RULE_FILE"

echo "Reloading udev rules..."
sudo udevadm control --reload
sudo udevadm trigger
sudo udevadm settle

echo "✅ Done. You may need to replug or reconnect your device."
