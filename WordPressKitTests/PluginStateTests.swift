import Foundation
import XCTest
import WordPressKit

class PluginStateTests: RemoteTestCase, RESTTestable {
    let siteID = 123
    let getPluginsSuccessMockFilename = "site-plugins-success.json"
    
    var sitePluginsEndpoint: String {
        return "sites/\(siteID)/plugins"
    }
    
    var sitePlugins: SitePlugins!
    var remote: PluginServiceRemote!
    
    
    override func setUp() {
        super.setUp()
        
        remote = PluginServiceRemote(wordPressComRestApi: getRestApi())
        //        stubRemoteResponse(sitePluginsEndpoint,
        //                       filename: getPluginsSuccessMockFilename,
        //                       contentType: .ApplicationJSON)
        //        remote.getPlugins(siteID: siteID, success: { (plugins) in
        //            self.sitePlugins = plugins
        //        }) { (error) in
        //            print(error)
        //        }
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        remote = nil
    }
    
    func testPluginStateEquatable() {
        let expect = expectation(description: "Site Description correct")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let lhs = sitePlugins.plugins[0]
            let rhs = sitePlugins.plugins[0]
            
            XCTAssertEqual(lhs, rhs)
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSiteDescriptionNotActiveNotAutoupdated() {
        let expect = expectation(description: "Site Description correct")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[0]
            
            XCTAssertEqual(plugin.slug, "akismet")
            XCTAssertEqual(plugin.active, false)
            XCTAssertEqual(plugin.autoupdate, false)
            XCTAssertEqual(plugin.stateDescription, "Inactive, Autoupdates off")
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testSiteDescriptionNotActiveAutoupdated() {
        let expect = expectation(description: "Site Description correct")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[6]
            
            XCTAssertEqual(plugin.slug, "mailchimp-for-wp")
            XCTAssertEqual(plugin.active, false)
            XCTAssertEqual(plugin.autoupdate, true)
            XCTAssertEqual(plugin.stateDescription, "Inactive, Autoupdates on")
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSiteDescriptionActiveNotAutoupdated() {
        let expect = expectation(description: "Site Description correct")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[3]
            
            XCTAssertEqual(plugin.slug, "jetpack-beta")
            XCTAssertEqual(plugin.active, true)
            XCTAssertEqual(plugin.autoupdate, false)
            XCTAssertEqual(plugin.stateDescription, "Active, Autoupdates off")
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSiteDescriptionActiveAutoupdated() {
        let expect = expectation(description: "Site Description correct")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[5]
            
            XCTAssertEqual(plugin.slug, "buddypress")
            XCTAssertEqual(plugin.active, true)
            XCTAssertEqual(plugin.autoupdate, true)
            XCTAssertEqual(plugin.stateDescription, "Active, Autoupdates on")
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
    }
    
    func testPluginHomeURLEqualsPluginURL() {
        let expect = expectation(description: "Get plugin Home URL success")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[0]
            
            XCTAssertEqual(plugin.slug, "akismet")
            XCTAssertEqual(plugin.homeURL, plugin.url)
            XCTAssertEqual(plugin.homeURL, URL(string: "https://akismet.com/"))
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testPluginDirectoryURL() {
        let expect = expectation(description: "Get plugin directory URL success")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[0]
            
            XCTAssertEqual(plugin.slug, "akismet")
            XCTAssertEqual(plugin.directoryURL, URL(string: "https://wordpress.org/plugins/\(plugin.slug)"))
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDeactivateAlowed() {
        let expect = expectation(description: "deactivate is allowed")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[0]
            
            XCTAssertEqual(plugin.slug, "akismet")
            XCTAssertEqual(plugin.automanaged, false)
            XCTAssertEqual(plugin.deactivateAllowed, true)
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDeactivateNotAlowed() {
        let expect = expectation(description: "deactivate is not allowed")
        
        stubRemoteResponse(sitePluginsEndpoint,
                           filename: getPluginsSuccessMockFilename,
                           contentType: .ApplicationJSON)
        remote.getPlugins(siteID: siteID, success: { (sitePlugins) in
            let plugin = sitePlugins.plugins[4]
            
            XCTAssertEqual(plugin.slug, "jetpack-dev")
            XCTAssertEqual(plugin.automanaged, false)
            XCTAssertEqual(plugin.deactivateAllowed, false)
            expect.fulfill()
        }) { (error) in
            XCTFail("This callback shouldn't get called")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
