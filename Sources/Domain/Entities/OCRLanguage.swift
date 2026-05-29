import Foundation

/// Languages offered for Vision text recognition matching.
///
/// Raw values are the `VNRecognizeTextRequest.recognitionLanguages` codes for the
/// `.accurate` level. The set is a curated list of widely-supported languages rather
/// than the full Vision catalog, so the UI stays stable across OS versions.
enum OCRLanguage: String, CaseIterable, Sendable, Codable {
    case english = "en-US"
    case japanese = "ja-JP"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case korean = "ko-KR"
    case french = "fr-FR"
    case german = "de-DE"
    case spanish = "es-ES"
    case italian = "it-IT"
    case portuguese = "pt-BR"
    case russian = "ru-RU"

    /// Fallback applied when no language is selected; recognition always needs at least one.
    static let `default`: [OCRLanguage] = [.english]

    /// Dedupes while preserving selection order, falling back to the default when empty
    /// so recognition never runs with an empty language list.
    static func normalized(_ languages: [OCRLanguage]) -> [OCRLanguage] {
        var seen = Set<OCRLanguage>()
        let unique = languages.filter { seen.insert($0).inserted }
        return unique.isEmpty ? OCRLanguage.default : unique
    }
}
