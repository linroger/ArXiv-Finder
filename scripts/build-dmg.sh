#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="ArXiv Finder.xcodeproj"
SCHEME_NAME="ArXiv Finder"
APP_NAME="ArXiv Finder.app"
VOLUME_NAME="ArXiv Finder"

BUILD_DIR="$ROOT_DIR/.build-macos"
STAGING_DIR="$BUILD_DIR/dmg-staging"
DIST_DIR="$ROOT_DIR/dist"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "error: xcodebuild is required but was not found in PATH." >&2
  exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "error: hdiutil is required but was not found in PATH." >&2
  exit 1
fi

MARKETING_VERSION="${MARKETING_VERSION:-}"
if [[ -z "$MARKETING_VERSION" ]]; then
  MARKETING_VERSION="$(
    xcodebuild \
      -project "$ROOT_DIR/$PROJECT_FILE" \
      -scheme "$SCHEME_NAME" \
      -showBuildSettings 2>/dev/null |
      awk -F ' = ' '/MARKETING_VERSION/ { print $2; exit }'
  )"
fi
MARKETING_VERSION="${MARKETING_VERSION:-dev}"

DMG_NAME="ArXiv-Finder-${MARKETING_VERSION}-macOS.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"
APP_PATH="$BUILD_DIR/Build/Products/Release/$APP_NAME"

echo "==> Building $APP_NAME (Release, macOS)"
xcodebuild \
  -project "$ROOT_DIR/$PROJECT_FILE" \
  -scheme "$SCHEME_NAME" \
  -configuration Release \
  -destination "platform=macOS" \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGNING_ALLOWED=NO \
  clean build

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: expected app not found at $APP_PATH" >&2
  exit 1
fi

echo "==> Preparing DMG staging directory"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
mkdir -p "$DIST_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/$APP_NAME"
ln -s /Applications "$STAGING_DIR/Applications"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$STAGING_DIR/$APP_NAME" >/dev/null 2>&1 || true
fi

echo "==> Creating $DMG_NAME"
rm -f "$DMG_PATH"
hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

DMG_SIZE="$(du -h "$DMG_PATH" | awk '{print $1}')"
echo "==> DMG ready: $DMG_PATH ($DMG_SIZE)"
