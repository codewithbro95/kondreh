import KondrehCore
import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var settings: SettingsService

    var body: some View {
        Form {
            Picker("Appearance", selection: $settings.appearance) {
                ForEach(AppAppearance.allCases) { appearance in
                    Text(appearance.displayName).tag(appearance)
                }
            }

            HStack {
                Slider(value: $settings.previewCornerRadius, in: 0...28, step: 1) {
                    Text("Preview corner radius")
                }
                Text("\(Int(settings.previewCornerRadius)) pt")
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .trailing)
            }
        }
        .formStyle(.grouped)
    }
}
