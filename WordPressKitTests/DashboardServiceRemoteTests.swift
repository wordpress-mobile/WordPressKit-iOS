import XCTest

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
        stubRemoteResponse("wpcom/v2/sites/165243437/dashboard/cards/v1_1/?cards=posts,todays_stats", filename: "dashboard-200-with-drafts-and-scheduled-posts.json", contentType: .ApplicationJSON)

        dashboardServiceRemote.fetch(cards: ["posts", "todays_stats"], forBlogID: 165243437) { _ in
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Return the cards when the request succeeds
    //
    func testRequestCards() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("wpcom/v2/sites/165243437/dashboard/cards/v1_1/?cards=posts,todays_stats", filename: "dashboard-200-with-drafts-and-scheduled-posts.json", contentType: .ApplicationJSON)

        dashboardServiceRemote.fetch(cards: ["posts", "todays_stats"], forBlogID: 165243437) { cards in
            XCTAssertTrue((cards["posts"] as! NSDictionary)["has_published"] as! Bool)
            XCTAssertEqual((cards["todays_stats"] as! NSDictionary)["views"] as! Int, 0)
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
