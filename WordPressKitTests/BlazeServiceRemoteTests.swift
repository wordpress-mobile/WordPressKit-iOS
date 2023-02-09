import XCTest
@testable import WordPressKit

final class BlazeServiceRemoteTests: RemoteTestCase, RESTTestable {

    // MARK: - Constants

    let siteId = 1

    // MARK: - Properties

    var statusEndpoint: String { return "sites/\(siteId)/blaze/status" }
    var service: BlazeServiceRemote!

    // MARK: - Tests

    func testGetStatusReturnsSuccess() throws {
        // Given
        let status = ["approved": true]
        let data = try JSONEncoder().encode(status)
        stubRemoteResponse(statusEndpoint, data: data, contentType: .ApplicationJSON)

        // When
        let expectation = XCTestExpectation()
        BlazeServiceRemote(wordPressComRestApi: getRestApi()).getStatus(forSiteId: siteId) { result in

            // Then
            let approved = try! result.get()
            XCTAssertEqual(approved, true)
            expectation.fulfill()

        }

        wait(for: [expectation], timeout: 1)
    }

    func testMalformedResponseReturnsError() throws {
        // Given
        let data = try toJSON(object: ["Invalid"])
        stubRemoteResponse(statusEndpoint, data: data, contentType: .ApplicationJSON)

        // When
        let expectation = XCTestExpectation()
        BlazeServiceRemote(wordPressComRestApi: getRestApi()).getStatus(forSiteId: siteId) { result in

            // Then
            switch result {
                case .success: XCTFail()
                case .failure: expectation.fulfill()
            }

        }

        wait(for: [expectation], timeout: 1)
    }

    func testGetStatusReturnsFailure() {
        // Given
        stubRemoteResponse(statusEndpoint, data: Data(), contentType: .NoContentType, status: 403)

        // When
        let expectation = XCTestExpectation()
        BlazeServiceRemote(wordPressComRestApi: getRestApi()).getStatus(forSiteId: siteId) { result in

            // Then
            if case .success = result {
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func toJSON<T: Codable>(object: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return try encoder.encode(object)
    }
}
