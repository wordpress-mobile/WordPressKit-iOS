import XCTest

@testable import WordPressKit

class BloggingPromptsServiceRemoteTests: RemoteTestCase, RESTTestable {

    private let siteID = NSNumber(value: 1)
    private let utcTimeZone = TimeZone(secondsFromGMT: 0)!
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

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
            XCTAssertEqual(firstPrompt.attribution, "dayone")

            let firstDateComponents = Calendar.current.dateComponents(in: self.utcTimeZone, from: firstPrompt.date)
            XCTAssertEqual(firstDateComponents.year!, 2022)
            XCTAssertEqual(firstDateComponents.month!, 5)
            XCTAssertEqual(firstDateComponents.day!, 3)

            XCTAssertFalse(firstPrompt.answered)
            XCTAssertEqual(firstPrompt.answeredUsersCount, 0)

            let secondPrompt = prompts.last!
            XCTAssertEqual(secondPrompt.answeredUsersCount, 1)
            XCTAssertEqual(secondPrompt.answeredUserAvatarURLs.count, 1)
            XCTAssertTrue(secondPrompt.attribution.isEmpty)

            let secondDateComponents = Calendar.current.dateComponents(in: self.utcTimeZone, from: secondPrompt.date)
            XCTAssertEqual(secondDateComponents.year!, 2021)
            XCTAssertEqual(secondDateComponents.month!, 9)
            XCTAssertEqual(secondDateComponents.day!, 12)

            let avatarURL = secondPrompt.answeredUserAvatarURLs.first!
            XCTAssertEqual(avatarURL.absoluteString, expectedAvatarURLString)

            expect.fulfill()
        }

        wait(for: [expect], timeout: timeout)
    }

    func test_fetchPrompts_correctlyAddsParametersToRequest() {
        let expectedNumber = 10
        let expectedDateString = "2022-01-02"
        let expectedDate = dateFormatter.date(from: expectedDateString)
        let customMockApi = MockWordPressComRestApi()
        service = BloggingPromptsServiceRemote(wordPressComRestApi: customMockApi)

        // no-op; we just need to check the passed params.
        service.fetchPrompts(for: siteID, number: expectedNumber, fromDate: expectedDate, completion: { _ in })

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
    static let bloggingPromptsEndpoint = "sites/1/blogging-prompts"
    static let mockFileName = "blogging-prompts-success.json"
    static let numberKey = "number"
    static let dateKey = "from"
}
