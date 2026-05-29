import SwiftUI

struct SplashWindowView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "pin.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.tint)
                .symbolEffect(.pulse, options: .repeating)

            VStack(spacing: 6) {
                Text("FukuJin")
                    .font(.title2.weight(.semibold))
                Text("initializing...")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            ProgressView()
                .controlSize(.small)
        }
        .padding(40)
        .frame(width: 280, height: 240)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
