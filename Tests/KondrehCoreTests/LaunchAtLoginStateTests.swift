import XCTest
@testable import KondrehCore

final class LaunchAtLoginStateTests: XCTestCase {
    func testLaunchAtLoginStateMapping() {
        XCTAssertEqual(LaunchAtLoginStatusMapper.map(.enabled), .enabled)
        XCTAssertEqual(LaunchAtLoginStatusMapper.map(.notRegistered), .disabled)
        XCTAssertEqual(LaunchAtLoginStatusMapper.map(.requiresApproval), .requiresApproval)
        XCTAssertEqual(LaunchAtLoginStatusMapper.map(.notFound), .unavailable)
    }
}
