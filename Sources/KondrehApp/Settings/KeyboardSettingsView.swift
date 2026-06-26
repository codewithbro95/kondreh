import KondrehCore
import SwiftUI

struct KeyboardSettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService

    init(environment: AppEnvironment) {
        self.environment = environment
        self.settings = environment.settings
    }

    var body: some View {
        Form {
            Toggle("Enable global shortcut", isOn: shortcutEnabled)

            HStack {
                Text("Shortcut")
                Spacer()
                ShortcutRecorderView(shortcut: shortcut)
                    .frame(width: 150, height: 30)
                    .help("Click, then press a supported shortcut")
            }
            .disabled(settings.shortcutEnabled == false)

            Button("Restore Default Shortcut") {
                settings.restoreDefaultShortcut()
                (NSApp.delegate as? AppDelegate)?.configureShortcut()
            }

            Text("Unsupported shortcuts must include Command, Option, or Control with a character key.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
    }

    private var shortcutEnabled: Binding<Bool> {
        Binding {
            settings.shortcutEnabled
        } set: { enabled in
            settings.shortcutEnabled = enabled
            (NSApp.delegate as? AppDelegate)?.configureShortcut()
        }
    }

    private var shortcut: Binding<GlobalKeyboardShortcut> {
        Binding {
            settings.keyboardShortcut
        } set: { newValue in
            settings.keyboardShortcut = newValue
            (NSApp.delegate as? AppDelegate)?.configureShortcut()
        }
    }
}
