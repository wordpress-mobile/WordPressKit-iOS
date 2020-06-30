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
        stubRemoteResponse("read/cards", filename: "reader-cards-success.json", contentType: .ApplicationJSON)

        readerPostServiceRemote.fetchCards(success: { cards in
            XCTAssertTrue(cards.count == 10)
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // All Post Cards contains a Post
    //
    func testReturnPosts() {
        let expect = expectation(description: "Get cards successfully")
        stubRemoteResponse("read/cards", filename: "reader-cards-success.json", contentType: .ApplicationJSON)

        readerPostServiceRemote.fetchCards(success: { cards in
            let postCards = cards.filter { $0.type == .post }
            XCTAssertTrue(postCards.allSatisfy { $0.post != nil })
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
