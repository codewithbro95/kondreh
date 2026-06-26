import KondrehCore
import SwiftUI

struct PurchaseView: View {
    let licenseState: LicenseState

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 34, weight: .semibold))
            Text("Continue with \(AppConstants.appName)")
                .font(.headline)
            Text("\(AppConstants.licenseModel). \(AppConstants.price). Connect a production provider before shipping.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            Button("Purchase") {
                if let url = URL(string: AppConstants.websiteURLString), url.scheme?.hasPrefix("http") == true {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.88))
        .foregroundStyle(.white)
    }
}
