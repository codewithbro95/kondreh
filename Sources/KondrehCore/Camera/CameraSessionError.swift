import Foundation

public enum CameraSessionError: LocalizedError, Equatable {
    case permissionDenied
    case permissionRestricted
    case noCameraAvailable
    case deviceUnavailable
    case cannotCreateInput
    case cannotAddInput
    case configurationFailed

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Camera access is turned off for Kondreh."
        case .permissionRestricted:
            "Camera access is restricted by macOS or an administrator."
        case .noCameraAvailable:
            "No camera is connected."
        case .deviceUnavailable:
            "The selected camera is unavailable."
        case .cannotCreateInput, .cannotAddInput, .configurationFailed:
            "Kondreh could not start the camera preview."
        }
    }
}
