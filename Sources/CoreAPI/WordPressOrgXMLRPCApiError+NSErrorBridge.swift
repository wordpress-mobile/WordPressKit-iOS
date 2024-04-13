/// See `extension WordPressComRestApiEndpointError: CustomNSError` for documentation and rationale.
extension WordPressOrgXMLRPCApiError: CustomNSError {

    public static let errorDomain = WordPressOrgXMLRPCApiErrorDomain

    public var errorCode: Int { self.rawValue }

    public var errorUserInfo: [String: Any] { [:] }
}
