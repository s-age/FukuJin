import Synchronization

final class PinDomainService: PinDomainServiceProtocol, Sendable {
    private let state: Mutex<PinnedWindowList> = Mutex(.empty)
    private let defaultConfigState: Mutex<OverlayConfig>
    private let settingsRepository: any SettingsRepositoryProtocol

    init(settingsRepository: any SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
        let loaded = settingsRepository.loadDefaultConfig()
        self.defaultConfigState = Mutex(loaded)
    }

    func pin(_ window: WindowInfo, config: OverlayConfig) -> PinnedWindowList {
        state.withLock { current in
            let next = current.pinning(window, seed: config)
            current = next
            return next
        }
    }

    func unpin(_ windowID: UInt32) -> PinnedWindowList {
        state.withLock { current in
            let next = current.unpinning(windowID)
            current = next
            return next
        }
    }

    func unpinAll() -> PinnedWindowList {
        state.withLock { current in
            let next = current.unpinningAll()
            current = next
            return next
        }
    }

    func mutateWindow(
        windowID: UInt32,
        transform: @Sendable (PinnedWindow) throws -> PinnedWindow
    ) throws -> PinnedWindowList {
        try state.withLock { current in
            let next = try current.mutatingWindow(windowID, transform: transform)
            current = next
            return next
        }
    }

    func currentState() -> PinnedWindowList {
        state.withLock { $0 }
    }

    func prune(keeping activeIDs: Set<UInt32>) -> PinnedWindowList {
        state.withLock { current in
            let next = current.pruning(keeping: activeIDs)
            current = next
            return next
        }
    }

    func defaultConfig() -> OverlayConfig {
        defaultConfigState.withLock { $0 }
    }

    func updateDefaultConfig(_ config: OverlayConfig) throws -> OverlayConfig {
        try settingsRepository.saveDefaultConfig(config)
        defaultConfigState.withLock { current in
            current = config
        }
        return config
    }

    func reorder(_ newOrder: [UInt32]) -> PinnedWindowList {
        state.withLock { current in
            let next = current.reordering(newOrder)
            current = next
            return next
        }
    }
}
