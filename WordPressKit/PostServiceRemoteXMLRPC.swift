import Foundation
import XMLRPC

extension PostServiceRemoteXMLRPC {

    typealias SinglePostSuccess = (RemotePost) -> Void
    typealias Failure = (Error) -> Void

    enum Errors: Error {
        case postNotFoundOnRemote
    }


    func updatePost(_ post: RemotePost, success: @escaping SinglePostSuccess, failure: @escaping Failure) throws {
        assert(post.postID.intValue > 0)

        if post.postID.intValue <= 0 {
            failure(Errors.postNotFoundOnRemote)
            return
        }

        let login = Login(blogID: 1, username: self.username, password: self.password)
        let request = UpdatePostRequest(login: login, postId: post.postID.intValue, postData: [:])

        Task {
            do {
                let response = try await XMLRPC.Client(endpoint: api.endpoint).perform(request: request)
                let post = try PostResponseProcessor().process(response).map { RemotePost(siteID: post.siteID, status: $0.status, title: $0.title, content: $0.content)}.first
                success(post!!)
            } catch {
                failure(error)
            }
        }
    }
}
