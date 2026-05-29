import Foundation

struct SettingsDTO: Codable, Sendable {
    var opacity: Double
    var fps: Double
    /// Optional for backward compatibility with stores written before OCR language
    /// selection existed — a missing key decodes to `nil` rather than failing.
    var ocrLanguages: [String]?
}
