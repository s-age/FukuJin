import Foundation

enum ValidationError: LocalizedError, Sendable {
    case invalidWindowID
    case invalidOpacity
    case invalidFPS
    case invalidCommandString(String)
    case invalidPID
    case emptyActionList
    case tooManyActions
    case missingAppIdentifier
    case bundleIdentifierTooLong
    case localizedNameTooLong
    case emptyPinOrder
    case tooManyPinEntries
    case duplicatePinOrder
    case emptySearchText
    case searchTextTooLong
    case emptyNotificationTitle
    case notificationTitleTooLong
    case notificationBodyTooLong
    case tooManyRecognitionLanguages

    var errorDescription: String? {
        switch self {
        case .invalidWindowID:
            "Window ID must be greater than 0"
        case .invalidOpacity:
            "Opacity must be between 0.1 and 1.0"
        case .invalidFPS:
            "FPS must be between 1 and 60"
        case .invalidCommandString(let reason):
            "Invalid command: \(reason)"
        case .invalidPID:
            "pid must be greater than 0"
        case .emptyActionList:
            "At least one action is required"
        case .tooManyActions:
            "Actions must be 16 or fewer"
        case .missingAppIdentifier:
            "bundleIdentifier or localizedName is required"
        case .bundleIdentifierTooLong:
            "bundleIdentifier must be 256 characters or fewer"
        case .localizedNameTooLong:
            "localizedName must be 256 characters or fewer"
        case .emptyPinOrder:
            "pin order must not be empty"
        case .tooManyPinEntries:
            "pin order must be 1024 entries or fewer"
        case .duplicatePinOrder:
            "pin order must not contain duplicates"
        case .emptySearchText:
            "Search text must not be empty"
        case .searchTextTooLong:
            "Search text must be 256 characters or fewer"
        case .emptyNotificationTitle:
            "Notification title must not be empty"
        case .notificationTitleTooLong:
            "Notification title must be 256 characters or fewer"
        case .notificationBodyTooLong:
            "Notification body must be 512 characters or fewer"
        case .tooManyRecognitionLanguages:
            "Too many recognition languages selected"
        }
    }
}
