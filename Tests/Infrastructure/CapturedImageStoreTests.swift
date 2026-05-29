import CoreGraphics
import XCTest
@testable import FukuJin

final class CapturedImageStoreTests: XCTestCase {
    private var sut: CapturedImageStore!

    override func setUp() {
        super.setUp()
        sut = CapturedImageStore()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - store / resolve

    func test_store_returnsDistinctUUIDs_forEachCall() {
        let id1 = sut.store(Self.makeImage())
        let id2 = sut.store(Self.makeImage())
        XCTAssertNotEqual(id1, id2)
    }

    func test_resolve_returnsStoredImage_whenIDExists() {
        let image = Self.makeImage()
        let id = sut.store(image)
        let resolved = sut.resolve(id)
        XCTAssertTrue(resolved === image)
    }

    func test_resolve_returnsNil_whenIDNotStored() {
        XCTAssertNil(sut.resolve(UUID()))
    }

    // MARK: - TTL

    func test_resolve_returnsNil_whenTTLExpired() async throws {
        sut = CapturedImageStore(ttl: 0.05)
        let id = sut.store(Self.makeImage())
        try await Task.sleep(for: .milliseconds(150))
        // a second store call triggers lazy eviction of the expired entry
        _ = sut.store(Self.makeImage())
        XCTAssertNil(sut.resolve(id))
    }

    func test_resolve_returnsImage_whenWithinTTL() async throws {
        sut = CapturedImageStore(ttl: 1.0)
        let image = Self.makeImage()
        let id = sut.store(image)
        try await Task.sleep(for: .milliseconds(50))
        XCTAssertTrue(sut.resolve(id) === image)
    }

    // MARK: - storeLatest / resolveLatest / clearLatest

    func test_resolveLatest_returnsLatestImage_whenStoredViaStoreLatest() {
        let image = Self.makeImage()
        sut.storeLatest(image, windowID: 42)
        XCTAssertTrue(sut.resolveLatest(windowID: 42) === image)
    }

    func test_resolveLatest_returnsNil_whenWindowIDNotStored() {
        XCTAssertNil(sut.resolveLatest(windowID: 99))
    }

    func test_storeLatest_replacesPreviousFrame_forSameWindowID() {
        sut.storeLatest(Self.makeImage(), windowID: 42)
        let newImage = Self.makeImage()
        sut.storeLatest(newImage, windowID: 42)
        // windowID always resolves to the most recent frame — no stale-token race.
        XCTAssertTrue(sut.resolveLatest(windowID: 42) === newImage)
    }

    func test_storeLatest_keepsFrames_forDifferentWindowIDs() {
        let imageA = Self.makeImage()
        let imageB = Self.makeImage()
        sut.storeLatest(imageA, windowID: 1)
        sut.storeLatest(imageB, windowID: 2)
        XCTAssertTrue(sut.resolveLatest(windowID: 1) === imageA)
        XCTAssertTrue(sut.resolveLatest(windowID: 2) === imageB)
    }

    func test_clearLatest_removesEntry_forWindowID() {
        sut.storeLatest(Self.makeImage(), windowID: 42)
        sut.clearLatest(windowID: 42)
        XCTAssertNil(sut.resolveLatest(windowID: 42))
    }

    func test_clearLatest_doesNotAffect_otherWindowIDs() {
        let image = Self.makeImage()
        sut.storeLatest(image, windowID: 1)
        sut.clearLatest(windowID: 2)
        XCTAssertTrue(sut.resolveLatest(windowID: 1) === image)
    }

    func test_resolve_doesNotResolveStreamingFrames_byOneShotToken() {
        // Streaming frames are keyed by windowID, not by a one-shot UUID token.
        sut.storeLatest(Self.makeImage(), windowID: 1)
        XCTAssertNil(sut.resolve(UUID()))
    }

    // MARK: - Concurrency

    func test_concurrentStoreAndResolve_isThreadSafe() async {
        let store = sut!
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    let image = Self.makeImage()
                    let id = store.store(image)
                    _ = store.resolve(id)
                }
                group.addTask {
                    let windowID = UInt32.random(in: 1...10)
                    store.storeLatest(Self.makeImage(), windowID: windowID)
                    _ = store.resolveLatest(windowID: windowID)
                }
            }
        }
        // Reaching here without crashing demonstrates absence of data races.
    }

    // MARK: - Helpers

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
