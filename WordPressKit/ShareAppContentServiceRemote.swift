/// Encapsulates logic for fetching content to be shared by the user.
///
open class ShareAppContentServiceRemote: ServiceRemoteWordPressComREST {
    /// Fetch content to be shared by the user, based on the provided `appName`.
    ///
    /// - Parameters:
    ///   - appName: A string that identifies the app to be shared.
    ///   - completion: A closure that will be called when the fetch request completes.
    open func getContent(for appName: ShareAppName, completion: @escaping (Result<RemoteShareAppContent, Error>) -> Void) {
        let endpoint = "mobile/share-app-link"
        let requestURLString = path(forEndpoint: endpoint, withVersion: ._2_0)
        let params: [String: AnyObject] = [Constants.appNameParameterKey: appName.rawValue as AnyObject]

        wordPressComRestApi.GET(requestURLString, parameters: params) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: [])
                    let content = try JSONDecoder.apiDecoder.decode(RemoteShareAppContent.self, from: data)
                    completion(.success(content))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public enum ShareAppName: String {
    case wordpress
    case jetpack
}

// MARK: - Private Helpers

private extension ShareAppContentServiceRemote {
    struct Constants {
        static let appNameParameterKey = "app"
    }
}
