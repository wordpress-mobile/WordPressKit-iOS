import Foundation
import wpxmlrpc
import Alamofire

/// Class to connect to the XMLRPC API on self hosted sites.
open class WordPressOrgXMLRPCApi: NSObject {
    public typealias SuccessResponseBlock = (AnyObject, HTTPURLResponse?) -> Void
    public typealias FailureReponseBlock = (_ error: NSError, _ httpResponse: HTTPURLResponse?) -> Void

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

        let  taskDidReceiveChallengeWithCompletion: ((URLSession, URLSessionTask, URLAuthenticationChallenge, @escaping(URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void) = { [sessionDelegate] session, task, authenticationChallenge, completionHandler in
            sessionDelegate.urlSession(session, task: task, didReceive: authenticationChallenge, completionHandler: completionHandler)
        }
        sessionManager.delegate.taskDidReceiveChallengeWithCompletion = taskDidReceiveChallengeWithCompletion
        return sessionManager
    }

    private let sessionDelegate = SessionDelegate()

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
        _sessionManager?.session.finishTasksAndInvalidate()
        _uploadSessionManager?.session.finishTasksAndInvalidate()
    }

    /**
     Cancels all ongoing and makes the session so the object will not fullfil any more request
     */
    @objc open func invalidateAndCancelTasks() {
        sessionManager.session.invalidateAndCancel()
        uploadSessionManager.session.invalidateAndCancel()
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
                    throw convertError(unwrappedError, data: originalData)
                } else {
                    throw convertError(WordPressOrgXMLRPCApiError.unknown as NSError, data: originalData)
                }
        }

        if (400..<600).contains(httpResponse.statusCode) {
            if let decoder = WPXMLRPCDecoder(data: data), decoder.isFault(), let decoderError = decoder.error() {
                // when XML-RPC is disabled for authenticated calls (e.g. xmlrpc_enabled is false on WP.org),
                // it will return a valid fault payload with a non-200
                throw decoderError
            } else {
                throw convertError(WordPressOrgXMLRPCApiError.httpErrorStatusCode as NSError, data: originalData, statusCode: httpResponse.statusCode)
            }
        }

        if ["application/xml", "text/xml"].filter({ (type) -> Bool in return contentType.hasPrefix(type)}).count == 0 {
            throw convertError(WordPressOrgXMLRPCApiError.responseSerializationFailed as NSError, data: originalData)
        }

        guard let decoder = WPXMLRPCDecoder(data: data) else {
            throw WordPressOrgXMLRPCApiError.responseSerializationFailed
        }
        guard !(decoder.isFault()), let responseXML = decoder.object() else {
            if let decoderError = decoder.error() {
                throw convertError(decoderError as NSError, data: data)
            } else {
                throw WordPressOrgXMLRPCApiError.responseSerializationFailed
            }
        }

        return responseXML as AnyObject
    }

    @objc public static let WordPressOrgXMLRPCApiErrorKeyData: NSError.UserInfoKey = "WordPressOrgXMLRPCApiErrorKeyData"
    @objc public static let WordPressOrgXMLRPCApiErrorKeyDataString: NSError.UserInfoKey = "WordPressOrgXMLRPCApiErrorKeyDataString"
    @objc public static let WordPressOrgXMLRPCApiErrorKeyStatusCode: NSError.UserInfoKey = "WordPressOrgXMLRPCApiErrorKeyStatusCode"

    private func convertError(_ error: NSError, data: Data?, statusCode: Int? = nil) -> NSError {
        let responseCode = statusCode == 403 ? 403 : error.code
        if let data = data {
            var userInfo: [AnyHashable: Any] = error.userInfo
            userInfo[type(of: self).WordPressOrgXMLRPCApiErrorKeyData] = data
            userInfo[type(of: self).WordPressOrgXMLRPCApiErrorKeyDataString] = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            userInfo[type(of: self).WordPressOrgXMLRPCApiErrorKeyStatusCode] = statusCode
            userInfo[NSLocalizedFailureErrorKey] = error.localizedDescription

            if let statusCode = statusCode, (400..<600).contains(statusCode) {
                let formatString = NSLocalizedString("An HTTP error code %i was returned.", comment: "A failure reason for when an error HTTP status code was returned from the site, with the specific error code.")
                userInfo[NSLocalizedFailureReasonErrorKey] = String(format: formatString, statusCode)
            } else {
                userInfo[NSLocalizedFailureReasonErrorKey] = error.localizedFailureReason
            }

            return NSError(domain: error.domain, code: responseCode, userInfo: userInfo as? [String: Any])
        }
        return error
    }
}

private class SessionDelegate: NSObject, URLSessionDelegate {

    @objc public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

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

    @objc public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

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
