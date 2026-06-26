import KondrehCore
import SwiftUI

struct CameraSettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService
    @ObservedObject private var cameraManager: CameraManager

    init(environment: AppEnvironment) {
        self.environment = environment
        self.settings = environment.settings
        self.cameraManager = environment.cameraManager
    }

    var body: some View {
        Form {
            Picker("Default camera", selection: selectedCamera) {
                Text("System Default").tag("")
                ForEach(cameraManager.devices) { device in
                    Text(device.name).tag(device.id)
                }
            }

            Toggle("Mirror preview", isOn: $settings.mirrorPreview)

            Picker("Default aspect ratio", selection: $settings.aspectRatio) {
                ForEach(PreviewAspectRatio.allCases) { ratio in
                    Text(ratio.displayName).tag(ratio)
                }
            }

            Picker("Preferred preview quality", selection: $settings.preferredQuality) {
                ForEach(PreviewQuality.allCases) { quality in
                    Text(quality.displayName).tag(quality)
                }
            }

            Toggle("Show camera name in preview", isOn: $settings.showCameraName)

            Button("Refresh Camera List") {
                cameraManager.refreshDevices()
            }
        }
        .formStyle(.grouped)
    }

    private var selectedCamera: Binding<String> {
        Binding {
            settings.selectedCameraID ?? ""
        } set: { value in
            settings.selectedCameraID = value.isEmpty ? nil : value
        }
    }
}
