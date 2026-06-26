# Contributing

## Code Style

- Use Swift and SwiftUI/AppKit native patterns.
- Keep views focused and move testable logic into `KondrehCore`.
- Avoid force unwraps and force casts in production code.
- Keep camera session work off the main thread.
- Do not add microphone, network, analytics, ad, or tracker dependencies.

## Testing

Run unit tests before opening a pull request:

```bash
swift test
```

Use `Tests/UI_TEST_PLAN.md` for camera and permission workflows that cannot be fully automated.

## Pull Requests

Include:

- What changed
- How it was tested
- Any privacy or entitlement impact
- Screenshots or short recordings for UI changes

## Release Changes

Release-related changes must preserve:

- Camera-only entitlement
- Hardened Runtime signing
- Notarization compatibility
- Accurate privacy documentation

Production licensing and update integrations must be behind `LicenseProviding` and `UpdateProviding`.
