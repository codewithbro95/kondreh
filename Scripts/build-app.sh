#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-release}"
VERSION="${VERSION:-1.0.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
APP_DIR="$ROOT_DIR/.build/${CONFIGURATION}/Kondreh.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$CONTENTS_DIR/Resources"
cp "$ROOT_DIR/.build/${CONFIGURATION}/Kondreh" "$MACOS_DIR/Kondreh"
cp "$ROOT_DIR/Supporting/Kondreh-Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Design/AppIcon.svg" "$CONTENTS_DIR/Resources/AppIcon.svg"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$CONTENTS_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$CONTENTS_DIR/Info.plist"

if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
  codesign \
    --force \
    --options runtime \
    --timestamp \
    --entitlements "$ROOT_DIR/Supporting/Kondreh-Direct.entitlements" \
    --sign "$SIGNING_IDENTITY" \
    "$APP_DIR"
fi

echo "Built $APP_DIR"
