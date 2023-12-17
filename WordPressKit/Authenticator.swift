import Alamofire
import Foundation
import WordPressShared

public typealias RequestAuthenticationValidator = (URLRequest) -> Bool

// MARK: - Authenticator

public protocol Authenticator: RequestRetrier & RequestAdapter {}

public extension Authenticator {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        completion(false, 0.0)
    }
}

// MARK: - Token Auth

public struct TokenAuthenticator: Authenticator {
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
    private var requestsToRetry = [RequestRetryCompletion]()
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
    }
}

// MARK: Private helpers
private extension CookieNonceAuthenticator {

    func startLoginSequence(manager: SessionManager) {
        WPKitLogInfo("Starting Cookie+Nonce login sequence for \(loginURL)")
        Task { @MainActor in
            guard let nonce = await self.nonceRetrievalMethod.retrieveNonce(
                username: username,
                password: password,
                loginURL: loginURL,
                adminURL: adminURL,
                using: manager.session
            ) else {
                self.invalidateLoginSequence(error: .missingNonce)
                return
            }

            self.nonce = Secret(nonce)
            self.successfulLoginSequence()
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
            completion(shouldRetry, 0.0)
        }
        requestsToRetry.removeAll()
    }

}
