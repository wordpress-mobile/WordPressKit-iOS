import Foundation

final class HTTPRequestBuilder {
    private var urlComponents: URLComponents
    private var method: String = "GET"
    private var path: String? = nil
    private var headers: [String: String] = [:]
    private var bodyBuilder: ((inout URLRequest) throws -> Void)?

    init(url: URL) {
        assert(url.scheme == "http" || url.scheme == "https")
        assert(url.host != nil)

        urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    }

    func set(method: String) -> Self {
        self.method = method.uppercased()
        return self
    }

    func set(path: String) -> Self {
        assert(!path.contains("?") && !path.contains("#"), "Path should not have query or fragment: \(path)")

        assert(self.path == nil, "\(#function) can only be called once")
        self.path = path
        return self
    }

    func set(value: String?, forHeader header: String) -> Self {
        headers[header] = value
        return self
    }

    func query(name: String, value: String?, override: Bool = false) -> Self {
        append(query: [URLQueryItem(name: name, value: value)], override: override)
    }

    func append(query: [URLQueryItem], override: Bool) -> Self {
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + query
        return self
    }

    func body(form: [String: String]) -> Self {
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        bodyBuilder = { req in
            var url = URLComponents(string: "https://wordpress.com")!
            url.queryItems = form.map { URLQueryItem(name: $0, value: $1) }
            req.httpBody = url.query?.data(using: .utf8)
        }
        return self
    }

    func body(json: Encodable, jsonEncoder: JSONEncoder = JSONEncoder()) -> Self {
        body(json: {
            try jsonEncoder.encode(json)
        })
    }

    func body(json: Any) -> Self {
        body(json: {
            try JSONSerialization.data(withJSONObject: json)
        })
    }

    func body(json: @escaping () throws -> Data) -> Self {
        headers["Content-Type"] = "application/json; charset=utf-8"
        bodyBuilder = { req in
            req.httpBody = try json()
        }
        return self
    }

    // FIXME: Not implemented yet
    func body(xmlrpc: Any /* XMLRPCRequest */) -> Self {
        body(xml: {
            fatalError("To be implemented")
        })
    }

    // FIXME: Not implemented yet
    func appendXMLRPCArgument(value: Any) -> Self {
        fatalError("To be implemented")
    }

    func body(xml: @escaping () throws -> Data) -> Self {
        headers["Content-Type"] = "application/xml; charset=utf-8"
        bodyBuilder = { req in
            req.httpBody = try xml()
        }
        return self
    }

    func build() throws -> URLRequest {
        assert(path != nil, "Endpoint path is not set")

        if let path {
            if path.hasPrefix("/") {
                urlComponents.path = path
            } else {
                var newPath = urlComponents.path
                if !newPath.hasPrefix("/") {
                    newPath = "/" + newPath
                }

                if newPath.hasSuffix("/") {
                    newPath = newPath + path
                } else {
                    newPath = newPath + "/" + path
                }
                urlComponents.path = newPath
            }
        }

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        if let bodyBuilder {
            assert(["POST", "PUT", "PATCH"].contains(method), "Can't include body in HTTP \(method) requests")
            try bodyBuilder(&request)
        }

        return request
    }
}
