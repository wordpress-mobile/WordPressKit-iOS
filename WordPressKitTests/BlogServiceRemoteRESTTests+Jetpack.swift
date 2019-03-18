import Foundation
import XCTest
@testable import WordPressKit

class BlogServiceRemoteRESTTests_Jetpack: RemoteTestCase, RESTTestable {
    let siteId = 12345
    let url = "http://www.wordpress.com"
    let encodedURL = "http%3A%2F%2Fwww.wordpress.com"
    let username = "username"
    let password = "qwertyuiop"
    
    let jetpackRemoteSuccessMockFilename = "blog-service-jetpack-remote-success.json"
    let jetpackRemoteFailureMockFilename = "blog-service-jetpack-remote-failure.json"

    let jetpackRemoteErrorUnknownMockFilename = "blog-service-jetpack-remote-error-unknown.json"
    let jetpackRemoteErrorInvalidCredentialsMockFilename = "blog-service-jetpack-remote-error-invalid-credentials.json"
    let jetpackRemoteErrorForbiddenMockFilename = "blog-service-jetpack-remote-error-forbidden.json"
    let jetpackRemoteErrorInstallFailureMockFilename = "blog-service-jetpack-remote-error-install-failure.json"
    let jetpackRemoteErrorInstallResponseMockFilename = "blog-service-jetpack-remote-error-install-response.json"
    let jetpackRemoteErrorLoginFailureMockFilename = "blog-service-jetpack-remote-error-login-failure.json"
    let jetpackRemoteErrorSiteIsJetpackMockFilename = "blog-service-jetpack-remote-error-site-is-jetpack.json"
    let jetpackRemoteErrorActivationInstallMockFilename = "blog-service-jetpack-remote-error-activation-install.json"
    let jetpackRemoteErrorActivationResponseMockFilename = "blog-service-jetpack-remote-error-activation-response.json"
    let jetpackRemoteErrorActivationFailureMockFilename = "blog-service-jetpack-remote-error-activation-failure.json"
    
    var endpoint: String { return "jetpack-install/\(encodedURL)/?locale=en_US" }
    
    var remote: BlogServiceRemoteREST!
    
    // MARK: - Overridden Methods
    
    override func setUp() {
        super.setUp()

        remote = BlogServiceRemoteREST(wordPressComRestApi: getRestApi(), siteID: NSNumber(value: siteId))
    }
    
    override func tearDown() {
        super.tearDown()
        
        remote = nil
    }

    func testJetpackRemoteInstallationSuccess() {
        let expect = expectation(description: "Install Jetpack success")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteSuccessMockFilename, contentType: .ApplicationJSON, status: 200)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertTrue(success, "Success should be true")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationFailure() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteFailureMockFilename, contentType: .ApplicationJSON, status: 200)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationErrorInvalidCredentials() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorInvalidCredentialsMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .invalidCredentials)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationErrorUnknown() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorUnknownMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .unknown)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationErrorForbidden() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorForbiddenMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .forbidden)
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationInstallFailure() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorInstallFailureMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .installFailure)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationInstallResponse() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorInstallResponseMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .installResponseError)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationLoginFailure() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorLoginFailureMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .loginFailure)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationSiteIsJetpack() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorSiteIsJetpackMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .siteIsJetpack)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationActivationInstall() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorActivationInstallMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .activationOnInstallFailure)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationActivationResponse() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorActivationResponseMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .activationResponseError)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJetpackRemoteInstallationActivationFailure() {
        let expect = expectation(description: "Install Jetpack failure")
        
        stubRemoteResponse(endpoint, filename: jetpackRemoteErrorActivationFailureMockFilename, contentType: .ApplicationJSON, status: 400)
        remote.installJetpack(url: url, username: username, password: password) { (success, error) in
            XCTAssertFalse(success, "Success should be false")
            XCTAssertEqual(error, .activationFailure)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
