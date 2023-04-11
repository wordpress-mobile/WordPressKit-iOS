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
            XCTAssertEqual(firstPrompt.promptID, 1804)
            XCTAssertEqual(firstPrompt.text, "What are your biggest challenges?")
            XCTAssertEqual(firstPrompt.attribution, "dayone")

            let firstDateComponents = Calendar.current.dateComponents(in: self.utcTimeZone, from: firstPrompt.date)
            XCTAssertEqual(firstDateComponents.year!, 2020)
            XCTAssertEqual(firstDateComponents.month!, 1)
            XCTAssertEqual(firstDateComponents.day!, 1)

            XCTAssertFalse(firstPrompt.answered)
            XCTAssertEqual(firstPrompt.answeredUsersCount, 5)

            XCTAssertNotNil(firstPrompt.answeredLink)
            XCTAssertEqual(firstPrompt.answeredLink!.absoluteString, "https://wordpress.com/tag/dailyprompt-1804")

            XCTAssertEqual(firstPrompt.answeredLinkText, "View all responses")

            let secondPrompt = prompts.last!
            XCTAssertTrue(secondPrompt.answered)
            XCTAssertEqual(secondPrompt.answeredUsersCount, 1)
            XCTAssertEqual(secondPrompt.answeredUserAvatarURLs.count, 1)
            XCTAssertTrue(secondPrompt.attribution.isEmpty)

            let secondDateComponents = Calendar.current.dateComponents(in: self.utcTimeZone, from: secondPrompt.date)
            XCTAssertEqual(secondDateComponents.year!, 2020)
            XCTAssertEqual(secondDateComponents.month!, 1)
            XCTAssertEqual(secondDateComponents.day!, 2)

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

    func test_fetchPrompts_givenIgnoresYearIsTrue_convertsDateToCustomFormat() {
        let requestDate = dateFormatter.date(from: "2023-04-05")
        let customMockApi = MockWordPressComRestApi()
        service = BloggingPromptsServiceRemote(wordPressComRestApi: customMockApi)

        // no-op; we just need to check the passed params.
        service.fetchPrompts(for: siteID, number: 1, fromDate: requestDate, ignoresYear: true, completion: { _ in })

        XCTAssertNotNil(customMockApi.parametersPassedIn as? [String: AnyObject])
        let params = customMockApi.parametersPassedIn! as! [String: AnyObject]

        XCTAssertNotNil(params[.dateKey])
        XCTAssertEqual(params[.dateKey] as! String, "--04-05")
    }

    func test_fetchSettings_returnsRemoteSettings() {
        stubRemoteResponse(.bloggingPromptsEndpoint, filename: .mockFetchSettingsFilename, contentType: .ApplicationJSON)

        let expect = expectation(description: "Fetch blogging prompts settings succeeded")
        service.fetchSettings(for: siteID) { result in
            guard case .success(let settings) = result else {
                XCTFail("Expected success result type")
                return
            }

            XCTAssertTrue(settings.promptCardEnabled)
            XCTAssertTrue(settings.promptRemindersEnabled)

            // reminder days
            XCTAssertFalse(settings.reminderDays.monday)
            XCTAssertTrue(settings.reminderDays.tuesday)
            XCTAssertFalse(settings.reminderDays.wednesday)
            XCTAssertTrue(settings.reminderDays.thursday)
            XCTAssertFalse(settings.reminderDays.friday)
            XCTAssertTrue(settings.reminderDays.saturday)
            XCTAssertFalse(settings.reminderDays.sunday)

            XCTAssertEqual(settings.reminderTime, "14.30")
            XCTAssertEqual(settings.isPotentialBloggingSite, true)
            expect.fulfill()
        }

        wait(for: [expect], timeout: timeout)
    }

    func test_updateSettings_withUpdatedFields_returnsUpdatedSettings() {
        let updatedSettings = makeSettings()
        stubRemoteResponse(.bloggingPromptsEndpoint, filename: .mockUpdateSettingsReturningObjectFilename, contentType: .ApplicationJSON)

        let expect = expectation(description: "Update blogging prompts settings succeeded")
        service.updateSettings(for: siteID, with: updatedSettings) { result in
            guard case .success(let settings) = result else {
                XCTFail("Expected success result type")
                return
            }

            XCTAssertNotNil(settings)
            expect.fulfill()
        }

        wait(for: [expect], timeout: timeout)
    }

    func test_updateSettings_withNoUpdatedFields_returnsNil() {
        let updatedSettings = makeSettings()
        stubRemoteResponse(.bloggingPromptsEndpoint, filename: .mockUpdateSettingsReturningEmptyFilename, contentType: .ApplicationJSON)

        let expect = expectation(description: "Update blogging prompts settings succeeded")
        service.updateSettings(for: siteID, with: updatedSettings) { result in
            guard case .success(let settings) = result else {
                XCTFail("Expected success result type")
                return
            }

            XCTAssertNil(settings)
            expect.fulfill()
        }

        wait(for: [expect], timeout: timeout)
    }
}

// MARK: - Private Helpers

private extension BloggingPromptsServiceRemoteTests {

    func makeSettings() -> RemoteBloggingPromptsSettings {
        let reminderDays = RemoteBloggingPromptsSettings.ReminderDays(
            monday: true,
            tuesday: false,
            wednesday: true,
            thursday: false,
            friday: true,
            saturday: false,
            sunday: true
        )

        return .init(promptCardEnabled: false, promptRemindersEnabled: true, reminderDays: reminderDays, reminderTime: "12.59 UTC", isPotentialBloggingSite: true)
    }

}

private extension String {
    static let bloggingPromptsEndpoint = "sites/1/blogging-prompts"
    static let settingsEndpoint = "sites/1/blogging-prompts/settings"
    static let mockFileName = "blogging-prompts-success.json"
    static let mockFetchSettingsFilename = "blogging-prompts-settings-fetch-success.json"
    static let mockUpdateSettingsReturningObjectFilename = "blogging-prompts-settings-update-with-response.json"
    static let mockUpdateSettingsReturningEmptyFilename = "blogging-prompts-settings-update-empty-response.json"
    static let numberKey = "per_page"
    static let dateKey = "after"
}
