import Foundation
@testable import FukuJin

final class SettingsDataSourceMock: SettingsDataSourceProtocol, @unchecked Sendable {
    var loadResult: SettingsDTO?
    var loadCallCount = 0

    var savedDTOs: [SettingsDTO] = []
    var saveCallCount = 0
    var saveError: Error?

    func load() -> SettingsDTO? {
        loadCallCount += 1
        return loadResult
    }

    func save(_ dto: SettingsDTO) throws {
        saveCallCount += 1
        savedDTOs.append(dto)
        if let saveError {
            throw saveError
        }
    }
}
