import Foundation
import XCTest
@testable import WordPressKit


class PluginStateTests: XCTestCase {
    
    func testPluginStateEquatable() {
        
        let lhs = MockPluginStateProvider.getPluginState()
        let rhs = MockPluginStateProvider.getPluginState()
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testSiteDescriptionNotActiveNotAutoupdated() {
        let plugin = MockPluginStateProvider.getPluginState(setToActive:false, autoupdate:false)
        
        let expected = "Inactive, Autoupdates off"
        
        XCTAssertEqual(plugin.active, false)
        XCTAssertEqual(plugin.autoupdate, false)
        XCTAssertEqual(plugin.stateDescription, expected)
        
    }
    
    func testSiteDescriptionNotActiveAutoupdated() {
        let plugin = MockPluginStateProvider.getPluginState(setToActive: false, autoupdate: true)
        
        let expected = "Inactive, Autoupdates on"
        
        XCTAssertEqual(plugin.active, false)
        XCTAssertEqual(plugin.autoupdate, true)
        XCTAssertEqual(plugin.stateDescription, expected)
    }
    
    func testSiteDescriptionActiveNotAutoupdated() {
        let plugin = MockPluginStateProvider.getPluginState(setToActive:true, autoupdate: false)
        
        let expected = "Active, Autoupdates off"
        
        XCTAssertEqual(plugin.active, true)
        XCTAssertEqual(plugin.autoupdate, false)
        XCTAssertEqual(plugin.stateDescription, expected)
    }
    
    func testSiteDescriptionActiveAutoupdated() {
        let plugin = MockPluginStateProvider.getPluginState(setToActive:true, autoupdate: true)
        
        let expected = "Active, Autoupdates on"
        
        XCTAssertEqual(plugin.active, true)
        XCTAssertEqual(plugin.autoupdate, true)
        XCTAssertEqual(plugin.stateDescription, expected)
    }
    
    func testPluginHomeURLEqualsPluginURL() {
        let plugin = MockPluginStateProvider.getPluginState()
        
        let expected = URL(string: "https://akismet.com/")
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.homeURL, plugin.url)
        XCTAssertEqual(plugin.homeURL, expected)
    }
    
    func testPluginDirectoryURL() {
        let plugin = MockPluginStateProvider.getPluginState()
        
        let expected = URL(string: "https://wordpress.org/plugins/\(plugin.slug)")
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.directoryURL, expected)
    }
    
    func testDeactivateAlowed() {
        let plugin = MockPluginStateProvider.getPluginState()
        
        let expected = true
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.automanaged, false)
        XCTAssertEqual(plugin.deactivateAllowed, expected)
    }
    
    func testDeactivateNotAlowed() {
        let plugin = MockPluginStateProvider.getNotDisableablePlugin()
        
        let expected = false
        
        XCTAssertEqual(plugin.slug, "jetpack-dev")
        XCTAssertEqual(plugin.automanaged, false)
        XCTAssertEqual(plugin.deactivateAllowed, expected)
    }
    
    func testUpdateStateEncodeDoesNotThrow() {
        let updateState = PluginState.UpdateState.updated
        let encoder = JSONEncoder()
        
        do {
            XCTAssertNoThrow(try encoder.encode(updateState), "encode did not throw an error")
            let data = try encoder.encode(updateState)
        } catch {
            XCTFail("Ecode Threw an Error")
        }
    }
    
    func testUpdateStateDecodeSucceeds() {
        let data = MockPluginStateProvider.getEncodedUpdateState(state: PluginState.UpdateState.available("4.0"))
        
        let decoder = JSONDecoder()
        do {
            XCTAssertNoThrow(try decoder.decode(PluginState.UpdateState.self, from: data), "Decode from JSON successful")
            let decoded = try decoder.decode(PluginState.UpdateState.self, from: data)
            
            XCTAssertEqual(decoded, PluginState.UpdateState.available("4.0"))
        } catch {
            XCTFail("Could not decode")
        }
    }
}
