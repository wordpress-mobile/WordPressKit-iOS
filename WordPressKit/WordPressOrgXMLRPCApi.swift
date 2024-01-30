import Foundation
import wpxmlrpc
import Alamofire

/// Class to connect to the XMLRPC API on self hosted sites.
open class WordPressOrgXMLRPCApi: NSObject {
    public typealias SuccessResponseBlock = (AnyObject, HTTPURLResponse?) -> Void
    public typealias FailureReponseBlock = (_ error: NSError, _ httpResponse: HTTPURLResponse?) -> Void

    public static var useURLSession = false

    private let endpoint: URL
    private let userAgent: String?
    private var backgroundUploads: Bool
    private var backgroundSessionIdentifier: String
    @objc public static let defaultBackgroundSessionIdentifier = "org.wordpress.wporgxmlrpcapi"

    /// onChallenge's Callback Closure Signature. Host Apps should call this method, whenever a proper AuthChallengeDisposition has been
    /// picked up (optionally with URLCredentials!).
    ///
    public typealias AuthenticationHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

    /// Closure to be executed whenever we receive a URLSession Authentication Challenge.
    ///
    public static var onChallenge: ((URLAuthenticationChallenge, @escaping AuthenticationHandler) -> Void)?

    /// Minimum WordPress.org Supported Version.
    ///
    @objc public static let minimumSupportedVersion = "4.0"

    private lazy var urlSession: URLSession = makeSession(configuration: .default)
    private lazy var uploadURLSession: URLSession = {
        backgroundUploads
            ? makeSession(configuration: .background(withIdentifier: self.backgroundSessionIdentifier))
            : urlSession
    }()

    private var _sessionManager: Alamofire.SessionManager?
    private var sessionManager: Alamofire.SessionManager {
        guard let sessionManager = _sessionManager else {
            let sessionConfiguration = URLSessionConfiguration.default
            let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
            _sessionManager = sessionManager
            return sessionManager
        }
        return sessionManager
    }

