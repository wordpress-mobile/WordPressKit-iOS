import Foundation
import XCTest

@testable import WordPressKit


final class CommentServiceRemoteRESTLikesTests: RemoteTestCase, RESTTestable {
    private let fetchCommentLikesSuccessFilename = "comment-likes-success.json"
    private let fetchCommentLikesFailureFilename = "post-likes-failure.json"
    private let siteId = 0
    private let commentId = 1
    private var remote: CommentServiceRemoteREST!
    private var commentLikesEndpoint: String {
        return "sites/\(siteId)/comments/\(commentId)/likes"
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
    
    func testThatFetchCommentLikesWorks() {
        let expect = expectation(description: "Fetching comment likes should succeed")
        
        stubRemoteResponse(commentLikesEndpoint, filename: fetchCommentLikesSuccessFilename, contentType: .ApplicationJSON)
        remote.getLikesForCommentID(NSNumber(value: commentId), success: { users in
            guard let user = users?.first else {
                XCTFail("Failed to retrieve mock comment likes")
                return
            }
            
            XCTAssertEqual(user.userID, NSNumber(value: 54321))
            XCTAssertEqual(user.username, "johnwick")
            XCTAssertEqual(user.displayName, "John Wick")
            XCTAssertEqual(user.primaryBlogID, NSNumber(value: 124625450))
            XCTAssertEqual(user.avatarURL, "avatar URL")
            expect.fulfill()
            
        }, failure: { _ in
            XCTFail("This callback shouldn't get called")
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testFailureBlockCalledWhenFetchingFails() {
        let expect = expectation(description: "Failure block should be called when fetching post likes fails")
        
        stubRemoteResponse(commentLikesEndpoint, filename: fetchCommentLikesFailureFilename, contentType: .ApplicationJSON, status: 403)
        remote.getLikesForCommentID(NSNumber(value: commentId), success: { _ in
        XCTFail("This callback shouldn't get called")
        }, failure: { error in
            XCTAssertNotNil(error)
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
