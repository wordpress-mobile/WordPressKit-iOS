import XCTest

@testable import WordPressKit

class JetpackCapabilitiesServiceRemoteTests: RemoteTestCase, RESTTestable {
    let mockRemoteApi = MockWordPressComRestApi()
    var service: JetpackCapabilitiesServiceRemote!

    override func setUp() {
        super.setUp()

        service = JetpackCapabilitiesServiceRemote(wordPressComRestApi: getRestApi())
    }

    /// Return the capabilities for the given siteIDs
    func testSuccessBatchCapabilities() {
        let expect = expectation(description: "Get the available capabilities")
        stubRemoteResponse("wpcom/v2/rewind/batch-capabilities", filename: "jetpack-batch-capabilities-success.json", contentType: .ApplicationJSON)

        service.for(siteIds: [34197361, 107159616], success: { capabilities in
            XCTAssertTrue(capabilities.count == 2)
            XCTAssertTrue((capabilities["34197361"] as? [String])!.isEmpty)
            XCTAssertTrue((capabilities["107159616"] as? [String])!.contains("backup"))
            XCTAssertTrue((capabilities["107159616"] as? [String])!.contains("backup-realtime"))
            XCTAssertTrue((capabilities["107159616"] as? [String])!.contains("scan"))
            XCTAssertTrue((capabilities["107159616"] as? [String])!.contains("antispam"))
            expect.fulfill()
        }, failure: {

        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    /// Calls the failure block in case of a malformed JSON
    func testMalformedBatchCapabilities() {
        let expect = expectation(description: "Failures to decode the JSON")
        stubRemoteResponse("wpcom/v2/rewind/batch-capabilities", filename: "jetpack-batch-capabilities-malformed.json", contentType: .ApplicationJSON)

        service.for(siteIds: [34197361, 107159616], success: { capabilities in
        }, failure: {
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
