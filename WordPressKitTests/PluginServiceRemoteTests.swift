import Foundation
import XCTest
@testable import WordPressKit

class PluginServiceRemoteTests: RemoteTestCase, RESTTestable {
    let siteID = 123
    let getPluginsSuccessMockFilename = "site-plugins-success.json"
    let getPluginsErrorMockFilename = "site-plugins-error.json"
    let getPluginsMalformedMockFile = "site-plugins-malformed.json"
    let getFeaturedPluginsMockFile = "plugin-service-remote-featured.json"
    let getFeaturedPluginsMalformedMockFile = "plugin-service-remote-featured-malformed.json"
    let getFeaturedPluginsInvalidResponse = "plugin-service-remote-featured-plugins-invalid.json"
    let getRemoteFeaturedPluginsEndpoint = "wpcom/v2/plugins/featured"
    let postRemotePluginUpdateJetpack = "plugin-update-jetpack-already-updated.json"
    let postRemotePluginUpdateGutenberg = "plugin-update-gutenberg-needs-update.json"
    let postRemotePluginUpdateAuthFailure = "plugin-service-remote-auth-failure.json"
    let postRemotePluginUpdateMalformed = "plugin-update-response-malformed.json"
    let postRemotePluginModifyActivate = "plugin-modify-activate.json"
    let postPluginInstallSucceeds = "plugin-install-succeeds.json"
    var sitePluginsEndpoint: String {
        return "sites/\(siteID)/plugins"
    }
    

    var remote: PluginServiceRemote!

    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()

