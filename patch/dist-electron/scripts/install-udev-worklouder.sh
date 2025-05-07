#!/bin/bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-worklouder.rules"
TEMP_FILE="$(mktemp)"
MATCH_NAME="Work Louder"

echo "Generating udev rules for \"$MATCH_NAME\" devices..."
echo "# udev rules for Work Louder devices" | sudo tee "$TEMP_FILE" > /dev/null

# Parse USB devices
mapfile -t DEVICES < <(lsusb | grep "$MATCH_NAME")

if [[ ${#DEVICES[@]} -eq 0 ]]; then
    echo "No USB devices found with manufacturer \"$MATCH_NAME\""
else
    echo "Found matching USB devices:"
    printf '%s\n' "${DEVICES[@]}"

    for DEVICE in "${DEVICES[@]}"; do
        ID_VENDOR=$(echo "$DEVICE" | awk '{print $6}' | cut -d: -f1)
        ID_PRODUCT=$(echo "$DEVICE" | awk '{print $6}' | cut -d: -f2)

        echo "Adding rules for $ID_VENDOR:$ID_PRODUCT"

        # USB rule
        echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$ID_VENDOR\", ATTR{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\", SYMLINK+=\"worklouder\"" | sudo tee -a "$TEMP_FILE" > /dev/null

        # HIDRAW rule
        echo "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"$ID_VENDOR\", ATTRS{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\", TAG+=\"uaccess\"" | sudo tee -a "$TEMP_FILE" > /dev/null

        # Serial rule (ttyACM*, ttyUSB*)
        echo "SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$ID_VENDOR\", ATTRS{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\"" | sudo tee -a "$TEMP_FILE" > /dev/null
    done
fi

# Add catch-all for HID access
echo 'SUBSYSTEM=="hidraw", KERNEL=="hidraw*", MODE="0666", GROUP="plugdev", TAG+="uaccess"' | sudo tee -a "$TEMP_FILE" > /dev/null

# Add static rule for ESP32-S3 serial port
echo 'SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666", GROUP="plugdev", TAG+="uaccess"' | sudo tee -a "$TEMP_FILE" > /dev/null

# Apply the new rules
echo "Writing rules to $RULE_FILE"
sudo mv "$TEMP_FILE" "$RULE_FILE"
sudo chmod 644 "$RULE_FILE"

echo "Reloading udev rules..."
sudo udevadm control --reload
sudo udevadm trigger
sudo udevadm settle

echo "Done. Please replug your device or restart the app if needed."
