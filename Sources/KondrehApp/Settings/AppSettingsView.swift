import KondrehCore
import SwiftUI

struct AppSettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService

    init(environment: AppEnvironment) {
        self.environment = environment
        self.settings = environment.settings
    }

    var body: some View {
        TabView {
            GeneralSettingsView(environment: environment)
                .tabItem { Label("General", systemImage: "gearshape") }
            CameraSettingsView(environment: environment)
                .tabItem { Label("Camera", systemImage: "video") }
            KeyboardSettingsView(environment: environment)
                .tabItem { Label("Keyboard", systemImage: "keyboard") }
            AppearanceSettingsView(settings: settings)
                .tabItem { Label("Appearance", systemImage: "circle.lefthalf.filled") }
            PrivacySettingsView(environment: environment)
                .tabItem { Label("Privacy", systemImage: "hand.raised") }
            AboutSettingsView(environment: environment)
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .padding(20)
        .preferredColorScheme(settings.appearance.colorScheme)
    }
}
