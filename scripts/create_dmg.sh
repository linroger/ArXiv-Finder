#!/bin/bash

# Script to create a DMG installer for ArXiv Finder
# Usage: ./scripts/create_dmg.sh [path/to/ArXiv Finder.app]

APP_NAME="ArXiv Finder"
DMG_NAME="ArXiv_Finder_Installer.dmg"
VOL_NAME="ArXiv Finder Installer"

# Attempt to find the .app bundle
if [ -d "$1" ]; then
    APP_BUNDLE_PATH="$1"
elif [ -d "./${APP_NAME}.app" ]; then
    APP_BUNDLE_PATH="./${APP_NAME}.app"
elif [ -d "./Build/Products/Release/${APP_NAME}.app" ]; then
    APP_BUNDLE_PATH="./Build/Products/Release/${APP_NAME}.app"
elif [ -d "./Build/Products/Debug/${APP_NAME}.app" ]; then
    APP_BUNDLE_PATH="./Build/Products/Debug/${APP_NAME}.app"
else
    echo "Error: Could not find ${APP_NAME}.app"
    echo "Usage: ./scripts/create_dmg.sh [path/to/${APP_NAME}.app]"
    exit 1
fi

echo "Using app bundle at: $APP_BUNDLE_PATH"

# Create a temporary directory for the DMG contents
STAGING_DIR=$(mktemp -d)
echo "Created staging directory: $STAGING_DIR"

# Copy the app to the staging directory
echo "Copying app to staging..."
cp -R "$APP_BUNDLE_PATH" "$STAGING_DIR/"

# Create a symbolic link to the Applications folder
echo "Creating link to /Applications..."
ln -s /Applications "$STAGING_DIR/Applications"

# Create the DMG
echo "Creating DMG..."
hdiutil create -volname "$VOL_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

# Cleanup
echo "Cleaning up..."
rm -rf "$STAGING_DIR"

echo "✅ DMG created successfully: $DMG_NAME"
