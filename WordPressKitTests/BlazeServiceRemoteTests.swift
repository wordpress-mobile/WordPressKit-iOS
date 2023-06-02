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

    // MARK: - Campaigns

    func testDecodeCampaignsSummaryResponse() throws {
        // Given
        let url = try XCTUnwrap(Bundle(for: BlazeServiceRemoteTests.self).url(forResource: "blaze-campaigns-summary", withExtension: "json"))
        let data = try Data(contentsOf: url)

        // When
        let response = try JSONDecoder.apiDecoder.decode(BlazeCampaignsSummaryResponse.self, from: data)

        // Then
        XCTAssertEqual(response.total, 2)
        XCTAssertTrue(response.canCreateCampaigns)

        let campaign = try XCTUnwrap(response.campaigns.first)
        XCTAssertEqual(campaign.campaignID, 26916)
        XCTAssertEqual(campaign.name, "Test Post - don't approve")
        XCTAssertEqual(campaign.startDate, ISO8601DateFormatter().date(from: "2023-06-13T00:00:00Z"))
        XCTAssertEqual(campaign.endDate, ISO8601DateFormatter().date(from: "2023-06-01T19:15:45Z"))
        XCTAssertEqual(campaign.status, .canceled)
        XCTAssertEqual(campaign.budgetCents, 500)
        XCTAssertEqual(campaign.targetURL, "https://alextest9123.wordpress.com/2023/06/01/test-post/")
        XCTAssertEqual(campaign.contentConfig?.title, "Test Post - don't approve")
        XCTAssertEqual(campaign.contentConfig?.snippet, "Test Post Empty Empty")
        XCTAssertEqual(campaign.contentConfig?.clickURL, "https://alextest9123.wordpress.com/2023/06/01/test-post/")
        XCTAssertEqual(campaign.contentConfig?.imageURL, "https://i0.wp.com/public-api.wordpress.com/wpcom/v2/wordads/dsp/api/v1/dsp/creatives/56259/image?w=600&zoom=2")
    }

    func testDecodeCampaignsSearchResponse() throws {
        // Given
        let url = try XCTUnwrap(Bundle(for: BlazeServiceRemoteTests.self).url(forResource: "blaze-campaigns-search", withExtension: "json"))
        let data = try Data(contentsOf: url)

        // When
        let response = try JSONDecoder.apiDecoder.decode(BlazeCampaignsSearchResponse.self, from: data)

        // Then
        XCTAssertEqual(response.totalItems, 1)
        XCTAssertEqual(response.totalPages, 1)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.campaigns?.count, 1)

        let campaign = try XCTUnwrap(response.campaigns?.first)
        XCTAssertEqual(campaign.campaignID, 26916)
        XCTAssertEqual(campaign.name, "Test Post - don't approve")
        XCTAssertEqual(campaign.startDate, ISO8601DateFormatter().date(from: "2023-06-13T00:00:00Z"))
        XCTAssertEqual(campaign.endDate, ISO8601DateFormatter().date(from: "2023-06-01T19:15:45Z"))
        XCTAssertEqual(campaign.status, .canceled)
        XCTAssertEqual(campaign.budgetCents, 500)
        XCTAssertEqual(campaign.targetURL, "https://alextest9123.wordpress.com/2023/06/01/test-post/")
        XCTAssertEqual(campaign.contentConfig?.title, "Test Post - don't approve")
        XCTAssertEqual(campaign.contentConfig?.snippet, "Test Post Empty Empty")
        XCTAssertEqual(campaign.contentConfig?.clickURL, "https://alextest9123.wordpress.com/2023/06/01/test-post/")
        XCTAssertEqual(campaign.contentConfig?.imageURL, "https://i0.wp.com/public-api.wordpress.com/wpcom/v2/wordads/dsp/api/v1/dsp/creatives/56259/image?w=600&zoom=2")
    }
}
