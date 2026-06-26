# Architecture

Kondreh is split into a testable core target and a macOS app target.

## Major Components

- `AppEnvironment`: creates shared app services for settings, camera, licensing, launch at login, and updates.
- `AppDelegate`: configures accessory app behavior, status item, preview panel, onboarding, and shortcut registration.
- `MenuBarController`: owns the `NSStatusItem`. Left click toggles preview; right/control click opens the utility menu.
- `PreviewPanelController`: owns the resizable `NSPanel`, positioning, Escape handling, outside-click closing, and camera stop on close.
- `CameraManager`: owns the `AVCaptureSession` lifecycle on a dedicated serial queue.
- `SettingsService`: stores typed preferences in `UserDefaults`.
- `CarbonGlobalShortcutManager`: isolates global hotkey registration behind `GlobalShortcutManaging`.
- `LocalDevelopmentLicenseProvider`: development-only trial/license provider behind `LicenseProviding`.
- `DevelopmentUpdateProvider`: disabled update provider behind `UpdateProviding`.

## Data Flow

Settings live in `SettingsService` and are observed by SwiftUI views. Preview controls mutate settings directly. Camera changes flow through `CameraManager`, which publishes explicit `CameraSessionState` values for the preview UI.

## Camera Lifecycle

1. Preview opens.
2. `CameraManager.start()` checks camera authorization.
3. If authorized, devices are discovered and the selected camera is resolved.
4. Session configuration runs on `com.codewithbro.kondreh.camera.session`.
5. Existing inputs are removed before a new `AVCaptureDeviceInput` is added.
6. No audio input, movie output, photo output, or frame-writing output is created.
7. `AVCaptureVideoPreviewLayer` displays the session locally.
8. Preview close calls `stop()`, stops the session, removes the input, and releases the active device reference.

## Permission Flow

`CameraAuthorizationService` maps every AVFoundation authorization state. For `notDetermined`, the UI explains why access is needed and requests permission only after the user clicks Allow Camera Access. Denied and restricted states show stable explanatory screens instead of retry loops.

## Panel Management

The preview uses `NSPanel` rather than `MenuBarExtra` because it needs reliable resizing, remembered size, multi-monitor placement, Escape close, outside-click close, and always-on-top behavior.

## Shortcut Registration

macOS does not provide a modern public API equivalent to a global app hotkey. Kondreh uses Carbon `RegisterEventHotKey`, isolated in `CarbonGlobalShortcutManager`, so the rest of the app depends only on `GlobalShortcutManaging`.

## Testability

Hardware-sensitive code is kept out of unit tests. The core target tests permission mapping, camera fallback selection, settings persistence, shortcut serialization, preview-state transitions, trial calculations, and launch-at-login state mapping. Camera hardware behavior is covered by the manual UI test plan.

## Entitlements

Kondreh includes only:

- App Sandbox
- Camera access

It does not include microphone, network client/server, file access, Apple Events, or location entitlements.
