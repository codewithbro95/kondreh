import AVFoundation
import KondrehCore
import SwiftUI

struct PrivacySettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var permissionState = CameraAuthorizationService().currentState()

    var body: some View {
        Form {
            LabeledContent("Camera permission", value: permissionState.displayName)

            Text("\(AppConstants.appName) works locally. It displays camera frames in a private preview layer, does not record video, does not capture still images, does not request microphone access, and does not upload camera frames.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack {
                Button("Open Privacy Settings") {
                    SystemSettingsOpener.openCameraPrivacy()
                }

                Button("Refresh Status") {
                    permissionState = CameraAuthorizationService().currentState()
                }
            }

            Button("Open Privacy Policy") {
                if let url = URL(string: AppConstants.privacyPolicyURLString), url.scheme?.hasPrefix("http") == true {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .formStyle(.grouped)
    }
}
