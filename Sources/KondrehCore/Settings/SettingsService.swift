import Combine
import Foundation

public enum MenuBarIconStyle: String, CaseIterable, Codable, Identifiable {
    case video
    case camera
    case lens
    case aperture
    case viewfinder
    case compact

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .video: "Default"
        case .camera: "Camera"
        case .lens: "Lens"
        case .aperture: "Aperture"
        case .viewfinder: "Frame"
        case .compact: "Dot"
        }
    }

    public var symbolName: String {
        switch self {
        case .video: "video.fill"
        case .camera: "camera.fill"
        case .lens: "circle.circle.fill"
        case .aperture: "circle.fill"
        case .viewfinder: "viewfinder"
        case .compact: "record.circle"
        }
    }
}

public enum WindowMaskStyle: String, CaseIterable, Codable, Identifiable {
    case rounded
    case square
    case circle

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .rounded: "Rounded"
        case .square: "Square"
        case .circle: "Circle"
        }
    }
}

public enum AppIconStyle: String, CaseIterable, Codable, Identifiable {
    case standard
    case focus
    case studio
    case midnight
    case classic
    case soft

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .standard: "Standard"
        case .focus: "Focus"
        case .studio: "Studio"
        case .midnight: "Midnight"
        case .classic: "Classic"
        case .soft: "Soft"
        }
    }

    public var symbolName: String {
        switch self {
        case .standard: "app.fill"
        case .focus: "camera.aperture"
        case .studio: "video.square.fill"
        case .midnight: "moon.stars.fill"
        case .classic: "rectangle.inset.filled"
        case .soft: "sparkles"
        }
    }
}

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
        static let showDockIcon = "showDockIcon"
        static let menuBarIconStyle = "menuBarIconStyle"
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
        static let lockAspectRatio = "lockAspectRatio"
        static let manualWindowPosition = "manualWindowPosition"
        static let windowMaskStyle = "windowMaskStyle"
        static let maskZoom = "maskZoom"
        static let maskRotation = "maskRotation"
        static let notchTriggerEnabled = "notchTriggerEnabled"
        static let hideMenuBarIconForNotch = "hideMenuBarIconForNotch"
        static let micCheckEnabled = "micCheckEnabled"
        static let micCheckHoverOnly = "micCheckHoverOnly"
        static let reactionsEnabled = "reactionsEnabled"
        static let alternateAppIconStyle = "alternateAppIconStyle"
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

    public var showDockIcon: Bool {
        get { defaults.bool(forKey: Key.showDockIcon) }
        set { set(newValue, for: Key.showDockIcon) }
    }

    public var menuBarIconStyle: MenuBarIconStyle {
        get { enumValue(for: Key.menuBarIconStyle, default: .video) }
        set { setEnum(newValue, for: Key.menuBarIconStyle) }
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

    public var lockAspectRatio: Bool {
        get { defaults.bool(forKey: Key.lockAspectRatio) }
        set { set(newValue, for: Key.lockAspectRatio) }
    }

    public var manualWindowPosition: Bool {
        get { defaults.bool(forKey: Key.manualWindowPosition) }
        set { set(newValue, for: Key.manualWindowPosition) }
    }

    public var windowMaskStyle: WindowMaskStyle {
        get { enumValue(for: Key.windowMaskStyle, default: .rounded) }
        set { setEnum(newValue, for: Key.windowMaskStyle) }
    }

    public var maskZoom: Double {
        get { defaults.double(forKey: Key.maskZoom) }
        set { set(max(1.0, min(newValue, 3.0)), for: Key.maskZoom) }
    }

    public var maskRotation: Double {
        get { defaults.double(forKey: Key.maskRotation) }
        set { set(max(0, min(newValue, 270)), for: Key.maskRotation) }
    }

    public var notchTriggerEnabled: Bool {
        get { defaults.bool(forKey: Key.notchTriggerEnabled) }
        set { set(newValue, for: Key.notchTriggerEnabled) }
    }

    public var hideMenuBarIconForNotch: Bool {
        get { defaults.bool(forKey: Key.hideMenuBarIconForNotch) }
        set { set(newValue, for: Key.hideMenuBarIconForNotch) }
    }

    public var micCheckEnabled: Bool {
        get { defaults.bool(forKey: Key.micCheckEnabled) }
        set { set(newValue, for: Key.micCheckEnabled) }
    }

    public var micCheckHoverOnly: Bool {
        get { defaults.bool(forKey: Key.micCheckHoverOnly) }
        set { set(newValue, for: Key.micCheckHoverOnly) }
    }

    public var reactionsEnabled: Bool {
        get { defaults.bool(forKey: Key.reactionsEnabled) }
        set { set(newValue, for: Key.reactionsEnabled) }
    }

    public var alternateAppIconStyle: AppIconStyle {
        get { enumValue(for: Key.alternateAppIconStyle, default: .standard) }
        set { setEnum(newValue, for: Key.alternateAppIconStyle) }
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
            Key.showDockIcon: false,
            Key.menuBarIconStyle: MenuBarIconStyle.video.rawValue,
            Key.reopenLastSelectedCamera: true,
            Key.preferredQuality: PreviewQuality.balanced.rawValue,
            Key.showCameraName: true,
            Key.shortcutEnabled: true,
            Key.appearance: AppAppearance.system.rawValue,
            Key.previewCornerRadius: 12.0,
            Key.onboardingCompleted: false,
            Key.panelWidth: AppConstants.defaultPanelWidth,
            Key.panelHeight: AppConstants.defaultPanelHeight,
            Key.lockAspectRatio: false,
            Key.manualWindowPosition: false,
            Key.windowMaskStyle: WindowMaskStyle.rounded.rawValue,
            Key.maskZoom: 1.0,
            Key.maskRotation: 0.0,
            Key.notchTriggerEnabled: false,
            Key.hideMenuBarIconForNotch: false,
            Key.micCheckEnabled: false,
            Key.micCheckHoverOnly: true,
            Key.reactionsEnabled: false,
            Key.alternateAppIconStyle: AppIconStyle.standard.rawValue
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
