import Foundation

public struct GetProfileRequest: Buildable {
    let login: Login
    let methodName: String = "wp.getProfile"

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
