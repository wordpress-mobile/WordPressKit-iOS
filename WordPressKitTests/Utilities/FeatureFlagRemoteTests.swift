import XCTest
@testable import WordPressKit

class FeatureFlagRemoteTests: RemoteTestCase, RESTTestable {

    private let endpoint = "/wpcom/v2/mobile-feature-flags"

    func testThatResponsesAreHandledCorrectly() throws {
        let flags = [
            FeatureFlag(title: UUID().uuidString, value: true),
            FeatureFlag(title: UUID().uuidString, value: false),
        ]

        let data = try JSONEncoder().encode(flags)
        stubRemoteResponse(endpoint, data: data, contentType: .ApplicationJSON)

        let expectation = XCTestExpectation()

        FeatureFlagRemote(wordPressComRestApi: getRestApi()).getRemoteFeatureFlags(forDeviceId: "Test") { result in
            let list = try! result.get()
            XCTAssertEqual(2, list.count)
            XCTAssertEqual(flags.first!, list.first!)
            XCTAssertEqual(flags.last!, list.last!)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testThatEmptyResponsesAreHandledCorrectly() throws {

        let data = try JSONEncoder().encode(FeatureFlagList())
        stubRemoteResponse(endpoint, data: data, contentType: .ApplicationJSON)

        let expectation = XCTestExpectation()

        FeatureFlagRemote(wordPressComRestApi: getRestApi()).getRemoteFeatureFlags(forDeviceId: "Test") { result in
            XCTAssertEqual(0, try! result.get().count)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testThatMalformedResponsesReturnEmptyArray() throws {
        let data = try toJSON(object: [
            [
                "key": "foo",
                "value": true,
            ]
        ])
        stubRemoteResponse(endpoint, data: data, contentType: .ApplicationJSON)

        let expectation = XCTestExpectation()

        FeatureFlagRemote(wordPressComRestApi: getRestApi()).getRemoteFeatureFlags(forDeviceId: "Test") { result in
            XCTAssertEqual(0, try! result.get().count)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testThatRequestErrorReturnsFailureResponse() {
        stubRemoteResponse(endpoint, data: Data(), contentType: .NoContentType, status: 400)

        let expectation = XCTestExpectation()

        FeatureFlagRemote(wordPressComRestApi: getRestApi()).getRemoteFeatureFlags(forDeviceId: "Test") { result in
            if case .success(_) = result {
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func toJSON(object: Any) throws -> Data {
        return try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
    }
}
