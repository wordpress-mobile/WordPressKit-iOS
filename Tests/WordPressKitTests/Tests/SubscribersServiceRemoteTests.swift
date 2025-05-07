import Foundation
import XCTest
@testable import WordPressKit

class SubscribersServiceRemoteTests: RemoteTestCase, RESTTestable {
    func testDecodeSubscribersResponse() throws {
        let data = try JSONLoader.data(named: "site-subscribers-response")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.supportMultipleDateFormats

        let response = try decoder.decode(SubscribersServiceRemote.GetSubscribersResponse.self, from: data)

        XCTAssertEqual(response.total, 1)

        let subscriber = try XCTUnwrap(response.subscribers.first)
        XCTAssertEqual(subscriber.userID, 1)
    }
}
