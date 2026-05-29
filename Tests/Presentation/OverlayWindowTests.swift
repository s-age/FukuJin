import AppKit
import XCTest
@testable import FukuJin

@MainActor
final class OverlayWindowTests: XCTestCase {
    private func makeFrame(width: CGFloat = 120, height: CGFloat = 80) -> CaptureResponse {
        CaptureResponse(
            image: CapturedImageRefResponse(
                snapshotID: nil,
                windowID: 1,
                bounds: BoundingBoxResponse(x: 0, y: 0, width: width, height: height)
            )
        )
    }

    private func makeWindow(targetWindowID: UInt32 = 7) -> OverlayWindow {
        OverlayWindow(
            targetWindowID: targetWindowID,
            initialFrame: makeFrame(),
            resolver: CapturedImageResolverMock()
        )
    }

    private func leftMouseDownEvent() -> NSEvent {
        NSEvent.mouseEvent(
            with: .leftMouseDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            eventNumber: 0,
            clickCount: 1,
            pressure: 1
        )!
    }

    // MARK: - click delivery

    func test_mouseDown_invokesOnClickedWithTargetWindowID() {
        let window = makeWindow(targetWindowID: 42)
        defer { window.teardown() }
        var clicked: UInt32?
        window.onClicked = { clicked = $0 }

        window.mouseDown(with: leftMouseDownEvent())

        XCTAssertEqual(clicked, 42)
    }

    func test_contentImageView_acceptsFirstMouse() {
        // Overlays belong to an .accessory app and float above other apps; without first-mouse
        // acceptance the activating click is swallowed and never reaches mouseDown.
        let window = makeWindow()
        defer { window.teardown() }

        let imageView = window.contentView?.subviews.first

        XCTAssertEqual(imageView?.acceptsFirstMouse(for: nil), true)
    }

    func test_teardown_clearsOnClicked_soLateClicksAreIgnored() {
        let window = makeWindow()
        var clickCount = 0
        window.onClicked = { _ in clickCount += 1 }

        window.teardown()
        window.mouseDown(with: leftMouseDownEvent())

        XCTAssertEqual(clickCount, 0)
    }
}
