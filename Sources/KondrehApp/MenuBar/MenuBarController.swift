import AppKit
import KondrehCore

@MainActor
final class MenuBarController: NSObject {
    private let environment: AppEnvironment
    private let previewPanelController: PreviewPanelController
    private var statusItem: NSStatusItem?

    init(environment: AppEnvironment, previewPanelController: PreviewPanelController) {
        self.environment = environment
        self.previewPanelController = previewPanelController
        super.init()
        rebuildStatusItem()
    }

    func rebuildStatusItem() {
        if environment.settings.showMenuBarIcon == false {
            statusItem = nil
            return
        }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(systemSymbolName: AppConstants.menuBarSymbolName, accessibilityDescription: AppConstants.appName)
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
            showMenu()
        } else {
            previewPanelController.toggle(positioning: .statusItem(statusItem))
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Camera Preview", action: #selector(openPreview), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "About \(AppConstants.appName)", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Check for Updates", action: #selector(checkForUpdates), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit \(AppConstants.appName)", action: #selector(quit), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func openPreview() {
        previewPanelController.show(positioning: .statusItem(statusItem))
    }

    @objc private func openSettings() {
        (NSApp.delegate as? AppDelegate)?.showSettings()
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
