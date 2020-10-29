import XCTest
@testable import WordPressKit

class SiteDesignServiceRemoteTests: RemoteTestCase, RESTTestable {
    let successMockFilename = "nux-starter-designs-success.json"

    /// The data in this file is missing required values.
    let malformedMockFilename = "nux-starter-designs-malformed.json"
    let endpoint = "rest/v1.1/nux/starter-designs"

    var restAPI: WordPressComRestApi!
    let request = SiteDesignRequest(previewSize: CGSize(width: 400, height: 800), scale: 2)

    // MARK: - Overridden Methods
    override func setUp() {
        super.setUp()
        restAPI = getRestApi()
    }

    override func tearDown() {
        super.tearDown()
        restAPI = nil
    }

    // MARK: - Success Tests
    func testFetchSiteDesigns() {
        let expect = expectation(description: "Fetch available site designs")
        stubRemoteResponse(endpoint, filename: successMockFilename, contentType: .ApplicationJSON)
        SiteDesignServiceRemote.fetchSiteDesigns(restAPI, request: request) { (result) in
            switch result {
            case .success(let siteDesigns):
                XCTAssertNotNil(siteDesigns)
                expect.fulfill()
            case .failure:
                XCTFail("This callback shouldn't get called")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testFetchSiteDesignsEmptyResponse() {
        let expect = expectation(description: "Fetch available site designs")
        let responseData = "[]".data(using: .utf8)!
        stubRemoteResponse(endpoint, data: responseData, contentType: .ApplicationJSON)
        SiteDesignServiceRemote.fetchSiteDesigns(restAPI) { (result) in
            switch result {
            case .success(let siteDesigns):
                XCTAssertNotNil(siteDesigns)
                expect.fulfill()
            case .failure:
                XCTFail("This callback shouldn't get called")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // MARK: - Malformed Data Tests
    func testMalformedData() {
        let expect = expectation(description: "Fetch available site designs")
        stubRemoteResponse(endpoint, filename: malformedMockFilename, contentType: .ApplicationJSON)
        SiteDesignServiceRemote.fetchSiteDesigns(restAPI) { (result) in
            switch result {
            case .success:
                XCTFail("This callback shouldn't get called")
                expect.fulfill()
            case .failure(let error):
                XCTAssertNotNil(error)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
