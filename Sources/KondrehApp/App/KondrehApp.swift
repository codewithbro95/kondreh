import SwiftUI

@main
struct KondrehApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var environment = AppEnvironment.shared

    var body: some Scene {
        Settings {
            AppSettingsView(environment: environment)
                .frame(width: 760, height: 600)
        }
    }
}
