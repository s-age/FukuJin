import CoreGraphics
import Foundation
import XCTest
@testable import FukuJin

final class CGImageCapturedImageResolverTests: XCTestCase {
    private var mockStore: CapturedImageStoreMock!
    private var sut: CGImageCapturedImageResolver!

    override func setUp() {
        super.setUp()
        mockStore = CapturedImageStoreMock()
        let store = mockStore!
        sut = CGImageCapturedImageResolver(resolveFrame: { store.resolveLatest(windowID: $0) })
    }

    override func tearDown() {
        sut = nil
        mockStore = nil
        super.tearDown()
    }

    func testResolve_returnsImage_whenStoreHasEntry() {
        let image = Self.makeImage()
        mockStore.stubbedResolveResult = image
        let response = Self.makeResponse()

        let result = sut.resolve(response)

        XCTAssertTrue(result === image)
    }

    func testResolve_returnsNil_whenStoreReturnsNil() {
        mockStore.stubbedResolveResult = nil
        let response = Self.makeResponse()

        let result = sut.resolve(response)

        XCTAssertNil(result)
    }

    func testResolve_callsStoreOnce_perInvocation() {
        let response = Self.makeResponse()

        _ = sut.resolve(response)

        XCTAssertEqual(mockStore.resolveLatestCallCount, 1)
    }

    func testResolve_forwardsResponseWindowID_toStore() {
        let response = CapturedImageRefResponse(
            snapshotID: nil,
            windowID: 88,
            bounds: BoundingBoxResponse(x: 0, y: 0, width: 0, height: 0)
        )

        _ = sut.resolve(response)

        XCTAssertEqual(mockStore.resolvedWindowIDs, [88])
    }

    // MARK: - Helpers

    private static func makeResponse() -> CapturedImageRefResponse {
        CapturedImageRefResponse(
            snapshotID: nil,
            windowID: 1,
            bounds: BoundingBoxResponse(x: 0, y: 0, width: 10, height: 10)
        )
    }

    private static func makeImage() -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }
}
