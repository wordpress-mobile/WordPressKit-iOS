import Foundation

public struct WordPressOrgXMLRPCApiError: Error {

    /// Error constants for the WordPress XML-RPC API
    @objc public enum Code: Int, CaseIterable {
        /// An error HTTP status code was returned.
        case httpErrorStatusCode
        /// The serialization of the request failed.
        case requestSerializationFailed
        /// The serialization of the response failed.
        case responseSerializationFailed
        /// An unknown error occurred.
        case unknown
    }

    let code: Code
}

extension WordPressOrgXMLRPCApiError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(
            "There was a problem communicating with the site.",
            comment: "A general error message shown to the user when there was an API communication failure."
        )
    }

    public var failureReason: String? {
        switch code {
        case .httpErrorStatusCode:
            return NSLocalizedString("An HTTP error code was returned.", comment: "A failure reason for when an error HTTP status code was returned from the site.")
        case .requestSerializationFailed:
            return NSLocalizedString("The serialization of the request failed.", comment: "A failure reason for when the request couldn't be serialized.")
        case .responseSerializationFailed:
            return NSLocalizedString("The serialization of the response failed.", comment: "A failure reason for when the response couldn't be serialized.")
        case .unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "A failure reason for when the error that occured wasn't able to be determined.")
        }
    }
}
