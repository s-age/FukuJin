final class ValidationSyncUseCaseDecorator<R: UseCaseRequest, Res>: SyncUseCase, Sendable
    where Res: Sendable
{
    private let decoratee: any SyncUseCase<R, Res>

    init(decoratee: any SyncUseCase<R, Res>) {
        self.decoratee = decoratee
    }

    func execute(_ request: R) throws -> Res {
        try request.validate()
        return try decoratee.execute(request)
    }
}
