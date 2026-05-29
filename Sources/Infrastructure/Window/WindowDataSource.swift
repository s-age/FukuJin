import CoreGraphics
import Foundation

final class WindowDataSource: WindowDataSourceProtocol, Sendable {
    func listVisibleWindows() -> [WindowDTO] {
        guard let infoList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return []
        }

        let selfPID = ProcessInfo.processInfo.processIdentifier
        var results: [WindowDTO] = []

        for info in infoList {
            guard let wid = info[kCGWindowNumber as String] as? UInt32,
                  let ownerPID = info[kCGWindowOwnerPID as String] as? Int32,
                  let ownerName = info[kCGWindowOwnerName as String] as? String,
                  let layer = info[kCGWindowLayer as String] as? Int,
                  layer == 0,
                  ownerPID != selfPID
            else { continue }

            let windowName = info[kCGWindowName as String] as? String ?? ""
            results.append(WindowDTO(
                windowID: wid,
                ownerPID: ownerPID,
                ownerName: ownerName,
                windowName: windowName
            ))
        }

        return results
    }
}
