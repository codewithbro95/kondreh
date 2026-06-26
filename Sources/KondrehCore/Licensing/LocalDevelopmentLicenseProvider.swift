import Foundation

public final class LocalDevelopmentLicenseProvider: LicenseProviding {
    private enum Key {
        static let trialStart = "license.trialStart"
        static let isLicensed = "license.isLicensed"
    }

    private let defaults: UserDefaults
    private let trialLength: TimeInterval
    private let calendar: Calendar

    public init(
        defaults: UserDefaults = .standard,
        trialLength: TimeInterval = 7 * 24 * 60 * 60,
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.trialLength = trialLength
        self.calendar = calendar
    }

    public var currentState: LicenseState {
        if defaults.bool(forKey: Key.isLicensed) {
            return .licensed
        }

        guard let start = defaults.object(forKey: Key.trialStart) as? Date else {
            return .unknown
        }

        guard let remaining = remainingTrialDuration(from: Date()) else {
            return .expired
        }

        let remainingDays = max(0, Int(ceil(remaining / (24 * 60 * 60))))
        if Date().timeIntervalSince(start) > trialLength {
            return .expired
        }
        return .trial(remainingDays: remainingDays)
    }

    public func activate(licenseKey: String) async -> LicenseState {
        guard licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return .invalid
        }
        defaults.set(true, forKey: Key.isLicensed)
        return .licensed
    }

    public func deactivate() async {
        defaults.set(false, forKey: Key.isLicensed)
    }

    public func restorePurchase() async -> LicenseState {
        currentState
    }

    public func beginTrial() async -> LicenseState {
        if defaults.object(forKey: Key.trialStart) == nil {
            defaults.set(Date(), forKey: Key.trialStart)
        }
        return currentState
    }

    public func remainingTrialDuration(from date: Date) -> TimeInterval? {
        guard let start = defaults.object(forKey: Key.trialStart) as? Date else {
            return nil
        }
        let elapsed = date.timeIntervalSince(start)
        let remaining = trialLength - elapsed
        return remaining >= 0 ? remaining : nil
    }
}
