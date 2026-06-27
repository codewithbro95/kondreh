import KondrehCore
import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService
    @ObservedObject private var launchAtLogin: LaunchAtLoginService

    init(environment: AppEnvironment) {
        self.environment = environment
        self.settings = environment.settings
        self.launchAtLogin = environment.launchAtLoginService
    }

    var body: some View {
        Form {
            Toggle("Launch \(AppConstants.appName) at login", isOn: launchAtLoginBinding)
            LabeledContent("Launch status", value: launchAtLogin.state.displayName)
            Toggle("Reopen the last selected camera", isOn: $settings.reopenLastSelectedCamera)
            Toggle("Always on top by default", isOn: $settings.alwaysOnTop)

            if let error = launchAtLogin.lastError {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding {
            launchAtLogin.state == .enabled
        } set: { enabled in
            settings.launchAtLogin = enabled
            launchAtLogin.setEnabled(enabled)
        }
    }
}
