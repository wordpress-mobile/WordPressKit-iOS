import Foundation

public struct GetPostRequest: Buildable, Request {
    let login: Login
    let methodName: String = "wp.getPost"

    private let postId: Int
    private let fields: [PostField]

    public init(login: Login, postId: Int, fields: [PostField] = PostField.allCases) {
        self.login = login
        self.postId = postId
        self.fields = fields
    }

    public func build() -> String {
        RequestBuilder()
            .set(methodCall: methodName)
            .addLoginDetails(login)
            .add(value: .int(postId))
            .build()
    }
}
