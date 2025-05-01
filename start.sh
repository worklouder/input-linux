#!/bin/bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ELECTRON_BIN="$SCRIPT_DIR/node_modules/.bin/electron"
SANDBOX="$SCRIPT_DIR/node_modules/electron/dist/chrome-sandbox"

# Udev rules check and update
UDEV_RULES_FILE="/etc/udev/rules.d/99-input.rules"
REQUIRED_RULES='# Work Louder Input Device\nSUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="3456", MODE="0666", GROUP="plugdev"'

check_udev_rules() {
    if [[ -f "$UDEV_RULES_FILE" ]]; then
        if grep -q "1209.*3456" "$UDEV_RULES_FILE"; then
            return 0
        fi
    fi
    return 1
}

if ! check_udev_rules; then
    echo -e "\e[33mUdev rules for Input device are missing or incomplete.\e[0m"
    echo "The following rules are required:\n"
    echo -e "$REQUIRED_RULES\n"
    read -p "Would you like to add/update these rules now? (Y/n): " yn
    yn=${yn:-Y}
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        echo -e "$REQUIRED_RULES" | sudo tee "$UDEV_RULES_FILE" > /dev/null
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        echo -e "\e[32mUdev rules updated. You may need to replug your device.\e[0m"
    else
        echo -e "\e[31mWarning: The app may not function correctly without the correct udev rules.\e[0m"
    fi
fi

# Fix sandbox permissions
if [[ -f "$SANDBOX" && ! -u "$SANDBOX" ]]; then
    echo "Fixing sandbox permissions..."
    sudo chown root:root "$SANDBOX"
    sudo chmod 4755 "$SANDBOX"
fi

# Launch the app
"$ELECTRON_BIN" "$SCRIPT_DIR"
