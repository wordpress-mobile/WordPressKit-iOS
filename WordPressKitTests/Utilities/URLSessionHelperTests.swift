import Foundation
import XCTest
import OHHTTPStubs

@testable import WordPressKit

class URLSessionHelperTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    func testConnectionError() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(error: URLError(.serverCertificateUntrusted))
        }

        let result = await URLSession.shared.perform(request: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)
        do {
            _ = try result.get()
            XCTFail("The above call should throw")
        } catch let WordPressAPIError<TestError>.connection(error) {
            XCTAssertEqual(error.code, URLError.Code.serverCertificateUntrusted)
        } catch {
            XCTFail("Unknown error: \(error)")
        }
    }

    func test200() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(data: "success".data(using: .utf8)!, statusCode: 200, headers: nil)
        }

        let result = await URLSession.shared.perform(request: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)

        // The result is a successful result. This line should not throw
        let response = try result.get()

        XCTAssertEqual(String(data: response.body, encoding: .utf8), "success")
    }

    func testUnacceptable500() async {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(data: "Internal server error".data(using: .utf8)!, statusCode: 500, headers: nil)
        }

        let result = await URLSession.shared
            .perform(request: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)

        switch result {
        case let .failure(.unacceptableStatusCode(response, _)):
            XCTAssertEqual(response.statusCode, 500)
        default:
            XCTFail("Got an unexpected result: \(result)")
        }
    }

    func testAcceptable404() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(data: "Not found".data(using: .utf8)!, statusCode: 404, headers: nil)
        }

        let result = await URLSession.shared
            .perform(
                request: .init(url: URL(string: "https://wordpress.org/hello")!),
                acceptableStatusCodes: [200...299, 400...499], errorType: TestError.self
            )

        // The result is a successful result. This line should not throw
        let response = try result.get()
        XCTAssertEqual(String(data: response.body, encoding: .utf8), "Not found")
    }

    func testParseError() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(data: "Not found".data(using: .utf8)!, statusCode: 404, headers: nil)
        }

        let result = await URLSession.shared
            .perform(request: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)
            .mapUnacceptableStatusCodeError { response, _ in
                XCTAssertEqual(response.statusCode, 404)
                return .postNotFound
            }

        if case .failure(WordPressAPIError<TestError>.endpointError(.postNotFound)) = result {
            // DO nothing
        } else {
            XCTFail("Unexpected result: \(result)")
        }
    }

    func testParseSuccessAsJSON() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(jsonObject: ["title": "Hello Post"], statusCode: 200, headers: nil)
        }

        struct Post: Decodable {
            var title: String
        }

        let result: WordPressAPIResult<Post, TestError> = await URLSession.shared
            .perform(request: .init(url: URL(string: "https://wordpress.org/hello")!))
            .mapSuccess()

        try XCTAssertEqual(result.get().title, "Hello Post")
    }
}

private enum TestError: LocalizedError, Equatable {
    case postNotFound
    case serverFailure
}
