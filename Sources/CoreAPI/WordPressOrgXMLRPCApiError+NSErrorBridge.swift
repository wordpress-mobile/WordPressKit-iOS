import Foundation
#if SWIFT_PACKAGE
import APIInterface
#endif

/// See `extension WordPressComRestApiEndpointError: CustomNSError` for documentation and rationale.
extension WordPressOrgXMLRPCApiError: CustomNSError {

    public static let errorDomain = WordPressOrgXMLRPCApiErrorDomain

    public var errorCode: Int { code.rawValue }

    public var errorUserInfo: [String: Any] { [:] }
}
