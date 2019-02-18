import Foundation
import XCTest
@testable import WordPressKit

class StatsRemoteV2Tests: RemoteTestCase, RESTTestable {

    // MARK: - Constants

    let siteID   = 321

    let getStreakMockFilename               = "stats-streak-result.json"

    // MARK: - Properties

    var siteStreakEndpoint: String { return "sites/\(siteID)/stats/streak" }
    var remote: StatsServiceRemoteV2!

    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        remote = StatsServiceRemoteV2(wordPressComRestApi: getRestApi(), siteID: siteID, siteTimezone: .autoupdatingCurrent)
    }

    func testFetchStreaks() {
        let expect = expectation(description: "It should return streak data")

        stubRemoteResponse(siteStreakEndpoint, filename: getStreakMockFilename, contentType: .ApplicationJSON)

        remote.getInsight { (insight: StatsPostingStreakInsight?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(insight)
            XCTAssertEqual(insight?.postingEvents.count, 31)
            XCTAssertEqual(insight?.postingEvents.filter { $0.postCount == 1}.count, 29)
            XCTAssertEqual(insight?.postingEvents.filter { $0.postCount == 2}.count, 2)

            let calendar = Calendar.autoupdatingCurrent

            let march28 = DateComponents(year: 2018, month: 3, day: 28)
            let march29 = DateComponents(year: 2018, month: 3, day: 29)
            let feb7 = DateComponents(year: 2019, month: 2, day: 7)

            XCTAssertEqual(insight?.longestStreakStart, calendar.date(from: march28))
            XCTAssertEqual(insight?.longestStreakEnd, calendar.date(from: march29))
            XCTAssertEqual(insight?.longestStreakLength, 2)

            XCTAssertEqual(insight?.currentStreakStart, calendar.date(from: feb7))
            XCTAssertEqual(insight?.currentStreakEnd, calendar.date(from: feb7))
            XCTAssertEqual(insight?.currentStreakLength, 1)

            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
