import XCTest
@testable import WordPressKit

class SiteDesignServiceRemoteTests: RemoteTestCase, RESTTestable {
    let successMockFilename = "nux-starter-designs-success.json"

    /// The data in this file is missing required values.
    let malformedMockFilename = "nux-starter-designs-malformed.json"
    let endpoint = "rest/v1.1/nux/starter-designs"

    var restAPI: WordPressComRestApi!
    let expectedParameters: [String: AnyObject] = [ "scale": "2" as AnyObject, "preview_width": "400" as AnyObject]

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
        SiteDesignServiceRemote.fetchSiteDesigns(restAPI, additionalParameters: expectedParameters) { (result) in
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
        SiteDesignServiceRemote.fetchSiteDesigns(restAPI, additionalParameters: expectedParameters) { (result) in
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

    func testFetchSiteDesignsConflictingParameters() {
        let expect = expectation(description: "Fetch available site designs")
        let expectedParameters: [String: AnyObject] = [
            "type": "test" as AnyObject, // This conficts with the default parameter.
            "scale": "2" as AnyObject,
            "preview_width": "400" as AnyObject
        ]

        stubRemoteResponse(endpoint, filename: successMockFilename, contentType: .ApplicationJSON)
        SiteDesignServiceRemote.fetchSiteDesigns(restAPI, additionalParameters: expectedParameters) { (result) in
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
        SiteDesignServiceRemote.fetchSiteDesigns(restAPI, additionalParameters: nil) { (result) in
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
