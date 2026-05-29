import XCTest
@testable import FukuJin

final class SettingsRepositoryTests: XCTestCase {
    private var sut: SettingsRepository!
    private var mockDataSource: SettingsDataSourceMock!

    override func setUp() {
        super.setUp()
        mockDataSource = SettingsDataSourceMock()
        sut = SettingsRepository(dataSource: mockDataSource)
    }

    override func tearDown() {
        sut = nil
        mockDataSource = nil
        super.tearDown()
    }

    // MARK: - loadDefaultConfig

    func test_loadDefaultConfig_returnsDefault_whenDataSourceReturnsNil() {
        mockDataSource.loadResult = nil
        let config = sut.loadDefaultConfig()
        XCTAssertEqual(config, .default)
    }

    func test_loadDefaultConfig_callsDataSourceOnce() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.5, fps: 30)
        _ = sut.loadDefaultConfig()
        XCTAssertEqual(mockDataSource.loadCallCount, 1)
    }

    func test_loadDefaultConfig_passesThroughValidOpacity() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.7, fps: 30)
        let config = sut.loadDefaultConfig()
        XCTAssertEqual(config.opacity, 0.7)
    }

    func test_loadDefaultConfig_passesThroughValidFPS() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.7, fps: 24)
        let config = sut.loadDefaultConfig()
        XCTAssertEqual(config.fps, 24)
    }

    func test_loadDefaultConfig_clampsOpacityAboveMaximum() {
        mockDataSource.loadResult = SettingsDTO(opacity: 2.0, fps: 30)
        let config = sut.loadDefaultConfig()
        XCTAssertEqual(config.opacity, 1.0)
    }

    func test_loadDefaultConfig_clampsOpacityBelowMinimum() {
        mockDataSource.loadResult = SettingsDTO(opacity: -0.5, fps: 30)
        let config = sut.loadDefaultConfig()
        XCTAssertEqual(config.opacity, 0.1)
    }

    func test_loadDefaultConfig_clampsFPSAboveMaximum() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.5, fps: 120)
        let config = sut.loadDefaultConfig()
        XCTAssertEqual(config.fps, 60)
    }

    func test_loadDefaultConfig_clampsFPSBelowMinimum() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.5, fps: 0)
        let config = sut.loadDefaultConfig()
        XCTAssertEqual(config.fps, 1)
    }

    // MARK: - saveDefaultConfig

    func test_saveDefaultConfig_callsDataSourceOnce() throws {
        try sut.saveDefaultConfig(OverlayConfig.create(opacity: 0.5, fps: 30))
        XCTAssertEqual(mockDataSource.saveCallCount, 1)
    }

    func test_saveDefaultConfig_forwardsOpacity() throws {
        try sut.saveDefaultConfig(OverlayConfig.create(opacity: 0.8, fps: 30))
        XCTAssertEqual(mockDataSource.savedDTOs.first?.opacity, 0.8)
    }

    func test_saveDefaultConfig_forwardsFPS() throws {
        try sut.saveDefaultConfig(OverlayConfig.create(opacity: 0.5, fps: 24))
        XCTAssertEqual(mockDataSource.savedDTOs.first?.fps, 24)
    }

    func test_saveDefaultConfig_wrapsDataSourceErrorAsPersistenceFailure() {
        mockDataSource.saveError = InfrastructureError.processExitedNonZero(status: "disk full")
        do {
            try sut.saveDefaultConfig(OverlayConfig.create(opacity: 0.5, fps: 30))
            XCTFail("Expected saveDefaultConfig to throw")
        } catch let InfrastructureError.settingsPersistenceFailed(message) {
            XCTAssertFalse(message.isEmpty)
        } catch {
            XCTFail("Expected settingsPersistenceFailed, got \(error)")
        }
    }

    func test_saveDefaultConfig_preservesExistingRecognitionLanguages() throws {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.5, fps: 30, ocrLanguages: ["ja-JP"])
        try sut.saveDefaultConfig(OverlayConfig.create(opacity: 0.8, fps: 24))
        XCTAssertEqual(mockDataSource.savedDTOs.first?.ocrLanguages, ["ja-JP"])
    }

    // MARK: - loadRecognitionLanguages

    func test_loadRecognitionLanguages_returnsDefault_whenDataSourceReturnsNil() {
        mockDataSource.loadResult = nil
        XCTAssertEqual(sut.loadRecognitionLanguages(), OCRLanguage.default)
    }

    func test_loadRecognitionLanguages_returnsDefault_whenStoredListEmpty() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.5, fps: 30, ocrLanguages: [])
        XCTAssertEqual(sut.loadRecognitionLanguages(), OCRLanguage.default)
    }

    func test_loadRecognitionLanguages_decodesStoredCodes() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.5, fps: 30, ocrLanguages: ["ja-JP", "ko-KR"])
        XCTAssertEqual(sut.loadRecognitionLanguages(), [.japanese, .korean])
    }

    func test_loadRecognitionLanguages_dropsUnknownCodes() {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.5, fps: 30, ocrLanguages: ["ja-JP", "xx-YY"])
        XCTAssertEqual(sut.loadRecognitionLanguages(), [.japanese])
    }

    // MARK: - saveRecognitionLanguages

    func test_saveRecognitionLanguages_forwardsCodes() throws {
        try sut.saveRecognitionLanguages([.english, .german])
        XCTAssertEqual(mockDataSource.savedDTOs.first?.ocrLanguages, ["en-US", "de-DE"])
    }

    func test_saveRecognitionLanguages_preservesExistingDefaultConfig() throws {
        mockDataSource.loadResult = SettingsDTO(opacity: 0.9, fps: 12, ocrLanguages: nil)
        try sut.saveRecognitionLanguages([.french])
        XCTAssertEqual(mockDataSource.savedDTOs.first?.opacity, 0.9)
    }

    func test_saveRecognitionLanguages_persistsDefaultWhenEmpty() throws {
        try sut.saveRecognitionLanguages([])
        XCTAssertEqual(mockDataSource.savedDTOs.first?.ocrLanguages, ["en-US"])
    }
}
