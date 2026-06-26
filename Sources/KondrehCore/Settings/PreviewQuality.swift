import Foundation

public enum PreviewQuality: String, CaseIterable, Codable, Identifiable {
    case efficient
    case balanced
    case high

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .efficient: "Efficient"
        case .balanced: "Balanced"
        case .high: "High"
        }
    }
}
