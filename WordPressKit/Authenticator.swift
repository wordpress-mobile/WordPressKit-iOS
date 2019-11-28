import Foundation
import Alamofire

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
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard
            // Only retry once
            request.retryCount == 0,
            // And don't retry the login request
            request.request?.url != loginURL,
            // Ensure we have an editor URL to extract the nonce
            let newPostURL = URL(string: "post-new.php", relativeTo: adminURL),
            // Only retry because of failed authorization
            case .responseValidationFailed(reason: .unacceptableStatusCode(code: 401)) = error as? AFError
        else {
            return completion(false, 0.0)
        }

        let request = authenticatedRequest(redirectURL: newPostURL)
        manager.request(request)
            .validate()
            .responseString { (response) in
                guard case let .success(page) = response.result,
                    let nonce = self.extractNonce(html: page) else {
                    return completion(false, 0.0)
                }

                self.nonce = Secret(nonce)

                completion(true, 0.0)
        }
    }

    // MARK: Private helpers

    private func authenticatedRequest(redirectURL: URL) -> URLRequest {
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

    private func extractNonce(html: String) -> String? {
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
