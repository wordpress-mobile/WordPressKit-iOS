import Foundation
import XCTest

@testable import WordPressKit

class HTTPRequestBuilderTests: XCTestCase {

    func testURL() throws {
        try XCTAssertEqual(HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!).build().url?.absoluteString, "https://wordpress.org")
        try XCTAssertEqual(HTTPRequestBuilder(url: URL(string: "https://wordpress.com")!).build().url?.absoluteString, "https://wordpress.com")
    }

    func testHTTPMethods() throws {
        try XCTAssertEqual(HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!).build().httpMethod, "GET")
        XCTAssertFalse(HTTPRequestBuilder.Method.get.allowsHTTPBody)

        try XCTAssertEqual(HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!).method(.delete).build().httpMethod, "DELETE")
        XCTAssertFalse(HTTPRequestBuilder.Method.delete.allowsHTTPBody)

        try XCTAssertEqual(HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!).method(.post).build().httpMethod, "POST")
        XCTAssertTrue(HTTPRequestBuilder.Method.post.allowsHTTPBody)

        try XCTAssertEqual(HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!).method(.patch).build().httpMethod, "PATCH")
        XCTAssertTrue(HTTPRequestBuilder.Method.patch.allowsHTTPBody)

        try XCTAssertEqual(HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!).method(.put).build().httpMethod, "PUT")
        XCTAssertTrue(HTTPRequestBuilder.Method.put.allowsHTTPBody)
    }

    func testHeader() throws {
        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .header(name: "X-Header-1", value: "Foo")
            .header(name: "X-Header-2", value: "Bar")
            .build()
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Header-1"), "Foo")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Header-2"), "Bar")
    }

    func testPath() throws {
        var request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .append(path: "hello/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .append(path: "/hello/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org/hello")!)
            .append(path: "world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org/hello")!)
            .append(path: "/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")
    }

    func testJSONBody() throws {
        var request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .method(.post)
            .body(json: 42)
            .build()
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("application/json") == true)
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), "42")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .method(.post)
            .body(json: ["foo": "bar"])
            .build()
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), #"{"foo":"bar"}"#)
    }

    func testJSONBodyWithEncodable() throws {
        struct Body: Encodable {
            var foo: String
        }
        let body = Body(foo: "bar")

        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .method(.post)
            .body(json: body)
            .build()
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("application/json") == true)
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), #"{"foo":"bar"}"#)
    }

    func testFormBody() throws {
        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .method(.post)
            .body(form: ["name": "Foo Bar"])
            .build()
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("application/x-www-form-urlencoded") == true)
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), #"name=Foo%20Bar"#)
    }

    func testFormWithSpecialCharacters() throws {
        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .method(.post)
            .body(form: ["text": ":#[]@!$&'()*+,;="])
            .build()
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), "text=%3A%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D")
    }

    func testFormWithRandomSpecialCharacters() throws {
        let asciis = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
        let unicodes = "表情符号😇🤔✅😎"
        let randomText: () -> String = {
            let chars = (1...10).map { _ in (asciis + unicodes).randomElement()! }
            return String(chars)
        }
        // Generate a form (key-value pairs) with random characters.
        let form = [
            randomText(): randomText(),
            randomText(): randomText(),
            randomText(): randomText(),
        ]

        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .method(.post)
            .body(form: form)
            .build()
        let encoded = try XCTUnwrap(request.httpBodyText)

        // Decoding the url-encoded form, whose format should be "<key>=<value>&<key>=<value>&...".
        let keyValuePairs = try encoded.split(separator: "&").map { pair in
            XCTAssertEqual(pair.firstIndex(of: "="), pair.lastIndex(of: "="), "There should be only one '=' in a key-value pair")

            let firstIndex = try XCTUnwrap(pair.firstIndex(of: "="))
            let key = pair[pair.startIndex..<firstIndex]
            let value = pair[pair.index(firstIndex, offsetBy: 1)..<pair.endIndex]

            return try (
                XCTUnwrap(String(key).removingPercentEncoding),
                XCTUnwrap(String(value).removingPercentEncoding)
            )
        }

        // The decoded form should be the same the original form.
        let decodedForm: [String: String] = Dictionary(uniqueKeysWithValues: keyValuePairs)
        XCTAssertEqual(form, decodedForm)
    }

}

private extension URLRequest {
    var httpBodyText: String? {
        guard let data = httpBody else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
