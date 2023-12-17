import Foundation
import XCTest
import Alamofire
import OHHTTPStubs

@testable import WordPressKit

final class CookieNonceAuthenticatorTests: XCTestCase {

    static let nonce = "leg1tn0nce"
    static let siteURL = URL(string: "https://test.com")!
    static let siteLoginURL = URL(string: "https://test.com/wp-login.php")!
    static let siteAdminURL = URL(string: "https://test.com/wp-admin/")!
    static let newPostURL = URL(string: "https://test.com/wp-admin/post-new.php")!
    static let ajaxURL = URL(string: "https://test.com/wp-admin/admin-ajax.php?action=rest-nonce")!
    static let endpointThatRequiresAuthentication = URL(string: "https://test.com/wp-json/wp/v2/post/delete")!

    override func setUp() {
        stub(condition: isAbsoluteURLString(Self.endpointThatRequiresAuthentication.absoluteString)) { request in
            if request.value(forHTTPHeaderField: "X-WP-Nonce") == Self.nonce {
                return HTTPStubsResponse(data: Data(), statusCode: 201, headers: nil)
            } else {
                return HTTPStubsResponse(data: Data(), statusCode: 401, headers: nil)
            }
        }
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }

    func testUsingNewPostPage() {
        stubLoginRedirect(dest: Self.newPostURL)
        stubNewPostPage(statusCode: 200)

        let authenticator = CookieNonceAuthenticator(username: "test", password: "password", loginURL: Self.siteLoginURL, adminURL: Self.siteAdminURL, version: "4.0")
        let session = SessionManager(configuration: .ephemeral)
        session.adapter = authenticator
        session.retrier = authenticator
        wait(for: [apiCallShouldSucceed(using: session)], timeout: 0.1)
    }

    func testUsingRESTNonceAjax() {
        stubLoginRedirect(dest: Self.ajaxURL)
        stubAjax(statusCode: 200)

        let authenticator = CookieNonceAuthenticator(username: "test", password: "password", loginURL: Self.siteLoginURL, adminURL: Self.siteAdminURL, version: "6.0")
        let session = SessionManager(configuration: .ephemeral)
        session.adapter = authenticator
        session.retrier = authenticator
        wait(for: [apiCallShouldSucceed(using: session)], timeout: 0.1)
    }

    private func stubLoginRedirect(dest: URL) {
        stub(condition: isAbsoluteURLString(Self.siteLoginURL.absoluteString)) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 302, headers: ["Location": dest.absoluteString])
        }
    }

    private func stubNewPostPage(nonceScript: String? = nil, statusCode: Int32) {
        let script = nonceScript ?? """
            wp.apiFetch.nonceMiddleware = wp.apiFetch.createNonceMiddleware( "\(Self.nonce)" );
            wp.apiFetch.use( wp.apiFetch.nonceMiddleware );
            wp.apiFetch.use( wp.apiFetch.mediaUploadMiddleware );
            """
        let html = "<!DOCTYPE html><html>\n\(script)\n</html>"
        stub(condition: isAbsoluteURLString(Self.newPostURL.absoluteString)) { _ in
            HTTPStubsResponse(data: html.data(using: .utf8)!, statusCode: statusCode, headers: nil)
        }
    }

    private func stubAjax(statusCode: Int32) {
        stub(condition: isAbsoluteURLString(Self.ajaxURL.absoluteString)) { _ in
            HTTPStubsResponse(data: (statusCode == 200 ? Self.nonce : "<html>...</html>").data(using: .utf8)!, statusCode: statusCode, headers: nil)
        }
    }

    private func apiCallShouldSucceed(using session: SessionManager) -> XCTestExpectation {
        let expectation = expectation(description: "API call should eventually succeed")
        session
            .request(Self.endpointThatRequiresAuthentication)
            .validate()
            .responseData { response in
            if response.response?.statusCode == 201 {
                expectation.fulfill()
            }
        }
        return expectation
    }

}
