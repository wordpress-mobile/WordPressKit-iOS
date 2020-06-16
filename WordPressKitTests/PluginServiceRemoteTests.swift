import Foundation
import XCTest
import WordPressKit

class PluginServiceRemoteTests: RemoteTestCase, RESTTestable {
    let siteID = 123
    let getPluginsSuccessMockFilename = "site-plugins-success.json"
    let getPluginsErrorMockFilename = "site-plugins-error.json"
    let getFeaturedPluginsMockFile = "plugin-service-remote-featured.json"
    let getRemoteFeaturedPluginsEndpoint = "wpcom/v2/plugins/featured"
    let postRemotePluginUpdateJetpack = "plugin-update-jetpack-already-updated.json"
    let postRemotePluginUpdateGutenberg = "plugin-update-gutenberg-needs-update.json"
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
            XCTAssertEqual(sitePlugins.plugins.count, 5)
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
    
    func testPluginIDEncoding() {
        
    }
    
    func testUpdatePluginPluginUpToDate() {
        let escapedPluginID = "/jetpack%2Fjetpack"
        let updatePluginJetpackEndpoint = sitePluginsEndpoint + escapedPluginID + "/update"
        let expect = expectation(description: "Plugin is already up to date")
        
        stubRemoteResponse(updatePluginJetpackEndpoint,
                           filename: postRemotePluginUpdateJetpack,
                           contentType: .ApplicationJSON)
        
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
        let escapedPluginID = "/gutenberg%2Fgutenberg"
        let updatePluginGutenbergEndpoint = sitePluginsEndpoint + escapedPluginID + "/update"
        let expect = expectation(description: "Plugin is updated successfully")
        
        stubRemoteResponse(updatePluginGutenbergEndpoint,
                           filename: postRemotePluginUpdateGutenberg,
                           contentType: .ApplicationJSON)
        
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
    
    
}
