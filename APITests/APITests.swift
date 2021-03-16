@testable import WordPressKit
import OHHTTPStubs
import XCTest

class APITests: XCTestCase {

    func testExample() throws {
        let remote = PluginServiceRemote(wordPressComRestApi: WordPressComRestApi.defaultApi())

        stub(
            condition: { _ in return true },
            response: { _ -> HTTPStubsResponse in
                return HTTPStubsResponse(
                    data: responseWithDouble.data(using: .utf8)!,
                    statusCode: 200,
                    headers: .none
                )
            }
        )

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

let responseWithDouble = #"""
[
    {
        "name": "WooCommerce",
        "author": "<a href=\"https://woocommerce.com\">Automattic</a>",
        "rating": 81.84055644729803,
        "icons": {
            "1x": "https://ps.w.org/woocommerce/assets/icon-128x128.png?rev=2383496",
            "2x": "https://ps.w.org/woocommerce/assets/icon-256x256.png?rev=2383496"
        },
        "slug": "woocommerce"
    }
]
"""#
