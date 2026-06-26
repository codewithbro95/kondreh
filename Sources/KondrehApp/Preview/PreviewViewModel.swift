import Combine
import KondrehCore
import SwiftUI

@MainActor
final class PreviewViewModel: ObservableObject {
    @Published var licenseState: LicenseState = .unknown

    let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
        self.licenseState = environment.licenseProvider.currentState
    }

    func refreshLicense() {
        licenseState = environment.licenseProvider.currentState
    }
}
