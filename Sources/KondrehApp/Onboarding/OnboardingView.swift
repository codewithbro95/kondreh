import KondrehCore
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var environment: AppEnvironment
    let finish: () -> Void
    @State private var selection = 0

    private let pages = [
        OnboardingPage(
            symbolName: "video.fill",
            title: "Check your camera before the call starts.",
            message: AppConstants.tagline
        ),
        OnboardingPage(
            symbolName: "lock.shield.fill",
            title: "Your preview stays on your Mac.",
            message: "Nothing is recorded or uploaded."
        ),
        OnboardingPage(
            symbolName: "keyboard",
            title: "Open Kondreh instantly.",
            message: "Allow camera access when you are ready, then use \(GlobalKeyboardShortcut.default.displayString) to toggle the preview."
        )
    ]

    var body: some View {
        VStack(spacing: 20) {
            TabView(selection: $selection) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 16) {
                        Image(systemName: page.symbolName)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(.tint)
                        Text(page.title)
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)
                        Text(page.message)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                    }
                    .tag(index)
                    .padding()
                }
            }
            .tabViewStyle(.automatic)

            HStack {
                Button("Skip") {
                    complete()
                }
                Spacer()
                if selection == pages.count - 1 {
                    Button("Allow Camera Access") {
                        environment.cameraManager.requestPermissionAndStart()
                        complete()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Continue") {
                        selection += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(24)
        .frame(width: 460, height: 360)
    }

    private func complete() {
        environment.settings.onboardingCompleted = true
        finish()
    }
}
