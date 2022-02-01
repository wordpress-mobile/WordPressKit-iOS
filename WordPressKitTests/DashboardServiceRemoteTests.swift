import XCTest

@testable import WordPressKit

class DashboardServiceRemoteTests: RemoteTestCase, RESTTestable {
    let mockRemoteApi = MockWordPressComRestApi()
    var dashboardServiceRemote: DashboardServiceRemote!

    override func setUp() {
        dashboardServiceRemote = DashboardServiceRemote(wordPressComRestApi: getRestApi())
    }

    // Request the correct set of cards
    //
    func testRequestCards() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("wpcom/v2/sites/165243437/dashboard/cards/v1_1/?cards=posts,today_stats", filename: "dashboard-200-with-drafts-and-scheduled-posts.json", contentType: .ApplicationJSON)

        dashboardServiceRemote.fetch(cards: ["posts", "today_stats"], forBlogID: 165243437) {
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
