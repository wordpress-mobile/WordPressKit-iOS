import Alamofire
import CocoaLumberjack
import Foundation

public typealias RequestAuthenticationValidator = (URLRequest) -> Bool

// MARK: - Authenticator

public struct Authenticator {
    let adapter: RequestAdapter?
    let retrier: RequestRetrier?

    public init(authenticator: RequestRetrier & RequestAdapter) {
        adapter = authenticator
        retrier = authenticator
    }

    public init(authenticator: RequestRetrier) {
        adapter = nil
        retrier = authenticator
    }

    public init(authenticator: RequestAdapter) {
        adapter = authenticator
        retrier = nil
    }
}

// MARK: - Token Auth

public struct TokenAuthenticator: RequestAdapter {
    fileprivate let token: Secret<String>
    fileprivate let shouldAuthenticate: RequestAuthenticationValidator

    public init(token: String, shouldAuthenticate: RequestAuthenticationValidator?) {
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

public extension Authenticator {
    static func token(_ token: String, shouldAuthenticate: RequestAuthenticationValidator? = nil) -> Authenticator {
        let authenticator = TokenAuthenticator(token: token, shouldAuthenticate: shouldAuthenticate)
        return Authenticator(authenticator: authenticator)
    }

}

// MARK: - Cookie Nonce Auth

public class CookieNonceAuthenticator: RequestAdapter, RequestRetrier {
    private let username: String
    private let password: Secret<String>
    private let loginURL: URL
    private let adminURL: URL
    private var nonce: Secret<String>? = nil
    // If we can't get this to work once, don't retry for the same site
    // It is likely that there is something preventing us from extracting a nonce
    private var canRetry = true
    private var isAuthenticating = false
    private var requestsToRetry = [RequestRetryCompletion]()

    public init(username: String, password: String, loginURL: URL, adminURL: URL) {
        self.username = username
        self.password = Secret(password)
        self.loginURL = loginURL
        self.adminURL = adminURL
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
    public func should(_ manager: SessionManager, retry request: Request, with error: Swift.Error, completion: @escaping RequestRetryCompletion) {
        guard
            canRetry,
            // Only retry once
            request.retryCount == 0,
            // And don't retry the login request
            request.request?.url != loginURL,
            // Only retry because of failed authorization
            case .responseValidationFailed(reason: .unacceptableStatusCode(code: 401)) = error as? AFError
        else {
            return completion(false, 0.0)
        }

        requestsToRetry.append(completion)
        if !isAuthenticating {
            startLoginSequence(manager: manager)
        }
    }

    enum Error: Swift.Error {
        case invalidNewPostURL
        case postLoginFailed(Swift.Error)
        case missingNonce
        case unknown(Swift.Error)

        var retriable: Bool {
            return false
        }
    }
}

    // MARK: Private helpers
private extension CookieNonceAuthenticator {
    func startLoginSequence(manager: SessionManager) {
        DDLogInfo("Starting Cookie+Nonce login sequence for \(loginURL)")
        guard let newPostURL = buildNewPostURL() else {
            return invalidateLoginSequence(error: .invalidNewPostURL)
        }
        let request = authenticatedRequest(redirectURL: newPostURL)
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
                    DDLogInfo("Posted Login to \(self.loginURL), redirected to \(redirectedTo)")
                    guard let nonce = self.extractNonce(html: page) else {
                        return self.invalidateLoginSequence(error: .missingNonce)
                    }
                    self.nonce = Secret(nonce)
                    self.successfulLoginSequence()
                }
        }
    }

    func successfulLoginSequence() {
        DDLogInfo("Completed Cookie+Nonce login sequence for \(loginURL)")
        requestsToRetry.forEach { (completion) in
            completion(true, 0.0)
        }
    }

    func invalidateLoginSequence(error: Error) {
        canRetry = error.retriable
        let retryMessage = canRetry ? "will retry" : "will not retry"
        DDLogError("Aborting Cookie+Nonce login sequence for \(loginURL), \(retryMessage)")
        requestsToRetry.forEach { (completion) in
            completion(false, 0.0)
        }
        isAuthenticating = false
    }

    func buildNewPostURL() -> URL? {
        return URL(string: "post-new.php", relativeTo: adminURL)
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

    func extractNonce(html: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "apiFetch.createNonceMiddleware\\(\\s*['\"](?<nonce>\\w+)['\"]\\s*\\)", options: []),
            let match = regex.firstMatch(in: html, options: [], range: NSMakeRange(0, html.count)) else {
                return nil
        }
        let nsrange = match.range(withName: "nonce")
        let nonce = Range(nsrange, in: html)
            .map( { html[$0] })
            .map( String.init )

        return nonce
    }
}

public extension Authenticator {
    static func cookieNonce(username: String, password: String, loginURL: URL, adminURL: URL) -> Authenticator {
        let authenticator = CookieNonceAuthenticator(username: username, password: password, loginURL: loginURL, adminURL: adminURL)
        return Authenticator(authenticator: authenticator)
    }
}
