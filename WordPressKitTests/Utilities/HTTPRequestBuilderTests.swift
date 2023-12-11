import Foundation
import XCTest

@testable import WordPressKit

class HTTPRequestBuilderTests: XCTestCase {

    func testDefaultMethod() throws {
        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!).build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org")
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testHeader() throws {
        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .set(value: "Foo", forHeader: "X-Header-1")
            .set(value: "Bar", forHeader: "X-Header-2")
            .build()
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Header-1"), "Foo")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Header-2"), "Bar")
    }

    func testPath() throws {
        var request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .set(path: "hello/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .set(path: "/hello/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org/hello")!)
            .set(path: "world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org/hello")!)
            .set(path: "/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/world")
    }

    func testJSONBody() throws {
        var request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .set(method: .post)
            .body(json: 42)
            .build()
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("application/json") == true)
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), "42")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .set(method: .post)
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
            .set(method: .post)
            .body(json: body)
            .build()
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("application/json") == true)
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), #"{"foo":"bar"}"#)
    }

    func testFormBody() throws {
        let request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .set(method: .post)
            .body(form: ["name": "Foo Bar"])
            .build()
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("application/x-www-form-urlencoded") == true)
        try XCTAssertEqual(XCTUnwrap(request.httpBodyText), #"name=Foo%20Bar"#)
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
