import XCTest
@testable import WordPressKit

final class AppTransportSecurityTests: XCTestCase {

    private var exampleURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        exampleURL = try XCTUnwrap(URL(string: "https://example.com"))
    }

    override func tearDown() {
        exampleURL = nil
        super.tearDown()
    }

    func testReturnsTrueIfAllowsLocalNetworkingIsTrue() throws {
        // Given
        let provider = FakeInfoDictionaryObjectProvider(appTransportSecurity: [
            "NSAllowsLocalNetworking": true,
            // This will be ignored
            "NSAllowsArbitraryLoads": true
        ])
        let appTransportSecurity = AppTransportSecurity(infoDictionaryObjectProvider: provider)

        // When
        let secureAccessOnly = appTransportSecurity.secureAccessOnly(for: exampleURL)

        // Then
        XCTAssertTrue(secureAccessOnly)
    }

    func testReturnsFalseIfAllowsArbitraryLoadsIsTrue() throws {
        // Given
        let provider = FakeInfoDictionaryObjectProvider(appTransportSecurity: [
            "NSAllowsArbitraryLoads": true
        ])
        let appTransportSecurity = AppTransportSecurity(infoDictionaryObjectProvider: provider)

        // When
        let secureAccessOnly = appTransportSecurity.secureAccessOnly(for: exampleURL)

        // Then
        XCTAssertFalse(secureAccessOnly)
    }

    func testReturnsTrueByDefault() throws {
        // Given
        let provider = FakeInfoDictionaryObjectProvider(appTransportSecurity: [String: Any]())
        let appTransportSecurity = AppTransportSecurity(infoDictionaryObjectProvider: provider)

        // When
        let secureAccessOnly = appTransportSecurity.secureAccessOnly(for: exampleURL)

        // Then
        XCTAssertTrue(secureAccessOnly)
    }
}

private class FakeInfoDictionaryObjectProvider: InfoDictionaryObjectProvider {
    private let appTransportSecurity: [String: Any]

    init(appTransportSecurity: [String: Any]) {
        self.appTransportSecurity = appTransportSecurity
    }

    func object(forInfoDictionaryKey key: String) -> Any? {
        if key == "NSAppTransportSecurity" {
            return appTransportSecurity
        }

        return nil
    }
}
