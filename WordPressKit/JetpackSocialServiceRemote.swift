/// Encapsulates remote service logic related to Jetpack Social.
public class JetpackSocialServiceRemote: ServiceRemoteWordPressComREST {

    /// Retrieves the Publicize information for the given site.
    ///
    /// Note: Sites with disabled share limits will return success with nil value.
    ///
    /// - Parameters:
    ///   - siteID: The target site's dotcom ID.
    ///   - completion: Closure to be called once the request completes.
    public func fetchPublicizeInfo(for siteID: Int,
                                   completion: @escaping (Result<RemotePublicizeInfo?, Error>) -> Void) {
        let path = path(forEndpoint: "sites/\(siteID)/jetpack-social", withVersion: ._2_0)
        wordPressComRestApi.GET(path, parameters: nil) { result, response in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject)
                    let info = try? JSONDecoder.apiDecoder.decode(RemotePublicizeInfo.self, from: data)
                    completion(.success(info))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
