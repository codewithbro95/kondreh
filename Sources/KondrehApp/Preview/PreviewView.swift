import KondrehCore
import SwiftUI

struct PreviewView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService
    @ObservedObject private var cameraManager: CameraManager
    @StateObject private var viewModel: PreviewViewModel
    let close: () -> Void

    init(environment: AppEnvironment, close: @escaping () -> Void) {
        self.environment = environment
        self.settings = environment.settings
        self.cameraManager = environment.cameraManager
        self._viewModel = StateObject(wrappedValue: PreviewViewModel(environment: environment))
        self.close = close
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                previewContent
                    .clipShape(RoundedRectangle(cornerRadius: settings.previewCornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: settings.previewCornerRadius, style: .continuous)
                            .stroke(.quaternary, lineWidth: 1)
                    }
                    .padding([.top, .horizontal], 12)

                if cameraManager.state == .running {
                    statusPill
                        .padding(20)
                }

                if settings.showCameraName, let device = cameraManager.devices.first(where: { $0.id == cameraManager.activeDeviceID }) {
                    Text(device.name)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.42), in: Capsule())
                        .padding(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .accessibilityLabel("Active camera: \(device.name)")
                }
            }

            PreviewControlsView(environment: environment, close: close)
                .padding(12)
        }
        .background(.regularMaterial)
        .preferredColorScheme(settings.appearance.colorScheme)
        .task {
            viewModel.refreshLicense()
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
}
