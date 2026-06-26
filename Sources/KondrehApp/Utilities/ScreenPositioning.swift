import AppKit
import KondrehCore

enum ScreenPositioning {
    static func position(panel: NSPanel, positioning: PreviewPanelPositioning) {
        let targetFrame: NSRect
        switch positioning {
        case .activeScreenCenter:
            let screen = NSScreen.main ?? NSScreen.screens.first
            targetFrame = centeredFrame(for: panel, on: screen)
        case .statusItem(let item):
            targetFrame = frameNearStatusItem(item, panel: panel)
        }
        panel.setFrame(constrain(targetFrame, to: bestScreen(for: targetFrame)), display: true)
    }

    private static func frameNearStatusItem(_ item: NSStatusItem?, panel: NSPanel) -> NSRect {
        guard let button = item?.button,
              let window = button.window,
              let screen = window.screen ?? NSScreen.main else {
            return centeredFrame(for: panel, on: NSScreen.main)
        }

        let buttonFrame = button.convert(button.bounds, to: nil)
        let screenFrame = window.convertToScreen(buttonFrame)
        let size = panel.frame.size
        return NSRect(
            x: screenFrame.midX - size.width + 24,
            y: screen.visibleFrame.maxY - size.height - 10,
            width: size.width,
            height: size.height
        )
    }

    private static func centeredFrame(for panel: NSPanel, on screen: NSScreen?) -> NSRect {
        let visible = (screen ?? NSScreen.main ?? NSScreen.screens.first)?.visibleFrame ?? .zero
        let size = panel.frame.size
        return NSRect(
            x: visible.midX - size.width / 2,
            y: visible.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    private static func constrain(_ frame: NSRect, to screen: NSScreen?) -> NSRect {
        guard let visible = screen?.visibleFrame else { return frame }
        var frame = frame
        if frame.maxX > visible.maxX { frame.origin.x = visible.maxX - frame.width }
        if frame.minX < visible.minX { frame.origin.x = visible.minX }
        if frame.maxY > visible.maxY { frame.origin.y = visible.maxY - frame.height }
        if frame.minY < visible.minY { frame.origin.y = visible.minY }
        return frame
    }

    private static func bestScreen(for frame: NSRect) -> NSScreen? {
        NSScreen.screens.max { first, second in
            first.visibleFrame.intersection(frame).width * first.visibleFrame.intersection(frame).height
                < second.visibleFrame.intersection(frame).width * second.visibleFrame.intersection(frame).height
        } ?? NSScreen.main
    }
}