    private var _uploadSessionManager: Alamofire.SessionManager?
    private var uploadSessionManager: Alamofire.SessionManager {
        if self.backgroundUploads {
            guard let uploadSessionManager = _uploadSessionManager else {
                let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: self.backgroundSessionIdentifier)
                let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
                _uploadSessionManager = sessionManager
                return sessionManager
            }
            return uploadSessionManager
        }
        return sessionManager
    }

    private func makeSessionManager(configuration sessionConfiguration: URLSessionConfiguration) -> Alamofire.SessionManager {
        var additionalHeaders: [String: AnyObject] = ["Accept-Encoding": "gzip, deflate" as AnyObject]
        if let userAgent = self.userAgent {
            additionalHeaders["User-Agent"] = userAgent as AnyObject?
        }
        sessionConfiguration.httpAdditionalHeaders = additionalHeaders
        let sessionManager = Alamofire.SessionManager(configuration: sessionConfiguration)

        let sessionDidReceiveChallengeWithCompletion: ((URLSession, URLAuthenticationChallenge, @escaping(URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void) = { [sessionDelegate] session, authenticationChallenge, completionHandler in
            sessionDelegate.urlSession(session, didReceive: authenticationChallenge, completionHandler: completionHandler)
        }
        sessionManager.delegate.sessionDidReceiveChallengeWithCompletion = sessionDidReceiveChallengeWithCompletion

        let taskDidReceiveChallengeWithCompletion: ((URLSession, URLSessionTask, URLAuthenticationChallenge, @escaping(URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void) = { [sessionDelegate] session, task, authenticationChallenge, completionHandler in
            sessionDelegate.urlSession(session, task: task, didReceive: authenticationChallenge, completionHandler: completionHandler)
        }
        sessionManager.delegate.taskDidReceiveChallengeWithCompletion = taskDidReceiveChallengeWithCompletion
        return sessionManager
    }

    private func makeSession(configuration sessionConfiguration: URLSessionConfiguration) -> URLSession {
        var additionalHeaders: [String: AnyObject] = ["Accept-Encoding": "gzip, deflate" as AnyObject]
        if let userAgent = self.userAgent {
            additionalHeaders["User-Agent"] = userAgent as AnyObject?
        }
        sessionConfiguration.httpAdditionalHeaders = additionalHeaders
        return URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
    }

    // swiftlint:disable weak_delegate
    /// `URLSessionDelegate` for the URLSession instances in this class.
    private let sessionDelegate = SessionDelegate()
    // swiftlint:enable weak_delegate

    /// Creates a new API object to connect to the WordPress XMLRPC API for the specified endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: the endpoint to connect to the xmlrpc api interface.
    ///   - userAgent: the user agent to use on the connection.
    ///   - backgroundUploads:  If this value is true the API object will use a background session to execute uploads requests when using the `multipartPOST` function. The default value is false.
    ///   - backgroundSessionIdentifier: The session identifier to use for the background session. This must be unique in the system.
    @objc public init(endpoint: URL, userAgent: String? = nil, backgroundUploads: Bool = false, backgroundSessionIdentifier: String) {
        self.endpoint = endpoint
        self.userAgent = userAgent
        self.backgroundUploads = backgroundUploads
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
        super.init()
    }

    /// Creates a new API object to connect to the WordPress XMLRPC API for the specified endpoint. The background uploads are disabled when using this initializer.
    ///
    /// - Parameters:
    ///   - endpoint:  the endpoint to connect to the xmlrpc api interface.
    ///   - userAgent: the user agent to use on the connection.
    @objc convenience public init(endpoint: URL, userAgent: String? = nil) {
        self.init(endpoint: endpoint, userAgent: userAgent, backgroundUploads: false, backgroundSessionIdentifier: WordPressOrgXMLRPCApi.defaultBackgroundSessionIdentifier + "." + endpoint.absoluteString)
    }

    deinit {
        for session in [urlSession, uploadURLSession, sessionManager.session, uploadSessionManager.session] {
            session.finishTasksAndInvalidate()
        }
    }

    /**
     Cancels all ongoing and makes the session so the object will not fullfil any more request
     */
    @objc open func invalidateAndCancelTasks() {
        for session in [urlSession, uploadURLSession, sessionManager.session, uploadSessionManager.session] {
            session.invalidateAndCancel()
        }
    }

    // MARK: - Network requests
    /**
     Check if username and password are valid credentials for the xmlrpc endpoint.

     - parameter username: username to check
     - parameter password: password to check
     - parameter success:  callback block to be invoked if credentials are valid, the object returned in the block is the options dictionary for the site.
     - parameter failure:  callback block to be invoked is credentials fail
     */
    @objc open func checkCredentials(_ username: String,
                                 password: String,
                                 success: @escaping SuccessResponseBlock,
                                 failure: @escaping FailureReponseBlock) {
        let parameters: [AnyObject] = [0 as AnyObject, username as AnyObject, password as AnyObject]
        callMethod("wp.getOptions", parameters: parameters, success: success, failure: failure)
    }
    /**
     Executes a XMLRPC call for the method specificied with the arguments provided.

     - parameter method:  the xmlrpc method to be invoked
     - parameter parameters: the parameters to be encoded on the request
     - parameter success:    callback to be called on successful request
     - parameter failure:    callback to be called on failed request

     - returns:  a NSProgress object that can be used to track the progress of the request and to cancel the request. If the method
     returns nil it's because something happened on the request serialization and the network request was not started, but the failure callback
     will be invoked with the error specificing the serialization issues.
     */
    @objc @discardableResult open func callMethod(_ method: String,
                           parameters: [AnyObject]?,
                           success: @escaping SuccessResponseBlock,
                           failure: @escaping FailureReponseBlock) -> Progress? {
        guard !WordPressOrgXMLRPCApi.useURLSession else {
            let progress = Progress.discreteProgress(totalUnitCount: 100)
            Task { @MainActor in
                let result = await self.call(method: method, parameters: parameters, fulfilling: progress, streaming: false)
                switch result {
                case let .success(response):
                    success(response.body, response.response)
                case let .failure(error):
                    failure(error.asNSError(), error.response)
                }
            }
            return progress
        }

        // Encode request
        let request: URLRequest
        do {
            request = try requestWithMethod(method, parameters: parameters)
        } catch let encodingError as NSError {
            failure(encodingError, nil)
            return nil
        }

        let progress: Progress = Progress.discreteProgress(totalUnitCount: 1)
        sessionManager.request(request)
            .downloadProgress { (requestProgress) in
                progress.totalUnitCount = requestProgress.totalUnitCount + 1
                progress.completedUnitCount = requestProgress.completedUnitCount
            }.response(queue: DispatchQueue.global()) { (response) in
                do {
                    let responseObject = try self.handleResponseWithData(response.data, urlResponse: response.response, error: response.error as NSError?)
                    DispatchQueue.main.async {
                        progress.completedUnitCount = progress.totalUnitCount
                        success(responseObject, response.response)
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        progress.completedUnitCount = progress.totalUnitCount
                        failure(error, response.response)
                    }
                    return
                }
            }
        return progress
    }

    /**
     Executes a XMLRPC call for the method specificied with the arguments provided, by streaming the request from a file.
     This allows to do requests that can use a lot of memory, like media uploads.

     - parameter method:  the xmlrpc method to be invoked
     - parameter parameters: the parameters to be encoded on the request
     - parameter success:    callback to be called on successful request
     - parameter failure:    callback to be called on failed request

     - returns:  a NSProgress object that can be used to track the progress of the request and to cancel the request. If the method
     returns nil it's because something happened on the request serialization and the network request was not started, but the failure callback
     will be invoked with the error specificing the serialization issues.
     */
    @objc @discardableResult open func streamCallMethod(_ method: String,
                                 parameters: [AnyObject]?,
                                 success: @escaping SuccessResponseBlock,
                                 failure: @escaping FailureReponseBlock) -> Progress? {
        guard !WordPressOrgXMLRPCApi.useURLSession else {
            let progress = Progress.discreteProgress(totalUnitCount: 100)
            Task { @MainActor in
                let result = await self.call(method: method, parameters: parameters, fulfilling: progress, streaming: true)
                switch result {
                case let .success(response):
                    success(response.body, response.response)
                case let .failure(error):
                    failure(error.asNSError(), error.response)
                }
            }
            return progress
        }

        let progress: Progress = Progress.discreteProgress(totalUnitCount: 1)
        progress.isCancellable = true
        DispatchQueue.global().async {
            let fileURL = self.URLForTemporaryFile()
            // Encode request
            let request: URLRequest
            do {
                request = try self.streamingRequestWithMethod(method, parameters: parameters, usingFileURLForCache: fileURL)
            } catch let encodingError as NSError {
                failure(encodingError, nil)
                return
            }

            let uploadRequest = self.uploadSessionManager.upload(fileURL, with: request)
                .uploadProgress { (requestProgress) in
                    progress.totalUnitCount = requestProgress.totalUnitCount + 1
                    progress.completedUnitCount = requestProgress.completedUnitCount
                }.response(queue: DispatchQueue.global()) { (response) in
                    do {
                        let responseObject = try self.handleResponseWithData(response.data, urlResponse: response.response, error: response.error as NSError?)
                        DispatchQueue.main.async {
                            progress.completedUnitCount = progress.totalUnitCount
                            success(responseObject, response.response)
                        }
                    } catch let error as NSError {
                        DispatchQueue.main.async {
                            progress.completedUnitCount = progress.totalUnitCount
                            failure(error, response.response)
                        }
                        return
                    }
              }
            progress.cancellationHandler = {
              uploadRequest.cancel()
            }
        }

        return progress
    }

    func call(method: String, parameters: [AnyObject]?, fulfilling progress: Progress, streaming: Bool = false) async -> WordPressAPIResult<HTTPAPIResponse<AnyObject>, WordPressOrgXMLRPCApiFault> {
        let session = streaming ? uploadURLSession : urlSession
        let builder = HTTPRequestBuilder(url: endpoint)
            .method(.post)
            .body(xmlrpc: method, parameters: parameters)
        return await session
            .perform(
                request: builder,
                // All HTTP responses are treated as successful result. Error handling will be done in `decodeXMLRPCResult`.
                acceptableStatusCodes: [1...999],
                fulfilling: progress,
                errorType: WordPressOrgXMLRPCApiFault.self
            )
            .decodeXMLRPCResult()
    }

    // MARK: - Request Building

    private func requestWithMethod(_ method: String, parameters: [AnyObject]?) throws -> URLRequest {
        let mutableRequest = NSMutableURLRequest(url: endpoint)
        mutableRequest.httpMethod = "POST"
        mutableRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        let encoder = WPXMLRPCEncoder(method: method, andParameters: parameters)
        mutableRequest.httpBody = try encoder.dataEncoded()

        return mutableRequest as URLRequest
    }

    private func streamingRequestWithMethod(_ method: String, parameters: [AnyObject]?, usingFileURLForCache fileURL: URL) throws -> URLRequest {
        let mutableRequest = NSMutableURLRequest(url: endpoint)
        mutableRequest.httpMethod = "POST"
        mutableRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        let encoder = WPXMLRPCEncoder(method: method, andParameters: parameters)
        try encoder.encode(toFile: fileURL.path)
        var optionalFileSize: AnyObject?
        try (fileURL as NSURL).getResourceValue(&optionalFileSize, forKey: URLResourceKey.fileSizeKey)
        if let fileSize = optionalFileSize as? NSNumber {
            mutableRequest.setValue(fileSize.stringValue, forHTTPHeaderField: "Content-Length")
        }

        return mutableRequest as URLRequest
    }

    private func URLForTemporaryFile() -> URL {
        let fileName = "\(ProcessInfo.processInfo.globallyUniqueString)_file.xmlrpc"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        return fileURL
    }

    // MARK: - Handling of data

    private func handleResponseWithData(_ originalData: Data?, urlResponse: URLResponse?, error: NSError?) throws -> AnyObject {
        guard let data = originalData,
            let httpResponse = urlResponse as? HTTPURLResponse,
            let contentType = httpResponse.allHeaderFields["Content-Type"] as? String, error == nil else {
                if let unwrappedError = error {
                    throw Self.convertError(unwrappedError, data: originalData)
                } else {
                    throw Self.convertError(WordPressOrgXMLRPCApiError.unknown as NSError, data: originalData)
                }
        }

        if (400..<600).contains(httpResponse.statusCode) {
            if let decoder = WPXMLRPCDecoder(data: data), decoder.isFault(), let decoderError = decoder.error() {
                // when XML-RPC is disabled for authenticated calls (e.g. xmlrpc_enabled is false on WP.org),
                // it will return a valid fault payload with a non-200
                throw decoderError
            } else {
                throw Self.convertError(WordPressOrgXMLRPCApiError.httpErrorStatusCode as NSError, data: originalData, statusCode: httpResponse.statusCode)
            }
        }

        if ["application/xml", "text/xml"].filter({ (type) -> Bool in return contentType.hasPrefix(type)}).count == 0 {
            throw Self.convertError(WordPressOrgXMLRPCApiError.responseSerializationFailed as NSError, data: originalData)
        }

        guard let decoder = WPXMLRPCDecoder(data: data) else {
            throw WordPressOrgXMLRPCApiError.responseSerializationFailed
        }
        guard !(decoder.isFault()), let responseXML = decoder.object() else {
            if let decoderError = decoder.error() {
                throw Self.convertError(decoderError as NSError, data: data)
            } else {
                throw WordPressOrgXMLRPCApiError.responseSerializationFailed
            }
        }

        return responseXML as AnyObject
    }

    @objc public static let WordPressOrgXMLRPCApiErrorKeyData: NSError.UserInfoKey = "WordPressOrgXMLRPCApiErrorKeyData"
    @objc public static let WordPressOrgXMLRPCApiErrorKeyDataString: NSError.UserInfoKey = "WordPressOrgXMLRPCApiErrorKeyDataString"
    @objc public static let WordPressOrgXMLRPCApiErrorKeyStatusCode: NSError.UserInfoKey = "WordPressOrgXMLRPCApiErrorKeyStatusCode"

    fileprivate static func convertError(_ error: NSError, data: Data?, statusCode: Int? = nil) -> NSError {
        let responseCode = statusCode == 403 ? 403 : error.code
        if let data = data {
            var userInfo: [String: Any] = error.userInfo
            userInfo[Self.WordPressOrgXMLRPCApiErrorKeyData as String] = data
            userInfo[Self.WordPressOrgXMLRPCApiErrorKeyDataString as String] = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            userInfo[Self.WordPressOrgXMLRPCApiErrorKeyStatusCode as String] = statusCode
            userInfo[NSLocalizedFailureErrorKey] = error.localizedDescription

            if let statusCode = statusCode, (400..<600).contains(statusCode) {
                let formatString = NSLocalizedString("An HTTP error code %i was returned.", comment: "A failure reason for when an error HTTP status code was returned from the site, with the specific error code.")
                userInfo[NSLocalizedFailureReasonErrorKey] = String(format: formatString, statusCode)
            } else {
                userInfo[NSLocalizedFailureReasonErrorKey] = error.localizedFailureReason
            }

            return NSError(domain: error.domain, code: responseCode, userInfo: userInfo)
        }
        return error
    }
}

private class SessionDelegate: NSObject, URLSessionDelegate {

    @objc func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {

        switch challenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodServerTrust:
            if let credential = URLCredentialStorage.shared.defaultCredential(for: challenge.protectionSpace), challenge.previousFailureCount == 0 {
                completionHandler(.useCredential, credential)
                return
            }

            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            _ = SecTrustEvaluateWithError(serverTrust, nil)
            var result = SecTrustResultType.invalid
            let certificateStatus = SecTrustGetTrustResult(serverTrust, &result)

            guard let hostAppHandler = WordPressOrgXMLRPCApi.onChallenge, certificateStatus == 0, result == .recoverableTrustFailure else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            DispatchQueue.main.async {
                hostAppHandler(challenge, completionHandler)
            }

        default:
            completionHandler(.performDefaultHandling, nil)
        }
    }

    @objc func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {

        switch challenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodHTTPBasic:
            if let credential = URLCredentialStorage.shared.defaultCredential(for: challenge.protectionSpace), challenge.previousFailureCount == 0 {
                completionHandler(.useCredential, credential)
                return
            }

            guard let hostAppHandler = WordPressOrgXMLRPCApi.onChallenge else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            DispatchQueue.main.async {
                hostAppHandler(challenge, completionHandler)
            }

        default:
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

/// Error constants for the WordPress XML-RPC API
@objc public enum WordPressOrgXMLRPCApiError: Int, Error {
    /// An error HTTP status code was returned.
    case httpErrorStatusCode
    /// The serialization of the request failed.
    case requestSerializationFailed
    /// The serialization of the response failed.
    case responseSerializationFailed
    /// An unknown error occurred.
    case unknown
}

extension WordPressOrgXMLRPCApiError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString("There was a problem communicating with the site.", comment: "A general error message shown to the user when there was an API communication failure.")
    }

    public var failureReason: String? {
        switch self {
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

public struct WordPressOrgXMLRPCApiFault: LocalizedError, HTTPURLResponseProviding {
    var response: HTTPAPIResponse<Data>

    var code: Int?
    var message: String?

    public var errorDescription: String? {
        message
    }

    var httpResponse: HTTPURLResponse? {
        response.response
    }
}

private extension WordPressAPIResult<HTTPAPIResponse<Data>, WordPressOrgXMLRPCApiFault> {

    func decodeXMLRPCResult() -> WordPressAPIResult<HTTPAPIResponse<AnyObject>, WordPressOrgXMLRPCApiFault> {
        // This is a re-implementation of `WordPressOrgXMLRPCApi.handleResponseWithData` function:
        // https://github.com/wordpress-mobile/WordPressKit-iOS/blob/11.0.0/WordPressKit/WordPressOrgXMLRPCApi.swift#L265
        flatMap { response in
            guard let contentType = response.response.allHeaderFields["Content-Type"] as? String else {
                return .failure(.unparsableResponse(response: response.response, body: response.body, underlyingError: WordPressOrgXMLRPCApiError.unknown))
            }

            if (400..<600).contains(response.response.statusCode) {
                if let decoder = WPXMLRPCDecoder(data: response.body), decoder.isFault() {
                    // when XML-RPC is disabled for authenticated calls (e.g. xmlrpc_enabled is false on WP.org),
                    // it will return a valid fault payload with a non-200
                    return .failure(.endpointError(.init(response: response, code: decoder.faultCode(), message: decoder.faultString())))
                } else {
                    return .failure(.unacceptableStatusCode(response: response.response, body: response.body))
                }
            }

            if ["application/xml", "text/xml"].filter({ (type) -> Bool in return contentType.hasPrefix(type)}).count == 0 {
                return .failure(.unparsableResponse(response: response.response, body: response.body, underlyingError: WordPressOrgXMLRPCApiError.unknown))
            }

            guard let decoder = WPXMLRPCDecoder(data: response.body) else {
                return .failure(.unparsableResponse(response: response.response, body: response.body))
            }

            guard !decoder.isFault() else {
                return .failure(.endpointError(.init(response: response, code: decoder.faultCode(), message: decoder.faultString())))
            }

            if let decoderError = decoder.error() {
                return .failure(.unparsableResponse(response: response.response, body: response.body, underlyingError: decoderError))
            }

            guard let responseXML = decoder.object() else {
                return .failure(.unparsableResponse(response: response.response, body: response.body))
            }

            return .success(HTTPAPIResponse(response: response.response, body: responseXML as AnyObject))
        }
    }

}

private extension WordPressAPIError where EndpointError == WordPressOrgXMLRPCApiFault {

    /// Convert to NSError for backwards compatiblity.
    ///
    /// Some Objective-C code in the WordPress app checks domain of the errors returned by `WordPressOrgXMLRPCApi`,
    /// which can be WordPressOrgXMLRPCApiError or WPXMLRPCFaultErrorDomain.
    ///
    /// Swift code should avoid dealing with NSError instances. Instead, they should use the strongly typed
    /// `WordPressAPIError<WordPressOrgXMLRPCApiFault>`.
    func asNSError() -> NSError {
        let error: NSError
        let data: Data?
        let statusCode: Int?
        switch self {
        case let .requestEncodingFailure(underlyingError):
            error = underlyingError as NSError
            data = nil
            statusCode = nil
        case let .connection(urlError):
            error = urlError as NSError
            data = nil
            statusCode = nil
        case let .endpointError(fault):
            error = NSError(domain: WPXMLRPCFaultErrorDomain, code: fault.code ?? 0, userInfo: [NSLocalizedDescriptionKey: fault.message].compactMapValues { $0 })
            data = fault.response.body
            statusCode = nil
        case let .unacceptableStatusCode(response, body):
            error = WordPressOrgXMLRPCApiError.httpErrorStatusCode as NSError
            data = body
            statusCode = response.statusCode
        case let .unparsableResponse(_, body, underlyingError):
            error = underlyingError as NSError
            data = body
            statusCode = nil
        case let .unknown(underlyingError):
            error = underlyingError as NSError
            data = nil
            statusCode = nil
        }

        return WordPressOrgXMLRPCApi.convertError(error, data: data, statusCode: statusCode)
    }

}
