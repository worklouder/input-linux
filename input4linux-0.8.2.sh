#!/bin/bash
set -euo pipefail

# This script sets up the Input Linux app from source.
# If you're just testing or debugging, you can run this with:
#   TEST_MODE=true ./input4linux-0.8.1.sh
# Set TEST_MODE=false to enforce strict failure on errors.

# Configuration
TEST_MODE="${TEST_MODE:-false}"
URL="https://github.com/worklouder/input-releases/releases/download/v0.8.2/input-Setup-0.8.2.exe"
FILENAME="input-Setup-0.8.2.exe"
DOWNLOAD_DIR="./input_download"
EXTRACT_DIR="./input_extracted"
REBUILD_DIR="./input_rebuild"
APP_64_EXTRACT_DIR="$REBUILD_DIR/app-64"
FINAL_APP_DIR="./input-app"
PATCH_DIR="./patch"
ELECTRON_VERSION="29.2.0"

# Python virtualenv setup
PY_VER="3.11"
VENV_DIR="$HOME/.node-build-env"
PYTHON="$VENV_DIR/bin/python"

echo " Setting up Python $PY_VER virtual environment for node-gyp compatibility..."
if [[ ! -d "$VENV_DIR" ]]; then
    if ! command -v python$PY_VER &>/dev/null; then
        echo " Error: python$PY_VER not found. Please install Python $PY_VER."
        exit 1
    fi
    python$PY_VER -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"

pip install --upgrade pip setuptools wheel

# Shim distutils if needed
DISTUTILS_SHIM="$VENV_DIR/lib/python$PY_VER/site-packages/distutils/__init__.py"
if [[ ! -f "$DISTUTILS_SHIM" ]]; then
    mkdir -p "$(dirname "$DISTUTILS_SHIM")"
    cat > "$DISTUTILS_SHIM" <<EOF
import setuptools._distutils as distutils
globals().update(vars(distutils))
EOF
fi

# Point npm to use this Python
export PYTHON="$PYTHON"

# Required tools check
for cmd in curl 7z asar npm; do
    if ! command -v "$cmd" &>/dev/null; then
        echo " Missing required command: $cmd"
        [[ "$TEST_MODE" == true ]] && echo " Test mode enabled, continuing..." || exit 1
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
echo " Downloading $FILENAME..."
if ! curl -L "$URL" -o "$DOWNLOAD_DIR/$FILENAME"; then
    handle_error "Download failed"
fi

# Extract installer
echo " Extracting $FILENAME..."
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
echo " Extracting app-64.7z..."
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

echo " Unpacking app.asar..."
mkdir -p "$UNPACKED_DIR"
if ! asar extract "$ASAR_FILE" "$UNPACKED_DIR"; then
    handle_error "Failed to unpack app.asar"
fi

# Setup Electron project
echo " Setting up Node environment..."
(
    cd "$UNPACKED_DIR" || handle_error "Cannot cd into unpacked directory"

    npm init -y || handle_error "npm init failed"
    npm install --save-dev "electron@$ELECTRON_VERSION" electron-rebuild || handle_error "Failed to install Electron or electron-rebuild"

    npm uninstall node-hid || true
    npm install node-hid --build-from-source || handle_error "node-hid build failed"

    npm install sudo-prompt || handle_error "Failed to install sudo-prompt"

    npx electron-rebuild -f -w node-hid -v "$ELECTRON_VERSION" || handle_error "electron-rebuild failed"
)

# Move app to final location
if [[ -d "$FINAL_APP_DIR" ]]; then
    echo " Removing old $FINAL_APP_DIR"
    rm -rf "$FINAL_APP_DIR"
fi

mv "$UNPACKED_DIR" "$FINAL_APP_DIR"

# Apply patch files
if [[ -d "$PATCH_DIR" ]]; then
    echo " Applying patch files from $PATCH_DIR to $FINAL_APP_DIR"
    cp -a "$PATCH_DIR/." "$FINAL_APP_DIR/"
    if [[ -f "$FINAL_APP_DIR/AppRun" ]]; then
        chmod +x "$FINAL_APP_DIR/AppRun"
    fi
else
    echo " No patch directory found at $PATCH_DIR, skipping patch step"
fi

# Cleanup
echo " Cleaning up temporary files..."
rm -rf "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$REBUILD_DIR"

echo " Done. Launch the app using:"
echo "./input-app/start.sh"