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
            let expectedPostTypes: [RemoteReaderCard.CardType] = [.interests, .unknown, .post, .post, .post, .post, .post, .post, .post, .post]
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
}
