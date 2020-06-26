import Foundation
import XCTest
@testable import WordPressKit

class PluginStateTests: RemoteTestCase, RESTTestable {
    let siteID = 123
    
    var sitePluginsEndpoint: String {
        return "sites/\(siteID)/plugins"
    }
    
    var sitePlugins: [PluginState]!
    
    override func setUp() {
        super.setUp()
        
        let remote = PluginServiceRemote(wordPressComRestApi: getRestApi())
        let sitePluginsMockPath = Bundle(for: type(of: self)).path(forResource: "site-plugins-success", ofType: "json")!
        let json = JSONLoader().loadFile(sitePluginsMockPath) as AnyObject
        guard let response = json as? [String : AnyObject] else {
            return
        }
        sitePlugins = try! remote.pluginStates(response: response)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPluginStateEquatable() {
        let lhs = sitePlugins[0]
        let rhs = sitePlugins[7]
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testSiteDescriptionNotActiveNotAutoupdated() {
        
        let plugin = sitePlugins[0]
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.active, false)
        XCTAssertEqual(plugin.autoupdate, false)
        XCTAssertEqual(plugin.stateDescription, "Inactive, Autoupdates off")
        
    }
    
    func testSiteDescriptionNotActiveAutoupdated() {
        
        let plugin = sitePlugins[6]
        
        XCTAssertEqual(plugin.slug, "mailchimp-for-wp")
        XCTAssertEqual(plugin.active, false)
        XCTAssertEqual(plugin.autoupdate, true)
        XCTAssertEqual(plugin.stateDescription, "Inactive, Autoupdates on")
    }
    
    func testSiteDescriptionActiveNotAutoupdated() {
        let plugin = sitePlugins[3]
        
        XCTAssertEqual(plugin.slug, "jetpack-beta")
        XCTAssertEqual(plugin.active, true)
        XCTAssertEqual(plugin.autoupdate, false)
        XCTAssertEqual(plugin.stateDescription, "Active, Autoupdates off")
    }
    
    func testSiteDescriptionActiveAutoupdated() {
        let plugin = sitePlugins[5]
        
        XCTAssertEqual(plugin.slug, "buddypress")
        XCTAssertEqual(plugin.active, true)
        XCTAssertEqual(plugin.autoupdate, true)
        XCTAssertEqual(plugin.stateDescription, "Active, Autoupdates on")
    }
    
    func testPluginHomeURLEqualsPluginURL() {
        let plugin = sitePlugins[0]
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.homeURL, plugin.url)
        XCTAssertEqual(plugin.homeURL, URL(string: "https://akismet.com/"))
    }
    
    func testPluginDirectoryURL() {
        let plugin = sitePlugins[0]
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.directoryURL, URL(string: "https://wordpress.org/plugins/\(plugin.slug)"))
    }
    
    func testDeactivateAlowed() {
        let plugin = sitePlugins[0]
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.automanaged, false)
        XCTAssertEqual(plugin.deactivateAllowed, true)
    }
    
    func testDeactivateNotAlowed() {
        let plugin = sitePlugins[4]
        
        XCTAssertEqual(plugin.slug, "jetpack-dev")
        XCTAssertEqual(plugin.automanaged, false)
        XCTAssertEqual(plugin.deactivateAllowed, false)
    }
    
    func testUpdateStateEncodableDecodableReturnsCorrectly() {
        let plugin = sitePlugins[0]
        let updateState = plugin.updateState
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        let data = try! encoder.encode(updateState)
        let decoded = try! decoder.decode(PluginState.UpdateState.self, from: data)
        
        XCTAssertEqual(plugin.updateState, decoded)
    }
}
