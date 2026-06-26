import Foundation

public enum LaunchAtLoginSystemStatus {
    case enabled
    case notRegistered
    case requiresApproval
    case notFound
    case unknown
}

public enum LaunchAtLoginStatusMapper {
    public static func map(_ status: LaunchAtLoginSystemStatus) -> LaunchAtLoginState {
        switch status {
        case .enabled:
            .enabled
        case .notRegistered:
            .disabled
        case .requiresApproval:
            .requiresApproval
        case .notFound:
            .unavailable
        case .unknown:
            .unavailable
        }
    }
}
