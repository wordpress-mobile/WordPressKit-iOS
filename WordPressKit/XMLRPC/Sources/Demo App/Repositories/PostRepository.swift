import SwiftUI
import XMLRPC

class PostRepository: ObservableObject {
    @Published
    var posts: [WPPost] = []

    @Published
    var isFetchingPosts: Bool = false

    @Published
    var error: Error?

    @EnvironmentObject
    var login: LoginRepository

    func fetchPosts(for login: Login) throws {
        self.isFetchingPosts = true
        try self.restoreCache()

        Task {
            do {
                let request = GetPostsRequest(login: login, postQuery: .with(count: 999))
                let result = try await XMLRPC.Client(endpoint: URL(string: "http://localhost/xmlrpc.php")!).perform(request: request)

                let posts = try PostResponseProcessor().process(result)
                try cache(posts: posts)
                self.posts = posts
            } catch {
                self.error = error
            }
        }
    }

    private let postsCache = URL.cachesDirectory
        .appendingPathComponent(Bundle.main.bundleIdentifier!)
        .appending(path: "posts")

    func cache(posts: [WPPost]) throws {
        try PropertyListEncoder().encode(posts).write(to: postsCache)
    }

    func restoreCache() throws {
        guard FileManager.default.fileExists(atPath: postsCache.path) else {
            return
        }

        self.posts = try PropertyListDecoder().decode([WPPost].self, from: Data(contentsOf: postsCache))
    }
}
