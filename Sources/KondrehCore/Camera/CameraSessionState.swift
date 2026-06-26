import Foundation

public enum CameraSessionState: Equatable {
    case idle
    case requestingPermission
    case permissionDenied
    case permissionRestricted
    case discoveringDevices
    case starting
    case running
    case switchingDevice
    case noDevice
    case failed(String)
    case stopping

    public var isActive: Bool {
        switch self {
        case .starting, .running, .switchingDevice:
            true
        default:
            false
        }
    }
}
