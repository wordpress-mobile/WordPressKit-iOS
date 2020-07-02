@testable import WordPressKit

class MockPluginState {
    static let akismetPlugin = PluginState(id: "akismet/akismet",
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
    
    static let jetpackBetaPlugin = PluginState(id: "jetpack-beta/jetpack-beta",
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
    
    static let mailchimpPlugin = PluginState(id: "mailchimp-for-wp/mailchimp-for-wp",
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
    
    static let buddypressPlugin = PluginState(id: "buddypress/bp-loader",
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
    
    static let jetpackDevPlugin = PluginState(id: "jetpack-dev/jetpack",
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
    
    static let updateStateJSON = Data("""
    {
    "update": {
            "new_version": "4.0"
        }
    }
    """.utf8)
}
