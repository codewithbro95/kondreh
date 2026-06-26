import Foundation

public enum LaunchAtLoginState: String, Equatable {
    case enabled
    case disabled
    case requiresApproval
    case unavailable
    case failed

    public var displayName: String {
        switch self {
        case .enabled: "Enabled"
        case .disabled: "Disabled"
        case .requiresApproval: "Requires Approval"
        case .unavailable: "Unavailable"
        case .failed: "Failed"
        }
    }
}
