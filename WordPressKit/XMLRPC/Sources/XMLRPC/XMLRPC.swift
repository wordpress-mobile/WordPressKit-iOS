import Foundation

public struct Client {

    private let endpoint: URL

    public init(endpoint: URL) {
        self.endpoint = endpoint
    }

    public init(scheme: String = "https", domain: String) {
        var components = URLComponents()
        components.scheme = scheme
        components.host = domain
        components.path = "xmlrpc.php"

        self.endpoint = components.url!
    }

    @available(iOS 13.0, *)
    public func perform(request buildable: Buildable) async throws -> Data {
        var request = URLRequest(url: self.endpoint)
        request.httpMethod = "post"
        request.httpBody = buildable.build().data(using: .utf8)

        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, urlResponse, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if let data {
                    continuation.resume(returning: data)
                    return
                }

                preconditionFailure("Something went wrong...")
            }.resume()
        }
    }
}
