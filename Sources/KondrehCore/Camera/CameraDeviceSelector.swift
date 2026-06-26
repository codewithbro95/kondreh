import Foundation

public enum CameraDeviceSelector {
    public static func preferredDevice(
        from devices: [CameraDevice],
        selectedID: String?,
        reopenLastSelectedCamera: Bool
    ) -> CameraDevice? {
        if reopenLastSelectedCamera,
           let selectedID,
           let selected = devices.first(where: { $0.id == selectedID }) {
            return selected
        }

        if let builtIn = devices.first(where: \.isBuiltIn) {
            return builtIn
        }

        return devices.first
    }
}
