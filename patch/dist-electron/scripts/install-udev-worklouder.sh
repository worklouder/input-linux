#!/bin/bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-worklouder.rules"
MATCH_NAME="Work Louder"
RULE_FOUND=false

# Find matching devices and extract vendor/product IDs
mapfile -t DEVICES < <(lsusb | grep "$MATCH_NAME")

if [[ ${#DEVICES[@]} -eq 0 ]]; then
    echo "No USB devices found with manufacturer \"$MATCH_NAME\""
    exit 0
fi

echo "Found matching devices:"
printf '%s\n' "${DEVICES[@]}"

# Ensure rule file exists
sudo touch "$RULE_FILE"
sudo chmod 644 "$RULE_FILE"

for DEVICE in "${DEVICES[@]}"; do
    BUS_ID=$(echo "$DEVICE" | awk '{print $2}')
    DEV_ID=$(echo "$DEVICE" | awk '{print $4}' | tr -d :)
    ID_VENDOR=$(echo "$DEVICE" | awk '{print $6}' | cut -d: -f1)
    ID_PRODUCT=$(echo "$DEVICE" | awk '{print $6}' | cut -d: -f2)

    # USB rule (for general access)
    USB_RULE="SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$ID_VENDOR\", ATTR{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\", SYMLINK+=\"worklouder\""

    # HIDRAW rule (for raw HID access like /dev/hidrawX)
    HIDRAW_RULE="KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"$ID_VENDOR\", ATTRS{idProduct}==\"$ID_PRODUCT\", MODE=\"0666\", GROUP=\"plugdev\""

    # Check if either rule already exists
    if grep -q "$ID_VENDOR.*$ID_PRODUCT" "$RULE_FILE"; then
        echo "Rules for $ID_VENDOR:$ID_PRODUCT already exist."
        RULE_FOUND=true
    else
        echo "Adding USB rule for $ID_VENDOR:$ID_PRODUCT"
        echo "$USB_RULE" | sudo tee -a "$RULE_FILE" > /dev/null
        echo "Adding HIDRAW rule for $ID_VENDOR:$ID_PRODUCT"
        echo "$HIDRAW_RULE" | sudo tee -a "$RULE_FILE" > /dev/null
    fi
done

echo "Reloading udev rules..."
sudo udevadm control --reload
sudo udevadm trigger

echo "Done. You may need to replug your device."
