import Foundation
import WordPressShared
import Alamofire

// MARK: - WordPressComRestApiError

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
    case preconditionFailure
}

// MARK: - WordPressComRestApi

open class WordPressComRestApi: NSObject {

    // MARK: Properties

    @objc public static let ErrorKeyErrorCode       = "WordPressComRestApiErrorCodeKey"
    @objc public static let ErrorKeyErrorMessage    = "WordPressComRestApiErrorMessageKey"
    @objc public static let ErrorKeyErrorData       = "WordPressComRestApiErrorDataKey"
    @objc public static let ErrorKeyErrorDataEmail  = "email"

    @objc public static let LocaleKeyDefault        = "locale"  // locale is specified with this for v1 endpoints
    @objc public static let LocaleKeyV2             = "_locale" // locale is prefixed with an underscore for v2

    @objc public static let SessionTaskKey          = "WordPressComRestAPI.sessionTask"

    public typealias RequestEnqueuedBlock = (_ taskID : NSNumber) -> Void
    public typealias SuccessResponseBlock = (_ responseObject: AnyObject, _ httpResponse: HTTPURLResponse?) -> ()
    public typealias FailureReponseBlock = (_ error: NSError, _ httpResponse: HTTPURLResponse?) -> ()

    @objc public static let apiBaseURLString: String = "https://public-api.wordpress.com/"

    @objc public static let defaultBackgroundSessionIdentifier = "org.wordpress.wpcomrestapi"
    
    private let oAuthToken: String?

    private let userAgent: String?

    @objc public let backgroundSessionIdentifier: String

    @objc public let sharedContainerIdentifier: String?

    private let backgroundUploads: Bool

    private let localeKey: String

    @objc public let baseURLString: String

    private var invalidTokenHandler: (() -> Void)? = nil

    /**
     Configure whether or not the user's preferred language locale should be appended. Defaults to true.
     */
    @objc open var appendsPreferredLanguageLocale = true

