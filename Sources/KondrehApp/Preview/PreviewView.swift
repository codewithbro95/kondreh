import AppKit
import KondrehCore
import SwiftUI

struct PreviewView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService
    @ObservedObject private var cameraManager: CameraManager
    @StateObject private var viewModel: PreviewViewModel
    @State private var snapshotMessage: String?
    let close: () -> Void

    init(environment: AppEnvironment, close: @escaping () -> Void) {
        self.environment = environment
        self.settings = environment.settings
        self.cameraManager = environment.cameraManager
        self._viewModel = StateObject(wrappedValue: PreviewViewModel(environment: environment))
        self.close = close
    }

    var body: some View {
        previewStage
            .background(.clear)
            .preferredColorScheme(settings.appearance.colorScheme)
            .task {
                viewModel.refreshLicense()
            }
    }

    private var previewStage: some View {
        ZStack(alignment: .topTrailing) {
            previewContent
                .scaleEffect(settings.maskZoom)
                .rotationEffect(.degrees(settings.maskRotation))
                .clipShape(RoundedRectangle(cornerRadius: previewCornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: previewCornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.34), radius: 18, y: 10)

            if cameraManager.state == .running {
                statusPill
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            PreviewGearMenu(environment: environment, close: close)
                .padding(10)

            quickPictureButton
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            if settings.showCameraName, let device = cameraManager.devices.first(where: { $0.id == cameraManager.activeDeviceID }) {
                Text(device.name)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.42), in: Capsule())
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .opacity(0)
                    .accessibilityLabel("Active camera: \(device.name)")
            }

            if settings.micCheckEnabled {
                audioPulse
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }

            if settings.reactionsEnabled {
                reactionHints
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }

            if let snapshotMessage {
                Text(snapshotMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.55), in: Capsule())
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.opacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: previewCornerRadius, style: .continuous))
    }

    private var previewCornerRadius: CGFloat {
        switch settings.windowMaskStyle {
        case .rounded:
            CGFloat(settings.previewCornerRadius)
        case .square:
            0
        case .circle:
            1000
        }
    }

    @ViewBuilder
    private var previewContent: some View {
        if viewModel.licenseState.permitsPreview == false {
            PurchaseView(licenseState: viewModel.licenseState)
        } else {
            switch cameraManager.state {
            case .idle, .discoveringDevices, .starting, .switchingDevice:
                loadingView
            case .requestingPermission:
                PermissionView(kind: .notDetermined) {
                    cameraManager.requestPermissionAndStart()
                }
            case .permissionDenied:
                PermissionView(kind: .denied) {
                    SystemSettingsOpener.openCameraPrivacy()
                }
            case .permissionRestricted:
                PermissionView(kind: .restricted) {}
            case .running:
                cameraPreview
            case .noDevice:
                NoCameraView(refresh: cameraManager.refreshDevices)
            case .failed(let message):
                CameraErrorView(message: message) {
                    cameraManager.start()
                }
            case .stopping:
                loadingView
            }
        }
    }

    private var cameraPreview: some View {
        CameraPreviewRepresentable(session: cameraManager.session, mirrored: settings.mirrorPreview)
            .aspectRatio(settings.aspectRatio.numericValue.map { CGFloat($0) }, contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .accessibilityLabel("Live camera preview")
    }

    private var loadingView: some View {
        VStack(spacing: 10) {
            ProgressView()
            Text("Starting camera preview")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.88))
        .accessibilityElement(children: .combine)
    }

    private var statusPill: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            Text("Live")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(.black.opacity(0.42), in: Capsule())
        .accessibilityLabel("Camera preview is live")
    }

    private var quickPictureButton: some View {
        Button {
            takeQuickPicture()
        } label: {
            Image(systemName: "camera.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.black.opacity(0.48), in: Circle())
                .overlay {
                    Circle().stroke(.white.opacity(0.22), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .help("Take quick picture")
        .accessibilityLabel("Take quick picture")
    }

    private var audioPulse: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(index < 5 ? 0.82 : 0.36))
                    .frame(width: 3, height: CGFloat(8 + (index % 4) * 5))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(.black.opacity(0.42), in: Capsule())
        .opacity(settings.micCheckHoverOnly ? 0.72 : 1)
        .accessibilityLabel("Audio pulse")
    }

    private var reactionHints: some View {
        HStack(spacing: 7) {
            ForEach(["hand.thumbsup.fill", "heart.fill", "sparkles"], id: \.self) { symbol in
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(.black.opacity(0.36), in: Circle())
            }
        }
        .accessibilityLabel("Reaction hints")
    }

    private func takeQuickPicture() {
        snapshotMessage = "Saving..."
        cameraManager.captureQuickPicture { result in
            withAnimation(.easeInOut(duration: 0.18)) {
                switch result {
                case .success:
                    snapshotMessage = "Saved"
                case .failure(let error):
                    snapshotMessage = error.localizedDescription
                }
            }

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_800_000_000)
                withAnimation(.easeInOut(duration: 0.18)) {
                    snapshotMessage = nil
                }
            }
        }
    }
}

private struct PreviewGearMenu: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var cameraManager: CameraManager
    let close: () -> Void

    init(environment: AppEnvironment, close: @escaping () -> Void) {
        self.environment = environment
        self.cameraManager = environment.cameraManager
        self.close = close
    }

    var body: some View {
        Menu {
            ForEach(cameraManager.devices) { device in
                Button {
                    cameraManager.switchCamera(to: device.id)
                } label: {
                    if cameraManager.activeDeviceID == device.id {
                        Label(device.name, systemImage: "checkmark")
                    } else {
                        Text(device.name)
                    }
                }
            }

            Divider()

            Button("What's New") {
                openSettings(section: .about)
            }

            Button("About \(AppConstants.appName)") {
                NSApp.orderFrontStandardAboutPanel(options: [
                    .applicationName: AppConstants.appName,
                    .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                    .version: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                ])
                NSApp.activate(ignoringOtherApps: true)
            }

            Button("Settings...") {
                openSettings(section: .general)
            }

            Divider()

            Button("Quit \(AppConstants.appName)") {
                AppCommands.quit()
            }
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.42), in: Circle())
                .overlay {
                    Circle().stroke(.white.opacity(0.18), lineWidth: 1)
                }
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .help("Preview menu")
        .accessibilityLabel("Preview menu")
    }

    private func openSettings(section: AppSettingsSection) {
        DispatchQueue.main.async {
            close()
            (NSApp.delegate as? AppDelegate)?.showSettings(section: section)
        }
    }
}
