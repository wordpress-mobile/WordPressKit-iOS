import Alamofire
import Foundation

/**
 Error constants for the WordPress.org REST API

 - RequestSerializationFailed:     The serialization of the request failed
 */
@objc public enum WordPressOrgRestApiError: Int, Error {
    case requestSerializationFailed
}

@objc
open class WordPressOrgRestApi: NSObject, WordPressRestApi {
    public typealias Completion = (Swift.Result<Any, Error>, HTTPURLResponse?) -> Void
    private let apiBase: URL
    private let authenticator: Authenticator?
    private let userAgent: String?

    public init(apiBase: URL, authenticator: Authenticator? = nil, userAgent: String? = nil) {
        self.apiBase = apiBase
        self.authenticator = authenticator
        self.userAgent = userAgent
        super.init()
    }

    @discardableResult
    open func GET(_ path: String,
                  parameters: [String: AnyObject]?,
                  completion: @escaping Completion) -> Progress? {
        return request(method: .get, path: path, parameters: parameters, completion: completion)
    }

    @discardableResult
    open func request(method: HTTPMethod,
                         path: String,
                         parameters: [String: AnyObject]?,
                         completion: @escaping Completion) -> Progress? {
        let relativePath = path.removingPrefix("/")
        guard let url = URL(string: relativePath, relativeTo: apiBase) else {
            let error = NSError(domain: String(describing: WordPressOrgRestApiError.self),
                    code: WordPressOrgRestApiError.requestSerializationFailed.rawValue,
                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Failed to serialize request to the REST API.", comment: "Error message to show when wrong URL format is used to access the REST API")])
            completion(.failure(error), nil)
            return nil
        }

        let progress = Progress(totalUnitCount: 1)
        let progressUpdater = {(taskProgress: Progress) in
            progress.totalUnitCount = taskProgress.totalUnitCount
            progress.completedUnitCount = taskProgress.completedUnitCount
        }

        let dataRequest = sessionManager.request(url, method: method, parameters: parameters, encoding: URLEncoding.default)
            .validate()
            .responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let responseObject):
                progress.completedUnitCount = progress.totalUnitCount
                completion(.success(responseObject), response.response)
            case .failure(let error):
                completion(.failure(error), response.response)
            }

        }).downloadProgress(closure: progressUpdater)
        progress.sessionTask = dataRequest.task
        progress.cancellationHandler = {
            dataRequest.cancel()
        }
        return progress
    }

    /**
     Cancels all ongoing and makes the session so the object will not fullfil any more request
     */
    @objc open func invalidateAndCancelTasks() {
        sessionManager.session.invalidateAndCancel()
    }

    private lazy var sessionManager: Alamofire.SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
        return sessionManager
    }()

    private func makeSessionManager(configuration sessionConfiguration: URLSessionConfiguration) -> Alamofire.SessionManager {
        var additionalHeaders: [String: AnyObject] = [:]
        if let userAgent = self.userAgent {
            additionalHeaders["User-Agent"] = userAgent as AnyObject?
        }

        sessionConfiguration.httpAdditionalHeaders = additionalHeaders

        let sessionManager = Alamofire.SessionManager(configuration: sessionConfiguration)
        sessionManager.adapter = authenticator
        sessionManager.retrier = authenticator
        return sessionManager
    }
}
