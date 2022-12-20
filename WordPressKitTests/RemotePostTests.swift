import XCTest
import WordPressKit

class RemotePostTests: RemoteTestCase, RESTTestable {

    private var remote: PostServiceRemoteREST!

    override func setUp() {
        remote = PostServiceRemoteREST(wordPressComRestApi: getRestApi(), siteID: 123)
    }

    func testEditPost() {
        stubRemoteResponse("sites/123/posts/9", filename: "post-edit-success.json", contentType: .ApplicationJSON)
        let apiResponseRecived = expectation(description: "Receive API response")
        let post = RemotePost(siteID: 123, status: RemotePost.statusPublish, title: "Draft", content: "Edited")
        post.postID = 9
        remote.update(post) { post in
            XCTAssertNotNil(post)
            XCTAssertEqual(post?.revisions, [61, 60, 57])
            XCTAssertEqual(post?.categories?.first?.name, "Uncategorized")
            XCTAssertEqual(post?.tags, ["random-tag"])
            apiResponseRecived.fulfill()
        } failure: { error in
            apiResponseRecived.fulfill()
            XCTFail("error: \(String(describing: error))")
        }
        wait(for: [apiResponseRecived], timeout: 1)
    }
    
}
