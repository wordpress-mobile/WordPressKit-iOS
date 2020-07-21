@testable import WordPressKit

struct MockPluginStateProvider: DynamicMockProvider {
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
    
    static func getDynamicValuePluginState(setToActive active: Bool = false, autoupdate: Bool = false, automanaged: Bool = false, updateState: PluginState.UpdateState = PluginState.UpdateState.updated) -> PluginState {
        return PluginState(id: MockPluginStateProvider.getDynamicPluginID(),
                           slug: MockPluginStateProvider.randomIntAsString(limit: 25),
                           active: active,
                           name: MockPluginStateProvider.randomString(length: 25),
                           author: MockPluginStateProvider.randomString(length: 15),
                           version: MockPluginStateProvider.randomIntAsString(limit: 5),
                           updateState: updateState,
                           autoupdate: autoupdate,
                           automanaged: false,
                           url: URL(string: MockPluginStateProvider.randomURLAsString()),
                           settingsURL: nil
        )
    }
    
    static func getDynamicPluginStateJSON() -> Data {
        let jsonString = """
        {
            \"id\": \"\(randomString())\",
            \"slug\": \"\(randomString())\",
            \"active\": false,
            \"name\": \"\(randomIntAsString())\",
            \"display_name\": \"\(randomIntAsString())\",
            \"plugin_url\": \"\(randomURLAsString())\",
            \"version\": \"\(randomIntAsString())\",
            \"description\": \"\(randomIntAsString())\",
            \"author\": \"\(randomIntAsString())\",
            \"author_url\": \"\(randomURLAsString())\",
            \"network\": false,
            \"autoupdate\": false,
            \"uninstallable\": false,
            \"updateState\": {
                \"updated\": true,
            },
            \"automanaged\": false
        }
        """
        
        return jsonString.data(using: .utf8)!
    }
    
    private static func getDynamicPluginID() -> String {
        let id = MockPluginStateProvider.randomString(length: 10)
        
        return id + "/" + id
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
    
    static func getEncodedUpdateState(state: PluginState.UpdateState) throws -> Data {
        var data = Data()
        let encoder = JSONEncoder()

        data = try encoder.encode(state)
        
        return data
    }
}
