import Foundation
import XCTest
@testable import WordPressKit

class SitePluginTests: RemoteTestCase, RESTTestable {
    let siteID = 123
    
    var sitePluginsEndpoint: String {
        return "sites/\(siteID)/plugins"
    }
    
    var sitePluginCapabilitiesA: SitePluginCapabilities!
    
    override func setUp() {
        super.setUp()
        
        let remote = PluginServiceRemote(wordPressComRestApi: getRestApi())
        let sitePluginsMockPath = Bundle(for: type(of: self)).path(forResource: "site-plugins-success", ofType: "json")!
        let json = JSONLoader().loadFile(sitePluginsMockPath) as AnyObject
        guard let response = json as? [String : AnyObject] else {
            return
        }
        sitePluginCapabilitiesA = try! remote.pluginCapabilities(response: response)
        sitePluginCapabilitiesA = try! remote.pluginCapabilities(response: response)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSitePluginCapabilitiesEquatableSucceeds() {
        let sitePluginCapabilitiesB = SitePluginCapabilities(modify: true, autoupdate: true)
        
        XCTAssertEqual(sitePluginCapabilitiesA, sitePluginCapabilitiesB)
    }
    
    func testSitePluginCapabilitiesFails() {
        let sitePluginCapabilitiesB = SitePluginCapabilities(modify: false, autoupdate: false)
        
        XCTAssertNotEqual(sitePluginCapabilitiesA, sitePluginCapabilitiesB)
    }
}
