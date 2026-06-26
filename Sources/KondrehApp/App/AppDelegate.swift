import AppKit
import KondrehCore
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let environment = AppEnvironment.shared
    private var menuBarController: MenuBarController?
    private var previewPanelController: PreviewPanelController?
    private var shortcutManager: GlobalShortcutManaging?
    private var onboardingController: OnboardingWindowController?
    private var settingsController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let previewPanelController = PreviewPanelController(environment: environment)
        self.previewPanelController = previewPanelController

        let menuBarController = MenuBarController(environment: environment, previewPanelController: previewPanelController)
        self.menuBarController = menuBarController

        let shortcutManager = CarbonGlobalShortcutManager()
        self.shortcutManager = shortcutManager
        configureShortcut()

        Task {
            _ = await environment.licenseProvider.beginTrial()
        }

        if environment.settings.onboardingCompleted == false {
            showOnboarding()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        shortcutManager?.unregister()
        previewPanelController?.close()
        environment.cameraManager.stop()
    }

    func showSettings() {
        if settingsController == nil {
            settingsController = SettingsWindowController(environment: environment)
        }
        settingsController?.showWindow(nil)
        settingsController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func configureShortcut() {
        shortcutManager?.unregister()
        guard environment.settings.shortcutEnabled else {
            return
        }
        shortcutManager?.register(environment.settings.keyboardShortcut) { [weak self] in
            Task { @MainActor in
                self?.previewPanelController?.toggle(positioning: .activeScreenCenter)
            }
        }
    }

    private func showOnboarding() {
        let controller = OnboardingWindowController(environment: environment)
        onboardingController = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@MainActor
private final class SettingsWindowController: NSWindowController {
    init(environment: AppEnvironment) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.minSize = NSSize(width: 560, height: 520)
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: AppSettingsView(environment: environment))
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        nil
    }
}
