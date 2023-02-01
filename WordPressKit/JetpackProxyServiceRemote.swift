/// The Jetpack Proxy.
/// TODO: Documentation
public class JetpackProxyServiceRemote: ServiceRemoteWordPressComREST {

    public enum DotComMethod: String {
        case get
        case post
        case put
        case delete
    }

    /// The old-fashioned way.
    /// TODO: Docs.
    ///
    public func proxyRequest(for siteID: Int,
                             path: String,
                             method: DotComMethod,
                             parameters: [String: AnyHashable] = [:],
                             locale: String? = nil,
                             completion: @escaping (Result<AnyObject, Error>) -> Void) -> Progress? {
        let urlString = self.path(forEndpoint: "jetpack-blogs/\(siteID)/rest-api", withVersion: ._1_1)

        // Construct the request parameters to be forwarded to the actual endpoint.
        var requestParams: [String: AnyHashable] = [
            "json": "true",
            "path": "\(path)&_method=\(method.rawValue)"
        ]

        // The parameters need to be encoded into a JSON string.
        if !parameters.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: parameters, options: []),
           let jsonString = String(data: data, encoding: .utf8) {
            // Use "query" for the body parameters if the method is GET. Otherwise, always use "body".
            let bodyParameterKey = (method == .get ? "query" : "body")
            requestParams[bodyParameterKey] = jsonString
        }

        if let locale {
            requestParams["locale"] = locale
        }

        return wordPressComRestApi.POST(urlString, parameters: requestParams as [String: AnyObject]) { response, _ in
            completion(.success(response))
        } failure: { error, _ in
            completion(.failure(error))
        }
    }
}
