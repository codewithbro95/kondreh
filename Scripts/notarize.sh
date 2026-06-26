#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${APP_PATH:-$ROOT_DIR/.build/release/Kondreh.app}"
ZIP_PATH="${ZIP_PATH:-$ROOT_DIR/.build/release/Kondreh.zip}"

: "${APPLE_ID:?Set APPLE_ID to your Apple developer account email.}"
: "${TEAM_ID:?Set TEAM_ID to your Apple Developer Team ID.}"
: "${APP_SPECIFIC_PASSWORD:?Set APP_SPECIFIC_PASSWORD to an app-specific password or use a notarytool keychain profile.}"

ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
xcrun notarytool submit "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_SPECIFIC_PASSWORD" \
  --wait
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"
