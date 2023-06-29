import Foundation

struct GetUserRequest {
    let login: Login
    let methodName: String = "wp.getUser"

    private let userId: Int

    public init(login: Login, userId: Int) {
        self.login = login
        self.userId = userId
    }

    public func build() -> String {
        RequestBuilder()
            .set(methodCall: methodName)
            .addLoginDetails(login)
            .add(value: .int(userId))
            .build()
    }
}
