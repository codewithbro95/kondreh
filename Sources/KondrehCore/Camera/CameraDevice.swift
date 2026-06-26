import Foundation

public struct CameraDevice: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let isContinuityCamera: Bool
    public let isBuiltIn: Bool

    public init(id: String, name: String, isContinuityCamera: Bool = false, isBuiltIn: Bool = false) {
        self.id = id
        self.name = name
        self.isContinuityCamera = isContinuityCamera
        self.isBuiltIn = isBuiltIn
    }
}
