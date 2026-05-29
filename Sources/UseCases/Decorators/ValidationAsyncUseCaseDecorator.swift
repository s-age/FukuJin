final class ValidationAsyncUseCaseDecorator<R: UseCaseRequest, Res>: AsyncUseCase, Sendable
    where Res: Sendable
{
    private let decoratee: any AsyncUseCase<R, Res>

    init(decoratee: any AsyncUseCase<R, Res>) {
        self.decoratee = decoratee
    }

    func execute(_ request: R) async throws -> Res {
        try request.validate()
        return try await decoratee.execute(request)
    }
}
