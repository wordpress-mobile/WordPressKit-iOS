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
    let getWpcomPlansSuccessMockFilename                 = "plans-mobile-success.json"


    // MARK: - Properties

    var sitePlansEndpoint: String { return "sites/\(siteID)/plans" }
    var plansMobileEndpoint: String { return "plans/mobile" }
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

    func testGetWpcomPlansSucceeds() {
        let expect = expectation(description: "Get wpcom plans success")

        stubRemoteResponse(plansMobileEndpoint, filename: getWpcomPlansSuccessMockFilename, contentType: .ApplicationJSON)

        remote.getWpcomPlans({ plans in
            XCTAssertEqual(plans.plans.count, 6, "The number of plans returned should be 6.")
            XCTAssertEqual(plans.features.count, 33, "The number of features returned should be 33.")
            XCTAssertEqual(plans.groups.count, 2, "The number of groups returned should be 2.")

            expect.fulfill()
        }) { error in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testGetWpcomPlansWithServerErrorFails() {
        let expect = expectation(description: "Get plans server error failure")

        stubRemoteResponse(plansMobileEndpoint, data: Data(), contentType: .NoContentType, status: 500)
        remote.getWpcomPlans({ plans in
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

    func testGetWpcomPlansWithBadJsonFails() {
        let expect = expectation(description: "Get plans with invalid json response failure")

        stubRemoteResponse(plansMobileEndpoint, filename: getPlansBadJsonFailureMockFilename, contentType: .ApplicationJSON, status: 200)
        remote.getWpcomPlans({ plans in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { error in
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testParseWpcomPlan() {
        let str = """
        {
            "groups": [
                "personal",
                "business"
            ],
            "products": [
                {
                    "plan_id": 1003
                },
                {
                    "plan_id": 1023
                }
            ],
            "name": "WordPress.com Premium",
            "short_name": "Premium",
            "tagline": "Best for Entrepreneurs and Freelancers",
            "description": "Build a unique website with advanced design tools, CSS editing, lots of space for audio and video, and the ability to monetize your site with ads.",
            "features": [
                "custom-domain",
                "jetpack-essentials",
                "support-live",
                "themes-premium",
                "design-custom",
                "space-13G",
                "no-ads",
                "simple-payments",
                "wordads",
                "videopress"
            ]
        }
        """
        let data = str.data(using: .utf8)!
        let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as! [String : AnyObject]
        XCTAssertNotNil(remote.parseWpcomPlan(json))
    }

    func testParseWpcomGroup() {
        let str = """
        {
            "slug": "personal",
            "name": "Personal"
        }
        """
        let data = str.data(using: .utf8)!
        let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as! [String : AnyObject]
        XCTAssertNotNil(remote.parsePlanGroup(json))
    }

    func testParseWpcomFeature() {
        let str = """
        {
            "id": "subdomain",
            "name": "WordPress.com Subdomain",
            "description": "Your site address will use a WordPress.com subdomain (sitename.wordpress.com)."
        }
        """
        let data = str.data(using: .utf8)!
        let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as! [String : AnyObject]
        XCTAssertNotNil(remote.parsePlanFeature(json))
    }

    func testUnexpectedJsonFormatYieldsNil() {
        let str = """
        {
            "key": "unexpected json"
        }
        """
        let data = str.data(using: .utf8)!
        let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as! [String : AnyObject]
        XCTAssertNil(remote.parseWpcomPlan(json))
        XCTAssertNil(remote.parsePlanGroup(json))
        XCTAssertNil(remote.parsePlanFeature(json))
    }

}
