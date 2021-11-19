import Foundation
import XCTest

@testable import WordPressKit

final class CommentServiceRemoteRESTTests: RemoteTestCase, RESTTestable {
    private let fetchCommentsSuccessFilename = "site-comments-success.json"
    private let siteId = 0
    private var remote: CommentServiceRemoteREST!

    private var siteCommentsEndpoint: String {
        return "sites/\(siteId)/comments"
    }

    override func setUp() {
        super.setUp()
        remote = CommentServiceRemoteREST(wordPressComRestApi: getRestApi(), siteID: NSNumber(value: siteId))
    }

    override func tearDown() {
        remote = nil
        super.tearDown()
    }

    // MARK: Tests

    func testGetCommentsSucceeds() {
        let expect = expectation(description: "Fetching site comments should succeed")

        stubRemoteResponse(siteCommentsEndpoint,
                           filename: fetchCommentsSuccessFilename,
                           contentType: .ApplicationJSON)

        remote.getCommentsWithMaximumCount(1,
                                           success: { comments, totalComments in

            guard let comment = comments?.first as? RemoteComment else {
                XCTFail("Failed to retrieve mock site comment")
                return
            }

            XCTAssertEqual(comment.author, "Comment Author")
            XCTAssertEqual(comment.authorEmail, "author@email.com")
            XCTAssertEqual(comment.authorUrl, "author URL")
            XCTAssertEqual(comment.authorIP, "000.0.00.000")
            XCTAssertEqual(comment.date, NSDate(wordPressComJSONString: "2021-08-04T07:58:49+00:00") as Date)
            XCTAssertEqual(comment.link, "comment URL")
            XCTAssertEqual(comment.parentID, nil)
            XCTAssertEqual(comment.postID, NSNumber(value: 1))
            XCTAssertEqual(comment.postTitle, "Post title")
            XCTAssertEqual(comment.status, "approve")
            XCTAssertEqual(comment.type, "comment")
            XCTAssertEqual(comment.isLiked, false)
            XCTAssertEqual(comment.likeCount, NSNumber(value: 0))
            XCTAssertEqual(comment.canModerate, true)
            XCTAssertEqual(comment.content, "I am comment content")
            XCTAssertEqual(comment.rawContent, "I am comment raw content")
            XCTAssertEqual(comments?.count, 1)
            expect.fulfill()
           }, failure: { _ in
            XCTFail("This callback shouldn't get called")
           })

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
