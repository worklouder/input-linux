#!/bin/bash

# Config
TEST_MODE=true  # Set to false for production
URL="https://github.com/worklouder/input-releases/releases/download/v0.8.0-rc.2/input-Setup-0.8.0-rc.2.exe"
FILENAME="input-Setup-0.8.0-rc.2.exe"
DOWNLOAD_DIR="./input_download"
EXTRACT_DIR="./input_extracted"
REBUILD_DIR="./input_rebuild"
APP_64_EXTRACT_DIR="$REBUILD_DIR/app-64"

# Helper Function
handle_error() {
  if [ $? -ne 0 ]; then
    echo "❌ $1"
    if [ "$TEST_MODE" = true ]; then
      echo "⚠️ TEST_MODE enabled, continuing..."
    else
      exit 1
    fi
  fi
}

# Prep directories
mkdir -p "$DOWNLOAD_DIR" "$EXTRACT_DIR" "$REBUILD_DIR" "$APP_64_EXTRACT_DIR"

# Download EXE
echo "📥 Downloading $FILENAME..."
curl -L "$URL" -o "$DOWNLOAD_DIR/$FILENAME"
handle_error "Download failed!"

# Extract EXE
echo "📦 Extracting $FILENAME..."
7z x "$DOWNLOAD_DIR/$FILENAME" -o"$EXTRACT_DIR"
handle_error "Extraction of EXE failed!"

# Locate and move app-64
APP_64_FILE=$(find "$EXTRACT_DIR" -type f -name "app-64.7z" | head -n 1)
if [ -z "$APP_64_FILE" ]; then
  echo "❌ app-64.7z not found!"
  [ "$TEST_MODE" = true ] && echo "⚠️ TEST_MODE enabled, continuing..." || exit 1
else
  cp "$APP_64_FILE" "$REBUILD_DIR/"
  echo "✅ Copied app-64.7z to $REBUILD_DIR"
fi


# Extract app-64.7z
echo "📦 Extracting app-64.7z..."
7z x "$REBUILD_DIR/app-64.7z" -o"$APP_64_EXTRACT_DIR"
handle_error "Extraction of app-64.7z failed!"

echo "✅ Extracted app-64.7z to $APP_64_EXTRACT_DIR"

# Unpack app.asar
RESOURCES_DIR="$APP_64_EXTRACT_DIR/resources"
ASAR_FILE="$RESOURCES_DIR/app.asar"
UNPACKED_DIR="$RESOURCES_DIR/app_unpacked"

if ! command -v asar &> /dev/null; then
  echo "❌ 'asar' CLI not found. Please run: npm install -g asar"
  [ "$TEST_MODE" = true ] && echo "⚠️ TEST_MODE enabled, continuing..." || exit 1
fi

if [ ! -f "$ASAR_FILE" ]; then
  echo "❌ app.asar not found at $ASAR_FILE"
  [ "$TEST_MODE" = true ] && echo "⚠️ TEST_MODE enabled, continuing..." || exit 1
fi

echo "📦 Unpacking app.asar to $UNPACKED_DIR..."
mkdir -p "$UNPACKED_DIR"
asar extract "$ASAR_FILE" "$UNPACKED_DIR"
handle_error "Failed to unpack app.asar"

echo "✅ app.asar successfully unpacked to $UNPACKED_DIR"


# INSTALL DEPENDENCIES
cd "$RESOURCES_DIR" || {
  echo "❌ Failed to cd into $RESOURCES_DIR"
  [ "$TEST_MODE" = true ] && echo "⚠️ TEST_MODE enabled, continuing..." || exit 1
}

echo "📦 Installing Electron 29.2.0..."
npm install electron@29.2.0 --save-dev
handle_error "Failed to install Electron"

echo "📦 Installing electron-rebuild..."
npm install electron-rebuild --save-dev
handle_error "Failed to install electron-rebuild"

# REBUILD NATIVE MODULES
cd "$UNPACKED_DIR" || {
  echo "❌ Failed to cd into $UNPACKED_DIR"
  [ "$TEST_MODE" = true ] && echo "⚠️ TEST_MODE enabled, continuing..." || exit 1
}

echo "🔧 Running electron-rebuild..."
npx electron-rebuild
handle_error "electron-rebuild failed"

echo "✅ electron-rebuild completed successfully"
