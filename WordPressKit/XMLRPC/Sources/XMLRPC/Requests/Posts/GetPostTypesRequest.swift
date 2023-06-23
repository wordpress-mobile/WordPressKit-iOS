import Foundation

public struct GetPostTypesRequest: Buildable, Request {
    let login: Login
    let methodName: String = "wp.getPostTypes"

    public init(login: Login) {
        self.login = login
    }

    public func build() -> String {
        RequestBuilder()
            .set(methodCall: methodName)
            .addLoginDetails(login)
            .build()
    }
}
