import Foundation
import XCTest
@testable import WordPressKit

class StatsRemoteV2Tests: RemoteTestCase, RESTTestable {

    // MARK: - Constants

    let siteID   = 321

    let getStreakMockFilename = "stats-streak-result.json"
    let getSearchDataFilename = "stats-search-term-result.json"
    let getAuthorsDataFilename = "stats-top-authors.json"
    let getVideosMockFilename = "stats-videos-data.json"

    // MARK: - Properties

    var siteStreakEndpoint: String { return "sites/\(siteID)/stats/streak" }
    var siteSearchDataEndpoint: String { return "sites/\(siteID)/stats/search-terms/" }
    var siteAuthorsDataEndpoint: String { return "sites/\(siteID)/stats/top-authors/" }
    var siteVideosDataEndpoint: String { return "sites/\(siteID)/stats/video-plays/" }

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

    func testFetchSearchData() {
        let expect = expectation(description: "It should return search data for a week")

        stubRemoteResponse(siteSearchDataEndpoint, filename: getSearchDataFilename, contentType: .ApplicationJSON)

        remote.getData(for: .week, endingOn: Date()) { (searchTerms: SearchTermStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(searchTerms)

            XCTAssertEqual(searchTerms!.hiddenSearchTermsCount, 634)
            XCTAssertEqual(searchTerms!.otherSearchTermsCount, 190)
            XCTAssertEqual(searchTerms!.totalSearchTermsCount, 867)

            XCTAssertEqual(searchTerms?.searchTerms.count, 9)
            XCTAssertEqual(searchTerms?.searchTerms.first!.term, "wordpress")
            XCTAssertEqual(searchTerms?.searchTerms.first!.viewsCount, 16)

            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testTopAuthors() {
        let expect = expectation(description: "It should return authors data for a year")

        stubRemoteResponse(siteAuthorsDataEndpoint, filename: getAuthorsDataFilename, contentType: .ApplicationJSON)

        let dec31 = DateComponents(year: 2018, month: 12, day: 31)
        let date = Calendar.autoupdatingCurrent.date(from: dec31)!


        remote.getData(for: .year, endingOn: date) { (topAuthors: AuthorsStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(topAuthors)

            XCTAssertEqual(topAuthors?.topAuthors.count, 10)

            XCTAssertEqual(topAuthors?.topAuthors.first!.viewsCount, 57)
            XCTAssertEqual(topAuthors?.topAuthors.first!.name, "George Hotelling")

            XCTAssertEqual(topAuthors?.topAuthors.first!.posts.count, 10)
            XCTAssertEqual(topAuthors?.topAuthors.first!.posts.first!.postID, 132)
            XCTAssertEqual(topAuthors?.topAuthors.first!.posts.first!.viewsCount, 7)
            XCTAssertEqual(topAuthors?.topAuthors.first!.posts.first!.title, "Josepha's Prospect ")
            XCTAssertEqual(topAuthors?.topAuthors.first!.posts.first!.postURL, URL(string: "http://bagomattic.wordpress.com/2016/09/20/josephas-prospect/"))

            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)

    }

    func testVideos() {
        let expect = expectation(description: "It should return video data for a year")

        stubRemoteResponse(siteVideosDataEndpoint, filename: getVideosMockFilename, contentType: .ApplicationJSON)

        let dec31 = DateComponents(year: 2019, month: 12, day: 31)
        let date = Calendar.autoupdatingCurrent.date(from: dec31)!


        remote.getData(for: .year, endingOn: date) { (videos: VideoStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(videos)

            XCTAssertEqual(videos?.totalPlaysCount, 13661)
            XCTAssertEqual(videos?.otherPlayCount, 62)

            XCTAssertEqual(videos?.videos.count, 10)

            XCTAssertEqual(videos?.videos.first!.playsCount, 7774)
            XCTAssertEqual(videos?.videos.first!.title, "you won't believe what's number two")
            XCTAssertEqual(videos?.videos.first!.postID, 9001)

            XCTAssertEqual(videos?.videos.last!.playsCount, 97)
            XCTAssertEqual(videos?.videos.last!.postID, 9010)
            XCTAssertEqual(videos?.videos.last!.title, "so call me maybe?")

            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)

    }
}
