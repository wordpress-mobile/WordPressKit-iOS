public extension CommentServiceRemoteREST {

    enum RequestKeys: String {
        case parent
        case author
    }

    /// Retrieves a list of comment replies for the specified comment.
    /// - Parameters:
    ///   - commentID:  The parent comment ID.
    ///   - siteID:     The ID of the site that contains the specified comment.
    ///   - parameters: Contains additional request parameters.
    ///   - success:    A closure that will be called when the request succeeds.
    ///   - failure:    A closure that will be called when the request fails.
    func getReplies(for commentID: Int,
                    siteID: Int,
                    parameters: [RequestKeys: AnyObject],
                    success: @escaping ([RemoteCommentV2]) -> Void,
                    failure: @escaping (Error) -> Void) {
        let path = coreV2Path(for: "sites/\(siteID)/comments")
        let requestParameters = [RequestKeys.parent: commentID as AnyObject]
            .merging(parameters) { oldValue, newValue in oldValue }
            .reduce([String: AnyObject]()) { result, pair in
                var result = result
                result[pair.key.rawValue] = pair.value
                return result
            }

        wordPressComRestApi.GET(path, parameters: requestParameters) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: [])
                    let comments = try JSONDecoder().decode([RemoteCommentV2].self, from: data)
                    success(comments)
                } catch {
                    failure(error)
                }

            case .failure(let error):
                failure(error)
            }
        }
    }

}

// MARK: - Private Helpers

private extension CommentServiceRemoteREST {
    struct Constants {
        static let coreV2String = "wp/v2"
    }

    func coreV2Path(for endpoint: String) -> String {
        return "\(Constants.coreV2String)/\(endpoint)"
    }
}
