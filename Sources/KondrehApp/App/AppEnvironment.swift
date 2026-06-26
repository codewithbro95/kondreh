import Foundation
import KondrehCore

@MainActor
final class AppEnvironment: ObservableObject {
    static let shared = AppEnvironment()

    let settings: SettingsService
    let cameraAuthorization: CameraAuthorizationService
    let cameraManager: CameraManager
    let launchAtLoginService: LaunchAtLoginService
    let updateProvider: UpdateProviding
    let licenseProvider: LicenseProviding

    private init() {
        let settings = SettingsService()
        self.settings = settings
        self.cameraAuthorization = CameraAuthorizationService()
        self.cameraManager = CameraManager(settings: settings)
        self.launchAtLoginService = LaunchAtLoginService()
        self.updateProvider = DevelopmentUpdateProvider()
        self.licenseProvider = LocalDevelopmentLicenseProvider()
    }
}
