#!/bin/bash
set -e

# Determine AppDir path
APPDIR="$(dirname "$(readlink -f "$0")")"

# Path to Electron binary in production
ELECTRON="$APPDIR/node_modules/electron/dist/electron"

# Path to the compiled main file
APP="$APPDIR/dist-electron/main/index.js"

# Launch the app
exec "$ELECTRON" "$APP"
