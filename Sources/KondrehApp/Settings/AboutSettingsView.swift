import KondrehCore
import SwiftUI

struct AboutSettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var licenseState: LicenseState = .unknown

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: AppConstants.menuBarSymbolName)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(AppConstants.appName)
                    .font(.title2.weight(.semibold))
                Text(AppConstants.tagline)
                    .foregroundStyle(.secondary)
            }

            Form {
                LabeledContent("Version", value: version)
                LabeledContent("Build", value: build)
                LabeledContent("Developer", value: AppConstants.developerName)
                LabeledContent("License", value: licenseState.displayName)
                LabeledContent("Price", value: AppConstants.price)
                Link("Website", destination: URL(string: AppConstants.websiteURLString) ?? URL(string: "https://example.com")!)
                Link("Support Email", destination: URL(string: "mailto:\(AppConstants.supportEmail)")!)
            }
            .formStyle(.grouped)
        }
        .padding(.top, 8)
        .task {
            licenseState = environment.licenseProvider.currentState
        }
    }

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
