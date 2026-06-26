import Foundation

public enum PreviewLifecycleEvent {
    case open
    case authorizationResolved(CameraPermissionState)
    case devicesResolved(hasDevices: Bool)
    case startSucceeded
    case startFailed(String)
    case stop
}

public enum PreviewLifecycleReducer {
    public static func reduce(_ state: CameraSessionState, event: PreviewLifecycleEvent) -> CameraSessionState {
        switch event {
        case .open:
            return .starting
        case .authorizationResolved(.authorized):
            return .discoveringDevices
        case .authorizationResolved(.notDetermined):
            return .requestingPermission
        case .authorizationResolved(.denied):
            return .permissionDenied
        case .authorizationResolved(.restricted):
            return .permissionRestricted
        case .devicesResolved(let hasDevices):
            return hasDevices ? .starting : .noDevice
        case .startSucceeded:
            return .running
        case .startFailed(let message):
            return .failed(message)
        case .stop:
            return state == .idle ? .idle : .stopping
        }
    }
}
