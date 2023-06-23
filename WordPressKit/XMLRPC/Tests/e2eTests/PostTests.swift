import XCTest
import XMLRPC

@available(iOS 15.0, macOS 12, *)
final class PostTests: XCTestCase {

    private let client = Client(endpoint: URL(string: "http://localhost/xmlrpc.php")!)

    private let login = Login(blogID: 1, username: "WP_USER", password: "WP_PASSWORD")

    @available(iOS 16.0, macOS 13, *)
    func lookupPost() async throws {
        let response = try await client.perform(request: GetPostRequest(login: login, postId: 1153))
        try response.write(to: URL(filePath: "/Users/jkmassel/Downloads/get-post-response.xml"))
    }
}
