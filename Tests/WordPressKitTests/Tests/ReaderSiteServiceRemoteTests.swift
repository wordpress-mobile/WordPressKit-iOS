import XCTest
import OHHTTPStubs
@testable import WordPressKit

class ReaderSiteServiceRemoteTests: XCTestCase {

    let mockRemoteApi = MockWordPressComRestApi()
    var readerSiteServiceRemote: ReaderSiteServiceRemote!

    override func setUp() {
        super.setUp()
        readerSiteServiceRemote = ReaderSiteServiceRemote(wordPressComRestApi: mockRemoteApi)
    }

    func testFetchFollowedSitesPath() {

        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "read/following/mine?meta=site,feed",
                                                        with: ._1_1)
        readerSiteServiceRemote.fetchFollowedSites(success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.getMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
    }

    func testFetchFollowedSites() {

        let response = ["subscriptions": [["ID": 1], ["ID": 2]]]
        var sites = [RemoteReaderSite]()
        readerSiteServiceRemote.fetchFollowedSites(success: {
            if let remoteSites = $0 as? [RemoteReaderSite] {
                sites = remoteSites
            }
        }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertFalse(sites.isEmpty, "Should have at least one site")
    }

    func testFollowSiteWithIDPath() {

        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "sites/1/follows/new",
                                                        with: ._1_1)
        readerSiteServiceRemote.followSite(withID: 1, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.postMethodCalled, "Wrong method")

        let url = URL(string: mockRemoteApi.URLStringPassedIn!)!
        XCTAssertEqual(url.path, expectedPath, "Wrong path")
        XCTAssertEqual(url.query, "source=ios", "incorrect source parameter")
    }

