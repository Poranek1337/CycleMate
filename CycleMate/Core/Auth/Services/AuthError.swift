enum AuthError: Error {
    case userNotFound
    case networkError(String)
    case profileUpdateFailed
    case configurationError
    case presentationError
    case invalidCredential
}