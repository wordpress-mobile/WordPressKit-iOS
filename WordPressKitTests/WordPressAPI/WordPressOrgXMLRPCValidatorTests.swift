import XCTest
import OHHTTPStubs

@testable import WordPressKit

final class WordPressOrgXMLRPCValidatorTests: XCTestCase {

    private let exampleURLString = "http://example.com"

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    func testItWillGuessXMLRPCOnHTTPSOnlyByDefault() {
        // Given
        var schemes = Set<String>()
        // Stub all, we only care about the URL schemes that are being tested.
        stub(condition: { request -> Bool in
            if let scheme = request.url?.scheme {
                schemes.insert(scheme)
            }
            return true
        }, response: { _ in
            let error = NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
            return HTTPStubsResponse(error: error)
        })

        let validator = WordPressOrgXMLRPCValidator()

        // When
        let expectation = self.expectation(description: "Wait for success or failure")
        validator.guessXMLRPCURLForSite(exampleURLString, userAgent: "", success: { _ in
            expectation.fulfill()
        }, failure: { _ in
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(schemes, Set(arrayLiteral: "https"))
    }

    func testItWillGuessXMLRPCOnBothHTTPAndHTTPSIfUnsecuredConnectionsAreAllowed() {
        // Given
        var schemes = Set<String>()
        // Stub all, we only care about the URL schemes that are being tested.
        stub(condition: { request -> Bool in
            if let scheme = request.url?.scheme {
                schemes.insert(scheme)
            }
            return true
        }, response: { _ in
            let error = NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
            return HTTPStubsResponse(error: error)
        })

        let validator = WordPressOrgXMLRPCValidator(makeUnsecuredAppTransportSecuritySettings())

        // When
        let expectation = self.expectation(description: "Wait for success or failure")
        validator.guessXMLRPCURLForSite(exampleURLString, userAgent: "", success: { _ in
            expectation.fulfill()
        }, failure: { _ in
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(schemes, Set(arrayLiteral: "https", "http"))
    }
}

private extension WordPressOrgXMLRPCValidatorTests {
    func makeUnsecuredAppTransportSecuritySettings() -> AppTransportSecuritySettings {
        let provider = FakeInfoDictionaryObjectProvider(appTransportSecurity: [
            "NSAllowsArbitraryLoads": true
        ])

        return AppTransportSecuritySettings(provider)
    }
}
