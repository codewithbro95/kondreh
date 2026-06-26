# Release Guide

This guide assumes direct distribution outside the Mac App Store. Replace placeholders with your actual Apple Developer values.

## 1. Update Version and Build

Choose semantic version and monotonically increasing build number:

```bash
export VERSION=1.0.0
export BUILD_NUMBER=1
```

## 2. Create a Release Build

```bash
SIGNING_IDENTITY="Developer ID Application: YOUR NAME (TEAMID)" \
VERSION="$VERSION" \
BUILD_NUMBER="$BUILD_NUMBER" \
bash Scripts/build-app.sh
```

The app is created at `.build/release/Kondreh.app`.

## 3. Signing

The build script signs with:

- Hardened Runtime: `--options runtime`
- Timestamp: `--timestamp`
- Entitlements: `Supporting/Kondreh-Direct.entitlements`

Verify signing:

```bash
codesign --verify --deep --strict --verbose=2 .build/release/Kondreh.app
spctl --assess --type execute --verbose .build/release/Kondreh.app
```

## 4. Export

The SwiftPM build script creates the bundle directly. For an Xcode archive workflow, open `Kondreh.xcodeproj`, select the `Kondreh` scheme, select your development team, and use Developer ID Application signing for direct distribution.

## 5. Notarize

```bash
APPLE_ID="you@example.com" \
TEAM_ID="TEAMID" \
APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
bash Scripts/notarize.sh
```

Prefer storing credentials in an Apple notarytool keychain profile for production automation.

## 6. Staple

`Scripts/notarize.sh` staples and validates the ticket automatically:

```bash
xcrun stapler validate .build/release/Kondreh.app
```

## 7. Create a DMG

```bash
bash Scripts/create-dmg.sh
```

Verify the DMG on a clean Mac before publishing.

## 8. Final Verification

Run:

```bash
codesign --display --entitlements :- .build/release/Kondreh.app
spctl --assess --type open --context context:primary-signature --verbose .build/release/Kondreh.dmg
```

Then perform the manual test plan in `Tests/UI_TEST_PLAN.md`.

## 9. Publishing Updates

`DevelopmentUpdateProvider` is intentionally disabled. For direct distribution, integrate Sparkle 2 before enabling update checks:

1. Add Sparkle through Swift Package Manager.
2. Add the Sparkle framework to the app bundle.
3. Generate an EdDSA signing key with Sparkle tools.
4. Add the public key to Info.plist.
5. Host an appcast XML over HTTPS.
6. Replace `DevelopmentUpdateProvider` with a Sparkle-backed `UpdateProviding`.
7. Sign every update archive with Sparkle's private key.

Never invent or commit signing keys.

## 10. Rollback

If a release is broken:

1. Remove the broken download from the website.
2. Restore the previous notarized DMG.
3. Update the appcast to point to the previous version.
4. Publish a support note with exact affected versions.
5. Ship a fixed build with a higher build number.
