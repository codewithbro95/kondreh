import XCTest
@testable import KondrehCore

final class PreviewViewModelTests: XCTestCase {
    func testPreviewLifecycleTransitions() {
        XCTAssertEqual(PreviewLifecycleReducer.reduce(.idle, event: .open), .starting)
        XCTAssertEqual(PreviewLifecycleReducer.reduce(.starting, event: .authorizationResolved(.denied)), .permissionDenied)
        XCTAssertEqual(PreviewLifecycleReducer.reduce(.discoveringDevices, event: .devicesResolved(hasDevices: false)), .noDevice)
        XCTAssertEqual(PreviewLifecycleReducer.reduce(.starting, event: .startSucceeded), .running)
        XCTAssertEqual(PreviewLifecycleReducer.reduce(.running, event: .stop), .stopping)
    }
}
