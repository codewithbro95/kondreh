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
    private var lastPositioning: PreviewPanelPositioning = .activeScreenCenter
    private var eventMonitors: [Any] = []
    private var settingsCancellable: AnyCancellable?

    init(environment: AppEnvironment) {
        self.environment = environment
        super.init()
        settingsCancellable = environment.settings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.applyWindowLevel()
                self?.applyWindowShape()
                if self?.isVisible == true {
                    self?.installEventMonitors()
                }
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
        lastPositioning = positioning
        let panel = panel ?? makePanel()
        self.panel = panel
        applyWindowLevel()
        applyWindowShape()
        applyPanelSizeIfNeeded(to: panel)
        panel.contentView = NSHostingView(rootView: PreviewView(environment: environment) { [weak self] in
            self?.close()
        })
        if environment.settings.manualWindowPosition == false || panel.frame.origin == .zero {
            ScreenPositioning.position(panel: panel, positioning: positioning)
        }
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
        let size = panelSize()
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.borderless, .nonactivatingPanel],
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
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        return panel
    }

    private func panelSize() -> CGSizeValue {
        let stored = environment.settings.panelSize
        return CGSizeValue(
            width: min(max(stored.width, AppConstants.minimumPanelWidth), 424),
            height: min(max(stored.height, AppConstants.minimumPanelHeight), 236)
        )
    }

    private func applyPanelSizeIfNeeded(to panel: NSPanel) {
        let size = panelSize()
        if panel.frame.width != size.width || panel.frame.height != size.height {
            panel.setContentSize(NSSize(width: size.width, height: size.height))
        }
    }

    private func applyWindowLevel() {
        panel?.level = environment.settings.alwaysOnTop ? .floating : .normal
    }

    private func applyWindowShape() {
        guard let panel else { return }
        if environment.settings.lockAspectRatio {
            let ratio = environment.settings.aspectRatio.numericValue ?? (16.0 / 9.0)
            panel.contentAspectRatio = NSSize(width: ratio, height: 1)
        } else {
            panel.resizeIncrements = NSSize(width: 1, height: 1)
            panel.contentAspectRatio = .zero
        }
        panel.isMovableByWindowBackground = true
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

        guard environment.settings.closeOnOutsideClick else {
            return
        }

        let mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                guard let self, let panel = self.panel, panel.isVisible else {
                    return
                }
                if panel.frame.contains(NSEvent.mouseLocation) == false {
                    self.close()
                }
            }
        }

        if let mouseMonitor {
            eventMonitors.append(mouseMonitor)
        }
    }

    private func removeEventMonitors() {
        eventMonitors.forEach(NSEvent.removeMonitor)
        eventMonitors.removeAll()
    }
}
