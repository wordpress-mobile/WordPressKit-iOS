import XCTest
@testable import WordPressKit

class BlockEditorSettingsServiceRemoteTests: XCTestCase {
    private let blockSettingsNOTThemeJSONResponseFilename = "wp-block-editor-v1-settings-success-NotThemeJSON"
    private let blockSettingsThemeJSONResponseFilename = "wp-block-editor-v1-settings-success-ThemeJSON"
    private let twentytwentyoneResponseFilename = "get_wp_v2_themes_twentytwentyone"
    private let testError = NSError(domain: "tests", code: 0, userInfo: nil)
    private let siteID = 1

    private var service: BlockEditorSettingsServiceRemote!
    var mockRemoteApi: MockWordPressComRestApi!

    override func setUp() {
        mockRemoteApi = MockWordPressComRestApi()
        service = BlockEditorSettingsServiceRemote(remoteAPI: mockRemoteApi)
    }

    func mockedData(withFilename filename: String) -> AnyObject {
        let json = Bundle(for: BlockEditorSettingsServiceRemoteTests.self).url(forResource: filename, withExtension: "json")!
        let data = try! Data(contentsOf: json)
        return try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
    }
}

// MARK: Editor `theme_supports` support
extension BlockEditorSettingsServiceRemoteTests {

