import Foundation

/// A builder type that appends HTTP request data to a URL.
///
/// Calling this class's url related functions (the ones that changes path, query, etc) does not modify the
/// original URL string. The URL will be perserved in the final result that's returned by the `build` function.
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

    private let original: URLComponents
    private(set) var method: Method = .get
    private var appendedPath: String = ""
    private var headers: [String: String] = [:]
    private var defaultQuery: [URLQueryItem] = []
    private var appendedQuery: [URLQueryItem] = []
    private var bodyBuilder: ((inout URLRequest) throws -> Void)?
    private(set) var multipartForm: [MultipartFormField]?

    init(url: URL) {
        assert(url.scheme == "http" || url.scheme == "https")
        assert(url.host != nil)

        original = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    }

    func method(_ method: Method) -> Self {
        self.method = method
        return self
    }

    /// Append path to the original URL.
    ///
    /// The argument will be appended to the original URL as it is.
    func append(percentEncodedPath path: String) -> Self {
        assert(!path.contains("?") && !path.contains("#"), "Path should not have query or fragment: \(path)")

        appendedPath = Self.join(appendedPath, path)

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

    func query(_ parameters: [String: Any]) -> Self {
        append(query: parameters.flatten(), override: false)
    }

    func append(query: [URLQueryItem], override: Bool = false) -> Self {
        if override {
            let newKeys = Set(query.map { $0.name })
            appendedQuery.removeAll(where: { newKeys.contains($0.name) })
        }

        appendedQuery.append(contentsOf: query)

        return self
    }

    func body(form: [String: Any]) -> Self {
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        bodyBuilder = { req in
            let content = form.flatten().percentEncoded
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
        // 'charset' parmaeter is not required for json body. See https://www.rfc-editor.org/rfc/rfc8259.html#section-11
        headers["Content-Type"] = "application/json"
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
        var components = original

        var newPath = Self.join(components.percentEncodedPath, appendedPath)
        if !newPath.isEmpty, !newPath.hasPrefix("/") {
            newPath = "/\(newPath)"
        }
        components.percentEncodedPath = newPath

        // Add default query items if they don't exist in `appendedQuery`.
        var newQuery = appendedQuery
        if !defaultQuery.isEmpty {
            let toBeAdded = defaultQuery.filter { item in
                !newQuery.contains(where: { $0.name == item.name})
            }
            newQuery.append(contentsOf: toBeAdded)
        }

        // Bypass `URLComponents`'s URL query encoding, use our own implementation instead.
        if !newQuery.isEmpty {
            components.percentEncodedQuery = Self.join(components.percentEncodedQuery ?? "", newQuery.percentEncoded, separator: "&")
        }

        guard let url = components.url else {
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

extension HTTPRequestBuilder {
    static func urlEncode(_ text: String) -> String {
        let specialCharacters = ":#[]@!$&'()*+,;="
        let allowed = CharacterSet.urlQueryAllowed.subtracting(.init(charactersIn: specialCharacters))
        return text.addingPercentEncoding(withAllowedCharacters: allowed) ?? text
    }

    /// Join a list of strings using a separator only if neighbour items aren't already separated with the given separator.
    static func join(_ aList: String..., separator: String = "/") -> String {
        guard !aList.isEmpty else { return "" }

        var list = aList
        let start = list.removeFirst()
        return list.reduce(into: start) { result, path in
            guard !path.isEmpty else { return }

            guard !result.isEmpty else {
                result = path
                return
            }

            switch (result.hasSuffix(separator), path.hasPrefix(separator)) {
            case (true, true):
                var prefixRemoved = path
                prefixRemoved.removePrefix(separator)
                result.append(prefixRemoved)
            case (true, false), (false, true):
                result.append(path)
            case (false, false):
                result.append("\(separator)\(path)")
            }
        }
    }
}

private extension Dictionary where Key == String, Value == Any {

    static func urlEncode(into result: inout [URLQueryItem], name: String, value: Any) {
        switch value {
        case let array as [Any]:
            for value in array {
                urlEncode(into: &result, name: "\(name)[]", value: value)
            }
        case let object as [String: Any]:
            for (key, value) in object {
                urlEncode(into: &result, name: "\(name)[\(key)]", value: value)
            }
        case let value as Bool:
            urlEncode(into: &result, name: name, value: value ? "1" : "0")
        default:
            result.append(URLQueryItem(name: name, value: "\(value)"))
        }
    }

    func flatten() -> [URLQueryItem] {
        sorted { $0.key < $1.key }
            .reduce(into: []) { result, entry in
                Self.urlEncode(into: &result, name: entry.key, value: entry.value)
            }
    }

}

extension Array where Element == URLQueryItem {

    var percentEncoded: String {
        map {
            let name = HTTPRequestBuilder.urlEncode($0.name)
            guard let value = $0.value else {
                return name
            }

            return "\(name)=\(HTTPRequestBuilder.urlEncode(value))"
        }
        .joined(separator: "&")
    }

}
