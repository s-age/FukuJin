import XCTest
@testable import FukuJin

final class TextScanResultTests: XCTestCase {
    private func block(_ text: String, box: BoundingBox = .zero) -> RecognizedTextBlock {
        RecognizedTextBlock(text: text, boundingBox: box)
    }

    // MARK: - match

    func test_match_returnsMatched_whenAnyBlockContainsSearch() {
        let result = TextScanResult.match(blocks: [block("Found needle here")], searchText: "needle")
        XCTAssertTrue(result.matched)
    }

    func test_match_collectsBoundingBoxOfMatchingBlock() {
        let box = BoundingBox(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
        let result = TextScanResult.match(blocks: [block("a needle", box: box)], searchText: "needle")
        XCTAssertEqual(result.matchedBoundingBoxes, [box])
    }

    func test_match_collectsOnlyMatchingBlocksBoxes() {
        let hit = BoundingBox(x: 1, y: 1, width: 1, height: 1)
        let miss = BoundingBox(x: 2, y: 2, width: 2, height: 2)
        let result = TextScanResult.match(
            blocks: [block("needle", box: hit), block("haystack", box: miss)],
            searchText: "needle"
        )
        XCTAssertEqual(result.matchedBoundingBoxes, [hit])
    }

    func test_match_isCaseInsensitive() {
        let result = TextScanResult.match(blocks: [block("NEEDLE")], searchText: "needle")
        XCTAssertTrue(result.matched)
    }

    func test_match_returnsUnmatched_whenNoBlockContainsSearch() {
        let result = TextScanResult.match(blocks: [block("haystack")], searchText: "needle")
        XCTAssertFalse(result.matched)
    }

    func test_match_returnsEmptyBoxes_whenNoBlockContainsSearch() {
        let result = TextScanResult.match(blocks: [block("haystack")], searchText: "needle")
        XCTAssertTrue(result.matchedBoundingBoxes.isEmpty)
    }

    func test_match_withEmptySearch_returnsUnmatched() {
        // Empty term must never match, even though "anything".contains("") is true for every string.
        let result = TextScanResult.match(blocks: [block("anything")], searchText: "")
        XCTAssertFalse(result.matched)
    }

    func test_match_withNoBlocks_returnsUnmatched() {
        let result = TextScanResult.match(blocks: [], searchText: "needle")
        XCTAssertFalse(result.matched)
    }

    func test_match_withWhitespaceOnlySearch_returnsUnmatched() {
        let result = TextScanResult.match(blocks: [block("anything")], searchText: "   ")
        XCTAssertFalse(result.matched)
    }

    // MARK: - normalization (Japanese / OCR quirks)

    func test_match_ignoresSpacesInjectedBetweenJapaneseGlyphs() {
        let result = TextScanResult.match(blocks: [block("ド キュメント を開く")], searchText: "ドキュメント")
        XCTAssertTrue(result.matched)
    }

    func test_match_foldsHalfWidthKatakanaToFullWidth() {
        let result = TextScanResult.match(blocks: [block("ﾄﾞｷｭﾒﾝﾄ")], searchText: "ドキュメント")
        XCTAssertTrue(result.matched)
    }

    func test_match_foldsFullWidthLatinToAscii() {
        let result = TextScanResult.match(blocks: [block("ＤＯＣＵＭＥＮＴ")], searchText: "document")
        XCTAssertTrue(result.matched)
    }

    func test_match_ignoresWhitespaceInSearchTerm() {
        let result = TextScanResult.match(blocks: [block("ドキュメント")], searchText: "ドキュ メント")
        XCTAssertTrue(result.matched)
    }

    // MARK: - unmatched

    func test_unmatched_isNotMatched() {
        XCTAssertFalse(TextScanResult.unmatched.matched)
    }

    func test_unmatched_hasNoBoundingBoxes() {
        XCTAssertTrue(TextScanResult.unmatched.matchedBoundingBoxes.isEmpty)
    }
}
