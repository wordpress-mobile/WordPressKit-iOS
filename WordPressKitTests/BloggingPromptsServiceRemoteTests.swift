import XCTest

@testable import WordPressKit

class BloggingPromptsServiceRemoteTests: RemoteTestCase, RESTTestable {

    let siteID = NSNumber(value: 1)
    static let dateFormatter = ISO8601DateFormatter()

    var mockApi: WordPressComRestApi!
    var service: BloggingPromptsServiceRemote!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        mockApi = getRestApi()
        service = BloggingPromptsServiceRemote(wordPressComRestApi: mockApi)
    }

    override func tearDown() {
        super.tearDown()

        mockApi = nil
        service = nil
    }

    // MARK: Tests

    func test_fetchPrompts_returnsRemotePrompts() {
        let formatter = JSONDecoder.DateDecodingStrategy.DateFormat.dateWithTime.formatter
        let expectedDate = formatter.date(from: "2022-01-01 10:00:00") // using value from the first prompt in blogging-prompts-success.json.
        let expectedAvatarURLString = "https://0.gravatar.com/avatar/example?s=96&d=identicon&r=G"
        stubRemoteResponse(.bloggingPromptsEndpoint, filename: .mockFileName, contentType: .ApplicationJSON)

        let expect = expectation(description: "Fetch blogging prompts succeeded")
        service.fetchPrompts(for: siteID) { result in
            guard case .success(let prompts) = result else {
                XCTFail("Expected success result type")
                return
            }

            XCTAssertEqual(prompts.count, 2)

            let firstPrompt = prompts.first!
            XCTAssertEqual(firstPrompt.promptID, 239)
            XCTAssertEqual(firstPrompt.text, "Was there a toy or thing you always wanted as a child, during the holidays or on your birthday, but never received? Tell us about it.")
            XCTAssertEqual(firstPrompt.title, "Prompt number 1")
            XCTAssertEqual(firstPrompt.content, "<!-- wp:pullquote -->\n<figure class=\"wp-block-pullquote\"><blockquote><p>Was there a toy or thing you always wanted as a child, during the holidays or on your birthday, but never received? Tell us about it.</p><cite>(courtesy of plinky.com)</cite></blockquote></figure>\n<!-- /wp:pullquote -->")
            XCTAssertEqual(firstPrompt.date, expectedDate)
            XCTAssertFalse(firstPrompt.answered)
            XCTAssertEqual(firstPrompt.answeringUserCount, 0)

            let secondPrompt = prompts.last!
            XCTAssertEqual(secondPrompt.answeringUserCount, 1)
            XCTAssertEqual(secondPrompt.answeringUsersAvatarURLs.count, 1)

            let avatarURL = secondPrompt.answeringUsersAvatarURLs.first!
            XCTAssertEqual(avatarURL.absoluteString, expectedAvatarURLString)

            expect.fulfill()
        }

        wait(for:[expect], timeout: timeout)
    }

    func test_fetchPrompts_correctlyAddsParametersToRequest() {
        let expectedNumber = 10
        let expectedDateString = "2022-01-02"
        let isoDateString = "2022-01-02T01:00:00+0400" // ensure that the converted date doesn't change dates (notice the time & timezone).
        let expectedDate = Self.dateFormatter.date(from: isoDateString)
        let customMockApi = MockWordPressComRestApi()
        service = BloggingPromptsServiceRemote(wordPressComRestApi: customMockApi)

        // no-op; we just need to check the passed params.
        service.fetchPrompts(for: siteID, number: expectedNumber, after: expectedDate, completion: { _ in })

        XCTAssertNotNil(customMockApi.parametersPassedIn as? [String: AnyObject])
        let params = customMockApi.parametersPassedIn! as! [String: AnyObject]

        XCTAssertNotNil(params[.numberKey])
        XCTAssertEqual(params[.numberKey] as! Int, expectedNumber)

        XCTAssertNotNil(params[.dateKey])
        XCTAssertEqual(params[.dateKey] as! String, expectedDateString)
    }

}

// MARK: - Private Helpers

private extension String {
    static let bloggingPromptsEndpoint = "blogging-prompts"
    static let mockFileName = "blogging-prompts-success.json"
    static let numberKey = "number"
    static let dateKey = "after"
}
