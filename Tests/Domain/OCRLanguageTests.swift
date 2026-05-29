import XCTest
@testable import FukuJin

final class OCRLanguageTests: XCTestCase {
    func test_default_isEnglishOnly() {
        XCTAssertEqual(OCRLanguage.default, [.english])
    }

    func test_normalized_returnsDefault_whenEmpty() {
        XCTAssertEqual(OCRLanguage.normalized([]), [.english])
    }

    func test_normalized_removesDuplicates() {
        XCTAssertEqual(OCRLanguage.normalized([.japanese, .japanese]), [.japanese])
    }

    func test_normalized_preservesOrder() {
        XCTAssertEqual(OCRLanguage.normalized([.korean, .english, .french]), [.korean, .english, .french])
    }

    func test_rawValue_matchesVisionLanguageCode() {
        XCTAssertEqual(OCRLanguage.chineseSimplified.rawValue, "zh-Hans")
    }
}
