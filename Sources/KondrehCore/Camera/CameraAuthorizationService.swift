import AVFoundation
import Foundation

public protocol CameraAuthorizing {
    func currentState() -> CameraPermissionState
    func requestAccess() async -> CameraPermissionState
}

public struct CameraAuthorizationService: CameraAuthorizing, Sendable {
    public init() {}

    public func currentState() -> CameraPermissionState {
        CameraPermissionState(status: AVCaptureDevice.authorizationStatus(for: .video))
    }

    public func requestAccess() async -> CameraPermissionState {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                let state = CameraPermissionState(status: AVCaptureDevice.authorizationStatus(for: .video))
                continuation.resume(returning: granted ? .authorized : state)
            }
        }
    }
}