        remote = PluginServiceRemote(wordPressComRestApi: getRestApi())
    }

    override func tearDown() {
        super.tearDown()

        remote = nil
    }

    // MARK: - Plugin Tests

    func testGetSitePluginsSucceeds() {
        let expect = expectation(description: "Get site plugins success")

        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            XCTAssertEqual(sitePlugins.plugins.count, 7)
            XCTAssertTrue(sitePlugins.capabilities.autoupdate)
            XCTAssertTrue(sitePlugins.capabilities.modify)
            expect.fulfill()
        }, failure: { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testGetSitePluginFails() {
        let expect = expectation(description: "Get site plugins fails")

        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsErrorMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (_)  in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { (error) in
            let error = error as NSError
            let expected = PluginServiceRemote.ResponseError.unauthorized as NSError
            XCTAssertEqual(error, expected)
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetSitePluginFailsMalformed() {
        let expect = expectation(description: "Get site plugins fails")

        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsMalformedMockFile,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (_)  in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }, failure: { (error) in
            let error = error as NSError
            let expected = WordPressComRestApiError.responseSerializationFailed as NSError
            XCTAssertEqual(error, expected)
            expect.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetFeaturedPluginSucceeds() {
        let expect = expectation(description: "Get Featured Plugins Succeeds")
        
        stubRemoteResponse(getRemoteFeaturedPluginsEndpoint,
                           filename: getFeaturedPluginsMockFile,
                           contentType: .ApplicationJSON)
        
        remote.getFeaturedPlugins(success: { (featuredPlugins) in
            XCTAssertEqual(featuredPlugins.count, 6)
            XCTAssertEqual(featuredPlugins[1].name, "Yoast SEO")
            XCTAssertEqual(featuredPlugins[3].slug, "tinymce-advanced")
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetFeaturedPluginFailsMalformedJSON() {
        let expect = expectation(description: "Get Featured Plugins Fails")
        
        stubRemoteResponse(getRemoteFeaturedPluginsEndpoint,
                           filename: getFeaturedPluginsMalformedMockFile,
                           contentType: .ApplicationJSON)
        
        remote.getFeaturedPlugins(success: { (featuredPlugins) in
            XCTFail("Callback should not get called")
            expect.fulfill()
        }) { (error) in
            let error = error as NSError
            let expected = WordPressComRestApiError.responseSerializationFailed as NSError
            XCTAssertEqual(error, expected)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetFeaturedPluginFailsInvalidResponse() {
        let expect = expectation(description: "Get Featured Plugins Fails")
        
        stubRemoteResponse(getRemoteFeaturedPluginsEndpoint,
                           filename: getFeaturedPluginsInvalidResponse,
                           contentType: .ApplicationJSON)
        
        remote.getFeaturedPlugins(success: { (featuredPlugins) in
            XCTFail("Callback should not get called")
            expect.fulfill()
        }) { (error) in
            let error = error as NSError
            let expected = PluginServiceRemote.ResponseError.decodingFailure as NSError
            XCTAssertEqual(error, expected)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testGetFeaturedPluginFailsIncorrectResponse() {
        let expect = expectation(description: "Get Featured Plugins Fails")
        
        stubRemoteResponse(getRemoteFeaturedPluginsEndpoint,
                           filename: getPluginsErrorMockFilename,
                           contentType: .ApplicationJSON)
        
        remote.getFeaturedPlugins(success: { (featuredPlugins) in
            XCTFail("Callback should not get called")
            expect.fulfill()
        }) { (error) in
            let error = error as NSError
            let expected = PluginServiceRemote.ResponseError.decodingFailure as NSError
            XCTAssertEqual(error, expected)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testPluginIDEncoding() {
        let pluginID = "jetpack/jetpack"
        let encoded = remote.encoded(pluginID: pluginID)
        
        let escapedPluginID = "jetpack%2Fjetpack"
        
        XCTAssertEqual(encoded, escapedPluginID)
    }
    
    func testUpdatePluginUpToDate() {
        let expect = expectation(description: "Plugin is already up to date")
        
        preparePostStubRemoteResponseWith(plugID: "jetpack/jetpack",
                                      pluginSlug: "jetpack",
                                      endpointAction: .update,
                                      responseFile: postRemotePluginUpdateJetpack)
        
        remote.updatePlugin(pluginID: "jetpack/jetpack", siteID: siteID, success: { (pluginState) in
            XCTAssertEqual(pluginState.slug, "jetpack")
            XCTAssertEqual(pluginState.name, "Jetpack by WordPress.com")
            XCTAssertEqual(pluginState.version, "8.6.1")
            XCTAssertEqual(pluginState.autoupdate, false)
            XCTAssertEqual(pluginState.updateState, PluginState.UpdateState.updated)
            
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testUpdatePluginNeedsUpdate() {
        let expect = expectation(description: "Plugin is updated successfully")
        
        preparePostStubRemoteResponseWith(plugID: "gutenberg/gutenberg",
                                      pluginSlug: "gutenberg",
                                      endpointAction: .update,
                                      responseFile: postRemotePluginUpdateGutenberg)
        
        remote.updatePlugin(pluginID: "gutenberg/gutenberg", siteID: siteID, success: { (pluginState) in
            XCTAssertEqual(pluginState.slug, "gutenberg")
            XCTAssertEqual(pluginState.name, "Gutenberg")
            XCTAssertEqual(pluginState.version, "7.2.1")
            XCTAssertEqual(pluginState.autoupdate, false)
            XCTAssertEqual(pluginState.updateState, PluginState.UpdateState.available("8.3.0"))
            
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testUpdatePluginAuthFails() {
        let expect = expectation(description: "Plugin is updated successfully")
        
        preparePostStubRemoteResponseWith(plugID: "gutenberg/gutenberg",
                                      pluginSlug: "gutenberg",
                                      endpointAction: .update,
                                      responseFile: postRemotePluginUpdateAuthFailure)
        
        remote.updatePlugin(pluginID: "gutenberg/gutenberg", siteID: siteID, success: { (pluginState) in
            XCTFail("This callback should not be called")
            expect.fulfill()
        }) { (error) in
            let error = error as NSError
            let expected = PluginServiceRemote.ResponseError.unauthorized as NSError
            
            XCTAssertEqual(error, expected)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testUpdatePluginFailsMalformedJSON() {
        let expect = expectation(description: "Plugin is updated successfully")
        
        preparePostStubRemoteResponseWith(plugID: "gutenberg/gutenberg",
                                      pluginSlug: "gutenberg",
                                      endpointAction: .update,
                                      responseFile: postRemotePluginUpdateMalformed)
        
        remote.updatePlugin(pluginID: "gutenberg/gutenberg", siteID: siteID, success: { (pluginState) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }) { (error) in
            let error = error as NSError
            let expected = WordPressComRestApiError.responseSerializationFailed as NSError
            XCTAssertEqual(error, expected)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testInstallPluginSucceeds() {
        let expect = expectation(description: "Plugin install succeeds")
        preparePostStubRemoteResponseWith(plugID: "code-snippets/code-snippets",
                                      pluginSlug: "code-snippets",
                                      endpointAction: .install,
                                      responseFile: postPluginInstallSucceeds)
        
        
        remote.install(pluginSlug: "code-snippets",siteID: siteID, success: { (pluginState) in
            XCTAssertEqual(pluginState.slug, "code-snippets")
            XCTAssertEqual(pluginState.name, "Code Snippets")
            XCTAssertEqual(pluginState.version, "2.14.0")
            XCTAssertEqual(pluginState.autoupdate, false)
            
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    
}

extension PluginServiceRemoteTests {
    enum EndpointAction: String {
        case update = "update"
        case install = "install"
        case remove = "delete"
        case none = ""
    }
    
    func preparePostStubRemoteResponseWith(plugID: String, pluginSlug: String, endpointAction: EndpointAction, responseFile: String) {
        guard let escapedPluginID = remote.encoded(pluginID: plugID) else {
            return
        }
        var pluginEndpoint = ""
        
        switch endpointAction {
        case .install:
            pluginEndpoint = sitePluginsEndpoint + "/\(pluginSlug)" + "/\(endpointAction.rawValue)"
        default:
            pluginEndpoint = sitePluginsEndpoint + "/\(escapedPluginID)" + "/\(endpointAction.rawValue)"
        }

        stubRemoteResponse(pluginEndpoint,
                           filename: responseFile,
                           contentType: .ApplicationJSON)
    }
}
