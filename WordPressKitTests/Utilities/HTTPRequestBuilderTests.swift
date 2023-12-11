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
            .path("hello/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org")!)
            .path("/hello/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org/hello")!)
            .path("world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/hello/world")

        request = try HTTPRequestBuilder(url: URL(string: "https://wordpress.org/hello")!)
            .path("/world")
            .build()
        XCTAssertEqual(request.url?.absoluteString, "https://wordpress.org/world")
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

}

private extension URLRequest {
    var httpBodyText: String? {
        guard let data = httpBody else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
