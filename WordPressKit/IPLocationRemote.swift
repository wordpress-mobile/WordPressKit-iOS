import Foundation

/// Remote type to fetch the user's IP Location using the public `geo` API.
///
public final class IPLocationRemote: ServiceRemoteWordPressComREST {

    /// Fetches the country code from the device ip.
    ///
    public func fetchIPCountryCode(completion: @escaping (Result<String, Error>) -> Void) {
        let path = path(forEndpoint: wordPressComRestApi.baseURLString + "geo/", withVersion: ._2_0)

        wordPressComRestApi.GET(path, parameters: nil) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: [])
                    let decoder = JSONDecoder.apiDecoder
                    // our API decoder assumes that we're converting from snake case.
                    // revert it to default so the CodingKeys match the actual response keys.
                    let response = try decoder.decode(RemoteIPCountryCode.self, from: data)
                    completion(.success(response.countryCode))
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

public struct RemoteIPCountryCode: Decodable {
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_short"
    }

    let countryCode: String
}
