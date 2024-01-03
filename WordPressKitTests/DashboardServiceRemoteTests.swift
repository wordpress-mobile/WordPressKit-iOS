import XCTest
import OHHTTPStubs

@testable import WordPressKit

class DashboardServiceRemoteTests: RemoteTestCase, RESTTestable {
    let mockRemoteApi = MockWordPressComRestApi()
    var dashboardServiceRemote: DashboardServiceRemote!

    override func setUp() {
        dashboardServiceRemote = DashboardServiceRemote(wordPressComRestApi: getRestApi())
    }

    // Requests the correct set of cards
    //
    func testRequestCardsParam() {
        let expect = expectation(description: "Get cards successfully")

        let expectedQueryParams = [
//            "identifier": "com.apple.dt.xctest.tool",
//            "platform": "ios",
//            "build_number": "22516",
//            "marketing_version": "15.1",
//            "device_id": "Test",
            "cards": "posts,todays_stats",
            "locale": "en"
        ]

        stubRemoteResponse({ req in
            let containsQueryParams = containsQueryParams(expectedQueryParams)(req)
            let matchesPath = isPath("/wpcom/v2/sites/165243437/dashboard/cards-data")(req)
            let matchesURL = containsQueryParams && matchesPath
            XCTAssertTrue(matchesURL)
            return matchesURL
        }, filename: "dashboard-200-with-drafts-and-scheduled-posts.json", contentType: .ApplicationJSON)

        dashboardServiceRemote.fetch(cards: ["posts", "todays_stats"], forBlogID: 165243437) { _ in
            expect.fulfill()
        } failure: { _ in }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Return the cards when the request succeeds
    //
    func testRequestCards() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("wpcom/v2/sites/165243437/dashboard/cards-data/?cards=posts,todays_stats", filename: "dashboard-200-with-drafts-and-scheduled-posts.json", contentType: .ApplicationJSON)

        dashboardServiceRemote.fetch(cards: ["posts", "todays_stats"], forBlogID: 165243437) { cards in
            XCTAssertTrue((cards["posts"] as! NSDictionary)["has_published"] as! Bool)
            XCTAssertEqual((cards["todays_stats"] as! NSDictionary)["views"] as! Int, 0)
            expect.fulfill()
        } failure: { _ in }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Calls the failure block when request fails
    //
    func testRequestFails() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("wpcom/v2/sites/165243437/dashboard/cards-data/?cards=posts,todays_stats", filename: "dashboard-200-with-drafts-and-scheduled-posts.json", contentType: .ApplicationJSON, status: 503)

        dashboardServiceRemote.fetch(cards: ["posts", "todays_stats"], forBlogID: 165243437) { _ in
            XCTFail("This call should not suceed")
        } failure: { error in
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Calls the failure block when an invalid card is given
    //
    func testRequestInvalidCard() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("wpcom/v2/sites/165243437/dashboard/cards-data/?cards=invalid_card", filename: "dashboard-400-invalid-card.json", contentType: .ApplicationJSON, status: 400)

        dashboardServiceRemote.fetch(cards: ["invalid_card"], forBlogID: 165243437) { _ in
            XCTFail("This call should not suceed")
        } failure: { error in
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Calls the failure block when request fails
    //
    func testRequestInvalidJSON() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("wpcom/v2/sites/165243437/dashboard/cards-data/?cards=posts,todays_stats", data: "foo".data(using: .utf8)!, contentType: .ApplicationJSON)

        dashboardServiceRemote.fetch(cards: ["posts", "todays_stats"], forBlogID: 165243437) { _ in
            XCTFail("This call should not suceed")
        } failure: { error in
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
