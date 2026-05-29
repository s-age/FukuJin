final class ScanTextUseCase: AsyncUseCase, Sendable {
    private let textWatchService: any TextWatchDomainServiceProtocol

    init(textWatchService: any TextWatchDomainServiceProtocol) {
        self.textWatchService = textWatchService
    }

    func execute(_ request: ScanTextRequest) async throws -> ScanTextResponse {
        let config = ScanConfig.default
            .applying(searchText: request.searchText)
            .applying(isScanning: true)
        let entity = CapturedImageRef(
            resolution: .oneShot(snapshotID: request.imageID),
            windowID: request.windowID,
            bounds: BoundingBox(
                x: request.bounds.x,
                y: request.bounds.y,
                width: request.bounds.width,
                height: request.bounds.height
            )
        )
        let result = try await textWatchService.scanAndMatch(image: entity, config: config)
        return ScanTextResponse(
            matched: result.matched,
            windowID: request.windowID,
            matchedBoundingBoxes: result.matchedBoundingBoxes.map(BoundingBoxResponse.init(from:))
        )
    }
}
