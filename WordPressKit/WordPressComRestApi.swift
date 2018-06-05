import Foundation
import WordPressShared
import Alamofire

/**
 Error constants for the WordPress.com REST API

 - InvalidInput:                   The parameters sent to the server where invalid
 - InvalidToken:                   The token provided was invalid
 - AuthorizationRequired:          Permission required to access resource
 - UploadFailed:                   The upload failed
 - RequestSerializationFailed:     The serialization of the request failed
 - Unknown:                        Unknow error happen
 */
@objc public enum WordPressComRestApiError: Int, Error {
    case invalidInput
    case invalidToken
    case authorizationRequired
    case uploadFailed
    case requestSerializationFailed
    case responseSerializationFailed
    case tooManyRequests
    case unknown
}

open class WordPressComRestApi: NSObject {    
    @objc open static let ErrorKeyErrorCode: String = "WordPressComRestApiErrorCodeKey"
    @objc open static let ErrorKeyErrorMessage: String = "WordPressComRestApiErrorMessageKey"

    public typealias RequestEnqueuedBlock = (_ taskID : NSNumber) -> Void
    public typealias SuccessResponseBlock = (_ responseObject: AnyObject, _ httpResponse: HTTPURLResponse?) -> ()
    public typealias FailureReponseBlock = (_ error: NSError, _ httpResponse: HTTPURLResponse?) -> ()

    @objc open static let apiBaseURLString: String = "https://public-api.wordpress.com/"
    
    @objc open static let defaultBackgroundSessionIdentifier = "org.wordpress.wpcomrestapi"
    
    @objc open let backgroundSessionIdentifier: String

    @objc open let sharedContainerIdentifier: String?
    
    fileprivate let backgroundUploads: Bool

    fileprivate static let localeKey = "locale"

    fileprivate let oAuthToken: String?
    fileprivate let userAgent: String?

    /**
     Configure whether or not the user's preferred language locale should be appended. Defaults to true.
     */
    @objc open var appendsPreferredLanguageLocale = true

