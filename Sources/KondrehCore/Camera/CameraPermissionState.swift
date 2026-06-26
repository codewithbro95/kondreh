import AVFoundation
import Foundation

public enum CameraPermissionState: String, Codable, Equatable {
    case authorized
    case notDetermined
    case denied
    case restricted

    public init(status: AVAuthorizationStatus) {
        switch status {
        case .authorized:
            self = .authorized
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        @unknown default:
            self = .restricted
        }
    }

    public var displayName: String {
        switch self {
        case .authorized: "Allowed"
        case .notDetermined: "Not Requested"
        case .denied: "Denied"
        case .restricted: "Restricted"
        }
    }
}
