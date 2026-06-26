import AVFoundation
import XCTest
@testable import KondrehCore

final class CameraAuthorizationServiceTests: XCTestCase {
    func testPermissionStateMapping() {
        XCTAssertEqual(CameraPermissionState(status: .authorized), .authorized)
        XCTAssertEqual(CameraPermissionState(status: .notDetermined), .notDetermined)
        XCTAssertEqual(CameraPermissionState(status: .denied), .denied)
        XCTAssertEqual(CameraPermissionState(status: .restricted), .restricted)
    }
}
