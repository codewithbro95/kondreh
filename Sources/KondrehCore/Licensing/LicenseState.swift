import Foundation

public enum LicenseState: Equatable {
    case trial(remainingDays: Int)
    case licensed
    case expired
    case invalid
    case unknown

    public var displayName: String {
        switch self {
        case .trial(let remainingDays):
            "Trial: \(remainingDays) day\(remainingDays == 1 ? "" : "s") remaining"
        case .licensed:
            "Licensed"
        case .expired:
            "Trial Expired"
        case .invalid:
            "Invalid License"
        case .unknown:
            "Unknown"
        }
    }

    public var permitsPreview: Bool {
        switch self {
        case .trial(let days):
            days >= 0
        case .licensed:
            true
        case .expired, .invalid, .unknown:
            false
        }
    }
}
