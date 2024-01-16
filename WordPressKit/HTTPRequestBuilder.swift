import Foundation

final class HTTPRequestBuilder {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"

        var allowsHTTPBody: Bool {
            self == .post || self == .put || self == .patch
        }
    }

    private var urlComponents: URLComponents
    private var method: Method = .get
    private var headers: [String: String] = [:]
    private var defaultQuery: [URLQueryItem] = []
    private var bodyBuilder: ((inout URLRequest) throws -> Void)?

    init(url: URL) {
        assert(url.scheme == "http" || url.scheme == "https")
        assert(url.host != nil)

        urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    }

    func method(_ method: Method) -> Self {
        self.method = method
        return self
    }

    func append(path: String) -> Self {
        assert(!path.contains("?") && !path.contains("#"), "Path should not have query or fragment: \(path)")

        var relPath = path
        if relPath.hasPrefix("/") {
            _ = relPath.removeFirst()
        }

        if urlComponents.path.hasSuffix("/") {
            urlComponents.path = urlComponents.path.appending(relPath)
        } else {
            urlComponents.path = urlComponents.path.appending("/").appending(relPath)
        }

        return self
    }

    func header(name: String, value: String?) -> Self {
        headers[name] = value
        return self
    }

    func query(defaults: [URLQueryItem]) -> Self {
        defaultQuery = defaults
        return self
    }

    func query(name: String, value: String?, override: Bool = false) -> Self {
        append(query: [URLQueryItem(name: name, value: value)], override: override)
    }

    func query(_ dict: [String: Any]) -> Self {
        dict.reduce(self) {
            $0.query(name: $1.key, value: $1.value)
        }
    }

    func query(name: String, value: Any) -> Self {
        switch value {
        case let array as [Any]:
            return array.reduce(self) {
                $0.query(name: "\(name)[]", value: $1)
            }
        case let object as [String: Any]:
            return object.reduce(self) {
                $0.query(name: "\(name)[\($1.key)]", value: $1.value)
            }
        case let value as Bool:
            return query(name: name, value: value ? "1" : "0", override: false)
        default:
            return query(name: name, value: "\(value)", override: false)
        }
    }

    func append(query: [URLQueryItem], override: Bool = false) -> Self {
        var allQuery = urlComponents.queryItems ?? []

        if override {
            let newKeys = Set(query.map { $0.name })
            allQuery.removeAll(where: { newKeys.contains($0.name) })
        }

        allQuery.append(contentsOf: query)

        urlComponents.queryItems = allQuery

        return self
    }

    func body(form: [String: String]) -> Self {
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        bodyBuilder = { req in
            let content = form
                .map {
                    "\(HTTPRequestBuilder.urlEncode($0))=\(HTTPRequestBuilder.urlEncode($1))"
                }
                .joined(separator: "&")
            req.httpBody = content.data(using: .utf8)
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

    func body(xml: @escaping () throws -> Data) -> Self {
        headers["Content-Type"] = "application/xml; charset=utf-8"
        bodyBuilder = { req in
            req.httpBody = try xml()
        }
        return self
    }

    func build() throws -> URLRequest {
        var allQuery = urlComponents.queryItems ?? []
        if !defaultQuery.isEmpty {
            let allQueryKeys = allQuery.reduce(into: Set()) { $0.insert($1.name) }
            let toBeAdded = defaultQuery.filter { !allQueryKeys.contains($0.name) }
            allQuery.append(contentsOf: toBeAdded)
        }

        var components = urlComponents
        components.queryItems = allQuery.isEmpty ? nil : allQuery

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        if let bodyBuilder {
            assert(method.allowsHTTPBody, "Can't include body in HTTP \(method.rawValue) requests")
            try bodyBuilder(&request)
        }

        return request
    }
}

extension HTTPRequestBuilder {
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
}

private extension HTTPRequestBuilder {
    static func urlEncode(_ text: String) -> String {
        let specialCharacters = ":#[]@!$&'()*+,;="
        let allowed = CharacterSet.urlQueryAllowed.subtracting(.init(charactersIn: specialCharacters))
        return text.addingPercentEncoding(withAllowedCharacters: allowed) ?? text
    }
}
