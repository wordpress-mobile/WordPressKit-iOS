import XCTest
import OHHTTPStubs
@testable import WordPressKit

class BlogSyncServiceTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    func testSyncBlogSuccess() throws {
        let api = WordPressComRestApi()
        let service = BlogSyncService(wordPressComRESTAPI: api, blogID: 1)

        // FIXME: Currently missing fixture for the correct response
        let path = try XCTUnwrap(OHPathForFile("rest-site-settings.json", type(of: self)))
        stub(condition: isPath("/rest/v1.1/sites/1")) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }

        let callCompleted = expectation(description: "API call completed.")

        service.syncBlog(
            success: { blog in
                callCompleted.fulfill()
                // Smoke test
                XCTAssertEqual(blog.name, "My Epic Blog")
                XCTAssertEqual(blog.tagline, "Definitely, the best blog out there")
            },
            failure: { error in
                XCTFail("Expected to succeed. Failed with \(String(describing: error)).")
            }
        )

        wait(for: [callCompleted], timeout: 1)
    }

    func testSyncBlogFailure() throws {
        let api = WordPressComRestApi()
        let service = BlogSyncService(wordPressComRESTAPI: api, blogID: 1)

        stub(condition: isPath("/rest/v1.1/sites/1")) { _ in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 500, headers: .none)
        }

        let callCompleted = expectation(description: "API call completed.")

        service.syncBlog(
            success: { blog in
                XCTFail("Expected to fail. Succeeded with \(blog)")
            },
            failure: { error in
                callCompleted.fulfill()
            }
        )

        wait(for: [callCompleted], timeout: 1)
    }

    func testSyncBlogSettingsSuccess() throws {
        let api = WordPressComRestApi()
        let service = BlogSyncService(wordPressComRESTAPI: api, blogID: 1)

        let path = try XCTUnwrap(OHPathForFile("rest-site-settings.json", type(of: self)))
        stub(condition: isPath("/rest/v1.1/sites/1/settings")) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }

        let callCompleted = expectation(description: "API call completed.")

        service.syncBlogSettings(
            success: { blogSettings in
                callCompleted.fulfill()
                // Smoke test
                XCTAssertEqual(blogSettings.name, "My Epic Blog")
                XCTAssertEqual(blogSettings.tagline, "Definitely, the best blog out there")
                XCTAssertEqual(blogSettings.ampSupported, 0)
            },
            failure: { error in
                XCTFail("Expected to succeed. Failed with \(String(describing: error)).")
            }
        )

        wait(for: [callCompleted], timeout: 1)
    }

    func testSyncBlogSettingsFailure() throws {
        let api = WordPressComRestApi()
        let service = BlogSyncService(wordPressComRESTAPI: api, blogID: 1)

        stub(condition: isPath("/rest/v1.1/sites/1/settings")) { _ in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 500, headers: .none)
        }

        let callCompleted = expectation(description: "API call completed.")

        service.syncBlogSettings(
            success: { blogSettings in
                XCTFail("Expected to fail. Succeeded with \(blogSettings)")
            },
            failure: { error in
                callCompleted.fulfill()
            }
        )

        wait(for: [callCompleted], timeout: 1)
    }

    func testUpdateBlogSettingsSuccess() throws {
        let api = WordPressComRestApi()
        let service = BlogSyncService(wordPressComRESTAPI: api, blogID: 1)

        stub(condition: updateSettingsCondition) { _ in
            return HTTPStubsResponse(jsonObject: ["updated": "TBD"], statusCode: 200, headers: .none)
        }

        let callCompleted = expectation(description: "API call completed.")

        service.updateBlogSettings(
            RemoteBlogSettings(jsonDictionary: [:]),
            success: {
                callCompleted.fulfill()
            },
            failure: { error in
                XCTFail("Expected to succeed. Failed with \(String(describing: error)).")
            }
        )

        wait(for: [callCompleted], timeout: 1)
    }

    func testUpdateBlogSettingsFailureUnexpectedResponse() throws {
        let api = WordPressComRestApi()
        let service = BlogSyncService(wordPressComRESTAPI: api, blogID: 1)

        // If updated is not present, it should fail with no error.
        stub(condition: updateSettingsCondition) { _ in
            return HTTPStubsResponse(jsonObject: ["key": "value"], statusCode: 200, headers: .none)
        }

        let callCompleted = expectation(description: "API call completed.")

        service.updateBlogSettings(
            RemoteBlogSettings(jsonDictionary: [:]),
            success: {
                XCTFail("Expected to fail, but succeeded")
            },
            failure: { error in
                callCompleted.fulfill()
                XCTAssertNil(error)
            }
        )

        wait(for: [callCompleted], timeout: 1)
    }

    func testUpdateBlogSettingsFailure() throws {
        let api = WordPressComRestApi()
        let service = BlogSyncService(wordPressComRESTAPI: api, blogID: 1)

        stub(condition: updateSettingsCondition) { _ in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 500, headers: .none)
        }

        let callCompleted = expectation(description: "API call completed.")

        service.syncBlogSettings(
            success: { blogSettings in
                XCTFail("Expected to fail, but succeeded")
            },
            failure: { error in
                callCompleted.fulfill()
            }
        )

        wait(for: [callCompleted], timeout: 1)
    }

    let updateSettingsCondition = isPath("/rest/v1.1/sites/1/settings") && containsQueryParams(["context": "update"])
}
