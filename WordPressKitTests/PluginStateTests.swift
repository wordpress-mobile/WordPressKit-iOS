import Foundation
import XCTest
@testable import WordPressKit

class PluginStateTests: XCTest {
    
    func testPluginStateEquatable() {
        
        let lhs = akismetPlugin
        let rhs = akismetPlugin
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testSiteDescriptionNotActiveNotAutoupdated() {
        let plugin = akismetPlugin
        
        let expected = "Inactive, Autoupdates off"
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.active, false)
        XCTAssertEqual(plugin.autoupdate, false)
        XCTAssertEqual(plugin.stateDescription, expected)
        
    }
    
    func testSiteDescriptionNotActiveAutoupdated() {
        let plugin = mailchimpPlugin
        
        let expected = "Inactive, Autoupdates on"
        
        XCTAssertEqual(plugin.slug, "mailchimp-for-wp")
        XCTAssertEqual(plugin.active, false)
        XCTAssertEqual(plugin.autoupdate, true)
        XCTAssertEqual(plugin.stateDescription, expected)
    }
    
    func testSiteDescriptionActiveNotAutoupdated() {
        let plugin = jetpackBetaPlugin
        
        let expected = "Active, Autoupdates off"
        
        XCTAssertEqual(plugin.slug, "jetpack-beta")
        XCTAssertEqual(plugin.active, true)
        XCTAssertEqual(plugin.autoupdate, false)
        XCTAssertEqual(plugin.stateDescription, expected)
    }
    
    func testSiteDescriptionActiveAutoupdated() {
        let plugin = buddypressPlugin
        
        let expected = "Active, Autoupdates on"
        
        XCTAssertEqual(plugin.slug, "buddypress")
        XCTAssertEqual(plugin.active, true)
        XCTAssertEqual(plugin.autoupdate, true)
        XCTAssertEqual(plugin.stateDescription, expected)
    }
    
    func testPluginHomeURLEqualsPluginURL() {
        let plugin = akismetPlugin
        
        let expected = URL(string: "https://akismet.com/")
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.homeURL, plugin.url)
        XCTAssertEqual(plugin.homeURL, expected)
    }
    
    func testPluginDirectoryURL() {
        let plugin = akismetPlugin
        
        let expected = URL(string: "https://wordpress.org/plugins/\(plugin.slug)")
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.directoryURL, expected)
    }
    
    func testDeactivateAlowed() {
        let plugin = akismetPlugin
        
        let expected = true
        
        XCTAssertEqual(plugin.slug, "akismet")
        XCTAssertEqual(plugin.automanaged, false)
        XCTAssertEqual(plugin.deactivateAllowed, expected)
    }
    
    func testDeactivateNotAlowed() {
        let plugin = jetpackDevPlugin
        
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
        let data = updateStateJSON
        
        let decoder = JSONDecoder()
        do {
            XCTAssertNoThrow(try decoder.decode(PluginState.UpdateState.self, from: data), "Decode from JSON successful")
            let decoder = try decoder.decode(PluginState.UpdateState.self, from: data)
        } catch {
            XCTFail("Could not decode")
        }
    }
}

private let akismetPlugin = PluginState(id: "akismet/akismet",
                                        slug: "akismet",
                                        active: false,
                                        name: "Akismet Anti-Spam",
                                        author: "Automattic",
                                        version: "3.3.4",
                                        updateState: PluginState.UpdateState.updated,
                                        autoupdate: false,
                                        automanaged: false,
                                        url: URL(string: "https://akismet.com/"),
                                        settingsURL: nil
)

private let jetpackBetaPlugin = PluginState(id: "jetpack-beta/jetpack-beta",
                                            slug: "jetpack-beta",
                                            active: true,
                                            name: "Jetpack Beta Tester",
                                            author: "Automattic",
                                            version: "2.0.3",
                                            updateState: PluginState.UpdateState.updated,
                                            autoupdate: false,
                                            automanaged: false,
                                            url: URL(string: "https://jetpack.com/"),
                                            settingsURL: URL(string: "https://example.com/wp-admin/admin.php?page=jetpack-beta")
)

private let mailchimpPlugin = PluginState(id: "mailchimp-for-wp/mailchimp-for-wp",
                                          slug: "mailchimp-for-wp",
                                          active: false,
                                          name: "MC4WP: Mailchimp for WordPress",
                                          author: "ibericode",
                                          version: "4.7.8",
                                          updateState: PluginState.UpdateState.updated,
                                          autoupdate: true,
                                          automanaged: false,
                                          url: URL(string: "https://ibericode.com"),
                                          settingsURL: nil
)

private let buddypressPlugin = PluginState(id: "buddypress/bp-loader",
                                           slug: "buddypress",
                                           active: true,
                                           name: "BuddyPress",
                                           author: "The BuddyPress Community",
                                           version: "6.0.0",
                                           updateState: PluginState.UpdateState.updated,
                                           autoupdate: true,
                                           automanaged: false,
                                           url: URL(string: "https://buddypress.org"),
                                           settingsURL: nil
)

private let jetpackDevPlugin = PluginState(id: "jetpack-dev/jetpack",
                                           slug: "jetpack-dev",
                                           active: true,
                                           name: "Jetpack by WordPress.com",
                                           author: "Automattic",
                                           version: "5.4",
                                           updateState: PluginState.UpdateState.updated,
                                           autoupdate: false,
                                           automanaged: false,
                                           url: URL(string: "https://jetpack.com/"),
                                           settingsURL: URL(string: "https://example.com/wp-admin/admin.php?page=jetpack#/settings")
)

private let updateStateJSON = Data("""
    {
    "update": {
            "new_version": "4.0"
        }
    }
    """.utf8)