    func testFollowSiteWithID() {

        var success = false
        let response = [String: AnyObject]()
        readerSiteServiceRemote.followSite(withID: 1, success: {
            success = true
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(success)
    }

    func testUnfollowSiteWithIDPath() {

        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "sites/1/follows/mine/delete",
                                                        with: ._1_1)
        readerSiteServiceRemote.unfollowSite(withID: 1, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.postMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
    }

    func testUnfollowSiteWithID() {

        var success = false
        let response = [String: AnyObject]()
        readerSiteServiceRemote.unfollowSite(withID: 1, success: {
            success = true
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(success)
    }

    func testFollowSiteAtURLPath() {

        let url = "http://www.wordpress.com"
        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "read/following/mine/new",
                                                        with: ._1_1)
        readerSiteServiceRemote.followSite(atURL: url, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.postMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
        let parameters: NSDictionary = mockRemoteApi.parametersPassedIn as! NSDictionary
        XCTAssertEqual(parameters["url"] as! String?, url, "incorrect url parameter")
        XCTAssertEqual(parameters["source"] as! String?, "ios", "incorrect source parameter")
    }

    func testFollowSiteAtURL() {

        let response = ["subscribed": true]
        var success = false
        let url = "http://www.wordpress.com"
        readerSiteServiceRemote.followSite(atURL: url, success: {
            success = true
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(success)
    }

    func testFollowSiteAtURLFailure() {

        let response = ["subscribed": false]
        var failure = false
        let url = "http://www.wordpress.com"
        readerSiteServiceRemote.followSite(atURL: url, success: nil, failure: { _ in
            failure = true
        })
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(failure)
    }

    func testUnfollowSiteAtURLPath() {

        let url = "http://www.wordpress.com"
        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "read/following/mine/delete",
                                                        with: ._1_1)
        readerSiteServiceRemote.unfollowSite(atURL: url, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.postMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
        let parameters: NSDictionary = mockRemoteApi.parametersPassedIn as! NSDictionary
        XCTAssertEqual(parameters["url"] as! String?, url, "incorrect url parameter")
    }

    func testUnfollowSiteAtURL() {

        let response = ["subscribed": false]
        var success = false
        let url = "http://www.wordpress.com"
        readerSiteServiceRemote.unfollowSite(atURL: url, success: {
            success = true
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(success)
    }

    func testUnfollowSiteAtURLFailure() {

        let response = ["subscribed": true]
        var failure = false
        let url = "http://www.wordpress.com"
        readerSiteServiceRemote.unfollowSite(atURL: url, success: nil, failure: { _ in
            failure = true
        })
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(failure)
    }

    func testFindSiteIDForURLPath() {

        let url = URL(string: "http://www.wordpress.com")!
        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "sites/\(url.host!)",
                                                        with: ._1_1)
        readerSiteServiceRemote.findSiteID(for: url as URL, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.getMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
    }

    func testFindSiteIDForURLWithNoHost() {

        let response = [String: AnyObject]()
        var failure = false
        let url = URL(string: "http://")!
        readerSiteServiceRemote.findSiteID(for: url as URL, success: nil, failure: { _ in
            failure = true
        })
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(failure)
    }

    func testFindSiteIDForURL() {

        let response = ["ID": 1]
        var siteID: UInt = 0
        let url = URL(string: "http://www.wordpress.com")!
        readerSiteServiceRemote.findSiteID(for: url as URL, success: {
            siteID = $0
        }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(siteID != 0)
    }

    func testSubscribedToSiteByIDPath() {

        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "sites/1/follows/mine",
                                                        with: ._1_1)
        readerSiteServiceRemote.checkSubscribedToSite(byID: 1, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.getMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
    }

    func testIsSubscribedToSiteByID() {

        var subscribed = false
        let response = ["is_following": true]
        readerSiteServiceRemote.checkSubscribedToSite(byID: 1, success: {
            subscribed = $0
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(subscribed)
    }

    func testIsNotSubscribedToSiteByID() {

        var subscribed = false
        let response = ["is_following": false]
        readerSiteServiceRemote.checkSubscribedToSite(byID: 1, success: {
            subscribed = $0
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertFalse(subscribed)
    }

    func testSubscribedToFeedByURLPath() {

        let url = URL(string: "http://www.wordpress.com")!
        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "read/following/mine",
                                                        with: ._1_1)
        readerSiteServiceRemote.checkSubscribedToFeed(by: url as URL, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.getMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
    }

    func testSubscribedToFeedByURL() {

        let url = URL(string: "http://www.wordpress.com")!
        var subscribed = false
        let response = url.absoluteString
        readerSiteServiceRemote.checkSubscribedToFeed(by: url as URL, success: {
            subscribed = $0
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(subscribed)
    }

    func testNotSubscribedToFeedByURL() {

        let url = URL(string: "http://www.wordpress.com")!
        var subscribed = false
        let response = "http://www.gravatar.com"
        readerSiteServiceRemote.checkSubscribedToFeed(by: url as URL, success: {
            subscribed = $0
        }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertFalse(subscribed)
    }

    func testFlagSiteWithIDPath() {

        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "me/block/sites/1/delete",
                                                        with: ._1_1)
        readerSiteServiceRemote.flagSite(withID: 1, asBlocked: false, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.postMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
    }

    func testFlagBlockedSiteWithIDPath() {

        let expectedPath = readerSiteServiceRemote.path(forEndpoint: "me/block/sites/1/new",
                                                        with: ._1_1)
        readerSiteServiceRemote.flagSite(withID: 1, asBlocked: true, success: nil, failure: nil)
        XCTAssertTrue(mockRemoteApi.postMethodCalled, "Wrong method")
        XCTAssertEqual(mockRemoteApi.URLStringPassedIn, expectedPath, "Wrong path")
    }

    func testFlagSiteWithID() {

        let response = ["success": true]
        var success = false
        readerSiteServiceRemote.flagSite(withID: 1, asBlocked: false, success: {
            success = true
            }, failure: nil)
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(success)
    }

    func testFlagSiteWithIDFailure () {

        let response = ["success": false]
        var failure = false
        readerSiteServiceRemote.flagSite(withID: 1, asBlocked: false, success: nil, failure: { _ in
            failure = true
        })
        mockRemoteApi.successBlockPassedIn?(response as AnyObject, HTTPURLResponse())
        XCTAssertTrue(failure)
    }

    func testCheckSiteExistsAtURLSuccess() throws {
        let testURLString = "http://www.wordpress.com"
        let testURL = URL(string: testURLString)!
        let stubPath = try XCTUnwrap(OHPathForFile("empty.json", type(of: self)))
        stub(condition: {request in request.url?.absoluteString == testURLString}) { _ in
            return fixture(filePath: stubPath, headers: ["Content-Type" as NSObject: "application/json" as AnyObject])
        }

        let expect = self.expectation(description: "One callback should be invoked")
        readerSiteServiceRemote.checkSiteExists(at: testURL, success: {
            expect.fulfill()
            XCTAssertTrue(true)
        }, failure: { (_) in
            expect.fulfill()
            XCTFail("This call should be successfull")
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testCheckSiteExistsAtURLFailure() throws {
        let testURLString = "http://www.wordpress.com"
        let testURL = URL(string: testURLString)!
        let stubPath = try XCTUnwrap(OHPathForFile("empty.json", type(of: self)))
        stub(condition: {request in request.url?.absoluteString == testURLString}) { _ in
            return fixture(
                filePath: stubPath,
                status: 400,
                headers: ["Content-Type" as NSObject: "application/json" as AnyObject]
            )
        }

        let expect = self.expectation(description: "One callback should be invoked")
        readerSiteServiceRemote.checkSiteExists(at: testURL, success: {
            expect.fulfill()
            XCTAssertTrue(false, "This call should be unsuccessfull")
        }, failure: { (_) in
            expect.fulfill()
            XCTAssertTrue(true)
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testCheckSiteExistsAtURLFailureNetworkError() {
        let testURLString = "http://www.wordpress.com"
        let testURL = URL(string: testURLString)!
        stub(condition: {request in request.url?.absoluteString == testURLString}) { _ in
            return HTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil))
        }

        let expect = self.expectation(description: "One callback should be invoked")
        readerSiteServiceRemote.checkSiteExists(at: testURL, success: {
            expect.fulfill()
            XCTAssertTrue(false, "This call should be unsuccessfull")
        }, failure: { (_) in
            expect.fulfill()
            XCTAssertTrue(true)
        })
        self.waitForExpectations(timeout: 2, handler: nil)
    }
}
