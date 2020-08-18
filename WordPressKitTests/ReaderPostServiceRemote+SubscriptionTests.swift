import XCTest

@testable import WordPressKit

class ReaderPostServiceRemoteSubscriptionTests: RemoteTestCase, RESTTestable {
    
    // MARK: - Constants
    
    let siteID: Int = 0
    let postID: Int = 0
    let response = [String: AnyObject]()
    
    let fetchSubscriptionStatusEndpoint = "sites/0/posts/0/subscribers/mine"
    let subscribeToPostEndpoint = "sites/0/posts/0/subscribers/new"
    let unsubscribeFromPostEndpoint = "sites/0/posts/0/subscribers/mine/delete"
    
    let fetchSubscriptionStatusSuccessMockFilename = "reader-post-comments-subscription-status-success.json"
    let subscribeToPostSuccessMockFilename = "reader-post-comments-subscribe-success.json"
    let unsubscribeFromPostSuccessMockFilename = "reader-post-comments-unsubscribe-success.json"
    
    // MARK: - Properties
    
    var readerPostServiceRemote: ReaderPostServiceRemote!

    override func setUp() {
        super.setUp()
        readerPostServiceRemote = ReaderPostServiceRemote(wordPressComRestApi: getRestApi())
    }
    
    func testReturnSubscriptionStatus() {
        stubRemoteResponse(fetchSubscriptionStatusEndpoint,
                           filename: fetchSubscriptionStatusSuccessMockFilename,
                           contentType: .ApplicationJSON)

        let expect = expectation(description: "Check for subscription status")
        readerPostServiceRemote.fetchSubscriptionStatus(for: postID, from: siteID, success: { (success) in
            XCTAssertTrue(success, "Success should be true")
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSubscribeToCommentsInPost() {
        stubRemoteResponse(subscribeToPostEndpoint,
                           filename: subscribeToPostSuccessMockFilename,
                           contentType: .ApplicationJSON)

        let expect = expectation(description: "Subscribe to comments for a post")
        readerPostServiceRemote.subscribeToPost(with: postID, for: siteID,  success: { () in
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testUnsubscribeFromCommentsInPost() {
        stubRemoteResponse(unsubscribeFromPostEndpoint,
                           filename: unsubscribeFromPostSuccessMockFilename,
                           contentType: .ApplicationJSON)

        let expect = expectation(description: "Unsubscribe from comments for a post")
        readerPostServiceRemote.unsubscribeFromPost(with: postID, for: siteID, success: { () in
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
