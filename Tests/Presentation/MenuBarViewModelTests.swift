import AppKit
import XCTest
@testable import FukuJin

@MainActor
final class MenuBarViewModelTests: XCTestCase {
    private func makeState(orderedIDs: [UInt32]) -> PinnedWindowList {
        var state = PinnedWindowList.empty
        for id in orderedIDs {
            state = state.pinning(
                WindowInfo(id: id, ownerPID: 1, ownerName: "App", windowName: "W\(id)"),
                seed: .default
            )
        }
        return state
    }

    private func makeOverlayManager() -> OverlayManager {
        OverlayManager(
            captureWindow: StubSyncUseCase<CaptureWindowRequest, CaptureResponse?>(stubbedResult: nil),
            manageCaptureStream: StubAsyncUseCase<ManageCaptureStreamRequest, Void>(stubbedResult: ()),
            orderWindowBelow: StubSyncUseCase<OrderWindowBelowRequest, Void>(stubbedResult: ()),
            observeCaptureFrames: StubSyncUseCase<ObserveCaptureFramesRequest, AsyncStream<CaptureResponse>>(
                stubbedResult: AsyncStream { $0.finish() }
            ),
            resolver: CapturedImageResolverMock(),
            syncOverlays: StubSyncUseCase<SyncOverlaysRequest, OverlayPlanResponse>(
                stubbedResult: OverlayPlanResponse(from: .empty)
            ),
            activatePinnedWindow: StubSyncUseCase<ActivatePinnedWindowRequest, OverlayPlanResponse>(
                stubbedResult: OverlayPlanResponse(from: .empty)
            )
        )
    }

