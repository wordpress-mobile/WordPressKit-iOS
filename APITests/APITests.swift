@testable import WordPressKit
import XCTest

class APITests: XCTestCase {

    func testExample() throws {
        let remote = PluginServiceRemote(wordPressComRestApi: WordPressComRestApi.defaultApi())

        let expectation = XCTestExpectation(description: "")

        remote.getFeaturedPlugins(
            success: { plugins in
                XCTAssertFalse(plugins.isEmpty)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Expected to request to succeed, failed with \(error)")
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 10)
    }
}

// Copied from WordPress iOS with tweaks
extension WordPressComRestApi {
    @objc public static func defaultApi(oAuthToken: String? = nil,
                                        userAgent: String? = nil,
                                        localeKey: String = WordPressComRestApi.LocaleKeyDefault) -> WordPressComRestApi {
        return WordPressComRestApi(
            oAuthToken: oAuthToken,
            userAgent: userAgent,
            localeKey: localeKey,
            baseUrlString: WordPressComRestApi.apiBaseURLString
        )
    }
}
