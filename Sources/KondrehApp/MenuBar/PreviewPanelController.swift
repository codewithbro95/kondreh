import AppKit
import Combine
import KondrehCore
import SwiftUI

enum PreviewPanelPositioning {
    case statusItem(NSStatusItem?)
    case activeScreenCenter
}

@MainActor
final class PreviewPanelController: NSObject, NSWindowDelegate {
    private let environment: AppEnvironment
    private var panel: NSPanel?
    private var eventMonitors: [Any] = []
    private var settingsCancellable: AnyCancellable?

    init(environment: AppEnvironment) {
        self.environment = environment
        super.init()
        settingsCancellable = environment.settings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.applyWindowLevel()
            }
        }
    }

    var isVisible: Bool {
        panel?.isVisible == true
    }

    func toggle(positioning: PreviewPanelPositioning) {
        if isVisible {
            close()
        } else {
            show(positioning: positioning)
        }
    }

    func show(positioning: PreviewPanelPositioning) {
        let panel = panel ?? makePanel()
        self.panel = panel
        applyWindowLevel()
        panel.contentView = NSHostingView(rootView: PreviewView(environment: environment) { [weak self] in
            self?.close()
        })
        ScreenPositioning.position(panel: panel, positioning: positioning)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        environment.cameraManager.start()
        installEventMonitors()
    }

    func close() {
        guard let panel else { return }
        environment.settings.panelSize = CGSizeValue(width: panel.frame.width, height: panel.frame.height)
        panel.orderOut(nil)
        removeEventMonitors()
        environment.cameraManager.stop()
    }

    func windowWillClose(_ notification: Notification) {
        close()
    }

    private func makePanel() -> NSPanel {
        let size = environment.settings.panelSize
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.title = AppConstants.appName
        panel.delegate = self
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.minSize = NSSize(width: AppConstants.minimumPanelWidth, height: AppConstants.minimumPanelHeight)
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        return panel
    }

    private func applyWindowLevel() {
        panel?.level = environment.settings.alwaysOnTop ? .floating : .normal
    }

    private func installEventMonitors() {
        removeEventMonitors()

        let keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.close()
                return nil
            }
            return event
        }

        if let keyMonitor {
            eventMonitors.append(keyMonitor)
        }
    }

    private func removeEventMonitors() {
        eventMonitors.forEach(NSEvent.removeMonitor)
        eventMonitors.removeAll()
    }
}
