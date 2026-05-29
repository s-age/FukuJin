struct UpdateRecognitionLanguagesRequest: UseCaseRequest, Sendable {
    let languages: [OCRLanguageResponse]

    func validate() throws {
        guard languages.count <= OCRLanguageResponse.allCases.count else {
            throw ValidationError.tooManyRecognitionLanguages
        }
    }
}
