import XCTest
import XMLRPC

final class RequestTests: XCTestCase {

    private let login = Login(blogID: 1, username: "WP_USER", password: "WP_PASSWORD")

    func testThatDeletePostIsFormattedCorrectly() throws {
        try Assert(DeletePostRequest(login: login, postID: 20), matches: "delete-post")
    }

    func testThatGetPostTypeIsFormattedCorrectly() throws {
        try Assert(GetPostTypeRequest(login: login, postType: "post"), matches: "get-post-type")
    }

    func testThatGetPostTypesIsFormattedCorrectly() throws {
        try Assert(GetPostTypesRequest(login: login), matches: "get-post-types")
    }

    func testThatGetPostIsFormattedCorrectly() throws {
        try Assert(GetPostRequest(login: login, postId: 1), matches: "get-post")
    }

    func testThatGetPostsWithCountIsFormattedCorrectly() throws {
        try Assert(GetPostsRequest(login: login, postQuery: .with(count: 14)), matches: "get-posts-with-count")
    }

    func testThatGetPostsWithPostTypePostIsFormattedCorrectly() throws {
        let request = GetPostsRequest(login: login, postQuery: .with(postType: "post"))
        try Assert(request, matches: "get-posts-with-post-type")
    }

    func testThatGetPostsWithPostTypePageIsFormattedCorrectly() throws {
        let request = GetPostsRequest(login: login, postQuery: .with(postType: "page"))
        try Assert(request, matches: "get-posts-with-page-type")
    }

    func testThatDefaultLookupPostsIsFormattedCorrectly() throws {
        try Assert(GetPostsRequest(login: login), matches: "get-posts")
    }

    private func Assert(
        _ request: Buildable,
        matches requestName: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let sampleRequest = try sampleRequest(named: requestName)
        XCTAssertEqual(request.build(), sampleRequest, file: file, line: line)
    }

    private func sampleRequest(named name: String) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: "xml") else {
            preconditionFailure("\(name).xml not found – did you remember to add it to the package manifest?")
        }

        return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