    private func makeValidPNGData() -> Data {
        let image = NSImage(size: NSSize(width: 1, height: 1))
        image.lockFocus()
        NSColor.red.setFill()
        NSRect(x: 0, y: 0, width: 1, height: 1).fill()
        image.unlockFocus()
        let tiff = image.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: tiff)!
        return bitmap.representation(using: .png, properties: [:])!
    }

    private func makeViewModel(
        reorderStub: StubSyncUseCase<ReorderPinnedWindowsRequest, PinnedWindowListResponse>,
        getAppIconStub: StubSyncUseCase<GetAppIconRequest, AppIconResponse?>
            = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: nil),
        listWindowsStub: StubSyncUseCase<ListWindowsRequest, [WindowGroupResponse]>
            = StubSyncUseCase<ListWindowsRequest, [WindowGroupResponse]>(stubbedResult: [])
    ) -> MenuBarViewModel {
        let defaultCfg = OverlayConfigResponse(opacity: 0.5, fps: 1.0)
        return MenuBarViewModel(
            listWindows: listWindowsStub,
            pinWindow: StubSyncUseCase<PinWindowRequest, PinnedWindowListResponse>(stubbedResult: PinnedWindowListResponse(from: .empty)),
            unpinWindow: StubSyncUseCase<UnpinWindowRequest, PinnedWindowListResponse>(stubbedResult: PinnedWindowListResponse(from: .empty)),
            unpinAll: StubSyncUseCase<UnpinAllRequest, PinnedWindowListResponse>(stubbedResult: PinnedWindowListResponse(from: .empty)),
            updateOpacity: StubSyncUseCase<UpdateOpacityRequest, PinnedWindowListResponse>(stubbedResult: PinnedWindowListResponse(from: .empty)),
            updateFPS: StubSyncUseCase<UpdateFPSRequest, PinnedWindowListResponse>(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getDefaultConfig: StubSyncUseCase<GetDefaultConfigRequest, OverlayConfigResponse>(stubbedResult: defaultCfg),
            reorderPinnedWindows: reorderStub,
            getLaunchAtLogin: StubSyncUseCase<GetLaunchAtLoginRequest, Bool>(stubbedResult: false),
            updateLaunchAtLogin: StubSyncUseCase<UpdateLaunchAtLoginRequest, Bool>(stubbedResult: false),
            getAppIcon: getAppIconStub,
            updateScanConfig: StubSyncUseCase<UpdateScanConfigRequest, PinnedWindowListResponse>(
                stubbedResult: PinnedWindowListResponse(from: .empty)
            ),
            decodeAppIcon: AppIconImageDecoder.decode,
            overlayManager: makeOverlayManager()
        )
    }

    func test_reorderPinnedWindows_callsUseCaseOnceAndUpdatesPinnedWindows() {
        let reorderedState = makeState(orderedIDs: [1, 2, 3]).reordering([3, 1, 2])
        let reorderStub = StubSyncUseCase<ReorderPinnedWindowsRequest, PinnedWindowListResponse>(
            stubbedResult: PinnedWindowListResponse(from: reorderedState)
        )
        let vm = makeViewModel(reorderStub: reorderStub)

        vm.reorderPinnedWindows([3, 1, 2])

        XCTAssertEqual(reorderStub.callCount, 1)
        XCTAssertEqual(reorderStub.lastRequest?.order, [3, 1, 2])
        XCTAssertEqual(vm.pinnedWindows.windowIDs, [3, 1, 2])
    }

    func test_appIcon_callsGetAppIconUseCaseOnce() {
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: nil)
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub
        )

        _ = vm.appIcon(localizedName: "App")

        XCTAssertEqual(getAppIconStub.callCount, 1)
    }

    func test_appIcon_forwardsLocalizedNameAsRequest() {
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: nil)
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub
        )

        _ = vm.appIcon(localizedName: "Example")

        XCTAssertEqual(getAppIconStub.lastRequest?.localizedName, "Example")
    }

    func test_appIcon_returnsImageDecodedFromUseCaseResponse() {
        let response = AppIconResponse(pngData: makeValidPNGData())
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: response)
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub
        )

        XCTAssertNotNil(vm.appIcon(localizedName: "Example"))
    }

    func test_appIcon_returnsNilWhenUseCaseThrows() {
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: nil)
        getAppIconStub.stubbedError = ValidationError.missingAppIdentifier
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub
        )

        XCTAssertNil(vm.appIcon(localizedName: "Example"))
    }

    func test_appIcon_repeatedLookupHitsCacheAndCallsUseCaseOnce() {
        let response = AppIconResponse(pngData: makeValidPNGData())
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: response)
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub
        )

        _ = vm.appIcon(localizedName: "Example")
        _ = vm.appIcon(localizedName: "Example")
        _ = vm.appIcon(localizedName: "Example")

        XCTAssertEqual(getAppIconStub.callCount, 1)
    }

    func test_isInitializing_isTrueOnConstruction() {
        let vm = makeViewModel(reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)))

        XCTAssertTrue(vm.isInitializing)
    }

    func test_performInitialWarmUp_flipsIsInitializingToFalse() async {
        let vm = makeViewModel(reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)))

        await vm.performInitialWarmUp(minimumSplashDuration: .zero)

        XCTAssertFalse(vm.isInitializing)
    }

    func test_performInitialWarmUp_runsCacheWarmUp() async {
        let response = AppIconResponse(pngData: makeValidPNGData())
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: response)
        let listWindowsStub = StubSyncUseCase<ListWindowsRequest, [WindowGroupResponse]>(
            stubbedResult: [WindowGroupResponse(appName: "FooApp", windows: [])]
        )
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub,
            listWindowsStub: listWindowsStub
        )

        await vm.performInitialWarmUp(minimumSplashDuration: .zero)

        XCTAssertEqual(getAppIconStub.callCount, 1)
    }

    func test_performInitialWarmUp_keepsIsInitializingTrueUntilMinimumDurationElapses() async {
        let vm = makeViewModel(reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)))

        let task = Task { @MainActor in
            await vm.performInitialWarmUp(minimumSplashDuration: .milliseconds(300))
        }
        try? await Task.sleep(for: .milliseconds(50))
        let snapshot = vm.isInitializing
        await task.value

        XCTAssertTrue(snapshot)
    }

    func test_refreshWindows_preWarmsIconCacheForActiveApps() {
        let response = AppIconResponse(pngData: makeValidPNGData())
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: response)
        let listWindowsStub = StubSyncUseCase<ListWindowsRequest, [WindowGroupResponse]>(
            stubbedResult: [
                WindowGroupResponse(appName: "FooApp", windows: []),
                WindowGroupResponse(appName: "BarApp", windows: [])
            ]
        )
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub,
            listWindowsStub: listWindowsStub
        )

        vm.refreshWindows()

        XCTAssertEqual(getAppIconStub.callCount, 2)
    }

    func test_refreshWindows_prunesIconCacheForInactiveApps() {
        let response = AppIconResponse(pngData: makeValidPNGData())
        let getAppIconStub = StubSyncUseCase<GetAppIconRequest, AppIconResponse?>(stubbedResult: response)
        let listWindowsStub = StubSyncUseCase<ListWindowsRequest, [WindowGroupResponse]>(
            stubbedResult: [WindowGroupResponse(appName: "Keep", windows: [])]
        )
        let vm = makeViewModel(
            reorderStub: StubSyncUseCase(stubbedResult: PinnedWindowListResponse(from: .empty)),
            getAppIconStub: getAppIconStub,
            listWindowsStub: listWindowsStub
        )
        _ = vm.appIcon(localizedName: "Stale")
        _ = vm.appIcon(localizedName: "Keep")
        XCTAssertEqual(getAppIconStub.callCount, 2)

        vm.refreshWindows()
        _ = vm.appIcon(localizedName: "Keep")
        _ = vm.appIcon(localizedName: "Stale")

        XCTAssertEqual(getAppIconStub.callCount, 3)
    }

    func test_reorderPinnedWindows_doesNotMutateStateOnUseCaseError() {
        let reorderStub = StubSyncUseCase<ReorderPinnedWindowsRequest, PinnedWindowListResponse>(
            stubbedResult: PinnedWindowListResponse(from: .empty)
        )
        reorderStub.stubbedError = ValidationError.emptyPinOrder
        let vm = makeViewModel(reorderStub: reorderStub)
        let original = vm.pinnedWindows

        vm.reorderPinnedWindows([1, 2])

        XCTAssertEqual(vm.pinnedWindows, original)
    }
}
