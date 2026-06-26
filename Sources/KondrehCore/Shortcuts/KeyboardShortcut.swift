import Foundation

public struct GlobalKeyboardShortcut: Codable, Equatable, Hashable {
    public struct Modifiers: OptionSet, Codable, Hashable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let command = Modifiers(rawValue: 1 << 0)
        public static let option = Modifiers(rawValue: 1 << 1)
        public static let control = Modifiers(rawValue: 1 << 2)
        public static let shift = Modifiers(rawValue: 1 << 3)
    }

    public let keyCode: UInt32
    public let characters: String
    public let modifiers: Modifiers

    public init(keyCode: UInt32, characters: String, modifiers: Modifiers) {
        self.keyCode = keyCode
        self.characters = characters.uppercased()
        self.modifiers = modifiers
    }

    public static let `default` = GlobalKeyboardShortcut(
        keyCode: 40,
        characters: "K",
        modifiers: [.command, .option, .control]
    )

    public var isSupported: Bool {
        !characters.isEmpty && modifiers.intersection([.command, .option, .control]).isEmpty == false
    }

    public var displayString: String {
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("Control") }
        if modifiers.contains(.option) { parts.append("Option") }
        if modifiers.contains(.shift) { parts.append("Shift") }
        if modifiers.contains(.command) { parts.append("Command") }
        parts.append(characters)
        return parts.joined(separator: " + ")
    }

    public var compactDisplayString: String {
        var result = ""
        if modifiers.contains(.control) { result += "⌃" }
        if modifiers.contains(.option) { result += "⌥" }
        if modifiers.contains(.shift) { result += "⇧" }
        if modifiers.contains(.command) { result += "⌘" }
        result += characters
        return result
    }
}
