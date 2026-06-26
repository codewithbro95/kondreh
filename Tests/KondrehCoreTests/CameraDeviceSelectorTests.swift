import XCTest
@testable import KondrehCore

final class CameraDeviceSelectorTests: XCTestCase {
    func testUsesPersistedCameraWhenAvailable() {
        let devices = [
            CameraDevice(id: "built-in", name: "FaceTime HD", isBuiltIn: true),
            CameraDevice(id: "usb", name: "USB Camera")
        ]

        XCTAssertEqual(
            CameraDeviceSelector.preferredDevice(from: devices, selectedID: "usb", reopenLastSelectedCamera: true)?.id,
            "usb"
        )
    }

    func testFallsBackToBuiltInWhenSelectedCameraIsGone() {
        let devices = [
            CameraDevice(id: "built-in", name: "FaceTime HD", isBuiltIn: true),
            CameraDevice(id: "usb", name: "USB Camera")
        ]

        XCTAssertEqual(
            CameraDeviceSelector.preferredDevice(from: devices, selectedID: "missing", reopenLastSelectedCamera: true)?.id,
            "built-in"
        )
    }
}
