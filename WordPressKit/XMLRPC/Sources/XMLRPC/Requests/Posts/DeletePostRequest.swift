import Foundation

public struct DeletePostRequest: Buildable, Request {
    let login: Login
    let methodName: String = "wp.deletePost"

    let postID: Int

    public init(login: Login, postID: Int) {
        self.login = login
        self.postID = postID
    }

    public func build() -> String {
        RequestBuilder()
            .addLoginDetails(login)
            .set(methodCall: methodName)
            .add(value: .int(postID))
            .build()
    }
}