    fileprivate lazy var sessionManager: Alamofire.SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
        return sessionManager
    }()

    fileprivate lazy var uploadSessionManager: Alamofire.SessionManager = {
        if self.backgroundUploads {
            let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: self.backgroundSessionIdentifier)
            sessionConfiguration.sharedContainerIdentifier = self.sharedContainerIdentifier
            let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
            return sessionManager
        }
        
        return self.sessionManager
    }()

    fileprivate func makeSessionManager(configuration sessionConfiguration: URLSessionConfiguration) -> Alamofire.SessionManager {
        var additionalHeaders: [String : AnyObject] = [:]
        if let oAuthToken = self.oAuthToken {
            additionalHeaders["Authorization"] = "Bearer \(oAuthToken)" as AnyObject?
        }
        if let userAgent = self.userAgent {
            additionalHeaders["User-Agent"] = userAgent as AnyObject?
        }

        sessionConfiguration.httpAdditionalHeaders = additionalHeaders
        let sessionManager = Alamofire.SessionManager(configuration: sessionConfiguration)

        return sessionManager
    }
    
    @objc convenience public init(oAuthToken: String? = nil, userAgent: String? = nil) {
        self.init(oAuthToken: oAuthToken, userAgent: userAgent, backgroundUploads: false, backgroundSessionIdentifier: WordPressComRestApi.defaultBackgroundSessionIdentifier)
    }
    
    /// Creates a new API object to connect to the WordPress Rest API.
    ///
    /// - Parameters:
    ///   - oAuthToken: the oAuth token to be used for authentication.
    ///   - userAgent: the user agent to identify the client doing the connection.
    ///   - backgroundUploads: If this value is true the API object will use a background session to execute uploads requests when using the `multipartPOST` function. The default value is false.
    ///   - backgroundSessionIdentifier: The session identifier to use for the background session. This must be unique in the system.
    ///   - sharedContainerIdentifier: An optional string used when setting up background sessions for use in an app extension. Default is nil.
    ///
    /// - Discussion: When backgroundUploads are activated any request done by the multipartPOST method will use background session. This background session is shared for all multipart
    ///   requests and the identifier used must be unique in the system, Apple recomends to use invert DNS base on your bundle ID. Keep in mind these requests will continue even
    ///   after the app is killed by the system and the system will retried them until they are done. If the background session is initiated from an app extension, you *must* provide a value
    ///   for the sharedContainerIdentifier.
    ///
    @objc public init(oAuthToken: String? = nil, userAgent: String? = nil,
                backgroundUploads: Bool = false,
                backgroundSessionIdentifier: String = WordPressComRestApi.defaultBackgroundSessionIdentifier,
                sharedContainerIdentifier: String? = nil) {
        self.oAuthToken = oAuthToken
        self.userAgent = userAgent
        self.backgroundUploads = backgroundUploads
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
        self.sharedContainerIdentifier = sharedContainerIdentifier
        super.init()
    }

    deinit {
        sessionManager.session.finishTasksAndInvalidate()
        uploadSessionManager.session.finishTasksAndInvalidate()
    }

    /**
     Cancels all ongoing taks and makes the session invalid so the object will not fullfil any more request
     */
    @objc open func invalidateAndCancelTasks() {
        sessionManager.session.invalidateAndCancel()
        uploadSessionManager.session.invalidateAndCancel()
    }

    // MARK: - Network requests

    /**
     Executes a GET request to the specified endpoint defined on URLString

     - parameter URLString:  the url string to be added to the baseURL
     - parameter parameters: the parameters to be encoded on the request
     - parameter success:    callback to be called on successful request
     - parameter failure:    callback to be called on failed request

     - returns:  a NSProgress object that can be used to track the progress of the request and to cancel the request. If the method
     returns nil it's because something happened on the request serialization and the network request was not started, but the failure callback
     will be invoked with the error specificing the serialization issues.
     */
    @objc @discardableResult open func GET(_ URLString: String,
                     parameters: [String: AnyObject]?,
                     success: @escaping SuccessResponseBlock,
                     failure: @escaping FailureReponseBlock) -> Progress? {

        guard let URLString = buildRequestURLFor(path: URLString) else {
            let error = NSError(domain: String(describing: WordPressComRestApiError.self),
                                code: WordPressComRestApiError.requestSerializationFailed.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Failed to serialize request to the REST API.", comment: "Error message to show when wrong URL format is used to access the REST API")])
            failure(error, nil)
            return nil
        }

        let progress = Progress(totalUnitCount: 1)
        let progressUpdater = {(taskProgress: Progress) in
            progress.totalUnitCount = taskProgress.totalUnitCount
            progress.completedUnitCount = taskProgress.completedUnitCount
        }

        let dataRequest = sessionManager.request(URLString, method: .get, parameters: parameters).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let responseObject):
                    progress.completedUnitCount = progress.totalUnitCount
                    success(responseObject as AnyObject, response.response)
                case .failure(let error):
                    let nserror = self.processError(response: response, originalError: error)
                    failure(nserror, response.response)
                }

        }).downloadProgress(closure: progressUpdater)

        progress.cancellationHandler = {
            dataRequest.cancel()
        }
        return progress
    }

    /**
     Executes a POST request to the specified endpoint defined on URLString

     - parameter URLString:  the url string to be added to the baseURL
     - parameter parameters: the parameters to be encoded on the request
     - parameter success:    callback to be called on successful request
     - parameter failure:    callback to be called on failed request

     - returns:  a NSProgress object that can be used to track the progress of the upload and to cancel the upload. If the method
     returns nil it's because something happened on the request serialization and the network request was not started, but the failure callback
     will be invoked with the error specificing the serialization issues.
     */
    @objc @discardableResult open func POST(_ URLString: String,
                     parameters: [String: AnyObject]?,
                     success: @escaping SuccessResponseBlock,
                     failure: @escaping FailureReponseBlock) -> Progress? {
        guard let URLString = buildRequestURLFor(path: URLString) else {
            let error = NSError(domain: String(describing: WordPressComRestApiError.self),
                                code: WordPressComRestApiError.requestSerializationFailed.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Failed to serialize request to the REST API.", comment: "Error message to show when wrong URL format is used to access the REST API")])
            failure(error, nil)
            return nil
        }

        let progress = Progress(totalUnitCount: 1)
        let progressUpdater = {(taskProgress: Progress) in
            progress.totalUnitCount = taskProgress.totalUnitCount
            progress.completedUnitCount = taskProgress.completedUnitCount
        }

        let dataRequest = sessionManager.request(URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let responseObject):
                progress.completedUnitCount = progress.totalUnitCount
                success(responseObject as AnyObject, response.response)
            case .failure(let error):
                let nserror = self.processError(response: response, originalError: error)
                failure(nserror, response.response)
            }

        }).downloadProgress(closure: progressUpdater)

        progress.cancellationHandler = {
            dataRequest.cancel()
        }
        return progress
    }

    /**
     Executes a multipart POST using the current serializer, the parameters defined and the fileParts defined in the request
     This request will be streamed from disk, so it's ideally to be used for large media post uploads.

     - parameter URLString:  the endpoint to connect
     - parameter parameters: the parameters to use on the request
     - parameter fileParts:  the file parameters that are added to the multipart request
     - parameter requestEnqueued: callback to be called when the fileparts are serialized and request is added to the background session. Defaults to nil
     - parameter success:    callback to be called on successful request
     - parameter failure:    callback to be called on failed request

     - returns:  a NSProgress object that can be used to track the progress of the upload and to cancel the upload. If the method
     returns nil it's because something happened on the request serialization and the network request was not started, but the failure callback
     will be invoked with the error specificing the serialization issues.
     */
    @objc @discardableResult open func multipartPOST(_ URLString: String,
                              parameters: [String: AnyObject]?,
                              fileParts: [FilePart],
                              requestEnqueued: RequestEnqueuedBlock? = nil,
                              success: @escaping SuccessResponseBlock,
                              failure: @escaping FailureReponseBlock) -> Progress? {

        guard let URLString = buildRequestURLFor(path: URLString) else {
            let error = NSError(domain: String(describing: WordPressComRestApiError.self),
                                code: WordPressComRestApiError.requestSerializationFailed.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Failed to serialize request to the REST API.", comment: "Error message to show when wrong URL format is used to access the REST API")])
            failure(error, nil)
            return nil
        }

        let progress = Progress(totalUnitCount: 1)
        let progressUpdater = {(taskProgress: Progress) in
            // Sergio Estevao: Add an extra 1 unit to the progress to take in account the upload response and not only the uploading of data
            progress.totalUnitCount = taskProgress.totalUnitCount + 1
            progress.completedUnitCount = taskProgress.completedUnitCount
        }

        uploadSessionManager.upload(multipartFormData: { (multipartFormData) in
            for filePart in fileParts {
                multipartFormData.append(filePart.url, withName: filePart.parameterName, fileName: filePart.filename, mimeType: filePart.mimeType)
            }
        }, to: URLString, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                if let taskIdentifier = upload.task?.taskIdentifier {
                    requestEnqueued?(NSNumber(value: taskIdentifier))
                }
                let dataRequest = upload.responseJSON(completionHandler: { response in                    
                    switch response.result {
                    case .success(let responseObject):
                        progress.completedUnitCount = progress.totalUnitCount
                        success(responseObject as AnyObject, response.response)
                    case .failure(let error):
                        let nserror = self.processError(response: response, originalError: error)
                        failure(nserror, response.response)
                    }
                }).uploadProgress(closure: progressUpdater)

                progress.cancellationHandler = {
                    dataRequest.cancel()
                }
            case .failure(let encodingError):
                failure(encodingError as NSError, nil)
            }
        })

        return progress
    }

    @objc open func hasCredentials() -> Bool {
        guard let authToken = oAuthToken else {
            return false
        }
        return !(authToken.isEmpty)
    }

    override open var hashValue: Int {
        return "\(String(describing: oAuthToken)),\(String(describing: userAgent))".hashValue
    }

    fileprivate func buildRequestURLFor(path: String) -> String? {
        let pathWithLocale = appendLocaleIfNeeded(path)
        let baseURL = URL(string: WordPressComRestApi.apiBaseURLString)
        let requestURLString = URL(string: pathWithLocale, relativeTo: baseURL)?.absoluteString
        return requestURLString
    }

    fileprivate func appendLocaleIfNeeded(_ path: String) -> String {
        guard appendsPreferredLanguageLocale else {
            return path
        }
        return WordPressComRestApi.pathByAppendingPreferredLanguageLocale(path)
    }

    @objc public func temporaryFileURL(withExtension fileExtension: String) -> URL {
        assert(!fileExtension.isEmpty, "file Extension cannot be empty")
        let fileName = "\(ProcessInfo.processInfo.globallyUniqueString)_file.\(fileExtension)"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        return fileURL
    }
}

