import Foundation
import os

public enum AppLogger {
    public static let camera = Logger(subsystem: AppConstants.bundleIdentifier, category: "Camera")
    public static let app = Logger(subsystem: AppConstants.bundleIdentifier, category: "App")
    public static let shortcut = Logger(subsystem: AppConstants.bundleIdentifier, category: "Shortcut")
}
