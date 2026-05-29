import Foundation

protocol WorkspaceRepositoryProtocol: Sendable {
    func observeAppActivation() -> AsyncStream<Int32>
    func frontmostApplicationPID() -> Int32?
    func activateApp(pid: Int32)
}
