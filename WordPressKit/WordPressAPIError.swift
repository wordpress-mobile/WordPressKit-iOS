import Foundation

public enum WordPressAPIError<EndpointError>: Error where EndpointError: LocalizedError {
    static var unknownErrorMessage: String {
        NSLocalizedString(
            "wordpress-api.error.unknown",
            value: "Something went wrong, please try again later.",
            comment: "Error message that describes an unknown error had occured"
        )
    }

    /// Can't encode the request arguments into a valid HTTP request. This is a programming error.
    case requestEncodingFailure
    /// Error occured in the HTTP connection.
    case connection(URLError)
    /// The API call returned an error result. For example, an OAuth endpoint may return an 'incorrect username or password' error, an upload media endpoint may return an 'unsupported media type' error.
    case endpointError(EndpointError)
    /// The API call returned an HTTP response that WordPressKit can't parse. Receiving this error could be an indicator that there is an error response that's not handled properly by WordPressKit.
    case unparsableResponse(response: HTTPURLResponse?, body: Data?)
    /// Other error occured.
    case unknown(underlyingError: Error)
}

extension WordPressComOAuthError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .requestEncodingFailure, .unparsableResponse:
            // These are usually programming errors.
            return Self.unknownErrorMessage
        case let .endpointError(error):
            return error.errorDescription
        case let .connection(error):
            return error.localizedDescription
        case let .unknown(underlyingError):
            if let msg = (underlyingError as? LocalizedError)?.errorDescription {
                return msg
            }
            return Self.unknownErrorMessage
        }
    }

}
