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
    let getCountriesMockFilename = "stats-countries-data.json"
    let getClicksMockFilename = "stats-clicks-data.json"
    let getReferrersMockFilename = "stats-referrer-data.json"
    let getPostsMockFilename = "stats-posts-data.json"
    let getPublishedPostsFilename = "stats-published-posts.json"

    // MARK: - Properties

    var siteStreakEndpoint: String { return "sites/\(siteID)/stats/streak" }
    var siteSearchDataEndpoint: String { return "sites/\(siteID)/stats/search-terms/" }
    var siteAuthorsDataEndpoint: String { return "sites/\(siteID)/stats/top-authors/" }
    var siteVideosDataEndpoint: String { return "sites/\(siteID)/stats/video-plays/" }
    var siteCountriesDataEndpoint: String { return "sites/\(siteID)/stats/country-views/" }
    var siteClicksDataEndpoint: String { return "sites/\(siteID)/stats/clicks/" }
    var siteReferrerDataEndpoint: String { return "sites/\(siteID)/stats/referrers/" }
    var sitePostsDataEndpoint: String { return "sites/\(siteID)/stats/top-posts/" }
    var sitePublishedPostsEndpoint: String { return "sites/\(siteID)/posts/" }

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

    func testCountries() {
        let expect = expectation(description: "It should return country data for a year")

        stubRemoteResponse(siteCountriesDataEndpoint, filename: getCountriesMockFilename, contentType: .ApplicationJSON)

        let dec31 = DateComponents(year: 2018, month: 12, day: 31)
        let date = Calendar.autoupdatingCurrent.date(from: dec31)!


        remote.getData(for: .year, endingOn: date) { (countries: CountryStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(countries)

            XCTAssertEqual(countries?.totalViewsCount, 1884)
            XCTAssertEqual(countries?.otherViewsCount, 242)

            XCTAssertEqual(countries?.countries.count, 10)

            XCTAssertEqual(countries?.countries.first!.viewsCount, 937)
            XCTAssertEqual(countries?.countries.first!.name, "United States")
            XCTAssertEqual(countries?.countries.first!.code, "US")

            XCTAssertEqual(countries?.countries.last!.viewsCount, 37)
            XCTAssertEqual(countries?.countries.last!.name, "Netherlands")
            XCTAssertEqual(countries?.countries.last!.code, "NL")


            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testClicks() {
        let expect = expectation(description: "It should return clicks data for a year")

        stubRemoteResponse(siteClicksDataEndpoint, filename: getClicksMockFilename, contentType: .ApplicationJSON)

        let dec31 = DateComponents(year: 2018, month: 12, day: 31)
        let date = Calendar.autoupdatingCurrent.date(from: dec31)!


        remote.getData(for: .year, endingOn: date) { (clicks: ClicksStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(clicks)

            XCTAssertEqual(clicks?.totalClicksCount, 1032)
            XCTAssertEqual(clicks?.otherClicksCount, 2)

            XCTAssertEqual(clicks!.clicks.count, 10)

            XCTAssertEqual(clicks?.clicks.first!.clicksCount, 767)
            XCTAssertEqual(clicks?.clicks.first!.title, "automattic.com/work-with-us/?utm_source=a8c&utm_medium=site&utm_campaign=officetoday")
            XCTAssertEqual(clicks?.clicks.first!.clickedURL, URL(string: "http://automattic.com/work-with-us/?utm_source=a8c&amp;utm_medium=site&amp;utm_campaign=officetoday"))
            XCTAssertEqual(clicks?.clicks.first?.iconURL, URL(string: "https://secure.gravatar.com/blavatar/70ac4b986ed274e446bd33c2fdeefe49?s=48"))
            XCTAssertEqual(clicks?.clicks.first?.children.count, 0)

            XCTAssertEqual(clicks?.clicks[1].clicksCount, 167)
            XCTAssertEqual(clicks?.clicks[1].title, "WordPress.com Media ")
            XCTAssertNil(clicks?.clicks[1].iconURL)
            XCTAssertNil(clicks?.clicks[1].clickedURL)

            XCTAssertEqual(clicks?.clicks[1].children.count, 10)
            XCTAssertEqual(clicks?.clicks[1].children.first?.clicksCount, 22)
            XCTAssertEqual(clicks?.clicks[1].children.first?.clickedURL, URL(string: "https://officetoday.files.wordpress.com/2018/11/20181115_093040.jpg"))
            XCTAssertEqual(clicks?.clicks[1].children.first?.title, "officetoday.files.wordpress.com/2018/11/20181115_093040.jpg")

            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testReferrers() {
        let expect = expectation(description: "It should return referrer data for a year")

        stubRemoteResponse(siteReferrerDataEndpoint, filename: getReferrersMockFilename, contentType: .ApplicationJSON)

        let jan31 = DateComponents(year: 2019, month: 1, day: 31)
        let date = Calendar.autoupdatingCurrent.date(from: jan31)!

        remote.getData(for: .month, endingOn: date) { (referrers: ReferrerStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(referrers)

            XCTAssertEqual(referrers?.totalReferrerViewsCount, 560)
            XCTAssertEqual(referrers?.otherReferrerViewsCount, 18)

            XCTAssertEqual(referrers?.referrers.count, 10)

            XCTAssertEqual(referrers?.referrers.first!.viewsCount, 126)
            XCTAssertEqual(referrers?.referrers.first!.title, "linkedin.com")
            XCTAssertEqual(referrers?.referrers.first!.iconURL, URL(string: "https://secure.gravatar.com/blavatar/f54db463750940e0e7f7630fe327845e?s=48"))
            XCTAssertEqual(referrers?.referrers.first?.children.count, 5)
            XCTAssertNil(referrers?.referrers.first!.url)

            let noChildrenItem = referrers?.referrers[1]
            XCTAssertNotNil(noChildrenItem)

            XCTAssertEqual(noChildrenItem!.viewsCount, 124)
            XCTAssertEqual(noChildrenItem!.title, "Twitter")
            XCTAssertEqual(noChildrenItem!.url, URL(string: "http://twitter.com/"))
            XCTAssertEqual(noChildrenItem?.iconURL, URL(string: "https://secure.gravatar.com/blavatar/7905d1c4e12c54933a44d19fcd5f9356?s=48"))
            XCTAssertEqual(noChildrenItem?.children.count, 0)

            XCTAssertEqual(referrers?.referrers[3].viewsCount, 55)
            XCTAssertEqual(referrers?.referrers[3].title, "Search Engines")
            XCTAssertEqual(referrers?.referrers[3].iconURL, URL(string: "https://wordpress.com/i/stats/search-engine.png"))
            XCTAssertEqual(referrers?.referrers[3].children.count, 1)
            XCTAssertNil(referrers?.referrers[3].url)

            let google = referrers?.referrers[3].children.first
            XCTAssertNotNil(google)

            XCTAssertEqual(google!.viewsCount, 55)
            XCTAssertEqual(google!.title, "Google Search")
            XCTAssertEqual(google!.iconURL, URL(string: "https://secure.gravatar.com/blavatar/6741a05f4bc6e5b65f504c4f3df388a1?s=48"))
            XCTAssertEqual(google?.children.count, 9)
            XCTAssertNil(google?.url)

            let firstGoogleChildren = google?.children.first
            XCTAssertNotNil(firstGoogleChildren)

            XCTAssertEqual(firstGoogleChildren?.viewsCount, 47)
            XCTAssertEqual(firstGoogleChildren?.title, "google.com")
            XCTAssertEqual(firstGoogleChildren?.url, URL(string: "http://www.google.com/"))
            XCTAssertEqual(firstGoogleChildren?.children.count, 0)
            XCTAssertNil(firstGoogleChildren?.iconURL)

            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testTopPosts() {
        let expect = expectation(description: "It should return posts data for a year")

        stubRemoteResponse(sitePostsDataEndpoint, filename: getPostsMockFilename, contentType: .ApplicationJSON)
      
        let jan31 = DateComponents(year: 2019, month: 1, day: 31)
        let date = Calendar.autoupdatingCurrent.date(from: jan31)!
      
        remote.getData(for: .month, endingOn: date) { (topPosts: PostsStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(topPosts)

            XCTAssertEqual(topPosts?.totalViewsCount, 3499)
            XCTAssertEqual(topPosts?.otherViewsCount, 237)

            XCTAssertEqual(topPosts?.topPosts.count, 10)

            XCTAssertEqual(topPosts?.topPosts.first?.viewsCount, 2816)
            XCTAssertEqual(topPosts?.topPosts.first?.kind, .homepage)
            XCTAssertEqual(topPosts?.topPosts.first?.title, "Home page / Archives")
            XCTAssertEqual(topPosts?.topPosts.first?.postID, 0)
            XCTAssertEqual(topPosts?.topPosts.first?.postURL, URL(string: "http://officetoday.wordpress.com/"))

            XCTAssertEqual(topPosts?.topPosts[1].viewsCount, 146)
            XCTAssertEqual(topPosts?.topPosts[1].kind, .post)
            XCTAssertEqual(topPosts?.topPosts[1].title, "Valizas, Uruguay")
            XCTAssertEqual(topPosts?.topPosts[1].postID, 2396)
            XCTAssertEqual(topPosts?.topPosts[1].postURL, URL(string: "http://officetoday.wordpress.com/2019/01/04/valizas-uruguay/"))

            XCTAssertEqual(topPosts?.topPosts[2].viewsCount, 141)
            XCTAssertEqual(topPosts?.topPosts[2].kind, .page)
            XCTAssertEqual(topPosts?.topPosts[2].title, "Dundee, Scotland")
            XCTAssertEqual(topPosts?.topPosts[2].postID, 2413)
            XCTAssertEqual(topPosts?.topPosts[2].postURL, URL(string: "http://officetoday.wordpress.com/2019/01/24/dundee-scotland-2/"))
                                                     
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)                                                    
    }                                                    

    func testsPublishedPosts() {
        let expect = expectation(description: "It should return published posts for a specified window")

        stubRemoteResponse(sitePublishedPostsEndpoint, filename: getPublishedPostsFilename, contentType: .ApplicationJSON)

        let jan31 = DateComponents(year: 2019, month: 1, day: 31)
        let date = Calendar.autoupdatingCurrent.date(from: jan31)!

        remote.getData(for: .month, endingOn: date) { (publishedPosts: PublishedPostsStatsType?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(publishedPosts)

            XCTAssertEqual(publishedPosts?.publishedPosts.count, 3)

            XCTAssertEqual(publishedPosts?.publishedPosts[0].postID, 41038)
            XCTAssertEqual(publishedPosts?.publishedPosts[0].postURL, URL(string: "http://en.blog.wordpress.com/2019/01/14/newspack-by-wordpress-com/"))
            XCTAssertEqual(publishedPosts?.publishedPosts[0].title, "Announcing Newspack by WordPress.com &#8212; A New Publishing Solution for News Organizations")


            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
      
    }    
}
