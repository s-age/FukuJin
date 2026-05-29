import XCTest
@testable import FukuJin

final class OverlayConfigTests: XCTestCase {

    // MARK: - create(opacity:fps:)

    func test_create_clampsOpacityBelowMinimum_toZeroPointOne() {
        let config = OverlayConfig.create(opacity: -0.5, fps: 30)
        XCTAssertEqual(config.opacity, 0.1)
    }

    func test_create_clampsOpacityAboveMaximum_toOne() {
        let config = OverlayConfig.create(opacity: 1.5, fps: 30)
        XCTAssertEqual(config.opacity, 1.0)
    }

    func test_create_clampsFPSBelowMinimum_toOne() {
        let config = OverlayConfig.create(opacity: 0.5, fps: 0)
        XCTAssertEqual(config.fps, 1)
    }

    func test_create_clampsFPSAboveMaximum_toSixty() {
        let config = OverlayConfig.create(opacity: 0.5, fps: 120)
        XCTAssertEqual(config.fps, 60)
    }

    func test_create_roundsFPSToIntegerValue() {
        let config = OverlayConfig.create(opacity: 0.5, fps: 30.7)
        XCTAssertEqual(config.fps, 31)
    }

    func test_create_passesValidOpacityThrough() {
        let config = OverlayConfig.create(opacity: 0.5, fps: 30)
        XCTAssertEqual(config.opacity, 0.5)
    }

    func test_create_passesValidFPSThrough() {
        let config = OverlayConfig.create(opacity: 0.5, fps: 30)
        XCTAssertEqual(config.fps, 30)
    }

    // MARK: - default

    func test_default_hasExpectedOpacity() {
        XCTAssertEqual(OverlayConfig.default.opacity, 0.5)
    }

    func test_default_hasExpectedFPS() {
        XCTAssertEqual(OverlayConfig.default.fps, 1.0)
    }

    // MARK: - applying(opacity:)

    func test_applyingOpacity_clampsBelowMinimum() {
        let config = OverlayConfig.default.applying(opacity: -1.0)
        XCTAssertEqual(config.opacity, 0.1)
    }

    func test_applyingOpacity_clampsAboveMaximum() {
        let config = OverlayConfig.default.applying(opacity: 2.0)
        XCTAssertEqual(config.opacity, 1.0)
    }

    func test_applyingOpacity_preservesFPS() {
        let config = OverlayConfig.create(opacity: 0.5, fps: 30).applying(opacity: 0.8)
        XCTAssertEqual(config.fps, 30)
    }

    // MARK: - applying(fps:)

    func test_applyingFPS_clampsBelowMinimum() {
        let config = OverlayConfig.default.applying(fps: 0)
        XCTAssertEqual(config.fps, 1)
    }

    func test_applyingFPS_clampsAboveMaximum() {
        let config = OverlayConfig.default.applying(fps: 120)
        XCTAssertEqual(config.fps, 60)
    }

    func test_applyingFPS_roundsToInteger() {
        let config = OverlayConfig.default.applying(fps: 30.7)
        XCTAssertEqual(config.fps, 31)
    }

    func test_applyingFPS_preservesOpacity() {
        let config = OverlayConfig.create(opacity: 0.8, fps: 1).applying(fps: 30)
        XCTAssertEqual(config.opacity, 0.8)
    }
}
