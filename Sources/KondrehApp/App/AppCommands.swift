import AppKit

enum AppCommands {
    static func quit() {
        NSApp.terminate(nil)
    }
}
