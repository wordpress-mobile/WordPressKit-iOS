import Alamofire
import Foundation

open class WordPressOrgRestApi {
    public typealias Completion = (Swift.Result<Any, Error>, HTTPURLResponse?) -> Void
    private let apiBase: URL
    private let userAgent: String?

    public init(apiBase: URL, userAgent: String? = nil) {
        self.apiBase = apiBase
        self.userAgent = userAgent
    }

    @discardableResult
    open func GET(_ path: String,
                  parameters: [String: AnyObject]?,
                  completion: @escaping Completion) -> Progress {
        return request(method: .get, path: path, parameters: parameters, completion: completion)
    }

    private func request(method: HTTPMethod,
                         path: String,
                         parameters: [String: AnyObject]?,
                         completion: @escaping Completion) -> Progress {
        let url = apiBase.appendingPathComponent(path)

        let progress = Progress(totalUnitCount: 1)
        let progressUpdater = {(taskProgress: Progress) in
            progress.totalUnitCount = taskProgress.totalUnitCount
            progress.completedUnitCount = taskProgress.completedUnitCount
        }

        let dataRequest = sessionManager.request(url, method: method, parameters: parameters, encoding:URLEncoding.default)
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
        return progress    }

    private lazy var sessionManager: Alamofire.SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        let sessionManager = self.makeSessionManager(configuration: sessionConfiguration)
        return sessionManager
    }()

    private func makeSessionManager(configuration sessionConfiguration: URLSessionConfiguration) -> Alamofire.SessionManager {
        var additionalHeaders: [String : AnyObject] = [:]
        if let userAgent = self.userAgent {
            additionalHeaders["User-Agent"] = userAgent as AnyObject?
        }

        sessionConfiguration.httpAdditionalHeaders = additionalHeaders
        let sessionManager = Alamofire.SessionManager(configuration: sessionConfiguration)

        return sessionManager
    }
}
