import Foundation

/// Remote type to fetch the user's IP Location using the public `geo` API.
///
public final class IPLocationRemote: ServiceRemoteWordPressComREST {

    /// Fetches the country code from the device ip.
    ///
    public func fetchIPCountryCode(onCompletion: @escaping (Result<String, Error>) -> Void) {
        let path = path(forEndpoint: wordPressComRestApi.baseURLString + "geo/", withVersion: ._2_0)

        wordPressComRestApi.GET(path, parameters: nil) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: [])
                    let decoder = JSONDecoder.apiDecoder
                    // our API decoder assumes that we're converting from snake case.
                    // revert it to default so the CodingKeys match the actual response keys.
                    let response = try decoder.decode(String.self, from: data)
                    completion(.success(response.values.first ?? []))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

/// `IPLocationRemote` known errors
///
public extension IPLocationRemote {
    enum IPLocationError: Error {
        case malformedURL
    }
}

/// Private mapper used to extract the country code from the `IPLocationRemote` response.
///
private struct IPCountryCodeMapper: Mapper {

    /// Response envelope
    ///
    struct Response: Decodable {
        enum CodingKeys: String, CodingKey {
            case countryCode = "country_short"
        }

        let countryCode: String
    }

    func map(response: Data) throws -> String {
        try JSONDecoder().decode(Response.self, from: response).countryCode
    }
}
