#!/bin/bash
set -euo pipefail

# Configuration
TEST_MODE="${TEST_MODE:-true}"
URL="https://github.com/worklouder/input-releases/releases/download/v0.8.0-rc.2/input-Setup-0.8.0-rc.2.exe"
FILENAME="input-Setup-0.8.0-rc.2.exe"
DOWNLOAD_DIR="./input_download"
EXTRACT_DIR="./input_extracted"
REBUILD_DIR="./input_rebuild"
APP_64_EXTRACT_DIR="$REBUILD_DIR/app-64"
FINAL_APP_DIR="./input-app"
ELECTRON_VERSION="29.2.0"

# Ensure required tools are available
for cmd in curl 7z asar npm; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Missing required command: $cmd"
        [[ "$TEST_MODE" == true ]] && echo "Test mode enabled, continuing..." || exit 1
    fi
done

# Error handling
handle_error() {
    local message="$1"
    if [[ "$TEST_MODE" == true ]]; then
        echo "$message (ignored due to TEST_MODE)"
    else
        echo "$message"
        exit 1
    fi
}

# Prepare directories
if [[ -f "$DOWNLOAD_DIR/$FILENAME" ]]; then
    echo "$FILENAME already exists, skipping download"
else
    curl -L "$URL" -o "$DOWNLOAD_DIR/$FILENAME" || handle_error "Download failed"
fi

if [[ ! -d "$APP_64_EXTRACT_DIR" ]]; then
    7z x "$REBUILD_DIR/app-64.7z" -o"$APP_64_EXTRACT_DIR" || handle_error "Extraction failed"
fi

# Locate and move app-64.7z
APP_64_FILE=$(find "$EXTRACT_DIR" -type f -name "app-64.7z" | head -n 1 || true)
if [[ -z "$APP_64_FILE" ]]; then
    handle_error "app-64.7z not found"
else
    cp "$APP_64_FILE" "$REBUILD_DIR/"
    echo "Copied app-64.7z to $REBUILD_DIR"
fi

# Extract app-64.7z
echo "Extracting app-64.7z..."
if ! 7z x "$REBUILD_DIR/app-64.7z" -o"$APP_64_EXTRACT_DIR"; then
    handle_error "Extraction of app-64.7z failed"
fi

# Unpack app.asar
RESOURCES_DIR="$APP_64_EXTRACT_DIR/resources"
ASAR_FILE="$RESOURCES_DIR/app.asar"
UNPACKED_DIR="$RESOURCES_DIR/app_unpacked"

if [[ ! -f "$ASAR_FILE" ]]; then
    handle_error "app.asar not found at $ASAR_FILE"
fi

echo "Unpacking app.asar to $UNPACKED_DIR..."
mkdir -p "$UNPACKED_DIR"
if ! asar extract "$ASAR_FILE" "$UNPACKED_DIR"; then
    handle_error "Failed to unpack app.asar"
fi

# Install Electron dependencies
echo "Installing Electron and rebuild tools..."
(
    cd "$RESOURCES_DIR" || handle_error "Failed to cd into $RESOURCES_DIR"
    npm install --save-dev "electron@$ELECTRON_VERSION" || handle_error "Failed to install Electron"
    npm install --save-dev electron-rebuild || handle_error "Failed to install electron-rebuild"
)

# Rebuild native modules for Electron, especially node-hid
echo "Rebuilding node-hid for Electron..."
(
    cd "$UNPACKED_DIR" || handle_error "Failed to cd into $UNPACKED_DIR"

    # Force build from source
    npm install node-hid --build-from-source || handle_error "Failed to install node-hid from source"

    # Rebuild ONLY node-hid for Electron ABI compatibility
    npx electron-rebuild -f -w node-hid -v "$ELECTRON_VERSION" || handle_error "electron-rebuild for node-hid failed"
)


# Move the final app to project root
if [[ -d "$FINAL_APP_DIR" ]]; then
    echo "Removing existing $FINAL_APP_DIR"
    rm -rf "$FINAL_APP_DIR"
fi
mv "$UNPACKED_DIR" "$FINAL_APP_DIR"
echo "Moved unpacked app to $FINAL_APP_DIR"

# Clean up
echo "Cleaning up temporary directories..."
rm -rf "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$REBUILD_DIR"

echo "All steps completed. You can now run the app with:"
echo "npx electron ./input-app"
