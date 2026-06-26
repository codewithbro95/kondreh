import XCTest
@testable import KondrehCore

@MainActor
final class SettingsServiceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "KondrehTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testPersistsSelectedCamera() {
        let settings = SettingsService(defaults: defaults)
        settings.selectedCameraID = "camera-1"

        let reloaded = SettingsService(defaults: defaults)
        XCTAssertEqual(reloaded.selectedCameraID, "camera-1")
    }

    func testPersistsAspectRatioAndMirrorPreference() {
        let settings = SettingsService(defaults: defaults)
        settings.aspectRatio = .sixteenNine
        settings.mirrorPreview = false

        let reloaded = SettingsService(defaults: defaults)
        XCTAssertEqual(reloaded.aspectRatio, .sixteenNine)
        XCTAssertFalse(reloaded.mirrorPreview)
    }
}
