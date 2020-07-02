@testable import WordPressKit

struct MockPluginStateProvider {
    static func getPluginState(setToActive active: Bool = false, autoupdate: Bool = false) -> PluginState {
        let akismetPlugin = PluginState(id: "akismet/akismet",
                                        slug: "akismet",
                                        active: active,
                                        name: "Akismet Anti-Spam",
                                        author: "Automattic",
                                        version: "3.3.4",
                                        updateState: PluginState.UpdateState.updated,
                                        autoupdate: autoupdate,
                                        automanaged: false,
                                        url: URL(string: "https://akismet.com/"),
                                        settingsURL: nil
        )
        
        return akismetPlugin
    }
    
    static func getNotDisableablePlugin() -> PluginState{
        
        let jetpackDevPlugin = PluginState(id: "jetpack-dev/jetpack",
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
        
        return jetpackDevPlugin
    }
    
    
    static func getUpdateStateJSON() -> Data {
        let updateStateJSON = Data("""
    {
    "update": {
            "new_version": "4.0"
        }
    }
    """.utf8)
        
        return updateStateJSON
    }
    
    static func getEncodedUpdateState(state: PluginState.UpdateState) -> Data {
        var data = Data()
        let encoder = JSONEncoder()
        
        do {
            data = try encoder.encode(state)
        } catch {
            print(error)
        }
        
        return data
    }
}
