import Foundation

public struct UpdatePostRequest: Buildable, Request {
    let login: Login
    let methodName: String = "metaWeblog.editPost"

    let postID: Int
    let postData: Dictionary<String, String>

    public init(login: Login, postId: Int, postData: Dictionary<String, String>) {
        self.login = login
        self.postID = postId
        self.postData = postData
    }

    public func build() -> String {
        RequestBuilder()
            .set(methodCall: methodName)
            .addLoginDetails(login)
            .add(value: .int(self.postID))
            .add(value: .struct(postData))
            .build()
    }
}

extension Dictionary<String, String>: ConvertableToStruct {
    func toStruct() -> Struct {
        Struct.empty.add(members: self.map {
            Struct.Member(name: $0.key, value: .string($0.value))
        })
    }
}
