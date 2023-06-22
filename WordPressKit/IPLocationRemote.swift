import Foundation

/// Remote type to fetch the user's IP Location using the public `geo` API.
///
public final class IPLocationRemote: ServiceRemoteWordPressComREST {

    /// Fetches the country code from the device ip.
    ///
    public func fetchIPCountryCode(completion: @escaping (Result<String, Error>) -> Void) {

        let path = WordPressComOAuthClient.WordPressComOAuthDefaultApiBaseUrl + "/geo/"
        guard let url = URL(string: path) else {
            return completion(.failure(IPLocationError.malformedURL))
        }

        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, _,error in
            if let data = data {
                /// do exception handler so that our app does not crash
                do {
                    let decoder = JSONDecoder.apiDecoder
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    let result = try decoder.decode(RemoteIPCountryCode.self, from: data)
                    completion(.success(result.countryCode))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        task.resume()
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
