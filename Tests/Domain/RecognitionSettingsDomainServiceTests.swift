import XCTest
@testable import FukuJin

final class RecognitionSettingsDomainServiceTests: XCTestCase {
    private var sut: RecognitionSettingsDomainService!
    private var stubSettings: RecognitionSettingsRepositoryStub!

    override func setUp() {
        super.setUp()
        stubSettings = RecognitionSettingsRepositoryStub()
        sut = RecognitionSettingsDomainService(settingsRepository: stubSettings)
    }

    override func tearDown() {
        sut = nil
        stubSettings = nil
        super.tearDown()
    }

    func test_currentLanguages_reflectsRepositoryAtInit() {
        stubSettings.storedLanguages = [.japanese]
        let service = RecognitionSettingsDomainService(settingsRepository: stubSettings)
        XCTAssertEqual(service.currentLanguages(), [.japanese])
    }

    func test_updateLanguages_persistsThroughRepository() throws {
        _ = try sut.updateLanguages([.korean, .german])
        XCTAssertEqual(stubSettings.storedLanguages, [.korean, .german])
    }

    func test_updateLanguages_updatesCachedValue() throws {
        _ = try sut.updateLanguages([.french])
        XCTAssertEqual(sut.currentLanguages(), [.french])
    }

    func test_updateLanguages_normalizesEmptyToDefault() throws {
        let result = try sut.updateLanguages([])
        XCTAssertEqual(result, [.english])
    }

    func test_updateLanguages_returnsNormalizedSelection() throws {
        let result = try sut.updateLanguages([.italian, .italian])
        XCTAssertEqual(result, [.italian])
    }
}

private final class RecognitionSettingsRepositoryStub: SettingsRepositoryProtocol, @unchecked Sendable {
    var storedConfig: OverlayConfig = .default
    var storedLanguages: [OCRLanguage] = OCRLanguage.default
    func loadDefaultConfig() -> OverlayConfig { storedConfig }
    func saveDefaultConfig(_ config: OverlayConfig) {}
    func loadRecognitionLanguages() -> [OCRLanguage] { storedLanguages }
    func saveRecognitionLanguages(_ languages: [OCRLanguage]) { storedLanguages = languages }
}
