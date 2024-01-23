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
    private var bodyBuilder: ((inout URLRequest) throws -> Void)?
    private(set) var multipartForm: [MultipartFormField]?

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

    func query(name: String, value: String?, override: Bool = false) -> Self {
        append(query: [URLQueryItem(name: name, value: value)], override: override)
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
            let content = form.map {
                    "\(HTTPRequestBuilder.urlEncode($0))=\(HTTPRequestBuilder.urlEncode($1))"
                }
                .joined(separator: "&")
            req.httpBody = content.data(using: .utf8)
        }
        return self
    }

    func body(form: [MultipartFormField]) -> Self {
        // Unlike other similar functions, multipart form encoding is handled by the `build` function.
        multipartForm = form
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

    func build(encodeMultipartForm: Bool = false) throws -> URLRequest {
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        if encodeMultipartForm {
            let encoded = try self.encodeMultipartForm(request: &request, forceWriteToFile: false)
            switch encoded {
            case let .left(data):
                request.httpBody = data
            case let .right(url):
                request.httpBodyStream = InputStream(url: url)
            }
        }

        if let bodyBuilder {
            assert(method.allowsHTTPBody, "Can't include body in HTTP \(method.rawValue) requests")
            try bodyBuilder(&request)
        }

        return request
    }

    func encodeMultipartForm(request: inout URLRequest, forceWriteToFile: Bool) throws -> Either<Data, URL> {
        guard let multipartForm, !multipartForm.isEmpty else {
            return .left(Data())
        }

        let boundery = String(format: "wordpresskit.%08x", Int.random(in: Int.min..<Int.max))
        request.setValue("multipart/form-data; boundary=\(boundery)", forHTTPHeaderField: "Content-Type")
        return try multipartForm
            .multipartFormDataStream(boundary: boundery, forceWriteToFile: forceWriteToFile)

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
