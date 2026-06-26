import Combine
import Foundation

@MainActor
public final class SettingsService: ObservableObject {
    private enum Key {
        static let selectedCameraID = "selectedCameraID"
        static let mirrorPreview = "mirrorPreview"
        static let aspectRatio = "aspectRatio"
        static let alwaysOnTop = "alwaysOnTop"
        static let closeOnOutsideClick = "closeOnOutsideClick"
        static let launchAtLogin = "launchAtLogin"
        static let showMenuBarIcon = "showMenuBarIcon"
        static let reopenLastSelectedCamera = "reopenLastSelectedCamera"
        static let preferredQuality = "preferredQuality"
        static let showCameraName = "showCameraName"
        static let shortcutEnabled = "shortcutEnabled"
        static let keyboardShortcut = "keyboardShortcut"
        static let appearance = "appearance"
        static let previewCornerRadius = "previewCornerRadius"
        static let onboardingCompleted = "onboardingCompleted"
        static let panelWidth = "panelWidth"
        static let panelHeight = "panelHeight"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    public var selectedCameraID: String? {
        get { defaults.string(forKey: Key.selectedCameraID) }
        set {
            defaults.set(newValue, forKey: Key.selectedCameraID)
            objectWillChange.send()
        }
    }

    public var mirrorPreview: Bool {
        get { defaults.bool(forKey: Key.mirrorPreview) }
        set { set(newValue, for: Key.mirrorPreview) }
    }

    public var aspectRatio: PreviewAspectRatio {
        get { enumValue(for: Key.aspectRatio, default: .native) }
        set { setEnum(newValue, for: Key.aspectRatio) }
    }

    public var alwaysOnTop: Bool {
        get { defaults.bool(forKey: Key.alwaysOnTop) }
        set { set(newValue, for: Key.alwaysOnTop) }
    }

    public var closeOnOutsideClick: Bool {
        get { defaults.bool(forKey: Key.closeOnOutsideClick) }
        set { set(newValue, for: Key.closeOnOutsideClick) }
    }

    public var launchAtLogin: Bool {
        get { defaults.bool(forKey: Key.launchAtLogin) }
        set { set(newValue, for: Key.launchAtLogin) }
    }

    public var showMenuBarIcon: Bool {
        get { defaults.bool(forKey: Key.showMenuBarIcon) }
        set { set(newValue, for: Key.showMenuBarIcon) }
    }

    public var reopenLastSelectedCamera: Bool {
        get { defaults.bool(forKey: Key.reopenLastSelectedCamera) }
        set { set(newValue, for: Key.reopenLastSelectedCamera) }
    }

    public var preferredQuality: PreviewQuality {
        get { enumValue(for: Key.preferredQuality, default: .balanced) }
        set { setEnum(newValue, for: Key.preferredQuality) }
    }

    public var showCameraName: Bool {
        get { defaults.bool(forKey: Key.showCameraName) }
        set { set(newValue, for: Key.showCameraName) }
    }

    public var shortcutEnabled: Bool {
        get { defaults.bool(forKey: Key.shortcutEnabled) }
        set { set(newValue, for: Key.shortcutEnabled) }
    }

    public var keyboardShortcut: GlobalKeyboardShortcut {
        get {
            guard let data = defaults.data(forKey: Key.keyboardShortcut),
                  let decoded = try? JSONDecoder().decode(GlobalKeyboardShortcut.self, from: data),
                  decoded.isSupported else {
                return GlobalKeyboardShortcut.default
            }
            return decoded
        }
        set {
            let value = newValue.isSupported ? newValue : GlobalKeyboardShortcut.default
            if let data = try? JSONEncoder().encode(value) {
                defaults.set(data, forKey: Key.keyboardShortcut)
            }
            objectWillChange.send()
        }
    }

    public var appearance: AppAppearance {
        get { enumValue(for: Key.appearance, default: .system) }
        set { setEnum(newValue, for: Key.appearance) }
    }

    public var previewCornerRadius: Double {
        get { defaults.double(forKey: Key.previewCornerRadius) }
        set { set(max(0, min(newValue, 28)), for: Key.previewCornerRadius) }
    }

    public var onboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.onboardingCompleted) }
        set { set(newValue, for: Key.onboardingCompleted) }
    }

    public var panelSize: CGSizeValue {
        get {
            CGSizeValue(
                width: max(defaults.double(forKey: Key.panelWidth), AppConstants.minimumPanelWidth),
                height: max(defaults.double(forKey: Key.panelHeight), AppConstants.minimumPanelHeight)
            )
        }
        set {
            defaults.set(max(newValue.width, AppConstants.minimumPanelWidth), forKey: Key.panelWidth)
            defaults.set(max(newValue.height, AppConstants.minimumPanelHeight), forKey: Key.panelHeight)
            objectWillChange.send()
        }
    }

    public func restoreDefaultShortcut() {
        keyboardShortcut = .default
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Key.mirrorPreview: true,
            Key.aspectRatio: PreviewAspectRatio.native.rawValue,
            Key.alwaysOnTop: false,
            Key.closeOnOutsideClick: false,
            Key.launchAtLogin: false,
            Key.showMenuBarIcon: true,
            Key.reopenLastSelectedCamera: true,
            Key.preferredQuality: PreviewQuality.balanced.rawValue,
            Key.showCameraName: true,
            Key.shortcutEnabled: true,
            Key.appearance: AppAppearance.system.rawValue,
            Key.previewCornerRadius: 12.0,
            Key.onboardingCompleted: false,
            Key.panelWidth: AppConstants.defaultPanelWidth,
            Key.panelHeight: AppConstants.defaultPanelHeight
        ])
    }

    private func set(_ value: Bool, for key: String) {
        defaults.set(value, forKey: key)
        objectWillChange.send()
    }

    private func set(_ value: Double, for key: String) {
        defaults.set(value, forKey: key)
        objectWillChange.send()
    }

    private func enumValue<T: RawRepresentable>(for key: String, default defaultValue: T) -> T where T.RawValue == String {
        guard let rawValue = defaults.string(forKey: key),
              let value = T(rawValue: rawValue) else {
            return defaultValue
        }
        return value
    }

    private func setEnum<T: RawRepresentable>(_ value: T, for key: String) where T.RawValue == String {
        defaults.set(value.rawValue, forKey: key)
        objectWillChange.send()
    }
}

public struct CGSizeValue: Codable, Equatable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}
