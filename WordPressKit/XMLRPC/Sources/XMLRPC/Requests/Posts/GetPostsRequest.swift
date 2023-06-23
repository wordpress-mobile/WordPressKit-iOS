import Foundation

public struct GetPostsRequest: Buildable, Request {
    let login: Login
    let methodName: String = "wp.getPosts"

    private let postQuery: PostQuery

    public init(login: Login, postQuery: PostQuery = .empty) {
        self.login = login
        self.postQuery = postQuery
    }

    public func build() -> String {
        RequestBuilder()
            .set(methodCall: methodName)
            .addLoginDetails(login)
            .add(value: .struct(postQuery))
            .build()
    }
}
