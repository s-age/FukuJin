/// Presentation-facing mirror of `OCRLanguage`. Raw values match the domain codes so
/// mapping in both directions is a lookup, and `allCases` preserves the domain order
/// for a stable checklist layout.
enum OCRLanguageResponse: String, CaseIterable, Equatable, Sendable {
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

    init(from entity: OCRLanguage) {
        self = OCRLanguageResponse(rawValue: entity.rawValue) ?? .english
    }

    var toDomain: OCRLanguage {
        OCRLanguage(rawValue: rawValue) ?? .english
    }
}
