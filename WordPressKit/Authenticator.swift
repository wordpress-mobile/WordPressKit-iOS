import Alamofire
import Foundation
import WordPressShared

public typealias RequestAuthenticationValidator = (URLRequest) -> Bool

// MARK: - Authenticator

public protocol Authenticator: RequestRetrier & RequestAdapter {}

public extension Authenticator {
    func should(_ manager: Session, retry request: Request, with error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.retry)
    }
}

// MARK: - Token Auth

public struct TokenAuthenticator: Authenticator {
    public func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: Error, completion: @escaping (Alamofire.RetryResult) -> Void) {

    }

    public func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
       
    }

    fileprivate let token: Secret<String>
    fileprivate let shouldAuthenticate: RequestAuthenticationValidator

    public init(token: String, shouldAuthenticate: RequestAuthenticationValidator? = nil) {
        self.token = Secret(token)
        self.shouldAuthenticate = shouldAuthenticate ?? { _ in true }
    }

    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard shouldAuthenticate(urlRequest) else {
            return urlRequest
        }
        var adaptedRequest = urlRequest
        adaptedRequest.addValue("Bearer \(token.secretValue)", forHTTPHeaderField: "Authorization")
        return adaptedRequest
    }
}

// MARK: - Cookie Nonce Auth

public class CookieNonceAuthenticator: Authenticator {
    public func retry(_ request: Request, for session: Session, dueTo error: Swift.Error, completion: @escaping (RetryResult) -> Void) {
    }

    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Swift.Error>) -> Void) {
        
    }

    private let username: String
    private let password: Secret<String>
    private let loginURL: URL
    private let adminURL: URL
    private let version: String
    private var nonce: Secret<String>?
    // If we can't get this to work once, don't retry for the same site
    // It is likely that there is something preventing us from extracting a nonce
    private var canRetry = true
    private var isAuthenticating = false
    private var requestsToRetry = [RetryResult]()
    private var nonceRetrievalMethod: NonceRetrievalMethod = .newPostScrap

    public init(username: String, password: String, loginURL: URL, adminURL: URL, version: String = "5.0", nonce: String? = nil) {
        self.username = username
        self.password = Secret(password)
        self.loginURL = loginURL
        self.adminURL = adminURL
        self.nonce = nonce.map(Secret.init)
        self.version = version
        let isVersionAtLeast5_3_0 = version.compare("5.3.0", options: .numeric) != .orderedAscending
        if  isVersionAtLeast5_3_0 {
            nonceRetrievalMethod = .ajaxNonceRequest
        }
    }

    // MARK: Request Adapter

    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let nonce = nonce else {
            return urlRequest
        }
        var adaptedRequest = urlRequest
        adaptedRequest.addValue(nonce.secretValue, forHTTPHeaderField: "X-WP-Nonce")
        return adaptedRequest
    }

    // MARK: Retrier
    public func should(_ manager: Session, retry request: Request, with error: Swift.Error, completion: @escaping (RetryResult) -> Void) {
        guard
            canRetry,
            // Only retry once
            request.retryCount == 0,
            // And don't retry the login request
            request.request?.url != loginURL,
            // Only retry because of failed authorization
            case .responseValidationFailed(reason: .unacceptableStatusCode(code: 401)) = error as? AFError
        else {
            return completion(.retry)
        }

//        requestsToRetry.append(completion)
        if !isAuthenticating {
            startLoginSequence(manager: manager)
        }
    }

    enum Error: Swift.Error {
        case invalidNewPostURL
        case postLoginFailed(Swift.Error)
        case missingNonce
        case unknown(Swift.Error)
    }
}

// MARK: Private helpers
private extension CookieNonceAuthenticator {

    func startLoginSequence(manager: Session) {
        WPKitLogInfo("Starting Cookie+Nonce login sequence for \(loginURL)")
        guard let nonceRetrievalURL = nonceRetrievalMethod.buildURL(base: adminURL) else {
            return invalidateLoginSequence(error: .invalidNewPostURL)
        }
        let request = authenticatedRequest(redirectURL: nonceRetrievalURL)
        manager.request(request)
            .validate()
            .responseString { [weak self] (response) in
                guard let self = self else {
                    return
                }
                switch response.result {
                case .failure(let error):
                    self.invalidateLoginSequence(error: .postLoginFailed(error))
                case .success(let page):
                    let redirectedTo = response.response?.url?.absoluteString ?? "nil"
                    WPKitLogInfo("Posted Login to \(self.loginURL), redirected to \(redirectedTo)")
                    guard let nonce = self.nonceRetrievalMethod.retrieveNonce(from: page) else {
                        return self.invalidateLoginSequence(error: .missingNonce)
                    }
                    self.nonce = Secret(nonce)
                    self.successfulLoginSequence()
                }
        }
    }

    func successfulLoginSequence() {
        WPKitLogInfo("Completed Cookie+Nonce login sequence for \(loginURL)")
        completeRequests(true)
    }

    func invalidateLoginSequence(error: Error) {
        canRetry = false
        if case .postLoginFailed(let originalError) = error {
            let nsError = originalError as NSError
            if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorNotConnectedToInternet {
                canRetry = true
            }
        }
        WPKitLogError("Aborting Cookie+Nonce login sequence for \(loginURL)")
        completeRequests(false)
        isAuthenticating = false
    }

    func completeRequests(_ shouldRetry: Bool) {
        requestsToRetry.forEach { (completion) in
//            completion(shouldRetry, 0.0)
        }
        requestsToRetry.removeAll()
    }

    func authenticatedRequest(redirectURL: URL) -> URLRequest {
        var request = URLRequest(url: loginURL)

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var parameters = [URLQueryItem]()
        parameters.append(URLQueryItem(name: "log", value: username))
        parameters.append(URLQueryItem(name: "pwd", value: password.secretValue))
        parameters.append(URLQueryItem(name: "rememberme", value: "true"))
        parameters.append(URLQueryItem(name: "redirect_to", value: redirectURL.absoluteString))
        var components = URLComponents()
        components.queryItems = parameters
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        return request
    }

}

private extension CookieNonceAuthenticator {
    enum NonceRetrievalMethod {
        case newPostScrap
        case ajaxNonceRequest

        func buildURL(base: URL) -> URL? {
            switch self {
                case .newPostScrap:
                    return URL(string: "post-new.php", relativeTo: base)
                case .ajaxNonceRequest:
                    return URL(string: "admin-ajax.php?action=rest-nonce", relativeTo: base)
            }
        }

        func retrieveNonce(from html: String) -> String? {
            switch self {
                case .newPostScrap:
                    return scrapNonceFromNewPost(html: html)
                case .ajaxNonceRequest:
                    return readNonceFromAjaxAction(html: html)
            }
        }

        func scrapNonceFromNewPost(html: String) -> String? {
            guard let regex = try? NSRegularExpression(pattern: "apiFetch.createNonceMiddleware\\(\\s*['\"](?<nonce>\\w+)['\"]\\s*\\)", options: []),
                let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) else {
                    return nil
            }
            let nsrange = match.range(withName: "nonce")
            let nonce = Range(nsrange, in: html)
                .map({ html[$0] })
                .map( String.init )

            return nonce
        }

        func readNonceFromAjaxAction(html: String) -> String? {
            guard !html.isEmpty else {
                return nil
            }
            return html
        }
    }
}
