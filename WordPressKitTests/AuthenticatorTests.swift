import Alamofire
import OHHTTPStubs
import XCTest
import WordPressKit

let apiBase = URL(string: "https://example.com/wp-json/")!
let loginURL = URL(string: "https://example.com/wp-login.php")!
let adminURL = URL(string: "https://example.com/wp-admin/")!
let apiRequest = URLRequest(url: apiBase)
let authorizationHeader = "Authorization"
let nonceHeader = "X-WP-Nonce"

class AuthenticatorTests: XCTestCase {
    var manager = SessionManager()

    override func setUp() {
        manager = SessionManager()
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        manager.session.invalidateAndCancel()
    }

    // MARK: - Token Adapter tests

    func testTokenAuthenticatorAdaptsRequests() {
        let authenticator = TokenAuthenticator(token: "TOKEN")
        let adapted = try! authenticator.adapt(apiRequest)
        let authorization = adapted.value(forHTTPHeaderField: authorizationHeader)
        XCTAssertEqual(authorization, "Bearer TOKEN", "TokenAuthenticator should add Authorization header")
    }

    func testTokenAuthenticatorDoesNotAdaptRequestsIfConditionFails() {
        let authenticator = TokenAuthenticator(token: "TOKEN", shouldAuthenticate: { _ in false })
        let adapted = try! authenticator.adapt(apiRequest)
        let authorization = adapted.value(forHTTPHeaderField: authorizationHeader)
        XCTAssertNil(authorization, "TokenAuthenticator should not add Authorization header if the condition is false")
    }

    // MARK: - CookieNonce Adapter tests

    func testCookieNonceAuthenticatorAdaptsRequestIfItHasNonce() {
        let authenticator = CookieNonceAuthenticator(username: "user", password: "pass", loginURL: loginURL, adminURL: adminURL, nonce: "TEST_NONCE")
        let adapted = try! authenticator.adapt(apiRequest)
        let nonce = adapted.value(forHTTPHeaderField: nonceHeader)
        XCTAssertEqual(nonce, "TEST_NONCE", "CookieNonceAuthenticator should add nonce header if it has a nonce")
    }

    func testCookieNonceAuthenticatorDoesNotAdaptRequestIfItDoesNotHaveNonce() {
        let authenticator = CookieNonceAuthenticator(username: "user", password: "pass", loginURL: loginURL, adminURL: adminURL)
        let adapted = try! authenticator.adapt(apiRequest)
        let nonce = adapted.value(forHTTPHeaderField: nonceHeader)
        XCTAssertNil(nonce, "CookieNonceAuthenticator should not add nonce header if it does not have one")
    }

    // MARK: - CookieNonce Retrier tests
    func testCookieNonceAuthenticatorRetriesOnlyOnce() {
        stub(condition: isLoginRequest()) { request in
            let stubPath = OHPathForFile("wp-admin-post-new.html", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "text/html" as AnyObject])
        }

        let authenticator = CookieNonceAuthenticator(username: "user", password: "pass", loginURL: loginURL, adminURL: adminURL)
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401))
        let completionExpectation = expectation(description: "First retry completion is called")
        var shouldRetry: Bool? = nil
        let completion: (Bool, TimeInterval) -> Void = { (retry, _) in
            shouldRetry = retry
            completionExpectation.fulfill()
        }
        let request = manager.request(apiRequest)
        authenticator.should(manager, retry: request, with: error, completion: completion)
        wait(for: [completionExpectation], timeout: 2)
        XCTAssertEqual(shouldRetry, true, "CookieNonceAuthenticator should retry request with 401 error if everything goes well")
    }
    
    
}

private extension AuthenticatorTests {
    func isLoginRequest() -> HTTPStubsTestBlock {
        return { request in
            return request.url?.absoluteString.hasPrefix(loginURL.absoluteString) ?? false
        }
    }
}
