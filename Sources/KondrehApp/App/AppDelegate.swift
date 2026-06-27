import AppKit
import Combine
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
    private var settingsCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        applyActivationPolicy()
        AppIconApplier.apply(environment.settings.alternateAppIconStyle, updateBundleIcon: false)
        settingsCancellable = environment.settings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.applyActivationPolicy()
            }
        }

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

    func showSettings(section: AppSettingsSection = .general) {
        if settingsController == nil {
            settingsController = SettingsWindowController(environment: environment)
        }
        settingsController?.show(section: section)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func openSettings(_ sender: Any?) {
        showSettings(section: .general)
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

    private func applyActivationPolicy() {
        NSApp.setActivationPolicy(environment.settings.showDockIcon ? .regular : .accessory)
    }
}

@MainActor
private final class SettingsWindowController: NSWindowController, NSToolbarDelegate {
    private let navigation = SettingsNavigation()

    private enum ToolbarID {
        static let toolbar = "Kondreh.Settings.Toolbar"
        static let free = NSToolbarItem.Identifier("Kondreh.Settings.Free")
        static let support = NSToolbarItem.Identifier("Kondreh.Settings.Support")
    }

    init(environment: AppEnvironment) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.minSize = NSSize(width: 720, height: 560)
        window.isReleasedWhenClosed = false
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.toolbarStyle = .unified
        window.center()
        window.contentView = NSHostingView(rootView: AppSettingsView(environment: environment, navigation: navigation))
        super.init(window: window)

        let toolbar = NSToolbar(identifier: ToolbarID.toolbar)
        toolbar.delegate = self
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconOnly
        window.toolbar = toolbar
    }

    required init?(coder: NSCoder) {
        nil
    }

    func show(section: AppSettingsSection) {
        navigation.select(section)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .flexibleSpace,
            ToolbarID.free,
            ToolbarID.support
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarAllowedItemIdentifiers(toolbar)
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case ToolbarID.free:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let label = NSTextField(labelWithString: "Free")
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .secondaryLabelColor
            item.view = label
            item.label = "Free"
            item.paletteLabel = "Free"
            return item

        case ToolbarID.support:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let button = NSButton(title: "Buy me a coffee", target: self, action: #selector(openCoffee))
            button.bezelStyle = .rounded
            button.controlSize = .small
            item.view = button
            item.label = "Buy me a coffee"
            item.paletteLabel = "Buy me a coffee"
            return item

        default:
            return nil
        }
    }

    @objc private func openCoffee() {
        let subject = "Buy me a coffee for Kondreh"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Kondreh"
        if let url = URL(string: "mailto:\(AppConstants.supportEmail)?subject=\(subject)") {
            NSWorkspace.shared.open(url)
        }
    }
}
