import Foundation

public struct SitePlugins: Codable {
    public var plugins: [PluginState]
    public var capabilities: SitePluginCapabilities

    public init(plugins: [PluginState], capabilities: SitePluginCapabilities) {
        self.plugins = plugins
        self.capabilities = capabilities
    }
}
