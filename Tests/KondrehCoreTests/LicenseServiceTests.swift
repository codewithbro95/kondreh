import XCTest
@testable import KondrehCore

final class LicenseServiceTests: XCTestCase {
    func testTrialDurationCalculatesRemainingTime() async {
        let defaults = UserDefaults(suiteName: "KondrehLicenseTests-\(UUID().uuidString)")!
        let provider = LocalDevelopmentLicenseProvider(defaults: defaults, trialLength: 7 * 24 * 60 * 60)

        _ = await provider.beginTrial()

        XCTAssertNotNil(provider.remainingTrialDuration(from: Date()))
        if case .trial(let days) = provider.currentState {
            XCTAssertGreaterThanOrEqual(days, 6)
        } else {
            XCTFail("Expected trial state")
        }
    }
}
