#!/bin/bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ELECTRON_BIN="$SCRIPT_DIR/node_modules/.bin/electron"
SANDBOX="$SCRIPT_DIR/node_modules/electron/dist/chrome-sandbox"

# Fix sandbox permissions
if [[ -f "$SANDBOX" && ! -u "$SANDBOX" ]]; then
    echo "Fixing sandbox permissions..."
    sudo chown root:root "$SANDBOX"
    sudo chmod 4755 "$SANDBOX"
fi

# Launch the app
"$ELECTRON_BIN" "$SCRIPT_DIR"