/// FilePart represents the infomartion needed to encode a file on a multipart form request
public final class FilePart: NSObject {
    @objc let parameterName: String
    @objc let url: URL
    @objc let filename: String
    @objc let mimeType: String

    @objc public init(parameterName: String, url: URL, filename: String, mimeType: String) {
        self.parameterName = parameterName
        self.url = url
        self.filename = filename
        self.mimeType = mimeType
    }
}

extension WordPressComRestApi {

    /// A custom error processor to handle error responses when status codes are betwen 400 and 500
    func processError(response: DataResponse<Any>, originalError: Error) -> NSError {

        let originalNSError = originalError as NSError
        guard let afError = originalError as?  AFError, case AFError.responseValidationFailed(_) = afError, let httpResponse = response.response, (400...500).contains(httpResponse.statusCode), let data = response.data else {
            if let afError = originalError as? AFError, case AFError.responseSerializationFailed(_) = afError {
                return WordPressComRestApiError.responseSerializationFailed as NSError
            }
            return WordPressComRestApiError.unknown as NSError
        }

        var userInfo: [String: Any] = originalNSError.userInfo

        guard let responseObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let responseDictionary = responseObject as? [String:AnyObject] else {
                // This endpoint is throttled, so check if we've sent too many requests and fill that error in as
                // when too many requests occur the API just spits out an html page.

            if let responseString = String(data:data, encoding:.utf8),
                responseString.contains("Limit reached") {
                userInfo[WordPressComRestApi.ErrorKeyErrorMessage] = NSLocalizedString("Limit reached. You can try again in 1 minute. Trying again before that will only increase the time you have to wait before the ban is lifted. If you think this is in error, contact support.", comment: "Message to show when a request for a WP.com API endpoint is throttled")
                userInfo[WordPressComRestApi.ErrorKeyErrorCode] = "too_many_requests"
                userInfo[NSLocalizedDescriptionKey] = userInfo[WordPressComRestApi.ErrorKeyErrorMessage]
                let nsError = WordPressComRestApiError.tooManyRequests as NSError
                let errorWithLocalizedMessage = NSError(domain: nsError.domain, code: nsError.code, userInfo:userInfo)
                return errorWithLocalizedMessage
            }
            return WordPressComRestApiError.unknown as NSError
        }
        var errorDictionary: AnyObject? = responseDictionary as AnyObject?
        if let errorArray = responseDictionary["errors"] as? [AnyObject], errorArray.count > 0 {
            errorDictionary = errorArray.first
        }
        guard let errorEntry = errorDictionary as? [String: AnyObject],
            let errorCode = errorEntry["error"] as? String,
            let errorDescription = errorEntry["message"] as? String
            else {
                return WordPressComRestApiError.unknown as NSError
        }

        let errorsMap = [
            "invalid_input": WordPressComRestApiError.invalidInput,
            "invalid_token": WordPressComRestApiError.invalidToken,
            "authorization_required": WordPressComRestApiError.authorizationRequired,
            "upload_error": WordPressComRestApiError.uploadFailed,
            "unauthorized": WordPressComRestApiError.authorizationRequired
        ]

        let mappedError = errorsMap[errorCode] ?? WordPressComRestApiError.unknown
        userInfo[WordPressComRestApi.ErrorKeyErrorCode] = errorCode
        userInfo[WordPressComRestApi.ErrorKeyErrorMessage] = errorDescription
        let nserror = mappedError as NSError
        userInfo[NSLocalizedDescriptionKey] =  errorDescription
        let resultError = NSError(domain: nserror.domain,
                               code: nserror.code,
                               userInfo: userInfo
            )
        return resultError
    }
}

extension WordPressComRestApi {
    /// Returns an Api object without an oAuthtoken defined and with the userAgent set for the WordPress App user agent
    @objc class public func anonymousApi(userAgent: String) -> WordPressComRestApi {
        return WordPressComRestApi(oAuthToken: nil, userAgent: userAgent)
    }

    /// Append the user's preferred device locale as a query param to the URL path.
    /// If the locale already exists the original path is returned.
    ///
    /// - Parameters:
    ///     - path: A URL string. Can be an absolute or relative URL string.
    ///
    /// - Returns: The path with the locale appended, or the original path if it already had a locale param.
    ///
    @objc class public func pathByAppendingPreferredLanguageLocale(_ path: String) -> String {
        let localeKey = WordPressComRestApi.localeKey
        if path.isEmpty || path.contains("\(localeKey)=") {
            return path
        }
        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
        let separator = path.contains("?") ? "&" : "?"
        return "\(path)\(separator)\(localeKey)=\(preferredLanguageIdentifier)"
    }
}
