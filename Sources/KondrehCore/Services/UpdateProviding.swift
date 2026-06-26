import Foundation

public enum UpdateCheckResult: Equatable {
    case disabled
    case upToDate
    case updateAvailable(version: String)
    case failed(String)
}

public protocol UpdateProviding {
    func checkForUpdates() async -> UpdateCheckResult
}

public struct DevelopmentUpdateProvider: UpdateProviding {
    public init() {}

    public func checkForUpdates() async -> UpdateCheckResult {
        .disabled
    }
}
