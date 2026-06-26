import AppKit
import SwiftUI

@MainActor
final class OnboardingWindowController: NSWindowController {
    init(environment: AppEnvironment) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 360),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Welcome to Kondreh"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.center()
        super.init(window: window)
        window.contentView = NSHostingView(rootView: OnboardingView(environment: environment) { [weak window] in
            window?.close()
        })
    }

    required init?(coder: NSCoder) {
        nil
    }
}
