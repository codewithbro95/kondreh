import Foundation

public enum PreviewAspectRatio: String, CaseIterable, Codable, Identifiable {
    case native
    case sixteenNine
    case fourThree
    case square

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .native: "Camera Native"
        case .sixteenNine: "16:9"
        case .fourThree: "4:3"
        case .square: "1:1"
        }
    }

    public var numericValue: Double? {
        switch self {
        case .native: nil
        case .sixteenNine: 16.0 / 9.0
        case .fourThree: 4.0 / 3.0
        case .square: 1.0
        }
    }
}
