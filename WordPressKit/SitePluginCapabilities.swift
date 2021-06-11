import Foundation

public struct SitePluginCapabilities: Equatable, Codable {
    public let modify: Bool
    public let autoupdate: Bool

    public init(modify: Bool, autoupdate: Bool) {
        self.modify = modify
        self.autoupdate = autoupdate
    }

    public static func ==(lhs: SitePluginCapabilities, rhs: SitePluginCapabilities) -> Bool {
        return lhs.modify == rhs.modify
            && lhs.autoupdate == rhs.autoupdate
    }
}
