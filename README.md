# Kondreh

**Look ready before you join.**

Kondreh is a private native macOS menu-bar utility for checking your appearance before video meetings. It opens a compact live camera preview from the menu bar or a global shortcut, then stops the camera session as soon as the preview closes.

## Configuration

- App name: Kondreh
- Product name: Kondreh
- Bundle identifier: `com.codewithbro.kondreh`
- Minimum macOS: 13.0
- Menu-bar icon: `video.fill`
- License model: one-time purchase with a seven-day free trial
- Price: `$4.99 lifetime`
- Support: `hello@fotiecodes.com`
- Website: `https://fotiecodes.com`
- Privacy policy: `[YOUR_PRIVACY_POLICY_URL]`

## Assumptions

- Distribution is prepared for direct download outside the Mac App Store, while keeping sandbox and camera entitlement choices compatible with a future Mac App Store target.
- The default shortcut is Control + Option + Command + K to avoid common paste and meeting-app shortcuts.
- Licensing and updates are protocol-backed development implementations. Production providers such as Lemon Squeezy, Paddle, Gumroad, Polar, StoreKit, or Sparkle 2 should be wired in before paid distribution.
- The app icon source is included as SVG in `Design/AppIcon.svg`; generate production `.icns` assets before final archive.

## Requirements

- macOS 13.0 or later
- Xcode 26 or current stable Xcode with SwiftPM support
- A camera for full manual testing
- Apple Developer ID certificate for direct distribution signing

## Development

Open the native app project in Xcode:

```bash
open Kondreh.xcodeproj
```

Build and test from Terminal:

```bash
swift test
swift build -c release
```

The Swift package remains useful for command-line tests, but use `Kondreh.xcodeproj` when you want Xcode's Run button to launch the bundled macOS app with the correct Info.plist, `LSUIElement`, camera usage description, and entitlements.

Build a `.app` bundle:

```bash
bash Scripts/build-app.sh
```

Sign the app for direct distribution:

```bash
SIGNING_IDENTITY="Developer ID Application: YOUR NAME (TEAMID)" bash Scripts/build-app.sh
```

## Project Structure

- `Sources/KondrehCore`: testable models, settings, permission mapping, licensing, shortcut serialization, state reducers
- `Sources/KondrehApp`: SwiftUI/AppKit app, status item, preview panel, AVFoundation camera manager, settings, onboarding
- `Supporting`: bundle Info.plist and entitlements
- `Scripts`: build, notarization, and DMG helpers
- `Tests/KondrehCoreTests`: hardware-free unit tests
- `Tests/UI_TEST_PLAN.md`: manual UI and camera test matrix
- `Design`: app icon source

## Privacy

Kondreh uses AVFoundation to show camera frames in a local preview layer. It does not record, save, upload, transmit, or analyze camera frames. It does not request microphone access and includes no analytics, ads, trackers, account system, backend, or network entitlement.

## Testing Camera Permissions

Reset camera permission during development:

```bash
tccutil reset Camera com.codewithbro.kondreh
```

For SwiftPM debug runs, macOS may associate permission with the host executable path. Test the packaged `.app` for final permission behavior.

## Multiple Cameras

Kondreh discovers built-in cameras, USB cameras, and Continuity Camera devices exposed by macOS. If a selected camera disappears, the app falls back to the built-in or first available camera.

## Distribution

See `RELEASE.md` for versioning, signing, notarization, stapling, DMG creation, Sparkle setup, publishing, and rollback.

## Troubleshooting

- If the preview shows a permission screen, enable Camera access in System Settings > Privacy & Security > Camera.
- If the global shortcut fails, choose a different combination with Command, Option, or Control.
- If launch at login requires approval, approve Kondreh in System Settings > General > Login Items.
- If camera hardware cannot be automated, use the manual test plan in `Tests/UI_TEST_PLAN.md`.
