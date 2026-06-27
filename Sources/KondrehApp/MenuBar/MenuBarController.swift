import AppKit
import Combine
import KondrehCore

@MainActor
final class MenuBarController: NSObject {
    private let environment: AppEnvironment
    private let previewPanelController: PreviewPanelController
    private var statusItem: NSStatusItem?
    private var settingsCancellable: AnyCancellable?

    init(environment: AppEnvironment, previewPanelController: PreviewPanelController) {
        self.environment = environment
        self.previewPanelController = previewPanelController
        super.init()
        rebuildStatusItem()
        settingsCancellable = environment.settings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.rebuildStatusItem()
            }
        }
    }

    func rebuildStatusItem() {
        if environment.settings.showMenuBarIcon == false {
            if let statusItem {
                NSStatusBar.system.removeStatusItem(statusItem)
            }
            statusItem = nil
            return
        }

        let item = statusItem ?? NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(
            systemSymbolName: environment.settings.menuBarIconStyle.symbolName,
            accessibilityDescription: AppConstants.appName
        )
        item.button?.target = self
        item.button?.action = #selector(statusItemPressed(_:))
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        item.button?.toolTip = "\(AppConstants.appName): open camera preview"
        statusItem = item
    }

    @objc private func statusItemPressed(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            previewPanelController.toggle(positioning: .statusItem(statusItem))
            return
        }

        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            showMenu(from: sender)
        } else {
            previewPanelController.toggle(positioning: .statusItem(statusItem))
        }
    }

    private func showMenu(from sender: NSStatusBarButton) {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(NSMenuItem(title: "Open Camera Preview", action: #selector(openPreview), keyEquivalent: ""))
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(AppDelegate.openSettings(_:)), keyEquivalent: ",")
        settingsItem.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
        settingsItem.target = NSApp.delegate
        settingsItem.isEnabled = true
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem(title: "About \(AppConstants.appName)", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Check for Updates", action: #selector(checkForUpdates), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit \(AppConstants.appName)", action: #selector(quit), keyEquivalent: "q"))
        menu.items.forEach { item in
            if item.target == nil {
                item.target = self
            }
            item.isEnabled = item.isSeparatorItem == false
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height + 2), in: sender)
    }

    @objc private func openPreview() {
        previewPanelController.show(positioning: .statusItem(statusItem))
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: AppConstants.appName,
            .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            .version: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        ])
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func checkForUpdates() {
        Task {
            _ = await environment.updateProvider.checkForUpdates()
            let alert = NSAlert()
            alert.messageText = "Updates are not configured in this development build."
            alert.informativeText = "Kondreh is ready for Sparkle 2 integration for direct distribution. See RELEASE.md for setup."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    @objc private func quit() {
        AppCommands.quit()
    }
}
