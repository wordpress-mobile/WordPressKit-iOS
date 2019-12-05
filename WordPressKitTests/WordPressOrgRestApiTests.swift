import Foundation
import XCTest
import OHHTTPStubs
@testable import WordPressKit

class WordPressOrgRestApiTests: XCTestCase {

    let apiBase = URL(string: "https://wordpress.org/wp-json/")!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    private func isAPIRequest() -> OHHTTPStubsTestBlock {
        return { request in
            return request.url?.absoluteString.hasPrefix(self.apiBase.absoluteString) ?? false
        }
    }

    func testUnauthorizedCall() {
        stub(condition: isAPIRequest()) { request in
            let stubPath = OHPathForFile("wp-forbidden.json", type(of: self))
            return fixture(filePath: stubPath!, status: 401, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgRestApi(apiBase: apiBase)
        api.GET("wp/v2/settings", parameters: nil) { (result, response) in
            expect.fulfill()
            switch result {
            case .success(_):
                XCTFail("This call should not suceed")
            case .failure(_):
                XCTAssertEqual(response?.statusCode, 401, "Response should be unauthorized")
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSuccessfulCall() {
        stub(condition: isAPIRequest()) { request in
            let stubPath = OHPathForFile("wp-pages.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgRestApi(apiBase: apiBase)
        api.GET("wp/v2/pages", parameters: nil) { (result, response) in
            expect.fulfill()
            switch result {
            case .success(let object):
                guard let pages = object as? [AnyObject] else {
                    XCTFail("Unexpected API result")
                    return
                }
                XCTAssertEqual(pages.count, 10, "The API should return 10 pages")
            case .failure(_):
                XCTFail("This call should not fail")
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
}
