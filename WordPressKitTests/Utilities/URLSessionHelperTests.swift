import Foundation
import XCTest
import OHHTTPStubs

@testable import WordPressKit

class URLSessionHelperTests: XCTestCase {

    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }

    func testConnectionError() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(error: URLError(.serverCertificateUntrusted))
        }

        let result = await URLSession.shared.apiResult(with: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)
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

        let result = await URLSession.shared.apiResult(with: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)

        // The result is a successful result. This line should not throw
        _ = try result.get()

        let expectation = expectation(description: "API call returns a successful result")
        _ = result
            .assessStatusCode { result in
                XCTAssertEqual(String(data: result.body, encoding: .utf8), "success")
                expectation.fulfill()
                return result
            } failure: { _ in
                // Do nothing
                return nil
            }
        await fulfillment(of: [expectation])
    }

    func testUnacceptable500() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(data: "Internal server error".data(using: .utf8)!, statusCode: 500, headers: nil)
        }

        let result = await URLSession.shared.apiResult(with: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)

        // The result is a successful result. This line should not throw
        _ = try result.get()

        let expectation = expectation(description: "API call returns server error")
        _ = result
            .assessStatusCode { result in
                return result
            } failure: { result in
                XCTAssertEqual(String(data: result.body, encoding: .utf8), "Internal server error")
                expectation.fulfill()
                return nil
            }
        await fulfillment(of: [expectation])
    }

    func testAcceptable404() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(data: "Not found".data(using: .utf8)!, statusCode: 404, headers: nil)
        }

        let result = await URLSession.shared.apiResult(with: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)

        // The result is a successful result. This line should not throw
        _ = try result.get()

        let expectation = expectation(description: "API call returns not found")
        _ = result
            .assessStatusCode(acceptable: [200...299, 400...499]) { result in
                XCTAssertEqual(String(data: result.body, encoding: .utf8), "Not found")
                expectation.fulfill()
                return result
            } failure: { result in
                return nil
            }
        await fulfillment(of: [expectation])
    }

    func testParseError() async throws {
        stub(condition: isPath("/hello")) { _ in
            HTTPStubsResponse(data: "Not found".data(using: .utf8)!, statusCode: 404, headers: nil)
        }

        let result = await URLSession.shared.apiResult(with: .init(url: URL(string: "https://wordpress.org/hello")!), errorType: TestError.self)

        // The result is a successful result. This line should not throw
        _ = try result.get()

        let expectation = expectation(description: "API call returns not found")
        let parsedResult = result
            .assessStatusCode { result in
                return result
            } failure: { result in
                expectation.fulfill()
                if result.response.statusCode == 404 {
                    return .postNotFound
                }
                return nil
            }
        await fulfillment(of: [expectation])

        if case .failure(WordPressAPIError<TestError>.endpointError(.postNotFound)) = parsedResult {
            // DO nothing
        } else {
            XCTFail("Unexpected result: \(parsedResult)")
        }
    }
}

private enum TestError: LocalizedError {
    case postNotFound
}
