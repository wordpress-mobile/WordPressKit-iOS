import XCTest
import wpxmlrpc

@testable import WordPressKit

class CommentServiceRemoteXMLRPCTests: RemoteTestCase, XMLRPCTestable {
    private var remote: Any?
    private let getSiteCommentsSuccessMockFilename = "xmlrpc-site-comments-success.xml"

    override func setUp() {
        super.setUp()
        remote = CommentServiceRemoteXMLRPC(api: getXmlRpcApi(),
                                            username: XMLRPCTestableConstants.xmlRpcUserName,
                                            password: XMLRPCTestableConstants.xmlRpcPassword)
    }

    override func tearDown() {
        super.tearDown()
        remote = nil
    }

    // MARK: - Tests

    func testGetCommentsSucceeds() {
        let expect = expectation(description: "Fetching site comments should succeed")

        stubRemoteResponse(XMLRPCTestableConstants.xmlRpcUrl,
                           filename: getSiteCommentsSuccessMockFilename,
                           contentType: .XML)

        if let remoteInstance = remote as? CommentServiceRemote {
            remoteInstance.getCommentsWithMaximumCount(1,
                                                       success: { comments, totalComments in

                guard let comment = comments?.first as? RemoteComment else {
                    XCTFail("Failed to retrieve mock site comment")
                    return
                }

                XCTAssertEqual(comment.author, "Comment Author")
                XCTAssertEqual(comment.authorEmail, "author@email.com")
                XCTAssertEqual(comment.authorUrl, "author URL")
                XCTAssertEqual(comment.authorIP, "000.0.00.000")
                XCTAssertEqual(comment.link, "comment URL")
                XCTAssertEqual(comment.parentID, NSNumber(value: 1))
                XCTAssertEqual(comment.postID, NSNumber(value: 2))
                XCTAssertEqual(comment.postTitle, "Post title")
                XCTAssertEqual(comment.status, "approve")
                XCTAssertEqual(comment.type, "comment")
                XCTAssertEqual(comment.content, "I am comment content")
                XCTAssertEqual(comment.rawContent, nil)
                XCTAssertEqual(comments?.count, 1)
                expect.fulfill()
               }, failure: { _ in
                XCTFail("This callback shouldn't get called")
               })

            waitForExpectations(timeout: timeout, handler: nil)
        }
    }

}
