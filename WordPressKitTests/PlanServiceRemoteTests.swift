import Foundation
import XCTest
@testable import WordPressKit

class PlanServiceRemoteTests: RemoteTestCase, RESTTestable {

    // MARK: - Constants

    let siteID   = 321

    let getPlansSuccessMockFilename                      = "site-plans-success.json"
    let getPlansEmptyFailureMockFilename                 = "site-plans-empty-failure.json"
    let getPlansAuthFailureMockFilename                  = "site-plans-auth-failure.json"
    let getPlansBadSiteFailureMockFilename               = "site-plans-failure.json"
    let getPlansBadJsonFailureMockFilename               = "site-plans-bad-json-failure.json"
    let getPlansSuccessMockFilename_ApiVersion1_3        = "site-plans-v3-success.json"
    let getPlansEmptyFailureMockFilename_ApiVersion1_3   = "site-plans-v3-empty-failure.json"
    let getPlansBadJsonFailureMockFilename_ApiVersion1_3 = "site-plans-v3-bad-json-failure.json"

    // MARK: - Properties

    var sitePlansEndpoint: String { return "sites/\(siteID)/plans" }
    var remote: PlanServiceRemote!
    var remoteV3: PlanServiceRemote_ApiVersion1_3!
    
    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()

        remote = PlanServiceRemote(wordPressComRestApi: getRestApi())
        remoteV3 = PlanServiceRemote_ApiVersion1_3(wordPressComRestApi: getRestApi())
    }

    override func tearDown() {
        super.tearDown()

        remote = nil
    }

    // MARK: - Get Plans Tests

    func testGetPlansSucceeds() {
        let expect = expectation(description: "Get plans for site success")

        stubRemoteResponse(sitePlansEndpoint, filename: getPlansSuccessMockFilename, contentType: .ApplicationJSON)
        remote.getPlansForSite(siteID, success: { sitePlans in
            XCTAssertEqual(sitePlans.activePlan?.id, 1, "The active plan id should be 1")
            XCTAssertEqual(sitePlans.availablePlans.count, 4, "The availible plans count should be 4")
            expect.fulfill()
        }) { error in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testGetPlansWithBadSiteFails() {
        let expect = expectation(description: "Get plans with incorrect site failure")

        stubRemoteResponse(sitePlansEndpoint, filename: getPlansBadSiteFailureMockFilename, contentType: .ApplicationJSON, status: 403)
        remote.getPlansForSite(siteID, success: { sitePlans in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, String(reflecting: WordPressComRestApiError.self), "The error domain should be WordPressComRestApiError")
            XCTAssertEqual(error.code, WordPressComRestApiError.authorizationRequired.rawValue, "The error code should be 2 - authorization_required")
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testGetPlansWithServerErrorFails() {
        let expect = expectation(description: "Get plans server error failure")

        stubRemoteResponse(sitePlansEndpoint, data: Data(), contentType: .NoContentType, status: 500)
        remote.getPlansForSite(siteID, success: { sitePlans in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, String(reflecting: WordPressComRestApiError.self), "The error domain should be WordPressComRestApiError")
            XCTAssertEqual(error.code, WordPressComRestApiError.unknown.rawValue, "The error code should be 7 - unknown")
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testGetPlansWithBadAuthFails() {
        let expect = expectation(description: "Get plans with bad auth failure")

        stubRemoteResponse(sitePlansEndpoint, filename: getPlansAuthFailureMockFilename, contentType: .ApplicationJSON, status: 403)
        remote.getPlansForSite(siteID, success: { sitePlans in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, String(reflecting: WordPressComRestApiError.self), "The error domain should be WordPressComRestApiError")
            XCTAssertEqual(error.code, WordPressComRestApiError.authorizationRequired.rawValue, "The error code should be 2 - authorization_required")
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testGetPlansWithBadJsonFails() {
        let expect = expectation(description: "Get plans with invalid json response failure")

        stubRemoteResponse(sitePlansEndpoint, filename: getPlansBadJsonFailureMockFilename, contentType: .ApplicationJSON, status: 200)
        remote.getPlansForSite(siteID, success: { sitePlans in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { error in
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetPlansSucceeds_ApiVersion1_3() {
        let expect = expectation(description: "Get plans for site success")
        
        stubRemoteResponse(sitePlansEndpoint, filename: getPlansSuccessMockFilename_ApiVersion1_3, contentType: .ApplicationJSON)
        
        remoteV3.getPlansForSite(siteID, success: { sitePlans in
            XCTAssertEqual(sitePlans.activePlan.hasDomainCredit, true, "Active plan should have domain credit")
            XCTAssertEqual(sitePlans.availablePlans.count, 7, "The availible plans count should be 7")
            expect.fulfill()
        }) { error in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetPlansWithEmptyResponseArrayFails_ApiVersion1_3() {
        let expect = expectation(description: "Get plans with empty response array success")
        
        stubRemoteResponse(sitePlansEndpoint, filename: getPlansEmptyFailureMockFilename_ApiVersion1_3, contentType: .ApplicationJSON)
        remoteV3.getPlansForSite(siteID, success: { sitePlans in
            XCTFail("The site should always return plans.")
            expect.fulfill()
        }, failure: { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, String(reflecting: PlanServiceRemote.ResponseError.self), "The error domain should be PlanServiceRemote.ResponseError")
            XCTAssertEqual(error.code, PlanServiceRemote.ResponseError.noActivePlan.rawValue, "The error code should be 2 - no active plan")
            expect.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetPlansWithBadJsonFails_ApiVersion1_3() {
        let expect = expectation(description: "Get plans with invalid json response failure")
        
        stubRemoteResponse(sitePlansEndpoint, filename: getPlansBadJsonFailureMockFilename_ApiVersion1_3, contentType: .ApplicationJSON, status: 200)
        remote.getPlansForSite(siteID, success: { sitePlans in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { error in
            expect.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
