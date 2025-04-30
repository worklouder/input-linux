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

# Required tools check
for cmd in curl 7z asar npm; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Missing required command: $cmd"
        [[ "$TEST_MODE" == true ]] && echo "Test mode enabled, continuing..." || exit 1
    fi
done

# Error handler
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
mkdir -p "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$REBUILD_DIR" "$APP_64_EXTRACT_DIR"

# Download installer
echo "Downloading $FILENAME..."
if ! curl -L "$URL" -o "$DOWNLOAD_DIR/$FILENAME"; then
    handle_error "Download failed"
fi

# Extract installer
echo "Extracting $FILENAME..."
if ! 7z x "$DOWNLOAD_DIR/$FILENAME" -o"$EXTRACT_DIR"; then
    handle_error "Failed to extract EXE"
fi

# Find app-64.7z and move it
APP_64_FILE=$(find "$EXTRACT_DIR" -type f -name "app-64.7z" | head -n 1 || true)
if [[ -z "$APP_64_FILE" ]]; then
    handle_error "app-64.7z not found"
else
    cp "$APP_64_FILE" "$REBUILD_DIR/"
fi

# Extract app-64.7z
echo "Extracting app-64.7z..."
if ! 7z x "$REBUILD_DIR/app-64.7z" -o"$APP_64_EXTRACT_DIR"; then
    handle_error "Failed to extract app-64.7z"
fi

# Extract app.asar
RESOURCES_DIR="$APP_64_EXTRACT_DIR/resources"
ASAR_FILE="$RESOURCES_DIR/app.asar"
UNPACKED_DIR="$RESOURCES_DIR/app_unpacked"

if [[ ! -f "$ASAR_FILE" ]]; then
    handle_error "app.asar not found"
fi

echo "Unpacking app.asar..."
mkdir -p "$UNPACKED_DIR"
if ! asar extract "$ASAR_FILE" "$UNPACKED_DIR"; then
    handle_error "Failed to unpack app.asar"
fi

# Prepare Electron environment in unpacked app
echo "Setting up Node environment..."
(
    cd "$UNPACKED_DIR" || handle_error "Cannot cd into unpacked directory"
    npm init -y || handle_error "npm init failed"
    npm install --save-dev "electron@$ELECTRON_VERSION" electron-rebuild || handle_error "Failed to install Electron or electron-rebuild"
    npm uninstall node-hid || true
    npm install node-hid --build-from-source || handle_error "node-hid build failed"
    npx electron-rebuild -f -w node-hid -v "$ELECTRON_VERSION" || handle_error "electron-rebuild failed"
)

# Move unpacked app to final destination
if [[ -d "$FINAL_APP_DIR" ]]; then
    echo "Removing old $FINAL_APP_DIR"
    rm -rf "$FINAL_APP_DIR"
fi

mv "$UNPACKED_DIR" "$FINAL_APP_DIR"

# Move start.sh if it exists
if [[ -f "./start.sh" ]]; then
    echo "Moving start.sh to $FINAL_APP_DIR"
    mv ./start.sh "$FINAL_APP_DIR/start.sh"
fi

# Cleanup
echo "Cleaning up temporary files..."
rm -rf "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$REBUILD_DIR"

echo "Done. Launch the app using:"
echo "./input-app/start.sh"
