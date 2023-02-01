/// The Jetpack Proxy.
/// TODO: Documentation
public class JetpackProxyServiceRemote: ServiceRemoteWordPressComREST {

    public enum DotComMethod: String {
        case get
        case post
        case put
        case delete
    }

    enum ParameterKey: String {
        case json
        case path
        case body
        case query
        case locale
    }

    /// The old-fashioned way.
    /// TODO: Documentation.
    ///
    public func proxyRequest(for siteID: Int,
                             path: String,
                             method: DotComMethod,
                             parameters: [String: AnyHashable]? = nil,
                             locale: String? = nil,
                             completion: @escaping (Result<AnyObject, Error>) -> Void) -> Progress? {
        let urlString = self.path(forEndpoint: "jetpack-blogs/\(siteID)/rest-api", withVersion: ._1_1)

        // construct the request parameters to be forwarded to the actual endpoint.
        var requestParams: [String: AnyHashable] = [
            ParameterKey.json.rawValue: "true",
            ParameterKey.path.rawValue: "\(path)&_method=\(method.rawValue)"
        ]

        let bodyParameterKey: ParameterKey = (method == .get ? .query : .body)

        // the parameters need to be encoded into a JSON string.
        if let parameters,
           !parameters.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: parameters, options: []),
           let jsonString = String(data: data, encoding: .utf8) {
            requestParams[bodyParameterKey.rawValue] = jsonString
        }

        if let locale {
            requestParams[ParameterKey.locale.rawValue] = locale
        }

        return wordPressComRestApi.POST(urlString, parameters: requestParams as [String: AnyObject]) { response, _ in
            completion(.success(response))
        } failure: { error, _ in
            completion(.failure(error))
        }
    }
}
