import Foundation

public struct Login {
    let blogID: Int

    let username: String
    let password: String

    public init(blogID: Int, username: String, password: String) {
        self.blogID = blogID

        self.username = username
        self.password = password
    }
}
