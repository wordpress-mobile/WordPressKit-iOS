import Foundation

/// Error domain of `NSError` instances that are converted from `WordPressOrgXMLRPCApiError`
/// and `WordPressAPIError<WordPressOrgXMLRPCApiError>` instances.
///
/// See `extension WordPressOrgXMLRPCApiError: CustomNSError` for context.
let WordPressOrgXMLRPCApiErrorDomain = "WordPressKit.WordPressOrgXMLRPCApiError"

// WordPressOrgXMLRPCApiErrorDomain is accessible only in Swift and, since it's a global, cannot be made @objc.
// As a workaround, here is a builder to init NSError with that domain and a method to check the domain.
@objc
public extension NSError {

    @objc
    static func wordPressOrgXMLRPCApiError(
        code: Int,
        userInfo: [String: Any]?
    ) -> NSError {
        NSError(
            domain: WordPressOrgXMLRPCApiErrorDomain,
            code: code,
            userInfo: userInfo
        )
    }

    @objc
    func hasWordPressOrgXMLRPCApiErrorDomain() -> Bool {
        domain == WordPressOrgXMLRPCApiErrorDomain
    }
}
