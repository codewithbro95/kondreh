import Foundation

public protocol GlobalShortcutManaging: AnyObject {
    var registrationError: String? { get }
    func register(_ shortcut: GlobalKeyboardShortcut, handler: @escaping () -> Void)
    func unregister()
}
