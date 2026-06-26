import KondrehCore
import SwiftUI

struct PreviewControlsView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService
    @ObservedObject private var cameraManager: CameraManager
    let close: () -> Void

    init(environment: AppEnvironment, close: @escaping () -> Void) {
        self.environment = environment
        self.settings = environment.settings
        self.cameraManager = environment.cameraManager
        self.close = close
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Picker("Camera", selection: cameraSelection) {
                    ForEach(cameraManager.devices) { device in
                        Text(device.name).tag(device.id)
                    }
                }
                .labelsHidden()
                .frame(minWidth: 150)
                .help("Choose camera")
                .accessibilityLabel("Camera")

                Picker("Aspect ratio", selection: aspectRatioSelection) {
                    ForEach(PreviewAspectRatio.allCases) { ratio in
                        Text(ratio.displayName).tag(ratio)
                    }
                }
                .labelsHidden()
                .frame(width: 112)
                .help("Preview aspect ratio")

                Toggle(isOn: $settings.mirrorPreview) {
                    Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
                }
                .toggleStyle(.button)
                .help("Mirror preview")
                .accessibilityLabel("Mirror preview")

                Toggle(isOn: $settings.alwaysOnTop) {
                    Image(systemName: "pin.fill")
                }
                .toggleStyle(.button)
                .help("Keep preview above other windows")
                .accessibilityLabel("Always on top")

                Button {
                    (NSApp.delegate as? AppDelegate)?.showSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .help("Open Settings")
                .accessibilityLabel("Open Settings")

                Button(action: close) {
                    Image(systemName: "xmark")
                }
                .keyboardShortcut(.cancelAction)
                .help("Close preview")
                .accessibilityLabel("Close preview")
            }
        }
    }

    private var cameraSelection: Binding<String> {
        Binding {
            settings.selectedCameraID ?? cameraManager.activeDeviceID ?? cameraManager.devices.first?.id ?? ""
        } set: { newValue in
            guard newValue.isEmpty == false else { return }
            cameraManager.switchCamera(to: newValue)
        }
    }

    private var aspectRatioSelection: Binding<PreviewAspectRatio> {
        Binding {
            settings.aspectRatio
        } set: { ratio in
            settings.aspectRatio = ratio
        }
    }
}
