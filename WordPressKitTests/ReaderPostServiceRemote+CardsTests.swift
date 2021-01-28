import XCTest

@testable import WordPressKit

class ReaderPostServiceRemoteCardTests: RemoteTestCase, RESTTestable {
    let mockRemoteApi = MockWordPressComRestApi()
    var readerPostServiceRemote: ReaderPostServiceRemote!

    override func setUp() {
        super.setUp()
        readerPostServiceRemote = ReaderPostServiceRemote(wordPressComRestApi: getRestApi())
    }

    // Return an array of cards
    //
    func testReturnCards() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("read/tags/cards?tags%5B%5D=dogs", filename: "reader-cards-success.json", contentType: .ApplicationJSON)

        readerPostServiceRemote.fetchCards(for: ["dogs"], success: { cards, _ in
            XCTAssertTrue(cards.count == 10)
            expect.fulfill()
        }, failure: { _ in })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // All Post Cards contains a Post
    //
    func testReturnPosts() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("read/tags/cards?tags%5B%5D=cats", filename: "reader-cards-success.json", contentType: .ApplicationJSON)

        readerPostServiceRemote.fetchCards(for: ["cats"], success: { cards, _ in
            let postCards = cards.filter { $0.type == .post }
            XCTAssertTrue(postCards.allSatisfy { $0.post != nil })
            expect.fulfill()
        }, failure: { _ in })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // All cards have the correct type
    //
    func testReturnCorrectCardType() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("read/tags/cards?tags%5B%5D=cats", filename: "reader-cards-success.json", contentType: .ApplicationJSON)

        readerPostServiceRemote.fetchCards(for: ["cats"], success: { cards, _ in
            let postTypes = cards.map { $0.type }
            let expectedPostTypes: [RemoteReaderCard.CardType] = [.interests, .sites, .post, .post, .post, .post, .post, .post, .post, .post]
            XCTAssertTrue(postTypes == expectedPostTypes)
            expect.fulfill()
        }, failure: { _ in })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Calls the failure block when an error happens
    //
    func testReturnError() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("read/tags/cards?tags%5B%5D=cats", filename: "reader-cards-success.json", contentType: .ApplicationJSON, status: 503)

        readerPostServiceRemote.fetchCards(for: ["cats"], success: { _, _ in }, failure: { error in
            XCTAssertNotNil(error)
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Return the next page handle
    //
    func testReturnNextPageHandle() {
        let expect = expectation(description: "Returns next page handle")
        stubRemoteResponse("read/tags/cards?tags%5B%5D=dogs", filename: "reader-cards-success.json", contentType: .ApplicationJSON)

        readerPostServiceRemote.fetchCards(for: ["dogs"], success: { cards, nextPageHandle in
            XCTAssertTrue(nextPageHandle == "ZnJvbT0xMCZiZWZvcmU9MjAyMC0wNy0yNlQxMyUzQTU1JTNBMDMlMkIwMSUzQTAw")
            expect.fulfill()
        }, failure: { _ in })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // Calls the API with the given page handle
    //
    func testCallAPIWithTheGivenPageHandle() {
        let readerPostServiceRemote = ReaderPostServiceRemote(wordPressComRestApi: mockRemoteApi)

        readerPostServiceRemote.fetchCards(for: ["dogs"], page: "foobar", success: { _, _ in }, failure: { _ in })

        XCTAssertTrue(mockRemoteApi.URLStringPassedIn?.contains("&page_handle=foobar") ?? false)
    }
    
    // Calls the API with the given sorting option
    //
    func testCallAPIWithTheGivenSortingOption() {
        let readerPostServiceRemote = ReaderPostServiceRemote(wordPressComRestApi: mockRemoteApi)

        readerPostServiceRemote.fetchCards(for: [], sortingOption: "foobar", success: { _, _ in }, failure: { _ in })

        XCTAssertTrue(mockRemoteApi.URLStringPassedIn?.contains("sort=foobar") ?? false)
    }
    
    // Calls the API without the given sorting option
    //
    func testCallAPIWithoutTheGivenSortingOption() {
        let readerPostServiceRemote = ReaderPostServiceRemote(wordPressComRestApi: mockRemoteApi)

        readerPostServiceRemote.fetchCards(for: [], sortingOption: nil, success: { _, _ in }, failure: { _ in })
        
        XCTAssertFalse(mockRemoteApi.URLStringPassedIn?.contains("sort=") ?? false)
    }
    
    // Calls the API with "date" as a sorting option and checks if posts are ordered properly
    //
    func testCallAPIWithDateAsGivenSortOption() {
        let expect = expectation(description: "Get cards sorted by date")
        stubRemoteResponse("read/tags/cards?tags%5B%5D=cats&sort=date", filename: "reader-cards-success.json", contentType: .ApplicationJSON)
        
        readerPostServiceRemote.fetchCards(for: ["cats"], sortingOption: "date", success: { cards, _ in
            let posts = cards.filter { $0.type == .post }
            for i in 1..<posts.count {
                guard let firstPostDate = posts[i-1].post?.sortDate,
                      let secondPostDate = posts[i].post?.sortDate,
                      firstPostDate > secondPostDate else {
                    XCTFail("Posts should be sorted by date, starting with most recent post")
                    expect.fulfill()
                    return
                }
            }
            expect.fulfill()
        }, failure: { _ in })
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
