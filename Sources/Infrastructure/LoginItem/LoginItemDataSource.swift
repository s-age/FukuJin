import ServiceManagement

final class LoginItemDataSource: LoginItemDataSourceProtocol, Sendable {
    func isEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws {
        let service = SMAppService.mainApp
        if enabled {
            try service.register()
        } else {
            try service.unregister()
        }
    }
}