    func testFetchThemeSuccess() {
        let waitExpectation = expectation(description: "Theme should be successfully fetched")
        let mockedResponse = mockedData(withFilename: twentytwentyoneResponseFilename)
        service.fetchTheme(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                XCTAssertGreaterThan(result!.themeSupport!.colors!.count, 0)
                XCTAssertGreaterThan(result!.themeSupport!.gradients!.count, 0)
                XCTAssertTrue(result!.themeSupport!.blockTemplates)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateEditorThemeRequest()
    }

    func testFetchThemeNoGradients() {
        let waitExpectation = expectation(description: "Theme should be successfully fetched")
        var mockedResponse = mockedData(withFilename: twentytwentyoneResponseFilename) as! [[String: Any]]

        // Clear out Gradients
        var theme = mockedResponse[0]
        var themeSupport = theme[RemoteEditorTheme.CodingKeys.themeSupport.stringValue] as! [String: Any]
        themeSupport[RemoteEditorThemeSupport.CodingKeys.gradients.stringValue] = "false"
        theme[RemoteEditorTheme.CodingKeys.themeSupport.stringValue] = themeSupport
        mockedResponse[0] = theme

        service.fetchTheme(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                XCTAssertGreaterThan(result!.themeSupport!.colors!.count, 0)
                XCTAssertNil(result!.themeSupport!.gradients)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateEditorThemeRequest()
    }

    func testFetchThemeNoColors() {
        let waitExpectation = expectation(description: "Theme should be successfully fetched")
        var mockedResponse = mockedData(withFilename: twentytwentyoneResponseFilename) as! [[String: Any]]

        // Clear out Colors
        var theme = mockedResponse[0]
        var themeSupport = theme[RemoteEditorTheme.CodingKeys.themeSupport.stringValue] as! [String: Any]
        themeSupport[RemoteEditorThemeSupport.CodingKeys.colors.stringValue] = "false"

        themeSupport[RemoteEditorThemeSupport.CodingKeys.blockTemplates.stringValue] = "false"
        theme[RemoteEditorTheme.CodingKeys.themeSupport.stringValue] = themeSupport

        mockedResponse[0] = theme

        service.fetchTheme(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                XCTAssertNil(result!.themeSupport!.colors)
                XCTAssertGreaterThan(result!.themeSupport!.gradients!.count, 0)
                XCTAssertFalse(result!.themeSupport!.blockTemplates)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateEditorThemeRequest()
    }

    func testFetchThemeNoThemeSupport() {
        let waitExpectation = expectation(description: "Theme should be successfully fetched")
        var mockedResponse = mockedData(withFilename: twentytwentyoneResponseFilename) as! [[String: Any]]
        var theme = mockedResponse[0]
        var themeSupport = theme[RemoteEditorTheme.CodingKeys.themeSupport.stringValue] as! [String: Any]

        themeSupport.removeValue(forKey: RemoteEditorThemeSupport.CodingKeys.blockTemplates.stringValue)
        theme[RemoteEditorTheme.CodingKeys.themeSupport.stringValue] = themeSupport
        mockedResponse[0] = theme

        service.fetchTheme(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                XCTAssertFalse(result!.themeSupport!.blockTemplates)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateEditorThemeRequest()
    }

    func testFetchThemeFailure() {
        let waitExpectation = expectation(description: "Theme should be successfully fetched")
        service.fetchTheme(forSiteID: siteID) { (response) in
            switch response {
            case .success:
                XCTFail("This Request should have failed")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.failureBlockPassedIn!(testError, nil)
        waitForExpectations(timeout: 0.1)
        validateEditorThemeRequest()
    }

    private func validateEditorThemeRequest() {
        XCTAssertTrue(self.mockRemoteApi.getMethodCalled)
        XCTAssertEqual(self.mockRemoteApi.URLStringPassedIn!, "/wp/v2/sites/1/themes")
        XCTAssertEqual((self.mockRemoteApi.parametersPassedIn as! [String: String])["status"], "active")
    }
}

// MARK: Editor Global Styles support
extension BlockEditorSettingsServiceRemoteTests {

    func testFetchBlockEditorSettingsNotThemeJSON() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        let mockedResponse = mockedData(withFilename: blockSettingsNOTThemeJSONResponseFilename)
        service.fetchBlockEditorSettings(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                self.validateFetchBlockEditorSettingsResults(result)
                XCTAssertNil(result!.rawStyles)
                XCTAssertFalse(result!.isFSETheme)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsThemeJSON() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        let mockedResponse = mockedData(withFilename: blockSettingsThemeJSONResponseFilename)

        service.fetchBlockEditorSettings(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                self.validateFetchBlockEditorSettingsResults(result)

                XCTAssertNotNil(result!.rawStyles)
                XCTAssertTrue(result!.isFSETheme)
                let gssRawJson = result!.rawStyles!.data(using: .utf8)!
                let vaildJson = try? JSONSerialization.jsonObject(with: gssRawJson, options: [])
                XCTAssertNotNil(vaildJson)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsNoFSETheme() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        var mockedResponse = mockedData(withFilename: blockSettingsThemeJSONResponseFilename) as! [String: Any]
        mockedResponse.removeValue(forKey: RemoteBlockEditorSettings.CodingKeys.isFSETheme.stringValue)

        service.fetchBlockEditorSettings(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                self.validateFetchBlockEditorSettingsResults(result)
                XCTAssertFalse(result!.isFSETheme)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsThemeJSON_ConsistentChecksum() {
        let json = Bundle(for: BlockEditorSettingsServiceRemoteTests.self).url(forResource: blockSettingsThemeJSONResponseFilename, withExtension: "json")!
        let data = try! Data(contentsOf: json)

        let blockEditorSettings1 = try? JSONDecoder().decode(RemoteBlockEditorSettings.self, from: data)
        let blockEditorSettings2 = try? JSONDecoder().decode(RemoteBlockEditorSettings.self, from: data)
        XCTAssertEqual(blockEditorSettings1!.checksum, blockEditorSettings2!.checksum)
    }

    func testFetchBlockEditorSettingsFailure() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        service.fetchBlockEditorSettings(forSiteID: siteID) { (response) in
            switch response {
            case .success:
                XCTFail("This Request should have failed")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.failureBlockPassedIn!(testError, nil)
        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsOrgEndpoint() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        let mockedResponse = mockedData(withFilename: blockSettingsThemeJSONResponseFilename)
        let mockOrgRemoteApi = MockWordPressOrgRestApi()
        service = BlockEditorSettingsServiceRemote(remoteAPI: mockOrgRemoteApi)

        service.fetchBlockEditorSettings(forSiteID: siteID) { (_) in
            waitExpectation.fulfill()
        }
        mockOrgRemoteApi.completionPassedIn!(.success(mockedResponse), HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        XCTAssertTrue(mockOrgRemoteApi.getMethodCalled)
        XCTAssertEqual(mockOrgRemoteApi.URLStringPassedIn!, "/wp-block-editor/v1/settings")
        XCTAssertEqual((mockOrgRemoteApi.parametersPassedIn as! [String: String])["context"], "mobile")
    }

    private func validateFetchBlockEditorSettingsRequest() {
        XCTAssertTrue(self.mockRemoteApi.getMethodCalled)
        XCTAssertEqual(self.mockRemoteApi.URLStringPassedIn!, "/wp-block-editor/v1/sites/1/settings")
        XCTAssertEqual((self.mockRemoteApi.parametersPassedIn as! [String: String])["context"], "mobile")
    }

    private func validateFetchBlockEditorSettingsResults(_ result: RemoteBlockEditorSettings?) {
        XCTAssertNotNil(result)
        XCTAssertFalse(result!.checksum.isEmpty)

        XCTAssertGreaterThan(result!.colors!.count, 0)
        XCTAssertGreaterThan(result!.gradients!.count, 0)

        XCTAssertNotNil(result!.rawFeatures)
        let themeRawJson = result!.rawFeatures!.data(using: .utf8)!
        let vaildJson = try? JSONSerialization.jsonObject(with: themeRawJson, options: [])
        XCTAssertNotNil(vaildJson)
    }
}
