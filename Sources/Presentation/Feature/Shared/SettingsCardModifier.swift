import SwiftUI

enum SettingsCardVariant {
    case defaultSettings
    case pinnedWindow

    fileprivate var tint: Color {
        switch self {
        case .defaultSettings: Color(nsColor: .systemGray)
        case .pinnedWindow: Color(nsColor: .systemBlue)
        }
    }

    fileprivate var fillOpacity: Double {
        switch self {
        case .defaultSettings: 0.10
        case .pinnedWindow: 0.12
        }
    }

    fileprivate var strokeOpacity: Double {
        switch self {
        case .defaultSettings: 0.30
        case .pinnedWindow: 0.35
        }
    }
}

extension View {
    func settingsCard(_ variant: SettingsCardVariant) -> some View {
        modifier(SettingsCardModifier(variant: variant))
    }
}

private struct SettingsCardModifier: ViewModifier {
    let variant: SettingsCardVariant

    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(variant.tint.opacity(variant.fillOpacity))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(variant.tint.opacity(variant.strokeOpacity), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
