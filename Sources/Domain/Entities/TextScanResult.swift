import Foundation

struct TextScanResult: Equatable, Sendable {
    let matched: Bool
    let matchedBoundingBoxes: [BoundingBox]

    static let unmatched = TextScanResult(matched: false, matchedBoundingBoxes: [])

    /// Normalized substring match of `searchText` against recognized text blocks.
    ///
    /// Both sides are normalized before comparison to absorb the common ways OCR — Japanese
    /// in particular — perturbs text without changing its meaning:
    /// - **NFKC compatibility folding** unifies half-width/full-width kana and Latin forms
    ///   (e.g. `ﾄﾞｷｭﾒﾝﾄ` ↔ `ドキュメント`, full-width `Ａ` → `A`).
    /// - **Whitespace removal** drops the spaces Vision frequently injects between CJK glyphs
    ///   (e.g. `ド キュメント` → `ドキュメント`), which would otherwise break `contains`.
    /// - **Lowercasing** keeps the match case-insensitive.
    ///
    /// A block matches when its normalized text contains the normalized search term; the result
    /// aggregates the bounding boxes of every matching block. An empty/whitespace-only term never
    /// matches. Normalization cannot recover genuine glyph misreads (e.g. small kana `ュ` read as
    /// large `ユ`) — those are recognition errors, not formatting differences.
    static func match(blocks: [RecognizedTextBlock], searchText: String) -> TextScanResult {
        let needle = normalize(searchText)
        guard !needle.isEmpty else { return .unmatched }
        let matchedBoxes = blocks
            .filter { normalize($0.text).contains(needle) }
            .map(\.boundingBox)
        return TextScanResult(matched: !matchedBoxes.isEmpty, matchedBoundingBoxes: matchedBoxes)
    }

    private static func normalize(_ text: String) -> String {
        text
            .precomposedStringWithCompatibilityMapping
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined()
    }
}
