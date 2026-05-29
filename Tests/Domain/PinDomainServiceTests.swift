import XCTest
@testable import FukuJin

final class PinDomainServiceTests: XCTestCase {
    private func makeWindow(id: UInt32) -> WindowInfo {
        WindowInfo(id: id, ownerPID: 100, ownerName: "App", windowName: "W\(id)")
    }

    private func makeService() -> PinDomainService {
        PinDomainService(settingsRepository: SettingsRepositoryStub())
    }

    func test_pin_appendsToOrder() {
        let service = makeService()
        _ = service.pin(makeWindow(id: 1), config: .default)
        _ = service.pin(makeWindow(id: 2), config: .default)
        let state = service.pin(makeWindow(id: 3), config: .default)
        XCTAssertEqual(state.windowIDs, [1, 2, 3])
        XCTAssertEqual(service.currentState().windowIDs, [1, 2, 3])
    }

    func test_pin_seedsOpacityAndFPSFromConfig() {
        let service = makeService()
        let state = service.pin(makeWindow(id: 1), config: .create(opacity: 0.8, fps: 24))
        XCTAssertEqual(state[1]?.opacity, 0.8)
        XCTAssertEqual(state[1]?.fps, 24)
    }

    func test_unpin_removesFromOrder() {
        let service = makeService()
        _ = service.pin(makeWindow(id: 1), config: .default)
        _ = service.pin(makeWindow(id: 2), config: .default)
        _ = service.pin(makeWindow(id: 3), config: .default)
        let state = service.unpin(2)
        XCTAssertEqual(state.windowIDs, [1, 3])
    }

    func test_mutateWindow_appliesTransformToState() throws {
        let service = makeService()
        _ = service.pin(makeWindow(id: 1), config: .default)
        let state = try service.mutateWindow(windowID: 1) { $0.applyingOpacity(0.9) }
        XCTAssertEqual(state[1]?.opacity, 0.9)
        XCTAssertEqual(service.currentState()[1]?.opacity, 0.9)
    }

    func test_reorder_updatesOrder() {
        let service = makeService()
        _ = service.pin(makeWindow(id: 1), config: .default)
        _ = service.pin(makeWindow(id: 2), config: .default)
        _ = service.pin(makeWindow(id: 3), config: .default)
        let state = service.reorder([3, 1, 2])
        XCTAssertEqual(state.windowIDs, [3, 1, 2])
        XCTAssertEqual(service.currentState().windowIDs, [3, 1, 2])
    }

    func test_reorder_preservesInvariantUnderDefensiveInput() {
        let service = makeService()
        _ = service.pin(makeWindow(id: 1), config: .default)
        _ = service.pin(makeWindow(id: 2), config: .default)
        _ = service.pin(makeWindow(id: 3), config: .default)
        let state = service.reorder([99, 3, 3])
        XCTAssertEqual(Set(state.windowIDs), [1, 2, 3])
        XCTAssertEqual(state.windowIDs.count, 3)
    }

    func test_prune_alsoTrimsOrder() {
        let service = makeService()
        _ = service.pin(makeWindow(id: 1), config: .default)
        _ = service.pin(makeWindow(id: 2), config: .default)
        _ = service.pin(makeWindow(id: 3), config: .default)
        let state = service.prune(keeping: [1, 3])
        XCTAssertEqual(state.windowIDs, [1, 3])
    }
}

private final class SettingsRepositoryStub: SettingsRepositoryProtocol, @unchecked Sendable {
    var storedConfig: OverlayConfig = .default
    var storedLanguages: [OCRLanguage] = OCRLanguage.default
    func loadDefaultConfig() -> OverlayConfig { storedConfig }
    func saveDefaultConfig(_ config: OverlayConfig) { storedConfig = config }
    func loadRecognitionLanguages() -> [OCRLanguage] { storedLanguages }
    func saveRecognitionLanguages(_ languages: [OCRLanguage]) { storedLanguages = languages }
}
