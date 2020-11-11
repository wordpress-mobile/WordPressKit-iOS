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
    var manager = Session()

    override func setUp() {
        manager = Session()
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        manager.session.invalidateAndCancel()
    }

    // MARK: - Token Adapter tests

    func testTokenAuthenticatorAdaptsRequests() {
        let expect = self.expectation(description: "Token authenticator adapts requests")
        
        let authenticator = TokenAuthenticator(token: "TOKEN")
        authenticator.adapt(apiRequest, for: manager, completion: { (result) in
            expect.fulfill()
            let authorization = try! result.get().value(forHTTPHeaderField: authorizationHeader)
            XCTAssertEqual(authorization, "Bearer TOKEN", "TokenAuthenticator should add Authorization header")
            
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenAuthenticatorDoesNotAdaptRequestsIfConditionFails() {
        let expect = self.expectation(description: "Token authenticator does not adapt requests")
        
        let authenticator = TokenAuthenticator(token: "TOKEN", shouldAuthenticate: { _ in false })
        authenticator.adapt(apiRequest, for: manager, completion: { (result) in
            expect.fulfill()
            let authorization = try! result.get().value(forHTTPHeaderField: authorizationHeader)
            XCTAssertNil(authorization, "TokenAuthenticator should not add Authorization header if the condition is false")
            
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    // MARK: - CookieNonce Adapter tests

    func testCookieNonceAuthenticatorAdaptsRequestIfItHasNonce() {
        let expect = self.expectation(description: "Cookie nonce authenticator adapt request if it has nonce")
        
        let authenticator = CookieNonceAuthenticator(username: "user", password: "pass", loginURL: loginURL, adminURL: adminURL, nonce: "TEST_NONCE")
        authenticator.adapt(apiRequest, for: manager, completion: { (result) in
            expect.fulfill()
            let nonce = try! result.get().value(forHTTPHeaderField: nonceHeader)
            XCTAssertEqual(nonce, "TEST_NONCE", "CookieNonceAuthenticator should add nonce header if it has a nonce")
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCookieNonceAuthenticatorDoesNotAdaptRequestIfItDoesNotHaveNonce() {
        let expect = self.expectation(description: "Cookie nonce authenticator does not adapt request if it has does not have nonce")
        
        let authenticator = CookieNonceAuthenticator(username: "user", password: "pass", loginURL: loginURL, adminURL: adminURL)
        authenticator.adapt(apiRequest, for: manager, completion: { (result) in
            expect.fulfill()
            let nonce = try! result.get().value(forHTTPHeaderField: nonceHeader)
            XCTAssertNil(nonce, "CookieNonceAuthenticator should not add nonce header if it does not have one")
            
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    // MARK: - CookieNonce Retrier tests
//    func testCookieNonceAuthenticatorRetriesOnlyOnce() {
//        stub(condition: isLoginRequest()) { request in
//            let stubPath = OHPathForFile("wp-admin-post-new.html", type(of: self))
//            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "text/html" as AnyObject])
//        }
//
//        let authenticator = CookieNonceAuthenticator(username: "user", password: "pass", loginURL: loginURL, adminURL: adminURL)
//        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401))
//        let completionExpectation = expectation(description: "First retry completion is called")
//        var shouldRetry: Bool? = nil
//        let completion: (Bool, TimeInterval) -> Void = { (retry, _) in
//            shouldRetry = retry
//            completionExpectation.fulfill()
//        }
//        let request = manager.request(apiRequest)
//        authenticator.should(manager, retry: request, with: error, completion: completion)
//        wait(for: [completionExpectation], timeout: 2)
//        XCTAssertEqual(shouldRetry, true, "CookieNonceAuthenticator should retry request with 401 error if everything goes well")
//    }

    
}

private extension AuthenticatorTests {
    func isLoginRequest() -> HTTPStubsTestBlock {
        return { request in
            return request.url?.absoluteString.hasPrefix(loginURL.absoluteString) ?? false
        }
    }
}
