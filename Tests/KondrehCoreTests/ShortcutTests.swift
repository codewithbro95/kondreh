import XCTest
@testable import KondrehCore

final class ShortcutTests: XCTestCase {
    func testShortcutSerializationRoundTrips() throws {
        let shortcut = GlobalKeyboardShortcut(keyCode: 8, characters: "C", modifiers: [.command, .option])
        let data = try JSONEncoder().encode(shortcut)
        let decoded = try JSONDecoder().decode(GlobalKeyboardShortcut.self, from: data)

        XCTAssertEqual(decoded, shortcut)
        XCTAssertEqual(decoded.displayString, "Option + Command + C")
    }

    func testUnsupportedShortcutWithoutPrimaryModifier() {
        let shortcut = GlobalKeyboardShortcut(keyCode: 8, characters: "C", modifiers: [.shift])
        XCTAssertFalse(shortcut.isSupported)
    }
}
