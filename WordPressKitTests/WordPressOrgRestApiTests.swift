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

    func testSuccessfulPostCall() async throws {
        stub(condition: isAPIRequest()) { _ in
            let stubPath = OHPathForFile("wp-reusable-blocks.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        struct Response: Decodable {
            struct Content: Decodable {
                var raw: String
            }

            var content: Content
        }

        let api = WordPressOrgRestApi(apiBase: apiBase)
        let blockContent = "<!-- wp:paragraph -->\n<p>Some text</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:list -->\n<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>\n<!-- /wp:list -->"
        let parameters: [String: String] = ["id": "6", "content": blockContent]
        let response = try await api.post(path: "wp/v2/blocks/6", parameters: parameters, type: Response.self).get()
        XCTAssertEqual(response.content.raw, blockContent, "The API should return the block")
    }

        /// Verify that parameters in POST requests are sent as urlencoded form.
    func testPostParametersContent() async throws {
        var req: URLRequest?
        stub(condition: isHost("wordpress.org")) {
            req = $0
            return HTTPStubsResponse(error: URLError(.notConnectedToInternet))
        }

        struct Empty: Decodable {}

        let api = WordPressOrgRestApi(apiBase: apiBase)
        let _ = await api.post(path: "/rest/v1/foo", parameters: ["arg1": "value1"], type: Empty.self)

        let request = try XCTUnwrap(req)
        XCTAssertEqual(request.httpMethod?.uppercased(), "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/wp-json/rest/v1/foo")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(request.httpBodyText, "arg1=value1")
    }
}

extension WordPressOrgRestApi {
    convenience init(apiBase: URL) {
        self.init(
            selfHostedSiteWPJSONURL: apiBase,
            credential: .init(loginURL: URL(string: "https://not-used.com")!, username: "user", password: "pass", adminURL: URL(string: "https://not-used.com")!)
        )
    }
}
