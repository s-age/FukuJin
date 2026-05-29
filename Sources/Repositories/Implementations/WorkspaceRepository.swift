import Foundation

final class WorkspaceRepository: WorkspaceRepositoryProtocol, AppIconRepositoryProtocol, Sendable {
    private let dataSource: any WorkspaceDataSourceProtocol

    init(dataSource: any WorkspaceDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func observeAppActivation() -> AsyncStream<Int32> {
        dataSource.observeAppActivation()
    }

    func frontmostApplicationPID() -> Int32? {
        dataSource.frontmostApplicationPID()
    }

    func activateApp(pid: Int32) {
        dataSource.activateApp(pid: pid)
    }

    func appIcon(for bundleIdentifier: String?, localizedName: String?) -> Data? {
        dataSource.appIcon(for: bundleIdentifier, localizedName: localizedName)
    }
}
