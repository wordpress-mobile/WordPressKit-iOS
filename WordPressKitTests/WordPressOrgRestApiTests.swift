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
        HTTPStubs.removeAllStubs()
    }

    private func isAPIRequest() -> HTTPStubsTestBlock {
        return { request in
            return request.url?.absoluteString.hasPrefix(self.apiBase.absoluteString) ?? false
        }
    }

    func testUnauthorizedCall() {
        stub(condition: isAPIRequest()) { _ in
            let stubPath = OHPathForFile("wp-forbidden.json", type(of: self))
            return fixture(filePath: stubPath!, status: 401, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgRestApi(apiBase: apiBase)
        api.GET("wp/v2/settings", parameters: nil) { (result, response) in
            expect.fulfill()
            switch result {
            case .success:
                XCTFail("This call should not suceed")
            case .failure:
                XCTAssertEqual(response?.statusCode, 401, "Response should be unauthorized")
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSuccessfulGetCall() {
        stub(condition: isAPIRequest()) { _ in
            let stubPath = OHPathForFile("wp-pages.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgRestApi(apiBase: apiBase)
        api.GET("wp/v2/pages", parameters: nil) { (result, _) in
            expect.fulfill()
            switch result {
            case .success(let object):
                guard let pages = object as? [AnyObject] else {
                    XCTFail("Unexpected API result")
                    return
                }
                XCTAssertEqual(pages.count, 10, "The API should return 10 pages")
            case .failure:
                XCTFail("This call should not fail")
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSuccessfulPostCall() {
        stub(condition: isAPIRequest()) { _ in
            let stubPath = OHPathForFile("wp-reusable-blocks.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let expect = self.expectation(description: "One callback should be invoked")
        let api = WordPressOrgRestApi(apiBase: apiBase)
        let blockContent = "<!-- wp:paragraph -->\n<p>Some text</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:list -->\n<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>\n<!-- /wp:list -->"
        let parameters: [String: String] = ["id": "6", "content": blockContent]
        api.POST("wp/v2/blocks/6", parameters: parameters as [String: AnyObject]) { (result, _) in
            expect.fulfill()
            switch result {
            case .success(let object):
                guard
                    let block = object as? [String: AnyObject],
                    let content = block["content"] as? [String: AnyObject],
                    let rawContent = content["raw"] as? String
                else {
                    XCTFail("Unexpected API result")
                    return
                }
                XCTAssertEqual(block.count, 15, "The API should return the block")
                XCTAssertEqual(rawContent, blockContent, "The API should return the block")
            case .failure:
                XCTFail("This call should not fail")
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
}
