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
    private var panelMode: PreviewWindowMode?
    private var lastPositioning: PreviewPanelPositioning = .activeScreenCenter
    private var eventMonitors: [Any] = []
    private var settingsCancellable: AnyCancellable?

    init(environment: AppEnvironment) {
        self.environment = environment
        super.init()
        settingsCancellable = environment.settings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                if self?.isVisible == true,
                   self?.panelMode != self?.environment.settings.previewWindowMode {
                    self?.replaceVisiblePanelForCurrentMode()
                }
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
        if panelMode != environment.settings.previewWindowMode {
            panel?.orderOut(nil)
            panel = nil
        }

        let panel = panel ?? makePanel(mode: environment.settings.previewWindowMode)
        self.panel = panel
        panelMode = environment.settings.previewWindowMode
        applyWindowLevel()
        applyWindowShape()
        applyPopoverSizeIfNeeded(to: panel, mode: environment.settings.previewWindowMode)
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

    private func makePanel(mode: PreviewWindowMode) -> NSPanel {
        let size = panelSize(for: mode)
        let styleMask: NSWindow.StyleMask = mode == .popover
            ? [.borderless, .nonactivatingPanel]
            : [.titled, .closable, .resizable, .fullSizeContentView]
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        panel.title = AppConstants.appName
        panel.delegate = self
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.minSize = NSSize(width: AppConstants.minimumPanelWidth, height: AppConstants.minimumPanelHeight)
        panel.titleVisibility = mode == .popover ? .hidden : .visible
        panel.titlebarAppearsTransparent = mode == .popover
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        return panel
    }

    private func panelSize(for mode: PreviewWindowMode) -> CGSizeValue {
        let stored = environment.settings.panelSize
        guard mode == .popover else {
            return stored
        }

        return CGSizeValue(
            width: min(max(stored.width, AppConstants.minimumPanelWidth), 424),
            height: min(max(stored.height, AppConstants.minimumPanelHeight), 236)
        )
    }

    private func applyPopoverSizeIfNeeded(to panel: NSPanel, mode: PreviewWindowMode) {
        guard mode == .popover else {
            return
        }

        let size = panelSize(for: mode)
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
        panel.isMovableByWindowBackground = environment.settings.previewWindowMode == .popover || environment.settings.manualWindowPosition
    }

    private func replaceVisiblePanelForCurrentMode() {
        let oldFrame = panel?.frame
        panel?.orderOut(nil)
        let newPanel = makePanel(mode: environment.settings.previewWindowMode)
        panel = newPanel
        panelMode = environment.settings.previewWindowMode
        applyWindowLevel()
        applyWindowShape()
        applyPopoverSizeIfNeeded(to: newPanel, mode: environment.settings.previewWindowMode)
        newPanel.contentView = NSHostingView(rootView: PreviewView(environment: environment) { [weak self] in
            self?.close()
        })
        if let oldFrame, environment.settings.manualWindowPosition {
            var replacementFrame = oldFrame
            if environment.settings.previewWindowMode == .popover {
                let size = panelSize(for: .popover)
                replacementFrame.size = NSSize(width: size.width, height: size.height)
            }
            newPanel.setFrame(replacementFrame, display: true)
        } else {
            ScreenPositioning.position(panel: newPanel, positioning: lastPositioning)
        }
        newPanel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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
