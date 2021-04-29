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
        theme[RemoteEditorTheme.CodingKeys.themeSupport.stringValue] = themeSupport
        mockedResponse[0] = theme

        service.fetchTheme(forSiteID: siteID) { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                XCTAssertNil(result!.themeSupport!.colors)
                XCTAssertGreaterThan(result!.themeSupport!.gradients!.count, 0)
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
        service.fetchBlockEditorSettings { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                XCTAssertGreaterThan(result!.colors!.count, 0)
                XCTAssertGreaterThan(result!.gradients!.count, 0)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsNotThemeJSON_NoColors() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        var mockedResponse = mockedData(withFilename: blockSettingsNOTThemeJSONResponseFilename) as! [String : Any]
        // Clear out Colors
        mockedResponse[RemoteBlockEditorSettings.CodingKeys.colors.stringValue] = "false"

        service.fetchBlockEditorSettings { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                XCTAssertNil(result!.colors)
                XCTAssertGreaterThan(result!.gradients!.count, 0)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsNotThemeJSON_NoGradients() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        var mockedResponse = mockedData(withFilename: blockSettingsNOTThemeJSONResponseFilename) as! [String : Any]
        // Clear out Gradients
        mockedResponse[RemoteBlockEditorSettings.CodingKeys.gradients.stringValue] = "false"

        service.fetchBlockEditorSettings { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                XCTAssertGreaterThan(result!.colors!.count, 0)
                XCTAssertNil(result!.gradients)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsThemeJSON() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        let mockedResponse = mockedData(withFilename: blockSettingsThemeJSONResponseFilename)

        service.fetchBlockEditorSettings { (response) in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result)
                XCTAssertFalse(result!.checksum.isEmpty)
                // ToDo: Enable when data is updated with GSS Samples
//                XCTAssertGreaterThan(result!.globalStylesBaseStyles!.colorSettings.colors!.count, 0)
//                XCTAssertGreaterThan(result!.globalStylesBaseStyles!.colorSettings.gradients!.count, 0)
            case .failure:
                XCTFail("This payload should parse successfully")
            }
            waitExpectation.fulfill()
        }
        mockRemoteApi.successBlockPassedIn!(mockedResponse as AnyObject, HTTPURLResponse())

        waitForExpectations(timeout: 0.1)
        validateFetchBlockEditorSettingsRequest()
    }

    func testFetchBlockEditorSettingsFailure() {
        let waitExpectation = expectation(description: "Block Settings should be successfully fetched")
        service.fetchBlockEditorSettings { (response) in
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

    private func validateFetchBlockEditorSettingsRequest() {
        XCTAssertTrue(self.mockRemoteApi.getMethodCalled)
        XCTAssertEqual(self.mockRemoteApi.URLStringPassedIn!, "/__experimental/wp-block-editor/v1/settings")
        XCTAssertEqual((self.mockRemoteApi.parametersPassedIn as! [String: String])["context"], "site-editor")
    }
}

