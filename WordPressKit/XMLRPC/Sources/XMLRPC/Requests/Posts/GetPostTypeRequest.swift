import Foundation

public struct GetPostTypeRequest: Buildable, Request {
    let login: Login
    let methodName: String = "wp.getPostType"

    private let postType: String

    public init(login: Login, postType: String) {
        self.login = login
        self.postType = postType
    }

    public func build() -> String {
        RequestBuilder()
            .set(methodCall: methodName)
            .addLoginDetails(login)
            .add(value: .string(postType))
            .build()
    }
}
