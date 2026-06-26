import Foundation

public protocol LicenseProviding: AnyObject {
    var currentState: LicenseState { get }
    func activate(licenseKey: String) async -> LicenseState
    func deactivate() async
    func restorePurchase() async -> LicenseState
    func beginTrial() async -> LicenseState
    func remainingTrialDuration(from date: Date) -> TimeInterval?
}
