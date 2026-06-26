import KondrehCore
import SwiftUI

enum PermissionViewKind {
    case notDetermined
    case denied
    case restricted
}

struct PermissionView: View {
    let kind: PermissionViewKind
    let action: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 340)

            if kind != .restricted {
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.88))
        .foregroundStyle(.white)
    }

    private var iconName: String {
        switch kind {
        case .notDetermined: "video.badge.plus"
        case .denied: "video.slash"
        case .restricted: "lock.shield"
        }
    }

    private var title: String {
        switch kind {
        case .notDetermined: "Allow Camera Access"
        case .denied: "Camera Access Is Off"
        case .restricted: "Camera Access Is Restricted"
        }
    }

    private var message: String {
        switch kind {
        case .notDetermined:
            AppConstants.cameraUsageDescription
        case .denied:
            "Enable camera access for \(AppConstants.appName) in System Settings to use the private preview."
        case .restricted:
            "Camera access is restricted by macOS, Screen Time, a device profile, or an administrator."
        }
    }

    private var buttonTitle: String {
        switch kind {
        case .notDetermined: "Allow Camera Access"
        case .denied: "Open Privacy Settings"
        case .restricted: ""
        }
    }
}