    private lazy var sessionManager: Alamofire.SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
        return sessionManager
    }()
    
    private lazy var uploadSessionManager: Alamofire.SessionManager = {
        if self.backgroundUploads {
            let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: self.backgroundSessionIdentifier)
            sessionConfiguration.sharedContainerIdentifier = self.sharedContainerIdentifier
            let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
            return sessionManager
        }
        
        return self.sessionManager
    }()

    private func makeSessionManager(configuration sessionConfiguration: URLSessionConfiguration) -> Alamofire.SessionManager {
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

    // MARK: WordPressComRestApi
    
    @objc convenience public init(oAuthToken: String? = nil, userAgent: String? = nil) {
        self.init(oAuthToken: oAuthToken, userAgent: userAgent, backgroundUploads: false, backgroundSessionIdentifier: WordPressComRestApi.defaultBackgroundSessionIdentifier)
    }
    
    @objc convenience public init(oAuthToken: String? = nil, userAgent: String? = nil, baseUrlString: String = WordPressComRestApi.apiBaseURLString) {
        self.init(oAuthToken: oAuthToken, userAgent: userAgent, backgroundUploads: false, backgroundSessionIdentifier: WordPressComRestApi.defaultBackgroundSessionIdentifier, baseUrlString: baseUrlString)
    }
    
    /// Creates a new API object to connect to the WordPress Rest API.
    ///
    /// - Parameters:
    ///   - oAuthToken: the oAuth token to be used for authentication.
    ///   - userAgent: the user agent to identify the client doing the connection.
    ///   - backgroundUploads: If this value is true the API object will use a background session to execute uploads requests when using the `multipartPOST` function. The default value is false.
    ///   - backgroundSessionIdentifier: The session identifier to use for the background session. This must be unique in the system.
    ///   - sharedContainerIdentifier: An optional string used when setting up background sessions for use in an app extension. Default is nil.
    ///   - localeKey: The key with which to specify locale in the parameters of a request.
    ///   - baseUrlString: The base url to use for API requests. Default is https://public-api.wordpress.com/
    ///
    /// - Discussion: When backgroundUploads are activated any request done by the multipartPOST method will use background session. This background session is shared for all multipart
    ///   requests and the identifier used must be unique in the system, Apple recomends to use invert DNS base on your bundle ID. Keep in mind these requests will continue even
    ///   after the app is killed by the system and the system will retried them until they are done. If the background session is initiated from an app extension, you *must* provide a value
    ///   for the sharedContainerIdentifier.
    ///
    @objc public init(oAuthToken: String? = nil, userAgent: String? = nil,
                backgroundUploads: Bool = false,
                backgroundSessionIdentifier: String = WordPressComRestApi.defaultBackgroundSessionIdentifier,
                sharedContainerIdentifier: String? = nil,
                localeKey: String = WordPressComRestApi.LocaleKeyDefault,
                baseUrlString: String = WordPressComRestApi.apiBaseURLString) {
        self.oAuthToken = oAuthToken
        self.userAgent = userAgent
        self.backgroundUploads = backgroundUploads
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
        self.sharedContainerIdentifier = sharedContainerIdentifier
        self.localeKey = localeKey
        self.baseURLString = baseUrlString

        super.init()
    }

    deinit {
        sessionManager.session.finishTasksAndInvalidate()
        uploadSessionManager.session.finishTasksAndInvalidate()
    }
    
    /// Cancels all outgoing tasks asynchronously without invalidating the session.
    public func cancelTasks() {
        sessionManager.session.getAllTasks { tasks in
            tasks.forEach({ $0.cancel() })
        }
    }

    /**
     Cancels all ongoing taks and makes the session invalid so the object will not fullfil any more request
     */
    @objc open func invalidateAndCancelTasks() {
        sessionManager.session.invalidateAndCancel()
        uploadSessionManager.session.invalidateAndCancel()
    }

    @objc func setInvalidTokenHandler(_ handler: @escaping () -> Void) {
        invalidTokenHandler = handler
    }

    // MARK: Network requests

    private func request(method: HTTPMethod,
                         urlString: String,
                         parameters: [String: AnyObject]?,
                         encoding: ParameterEncoding,
                         success: @escaping SuccessResponseBlock,
                         failure: @escaping FailureReponseBlock) -> Progress? {

        guard let URLString = buildRequestURLFor(path: urlString, parameters: parameters) else {
            let error = NSError(domain: String(describing: WordPressComRestApiError.self),
                                code: WordPressComRestApiError.requestSerializationFailed.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Failed to serialize request to the REST API.", comment: "Error message to show when wrong URL format is used to access the REST API")])
            failure(error, nil)
            return nil
        }

        let progress = Progress(totalUnitCount: 1)
        let progressUpdater = { [weak progress] (taskProgress: Progress) in
            progress?.totalUnitCount = taskProgress.totalUnitCount
            progress?.completedUnitCount = taskProgress.completedUnitCount
        }

        let dataRequest = sessionManager.request(URLString, method: method, parameters: parameters, encoding:encoding)
            .validate()
            .responseJSON(completionHandler: { [weak progress] (response) in
            switch response.result {
            case .success(let responseObject):
                progress?.completedUnitCount = progress?.totalUnitCount ?? 0
                success(responseObject as AnyObject, response.response)
            case .failure(let error):
                let nserror = self.processError(response: response, originalError: error)
                failure(nserror, response.response)
            }
        }).downloadProgress(closure: progressUpdater)
        progress.sessionTask = dataRequest.task
        progress.cancellationHandler = { [weak dataRequest] in
            dataRequest?.cancel()
        }
        return progress
    }

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

        return request(method: .get, urlString: URLString, parameters: parameters, encoding: URLEncoding.default, success: success, failure: failure)
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

        return request(method: .post, urlString: URLString, parameters: parameters, encoding: JSONEncoding.default, success: success, failure: failure)
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

        guard let URLString = buildRequestURLFor(path: URLString, parameters: parameters) else {
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
                let dataRequest = upload.validate().responseJSON(completionHandler: { response in                    
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

    override open var hash: Int {
        return "\(String(describing: oAuthToken)),\(String(describing: userAgent))".hashValue
    }

    /// This method assembles a valid request URL for the specified path & parameters.
    /// The framework relies on a field (`appendsPreferredLanguageLocale`) to influence whether or not locale should be
    /// added to the path of requests. This approach did not consider request parameters.
    ///
    /// This method now considers both the path and specified request parameters when performing the substitution.
    /// It only accounts for the locale parameter. AlamoFire encodes other parameters via `SessionManager.request(_:method:parameters:encoding:headers:)`
    ///
    /// - Parameters:
    ///   - path: the path for the request, which might include `locale`
    ///   - parameters: the request parameters, which could conceivably include `locale`
    /// - Returns: a request URL if successful, `nil` otherwise.
    ///
    func buildRequestURLFor(path: String, parameters: [String: AnyObject]? = [:]) -> String? {

        let baseURL = URL(string: self.baseURLString)

        guard let requestURLString = URL(string: path, relativeTo: baseURL)?.absoluteString,
            let urlComponents = URLComponents(string: requestURLString) else {

            return nil
        }

        let urlComponentsWithLocale = applyLocaleIfNeeded(urlComponents: urlComponents, parameters: parameters, localeKey: localeKey)

        return urlComponentsWithLocale?.url?.absoluteString
    }

    private func applyLocaleIfNeeded(urlComponents: URLComponents, parameters: [String: AnyObject]? = [:], localeKey: String) -> URLComponents? {
        guard appendsPreferredLanguageLocale else {
            return urlComponents
        }

        var componentsWithLocale = urlComponents
        var existingQueryItems = componentsWithLocale.queryItems ?? []
        let existingLocaleQueryItems = existingQueryItems.filter { $0.name == localeKey }

        let inputParameters = parameters ?? [:]

        if inputParameters[localeKey] == nil, existingLocaleQueryItems.isEmpty {
            let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
            let localeQueryItem = URLQueryItem(name: localeKey, value: preferredLanguageIdentifier)

            existingQueryItems.append(localeQueryItem)
        }
        componentsWithLocale.queryItems = existingQueryItems

        return componentsWithLocale
    }

    @objc public func temporaryFileURL(withExtension fileExtension: String) -> URL {
        assert(!fileExtension.isEmpty, "file Extension cannot be empty")
        let fileName = "\(ProcessInfo.processInfo.globallyUniqueString)_file.\(fileExtension)"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        return fileURL
    }
}

// MARK: - FilePart

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

// MARK: - Error processing

extension WordPressComRestApi {

    /// A custom error processor to handle error responses when status codes are betwen 400 and 500
    func processError(response: DataResponse<Any>, originalError: Error) -> NSError {

        let originalNSError = originalError as NSError
        guard let afError = originalError as?  AFError, case AFError.responseValidationFailed(_) = afError, let httpResponse = response.response, (400...500).contains(httpResponse.statusCode), let data = response.data else {
            if let afError = originalError as? AFError, case AFError.responseSerializationFailed(_) = afError {
                return WordPressComRestApiError.responseSerializationFailed as NSError
            }
            return originalNSError
        }

        var userInfo: [String: Any] = originalNSError.userInfo

        guard let responseObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let responseDictionary = responseObject as? [String: AnyObject] else {

            if let error = checkForThrottleErrorIn(data: data) {
                return error;
            }
            return WordPressComRestApiError.unknown as NSError
        }

        //FIXME: A hack to support free WPCom sites and Rewind. Should be obsolote as soon as the backend
        // stops returning 412's for those sites.
        if httpResponse.statusCode == 412, let code = responseDictionary["code"] as? String, code == "no_connected_jetpack" {
            return WordPressComRestApiError.preconditionFailure as NSError
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
        if mappedError == .invalidToken {
            invalidTokenHandler?()
        }
        userInfo[WordPressComRestApi.ErrorKeyErrorCode] = errorCode
        userInfo[WordPressComRestApi.ErrorKeyErrorMessage] = errorDescription
        userInfo[NSLocalizedDescriptionKey] =  errorDescription

        if let errorData = errorEntry["data"] {
            userInfo[WordPressComRestApi.ErrorKeyErrorData] = errorData
        }

        let nserror = mappedError as NSError
        let resultError = NSError(domain: nserror.domain,
                               code: nserror.code,
                               userInfo: userInfo
            )
        return resultError
    }

    func checkForThrottleErrorIn(data: Data) -> NSError? {
        // This endpoint is throttled, so check if we've sent too many requests and fill that error in as
        // when too many requests occur the API just spits out an html page.
        guard let responseString = String(data: data, encoding: .utf8),
            responseString.contains("Limit reached") else {
                return nil
        }
        var userInfo = [String: Any]()
        userInfo[WordPressComRestApi.ErrorKeyErrorCode] = "too_many_requests"
        userInfo[WordPressComRestApi.ErrorKeyErrorMessage] = NSLocalizedString("Limit reached. You can try again in 1 minute. Trying again before that will only increase the time you have to wait before the ban is lifted. If you think this is in error, contact support.", comment: "Message to show when a request for a WP.com API endpoint is throttled")
        userInfo[NSLocalizedDescriptionKey] = userInfo[WordPressComRestApi.ErrorKeyErrorMessage]
        let nsError = WordPressComRestApiError.tooManyRequests as NSError
        let errorWithLocalizedMessage = NSError(domain: nsError.domain, code: nsError.code, userInfo:userInfo)
        return errorWithLocalizedMessage
    }
}
// MARK: - Anonymous API support

extension WordPressComRestApi {

    /// Returns an API object without an OAuth token defined & with the userAgent set for the WordPress App user agent
    ///
    @objc class public func anonymousApi(userAgent: String) -> WordPressComRestApi {
        return WordPressComRestApi(oAuthToken: nil, userAgent: userAgent)
    }

    /// Returns an API object without an OAuth token defined & with both the userAgent & localeKey set for the WordPress App user agent
    ///
    @objc class public func anonymousApi(userAgent: String, localeKey: String) -> WordPressComRestApi {
        return WordPressComRestApi(oAuthToken: nil, userAgent: userAgent, localeKey: localeKey)
    }
}

// MARK: - Progress

@objc extension Progress {

    @objc var sessionTask: URLSessionTask? {
        get {
            return userInfo[.sessionTaskKey] as? URLSessionTask
        }

        set {
            self.setUserInfoObject(newValue, forKey: .sessionTaskKey)
        }
    }
}

extension ProgressUserInfoKey {
    public static let sessionTaskKey = ProgressUserInfoKey(rawValue: WordPressComRestApi.SessionTaskKey)
}
