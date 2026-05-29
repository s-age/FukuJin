import SwiftUI

extension OCRLanguageResponse {
    var displayName: String {
        switch self {
        case .english: "English"
        case .japanese: "日本語"
        case .chineseSimplified: "简体中文"
        case .chineseTraditional: "繁體中文"
        case .korean: "한국어"
        case .french: "Français"
        case .german: "Deutsch"
        case .spanish: "Español"
        case .italian: "Italiano"
        case .portuguese: "Português"
        case .russian: "Русский"
        }
    }
}
