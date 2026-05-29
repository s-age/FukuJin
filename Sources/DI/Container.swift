final class Container {
    let infrastructure: InfrastructureContainer
    let repositories: RepositoryContainer
    let domain: DomainContainer
    let useCases: UseCaseContainer
    let presentation: PresentationContainer

    init() {
        infrastructure = InfrastructureContainer()
        repositories = RepositoryContainer(infrastructure: infrastructure)
        domain = DomainContainer(repositories: repositories)
        useCases = UseCaseContainer(domain: domain)
        let capturedImageStore = infrastructure.capturedImageStore
        presentation = PresentationContainer(
            useCases: useCases,
            resolveFrame: { capturedImageStore.resolveLatest(windowID: $0) }
        )
    }
}
