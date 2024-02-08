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

    func testUnauthorizedCall() async throws {
        stub(condition: isAPIRequest()) { _ in
            let stubPath = OHPathForFile("wp-forbidden.json", type(of: self))
            return fixture(filePath: stubPath!, status: 401, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let api = WordPressOrgRestApi(apiBase: apiBase)
        let result = await api.get(path: "wp/v2/settings", type: AnyResponse.self)
        switch result {
        case .success:
            XCTFail("This call should not suceed")
        case let .failure(error):
            XCTAssertEqual(error.response?.statusCode, 401, "Response should be unauthorized")
        }
    }

    func testSuccessfulGetCall() async throws {
        stub(condition: isAPIRequest()) { _ in
            let stubPath = OHPathForFile("wp-pages.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }
        let api = WordPressOrgRestApi(apiBase: apiBase)
        let pages = try await api.get(path: "wp/v2/pages", type: [AnyResponse].self).get()
        XCTAssertEqual(pages.count, 10, "The API should return 10 pages")
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

    func testRequestPathModificationsWPV2() async throws {
        stub(condition: isPath("/wp/v2/sites/1001/themes") && containsQueryParams(["status": "active"])) { _ in
            HTTPStubsResponse(jsonObject: [String: String](), statusCode: 200, headers: nil)
        }
        let api = WordPressOrgRestApi(site: .dotCom(siteID: 1001, bearerToken: "fakeToken"))
        let _ = try await api.get(path: "/wp/v2/themes", parameters: ["status": "active"], type: AnyResponse.self).get()
    }

    func testRequestPathModificationsWPBlockEditor() async throws {
        stub(condition: isPath("/wp-block-editor/v1/sites/1001/settings")) { _ in
            HTTPStubsResponse(jsonObject: [String: String](), statusCode: 200, headers: nil)
        }
        let api = WordPressOrgRestApi(site: .dotCom(siteID: 1001, bearerToken: "fakeToken"))
        let _ = try await api.get(path: "/wp-block-editor/v1/settings", type: AnyResponse.self).get()
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

private struct AnyResponse: Decodable {}
