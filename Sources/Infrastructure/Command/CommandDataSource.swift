import Foundation

final class CommandDataSource: CommandDataSourceProtocol, Sendable {
    func execute(_ command: String) async throws {
        try await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", command]
            // Discard stdout/stderr entirely: a Pipe with no concurrent reader can
            // deadlock once the OS buffer (~64KB) fills, and surfacing stderr content
            // to the UI would risk leaking sensitive output. Exit status is sufficient.
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                throw InfrastructureError.processExitedNonZero(status: "Exit code \(process.terminationStatus)")
            }
        }.value
    }
}
