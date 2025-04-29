#!/bin/bash
set -euo pipefail

# Configuration
TEST_MODE="false"
URL="https://github.com/worklouder/input-releases/releases/download/v0.8.0-rc.2/input-Setup-0.8.0-rc.2.exe"
FILENAME="input-Setup-0.8.0-rc.2.exe"
DOWNLOAD_DIR="./input_download"
EXTRACT_DIR="./input_extracted"
REBUILD_DIR="./input_rebuild"
APP_64_EXTRACT_DIR="$REBUILD_DIR/app-64"
FINAL_APP_DIR="./input-app"

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
mkdir -p "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$REBUILD_DIR" "$APP_64_EXTRACT_DIR"

# Download EXE
echo "Downloading $FILENAME..."
if ! curl -L "$URL" -o "$DOWNLOAD_DIR/$FILENAME"; then
    handle_error "Download failed"
fi

# Extract EXE
echo "Extracting $FILENAME..."
if ! 7z x "$DOWNLOAD_DIR/$FILENAME" -o"$EXTRACT_DIR"; then
    handle_error "Extraction of EXE failed"
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
echo "Installing Electron and dependencies..."
(
    cd "$RESOURCES_DIR" || handle_error "Failed to cd into $RESOURCES_DIR"
    npm install electron@29.2.0 --save-dev || handle_error "Failed to install Electron"
    npm install electron-rebuild --save-dev || handle_error "Failed to install electron-rebuild"
)

# Rebuild native modules
echo "Running electron-rebuild..."
(
    cd "$UNPACKED_DIR" || handle_error "Failed to cd into $UNPACKED_DIR"
    npx electron-rebuild || handle_error "electron-rebuild failed"
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