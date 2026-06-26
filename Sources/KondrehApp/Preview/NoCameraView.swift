import SwiftUI

struct NoCameraView: View {
    let refresh: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "web.camera")
                .font(.system(size: 34, weight: .semibold))
            Text("No Camera Found")
                .font(.headline)
            Text("Connect a built-in, USB, or Continuity Camera device, then refresh.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 340)
            Button("Refresh Cameras", action: refresh)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.88))
        .foregroundStyle(.white)
    }
}
