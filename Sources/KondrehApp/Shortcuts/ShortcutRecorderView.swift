import AppKit
import KondrehCore
import SwiftUI

struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var shortcut: GlobalKeyboardShortcut

    func makeNSView(context: Context) -> ShortcutRecorderNSView {
        let view = ShortcutRecorderNSView()
        view.onChange = { newShortcut in shortcut = newShortcut }
        view.shortcut = shortcut
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSView, context: Context) {
        nsView.shortcut = shortcut
    }
}

final class ShortcutRecorderNSView: NSView {
    var shortcut: GlobalKeyboardShortcut = .default {
        didSet { needsDisplay = true }
    }
    var onChange: ((GlobalKeyboardShortcut) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.cgColor
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        needsDisplay = true
    }

    override func keyDown(with event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers?.uppercased(),
              characters.isEmpty == false else {
            return
        }
        let modifiers = GlobalKeyboardShortcut.Modifiers(eventModifierFlags: event.modifierFlags)
        let candidate = GlobalKeyboardShortcut(keyCode: UInt32(event.keyCode), characters: characters, modifiers: modifiers)
        if candidate.isSupported {
            shortcut = candidate
            onChange?(candidate)
        } else {
            NSSound.beep()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.controlBackgroundColor.setFill()
        dirtyRect.fill()
        let text = shortcut.compactDisplayString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.labelColor
        ]
        let size = text.size(withAttributes: attributes)
        text.draw(
            at: NSPoint(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2),
            withAttributes: attributes
        )
    }
}

private extension GlobalKeyboardShortcut.Modifiers {
    init(eventModifierFlags: NSEvent.ModifierFlags) {
        var value: GlobalKeyboardShortcut.Modifiers = []
        if eventModifierFlags.contains(.command) { value.insert(.command) }
        if eventModifierFlags.contains(.option) { value.insert(.option) }
        if eventModifierFlags.contains(.control) { value.insert(.control) }
        if eventModifierFlags.contains(.shift) { value.insert(.shift) }
        self = value
    }
}
