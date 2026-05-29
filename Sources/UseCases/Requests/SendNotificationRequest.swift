struct SendNotificationRequest: UseCaseRequest, Sendable {
    let title: String
    let body: String

    func validate() throws {
        guard !title.isEmpty else {
            throw ValidationError.emptyNotificationTitle
        }
        guard title.count <= 256 else {
            throw ValidationError.notificationTitleTooLong
        }
        guard body.count <= 512 else {
            throw ValidationError.notificationBodyTooLong
        }
    }
}
