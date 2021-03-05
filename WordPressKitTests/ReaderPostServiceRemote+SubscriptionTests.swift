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
    let subscribeToPostSuccessFalseMockFilename = "reader-post-comments-subscribe-failure.json"
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
        }) { (_) in
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
        readerPostServiceRemote.subscribeToPost(with: postID, for: siteID, success: { (success) in
            XCTAssertTrue(success, "Success should be true")
            expect.fulfill()
        }) { (_) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    /// Test that the attempt to subscribe to comments in a post returns `success: false`
    /// while "Block emails" is enabled on https://wordpress.com/me/notifications/subscriptions
    ///
    func testSubscribeToCommentsInPostSuccessFalse() {
        stubRemoteResponse(subscribeToPostEndpoint,
                           filename: subscribeToPostSuccessFalseMockFilename,
                           contentType: .ApplicationJSON)

        let expect = expectation(description: "Subscribe to comments for a post")
        readerPostServiceRemote.subscribeToPost(with: postID, for: siteID, success: { (successfullySubscribed) in
            XCTAssertFalse(successfullySubscribed, "Success response should be false")
            expect.fulfill()
        }) { (_) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    /// Test that the attempt to unsubscribe to comments in a post allows a user to successfully unsubscribe
    /// whether "Block emails" is enabled on https://wordpress.com/me/notifications/subscriptions or not.
    ///
    func testUnsubscribeFromCommentsInPost() {
        stubRemoteResponse(unsubscribeFromPostEndpoint,
                           filename: unsubscribeFromPostSuccessMockFilename,
                           contentType: .ApplicationJSON)

        let expect = expectation(description: "Unsubscribe from comments for a post")
        readerPostServiceRemote.unsubscribeFromPost(with: postID, for: siteID, success: { (success) in
            XCTAssertTrue(success, "Success should be true")
            expect.fulfill()
        }) { (_) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
